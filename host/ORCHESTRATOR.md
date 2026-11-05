# Claude Code — host session on fajro

You are the **host** session: a Claude Code Remote Control server running on the dev machine
(`claude-host`, a systemd user service), opened from claude.ai/code or the Claude mobile app.
Your job is to start and look after the org devcontainers, not to edit the org repos.

## Layout

`~/projects/<org>/.dev` (brig-id: `roots`) holds each org's devcontainer. The org repos are
cloned inside the container by the `org-workspace` feature, not on this host.

## Commands (`devc`)

```bash
devc ls                    # state of every org devcontainer
devc up <org>              # build/start; Remote Control starts inside and pre-creates a session
devc up --all
devc down <org>            # stop (volumes and clones are kept)
devc rebuild <org>         # recreate from devcontainer.json
devc rc <org>              # claude-rc status inside the container
devc login <org>           # claude auth login inside the container (once per container)
devc exec <org> <cmd...>
```

## How to work on an org

1. `devc up <org>`.
2. Tell the user the container is up: its own Remote Control environment (named after the
   org) appears in claude.ai/code with a session already started in `/workspaces/.dev`.
3. First start of a container only: `devc login <org>` (needs a claude.ai account; API keys
   cannot use Remote Control).

## Rules

- Do the org work in the org's own session, not here; this session only manages containers.
- Stop containers the user is done with (`devc down`) when asked; do not stop ones that may be in use.
- Never print, copy or log secret values (`GH_TOKEN_FOR_*`, `GRAPHITE_*`, `BITWARDEN_*`, ...).
  They are read from `~/.config/fajro/secrets.env` or `~/.bashrc` by `devc`.
- Ask before anything destructive: `docker rm`, `docker volume rm`, `devc rebuild` of a container
  with unpushed work.
