# Troubleshooting

Issues hit during the build, with fixes. Order within each section is
roughly most-to-least common.

## npm / workspaces

### `workspaces web in filter set, but no workspace folder present`

**When:** right after `npx create-next-app` for a new workspace, before
the workspace's `package.json` is fully written.

**Fix:** run `npm install` from the repo root. Harmless warning, resolves
itself.

### Stale workspace alias (`api@npm:@persona/api@0.1.0 extraneous`)

**Cause:** you ran `npm init -y` inside a workspace, installed deps while
the name was still the default, then renamed the workspace.

**Fix:**

    Remove-Item -Recurse -Force node_modules
    Remove-Item -Force package-lock.json
    npm install

Verify with `npm ls --depth=0` — no `extraneous` lines for real deps.

### Two copies of TypeScript / ESLint

**Cause:** root and workspace each `npm install`-ed a different major.

**Fix:** pin root to the workspace's version:

    npm install -D typescript@<workspace-version> eslint@<workspace-version>

Then `npm ls --depth=0` — expect `deduped` markers.

## Docker

### `Bind for 0.0.0.0:6379 failed: port is already allocated`

**Cause:** another process already owns the port — native Redis, a stale
container, WSL relay, or Docker Desktop's leftover port forward.

**Diagnose:**

    Get-NetTCPConnection -LocalPort 6379 -State Listen |
      Select-Object OwningProcess,
        @{n='Proc';e={(Get-Process -Id $_.OwningProcess).ProcessName}},
        @{n='Path';e={(Get-Process -Id $_.OwningProcess).Path}}

**Fix by owner:**

- `redis-server` → `Stop-Service *redis*`; `Set-Service *redis* -StartupType Manual`
- Old container → `docker rm -f <name>`
- WSL → `wsl --shutdown`
- Docker's own backend → restart Docker Desktop from tray

Same problem can hit 5432 with native PostgreSQL.

### `unhealthy` for more than 60s

    docker compose logs <service>

Common cause: Postgres re-initializing volume after an image major bump.
`docker compose down -v` + `up -d` (nukes data — acceptable in dev only).

## Environment variables

### Root `.env` is not being read by the API

**Cause:** `import "dotenv/config"` resolves `.env` from `process.cwd()`,
which npm sets to `services/api` when you use `--workspace`.

**Fix (choose one):**

1. Put a `.env` inside `services/api/`
2. In `services/api/src/server.ts`:

       import dotenv from "dotenv";
       dotenv.config({ path: "../../.env" });

Day 1–2 are unaffected because every port has a `|| default` fallback.

## Python / AI

### `Activate.ps1 cannot be loaded because running scripts is disabled`

    Set-ExecutionPolicy -Scope Process -ExecutionPolicy Bypass

Run once per PowerShell session, or use `.\.venv\Scripts\python.exe`
directly instead of activating.