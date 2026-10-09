# On-prem GitOps plan (Spark + db14) — Argo CD flavoured

> Recon done over SSH on 2026-10-09 (read-only). Answers to the 5 questions are at the bottom.

## 0. What is actually running today (ground truth)

### `spark` (spark-da41) — DGX OS / Ubuntu 24.04 aarch64, GB10, 121 GiB unified, 3.7 TB NVMe

| Thing | How it runs | Declared anywhere? |
|---|---|---|
| `stratec-semantic-service` (semantic-api :80/:443, embedding vLLM Nemotron-3-Embed-1B, Qdrant 1.12.4) | Docker Compose, `/opt/stratec-semantic/docker-compose.spark.yml`. Images arrive by `docker load` from an offline bundle, so there's **no registry**. | Yes, in a git repo (`/opt/stratec-semantic/repo`), but the deployed copy is a separate file |
| `qwen38-flash-blazux` (Qwen3.8-Flash-Next NVFP4, **~98 GB**, `--gpu-memory-utilization 0.80`, 256k ctx) | Ad-hoc `docker run`, `restart=no`, `--ipc=host`, bound to the semantic bridge gateway :8888 | **No.** It disappears on reboot. |
| `codellm-mode.sh` | Script that shrinks/grows the embedding model's GPU memory share while Qwen runs or stops | Imperative |
| ollama (9 models, ~260 GB on disk, idle) | systemd, `0.0.0.0:11434` | No |
| ComfyUI | systemd, **as root**, `0.0.0.0:8188` | No |
| Exited `open-webui` and `nemoclaw` sandbox, ~12 stale `semantic-api:*` tags, 20 GB+ vLLM images ×5 | Leftovers | — |
| Several `/opt/stratec-codellm-*` experiment dirs (group `aiteam`) | Hand-made | Partly (start.sh) |
| Also: Docker 29.2.1, nvidia-ctk 1.20, cgroup v2, swap 16 GB (7 GB used), GNOME desktop, samba, dgx-dashboard | | |

**Memory: 111/121 GiB used.** `start.sh` documents that *exhausting the unified pool hangs the kernel: no OOM killer, no logs*. This is the most important operational fact in this whole plan.

Access: `vstan` has passwordless sudo but is not in the `docker` group (only `kweide` is).

### `db14` (sap-db14) — SLES 15 SP7 x86_64 **VMware VM**, 4 vCPU / 15 GB, `/` is 89% full (6.8 GB free)

- **Managed by corporate IT**: Salt minion, auditbeat/filebeat, Nagios NRPE and a Rapid7 scanner all run on it. **No sudo** for `rvsclient`.
- System PostgreSQL 17 on :5432 (`/mnt/data/pgsql`, 200 GB xfs).
- A second, user-space Postgres on :5433 (integrityTick), a Python app on :8001, n8n on :5678, `integrity-mcp` (a homemade `releases/<timestamp>` deploy), the Windchill RVS Java client, and user crontabs that start/stop `systemctl --user` units.
- dockerd is running (ports 8443/21047/43011 are probably containers), but you can't see them without docker group access.

**Conclusion:** db14 is someone else's VM, so you don't own it as a "node". The Spark is yours.

---

## 1. Target architecture

```text
            git (platform repo)          git (app repos → images in a registry)
                   │ pull                          │
   ┌───────────────▼──────────────┐   ┌────────────▼──────────────┐
   │ k3s on spark (cluster "onprem")│   │ AKS nonprod / AKS prod    │
   │  Argo CD (own instance, pulls) │   │  Argo CD (own instance)   │
   │  ns: platform  (GPU model srv) │   │  ns per stage             │
   │  ns: semantic-prod / -qa       │   └───────────────────────────┘
   │  ns: codellm, monitoring …     │
   └───────────────┬────────────────┘
                   │ plain TCP 5432 (ExternalName / EndpointSlice)
            db14 Postgres (IT-owned VM, NOT a k8s node)
```

Layering (each layer only manages the one below it, and nothing overlaps):

| Layer | Tool | Scope |
|---|---|---|
| Cloud resources, DNS, Key Vault, AKS, ACR | **OpenTofu** | Azure only |
| Bare-metal host: packages, users, sudo, nvidia toolkit, kubelet/k3s config, firewall, swap decision | **Ansible** (static inventory in git) | spark only, plus db14 only if IT allows it |
| Everything above the kubelet | **Argo CD** (app-of-apps + ApplicationSets) | all clusters |
| Secrets | External Secrets Operator → Azure Key Vault (or SOPS+age to start) | all clusters |

## 2. Helm charts / components for the `onprem` cluster

| Component | Chart / source | Notes |
|---|---|---|
| k3s | `k3s-io/k3s-ansible` (official) or a tiny own role | Use `--disable traefik` initially: semantic-api already owns :80/:443. Set `system-reserved`, `kube-reserved` and **hard eviction thresholds** (e.g. `memory.available<6Gi`) because of the kernel-hang issue. |
| GPU | `nvidia/gpu-operator` **≥ v25.10** with `driver.enabled=false`, `toolkit.enabled=false` | The DGX OS driver and toolkit are already installed. Older device plugins crash on GB10 ("device memory: Not Supported"). |
| GPU sharing | Device-plugin **time-slicing** config (`replicas: N`) | GB10 has no MIG, and MPS crashes on it, so time-slicing is the only option. It gives **no memory isolation**. |
| GPU "like a PVC" | **DRA** (`ResourceClaim` / `DeviceClass` / `ResourceSlice`, GA in k8s 1.34) + `dra-driver-nvidia-gpu` | The right model long term. **Today the NVIDIA DRA driver doesn't enumerate GB10** (kubernetes-sigs/dra-driver-nvidia-gpu#1073, PR #1121 is in progress). Revisit once it lands. |
| Storage | k3s built-in `local-path` (NVMe) | Data stays on one node anyway. Point it at `/var/lib/rancher/...` or a dedicated `/srv/k8s`. |
| Argo CD | `argo/argo-cd` | Bootstrap once (Ansible or `helm install`), then let it manage itself through an app-of-apps. SSO via Entra ID OIDC. Use `AppProject` per team. |
| Qdrant | `qdrant/qdrant` official chart | 1 replica, PVC on local-path. |
| Postgres on spark (if needed) | **CloudNativePG** operator | A `Cluster` CR per stage. Backups to Azure Blob. |
| Model servers (vLLM) | Plain Deployment via Kustomize/Helm (or `vllm-project/production-stack`) | `strategy: Recreate` is mandatory (see Q5). `ipc: host` becomes an `emptyDir{medium: Memory}` at `/dev/shm`. |
| Day/night scaling | **KEDA** cron scaler | The schedule is declared in git, so Argo won't fight it. Replaces `codellm-mode.sh`. |
| Registry | ACR, with k3s `registries.yaml` mirror (or Zot/Harbor on-box if air-gapped) | Replaces `docker save`/`docker load` bundles. **Prerequisite** for any GitOps. |
| Ingress / TLS | Traefik (re-enable at cutover) + cert-manager | |
| Observability | kube-prometheus-stack + DCGM exporter (bundled in the GPU operator) + node-exporter | On GB10, read memory from `node_memory_MemAvailable`, not DCGM. |

## 3. Migration phases

### Phase 0: Inventory and clean-up (no new tech)

- [ ] Create the `platform` repo: `ansible/`, `clusters/onprem/`, `apps/`, `infra/azure/`, `mise.toml`.
- [ ] Write down the current spark state as data (`ansible/host_vars/spark.yml`): the services above, ports and dirs.
- [ ] Decide the fate of each item: ollama, ComfyUI-as-root, open-webui, nemoclaw, the `stratec-codellm-*` dirs. Delete it, migrate it, or keep it as an explicitly listed host service.
- [ ] Put the ad-hoc Qwen `docker run` into the semantic repo's compose (stop-gap) so a reboot doesn't lose it.
- [ ] Ask IT about db14: (a) docker group or sudo for your user, (b) whether they would rather you send Salt states, (c) who owns Postgres backups.

### Phase 1: Ansible baseline for spark

- [ ] Role `base`: users/groups (`aiteam`), sudoers, packages, `/srv/k8s` layout, unattended-upgrades policy, firewall.
- [ ] Role `nvidia`: assert the driver and nvidia-ctk versions (don't install; DGX OS owns them).
- [ ] Decide on swap: kubelet needs `failSwapOn: false` plus `LimitedSwap`, or swap off. Pick one deliberately.
- [ ] `ansible-playbook --check --diff` must be green and idempotent.

### Phase 2: k3s next to Docker (both can coexist, since k3s brings its own containerd)

- [ ] Ansible role `k3s` (single server node, traefik disabled, eviction thresholds, reserved memory).
- [ ] Bootstrap Argo CD, then the root app-of-apps pointing at `clusters/onprem/`.
- [ ] Argo apps: gpu-operator (time-slicing), KEDA, cert-manager, monitoring.
- [ ] Smoke test: a pod requesting `nvidia.com/gpu: 1` runs `nvidia-smi`.

### Phase 3: Registry and CI

- [ ] Semantic repo CI builds a multi-arch (`linux/arm64`) image and pushes it to ACR by digest.
- [ ] k3s pulls from ACR (pull secret from ESO/Key Vault).

### Phase 4: Migrate the semantic service

- [ ] Convert the compose file to a Helm chart or Kustomize base (`apps/semantic/base`) with overlays `prod` and `qa`.
- [ ] ApplicationSet (git-directory generator) stamps `semantic-prod` and `semantic-qa`. Prod tracks a tag, QA tracks `main`.
- [ ] The embedding model goes in `platform` ns as a **shared** service (one copy for both stages; it's 1B and cheap anyway).
- [ ] Qdrant: one per stage, `ResourceQuota` on QA.
- [ ] Migrate the Qdrant data (snapshot API → restore), cut :443 over to the ingress, then `docker compose down`.

### Phase 5: Model servers

- [ ] Qwen vLLM as a Deployment in `platform` (or `codellm`) ns: `replicas: 1`, `strategy: Recreate`, `resources.requests.memory` ≈ real footprint (on GB10 the GPU memory *is* RAM, so this makes the scheduler budget it; test whether the cgroup limit actually catches CUDA allocations before relying on it).
- [ ] `PriorityClass`es: `platform-critical` > `prod` > `qa` > `batch`.
- [ ] KEDA cron for day/night (big LLM by day, batch/OCR jobs by night).
- [ ] Retire `codellm-mode.sh`.

### Phase 6: db14 integration

- [ ] In k8s: `Service` of type ExternalName (or selector-less Service + EndpointSlice) `postgres-db14`, so apps never hard-code the host.
- [ ] Manage roles/databases with the OpenTofu `cyrilgdn/postgresql` provider (state in Azure Blob) **if** IT grants an admin role. Otherwise leave it.
- [ ] Don't join it to k3s: 4 vCPU, a nearly full disk, no root, and IT's Salt already owns the box.

### Phase 7: Cloud

- [ ] OpenTofu: AKS `nonprod` + `prod`, ACR, Key Vault, workload identity.
- [ ] Each AKS gets its own Argo CD, pointing at the same `platform` repo (`clusters/aks-prod/`, …).
- [ ] Optional: Azure Arc-connect the onprem k3s for inventory/visibility in the Azure portal.

### Self-service for colleagues ("use what's on the Spark without doing ops")

- Adding an app = PR adding `apps/<name>/values.yaml`. An ApplicationSet picks it up and an `AppProject` limits where it can land.
- Read-only Argo CD UI with SSO, so people can see what's deployed and its health without SSH.
- Consumption: stable in-cluster/ingress names (`embeddings.onprem.internal`, `qwen.onprem.internal`), never `spark:8888`.

---

## 4. Answers (short version)

**1. How to run on-prem stuff declaratively?**
Make the Spark a (single-node) k3s cluster; then it's "just another cluster" for Argo. Ansible handles the thin layer below the kubelet. The Ansible OpenTofu provider (`ansible_host`/`ansible_group` write inventory into tofu state, read by the `cloud.terraform.terraform_provider` inventory plugin; `ansible_playbook` runs a playbook on apply) is glue for *VMs that tofu creates*. For bare metal that already exists it adds state and nothing else, so a static inventory file is the declaration. Don't wrap Ansible in Tofu wrapped in Argo; that's three layers for one job.

**2. Stages on the same hardware?**
Namespaces + `ResourceQuota` + `NetworkPolicy` + `PriorityClass` (prod preempts QA). Separate PVCs and DBs per stage. Shared GPU models live once in a `platform` ns. QA on the same box catches *app/config/migration* bugs. It can't catch *platform* bugs: a k3s, driver or OS upgrade hits both stages at once. The GPU has no memory isolation (no MIG, MPS broken, time-slicing only), and a greedy QA vLLM can hang the whole box, prod included. So QA GPU workloads get hard caps or a time window.

**3. Cluster per stage × env, each with its own Argo?**
Clusters per *failure domain*, stages per *namespace*, except in the cloud, where a separate prod cluster is cheap and worth it. That gives `onprem` (1), `aks-nonprod`, `aks-prod`. One Argo per cluster is the purest pull model, and on-prem never needs inbound firewall holes. A single hub Argo is fine too, but then it needs credentials *into* on-prem. (`argocd-agent` exists to give you a hub UI with pull semantics.) Promotion is via git, and Argo doesn't care.

**4. Hybrid cloud+onprem clusters?**
No. The control plane over a WAN, pod networking across a VPN, and the cloud CCM thinking your Spark is a "missing VM" (its node-lifecycle controller deletes Nodes it can't find in the cloud) all hurt. When the link flaps you get a partition, not HA. Connect clusters at the *service* level (ingress/API, later Cilium ClusterMesh or Tailscale/Skupper if you really need it).

**5. Replicas on one machine?**
Containers are processes, so replicas cost almost nothing in overhead. They're still worth it for: zero-downtime rolling updates, crash isolation, and runtimes that don't scale in-process (Python without workers, Node). They're **not** HA (same kernel, same PSU), and **never** for the GPU model. vLLM's continuous batching *is* the scale-out, and a default `RollingUpdate` would start a second ~98 GB Qwen next to the first and hang the box. Use `replicas: 1` + `strategy: Recreate`. Stateful things (Qdrant/Postgres) on one disk: one replica, with real backups.

**GPU like PVCs:** that's **DRA**. `DeviceClass` ≈ StorageClass, `ResourceClaim` ≈ PVC, `ResourceSlice` ≈ the advertised inventory. It's GA in k8s 1.34, but NVIDIA's DRA driver doesn't support GB10 yet. Use GPU Operator ≥ 25.10 + `nvidia.com/gpu` + time-slicing now, and switch when PR #1121 lands.
