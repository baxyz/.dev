# fajro host setup

fajro (the mini PC) is the dev host; ligno, stupo and the phone are clients. This folder holds
what runs on the host itself, outside the devcontainers.

| File | What it does |
| --- | --- |
| `claude-host` | Keeps `claude remote-control` running in a tmux session (restarted if it exits) |
| `claude-host.service` | systemd *user* service that starts `claude-host` at boot |
| `devc` | Starts, stops and inspects the org devcontainers on demand |
| `ORCHESTRATOR.md` | Instructions for the host Claude session, installed as `~/projects/CLAUDE.md` |
| `install.sh` | Installs all of the above (idempotent) |

## How it fits together

```text
boot ─▶ claude-host.service ─▶ tmux "claude-host" ─▶ claude remote-control   (env "fajro")
                                                       │ claude.ai/code / mobile
                                                       ▼
                                    host session in ~/projects  ──▶  devc up <org>
                                                                      │
                                    devcontainer up (devcontainer CLI) ▼
                                    container ─▶ claude-dev postStart ─▶ claude-rc ─▶ env "<org>"
                                                                           │ session pre-created
                                                                           ▼
                                                              work happens in /workspaces/*
```

Two kinds of Remote Control server therefore appear in claude.ai/code: the host one (always
up, manages containers) and one per started devcontainer (the actual dev session).

## Install

```bash
host/install.sh
```

It needs Docker, tmux, Node and `claude` (logged in with a claude.ai account — Remote Control
does not work with API keys). It enables lingering for your user (`sudo loginctl enable-linger`)
so the service starts at boot without a login.

## Secrets

`devc` exports `GH_TOKEN_FOR_<ORG>`, `GRAPHITE_*`, `BITWARDEN_*`, `TURSO_*`, `GOOGLE_AI_*` and
`GROQ_*` for `devcontainer up`, because the devcontainers read them with `${localEnv:...}`.
Values come from `~/.config/fajro/secrets.env` (`export NAME=value` or `NAME=value`, mode 600)
when it exists, otherwise from the matching `export` lines of `~/.bashrc`. Moving them to
`secrets.env` is recommended: it is read by non-interactive shells and services as well.

## First start of an org container

1. `devc up <org>` — builds the container, clones the org repos, starts Remote Control.
2. `devc login <org>` — once per container, with a claude.ai account.
3. Open claude.ai/code (or the mobile app): the `<org>` environment has a session ready.

## Day to day

```bash
claude-host status         # is the host server up?
claude-host attach         # look at it (detach: Ctrl-B d)
devc ls                    # which org containers are running
devc down --all            # free the RAM when you are done
```
