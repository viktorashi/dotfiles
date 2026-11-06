<https://github.com/anomalyco/opentunnel> cauta cum naiba functioneaza opentunnel, si macar ce naiba inseamna "terminate" in TLS sau TCP in general că aud peste tot

What's new in 2.0.29
Remote Device Pairing
In Settings → Pairing, select Pair device to enable OpenTunnel remote access and get a QR code or copyable link.

----

- WORKAROUND: OpenCode -> STRATEC Cloud MCP (integrity). Entra has no DCR, so `opencode mcp auth` fails; we use `STRATEC_CLOUD_TOKEN=$(stratec-cloud-token)` (az login). Proper fix: ask whoever owns the Cloud API Entra app for a public client + loopback redirect (http://127.0.0.1) for OpenCode, then set oauth.client_id and drop files/bin/stratec-cloud-token.
- WORKAROUND: opencode integrity MCP points at old ACA QAS (connector db14 still dials ACA, AKS /mcp/integrity/ lists 0 tools, Open WebUI on AKS shows "tools could not be loaded"). Fix: repoint the db14 Integrity connector to wss://aistratec-ai-capital[-qas].swedencentral.cloudapp.azure.com/integrations/mcp-tunnel/v1/connect with a credential created for that AKS stage, then switch the url back in files/opencode/opencode.jsonc.
