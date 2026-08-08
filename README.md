# my-config

One tree, all machines.

There are no per-machine branches. Every machine checks out the same commit and picks a
*machine file* that says which packages it wants and where anything unusual goes. Whatever
differs between two machines is visible in one diff, in one place.

Managed with [dotter](https://github.com/SuperCuber/dotter).

## Layout

```
.dotter/
  global.toml          every package, and where each of its files goes
  machines/<name>.toml which packages this machine takes, and its overrides
  post_deploy.sh       runs scripts/<pkg>/ for the selected packages
  local.toml           generated, not tracked: names this machine
files/                 anything that gets placed somewhere
scripts/<pkg>/         anything that gets run on deploy, if <pkg> is selected
```

If something under `files/` is not claimed by an entry in `global.toml`, it is dead. If
something is meant to be run rather than linked, it belongs in `scripts/`, not `files/`.

## Install

Nothing but a shell is required. The bootstrap installs `git` and `dotter`, clones this
repo to `~/.dotfiles`, and asks which machine this is.

```sh
curl -fsSL https://dot.viktorashi.dev | sh
```

PowerShell:

```powershell
irm https://dot.viktorashi.dev | iex
```

## Day to day

```sh
conf status          # git, against ~/.dotfiles
conflazygit          # lazygit, same
dot deploy           # apply the config
dot undeploy         # take it back off
dot watch            # redeploy on every change
```

Configs are linked, not copied, so editing `~/.zshrc` edits the file in the repo. Whole
directories that an app rewrites itself — `nvim`, `codex`, `opencode`, `agents` — are
linked as one unit on purpose: it is the only mode where a file the app creates lands back
in the repo without being asked.

## Adding a machine

1. Write `.dotter/machines/<name>.toml` — the package list, plus a `[files]` block for
   anything that lives somewhere else here.
2. Add `files/shell/machines/<name>.sh` and `.zsh` for `PATH` entries and anything else
   that is only true on that box. They are sourced at the end of `.profile` and `.zshrc`.
3. Deploy.

Machine-specific settings go in an include the app already understands, not in a template.
Only a format with no include mechanism gets templated.
