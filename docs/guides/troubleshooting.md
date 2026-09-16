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

### `P1000: Authentication failed` from Prisma, but `docker exec psql` works

**Symptom:** `npx prisma migrate status` fails with P1000 ("provided
database credentials for `persona` are not valid"), but running
`docker exec persona-postgres psql "postgresql://persona:persona_dev@..." -c "SELECT 1;"`
succeeds.

**Cause:** A native PostgreSQL service is running on the Windows host,
also bound to 5432. `docker exec` runs *inside* the container and hits
the container's Postgres. The Prisma CLI runs *on the host* and Windows
routes the connection to whichever process claimed the port first —
usually the native service, which has different credentials.

This is the same class of problem as the 6379 collision above, but
harder to spot because `docker compose ps` shows both containers
healthy.

**Diagnose:**

    netstat -ano | findstr :5432
    # two PIDs = conflict confirmed

    Get-Service | Where-Object { $_.Name -like "*postgres*" }
    # find the native service name

**Fix:** stop and disable the native service (Admin PowerShell):

    Stop-Service -Name "postgresql-x64-17"    # actual version may differ
    Set-Service -Name "postgresql-x64-17" -StartupType Manual

**Alternative:** remap the Docker port to 5433 in `docker-compose.yml`:

    ports:
      - "5433:5432"

Then update `DATABASE_URL` in both `.env` files to `localhost:5433`.
Useful if you need the native Postgres for other projects.

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

## Prisma

### `prisma@8.0.0-rc.x` installed instead of 6.x

**Cause:** `npm install prisma` resolves the `latest` tag, which at time
of writing points at a Prisma 8 release candidate. Prisma 8 is a
ground-up rewrite: different CLI (`orm init` not `init`), different
schema file (`contract.prisma`), different config (requires
`prisma.config.ts`), and requires Node 24+.

**Fix:** pin to the stable 6.x line:

    npm uninstall --workspace @persona/database prisma @prisma/client
    npm install --workspace @persona/database @prisma/client@6
    npm install --workspace @persona/database -D prisma@6

Then verify `npx prisma --version` reports 6.x.

If npx still resolves the RC from cache:

    npm cache clean --force

Or call the local binary directly:

    .\node_modules\.bin\prisma --version

### `No flag registered for --datasource-provider`

**Cause:** You're on Prisma 8. That flag was removed.

**Fix:** Downgrade to Prisma 6 (see previous entry).

### `No flag registered for --schema` (Prisma 6)

**Cause:** `prisma init` in Prisma 6 does not accept `--schema`. It
always writes to `prisma/schema.prisma` relative to the current
working directory.

**Fix:** `cd` into the directory containing the target `prisma/` folder
before running `init`:

    cd packages\database
    npx prisma init --datasource-provider postgresql

### `Environment variable not found: DATABASE_URL` or `Datasource is missing a database connection URL`

**Cause (two variants):**

1. `prisma.config.ts` uses the `env()` helper from `prisma/config`. If
   the variable isn't defined when the config loads, Prisma 6.19
   throws or returns undefined — it does not silently fail.
2. You ran `npx prisma ...` from the wrong directory. Prisma CLI reads
   `prisma.config.ts` and `.env` from the current working directory,
   not from the schema location.

**Fix for variant 1:** replace `env("DATABASE_URL")` with
`process.env.DATABASE_URL!` in `prisma.config.ts`:

    import "dotenv/config";
    import { defineConfig } from "prisma/config";

    export default defineConfig({
      schema: "prisma/schema.prisma",
      migrations: { path: "prisma/migrations" },
      engine: "classic",
      datasource: { url: process.env.DATABASE_URL! },
    });

Also add `dotenv` as an explicit devDependency of the Prisma workspace:

    npm install --workspace @persona/database -D dotenv

**Fix for variant 2:** always run Prisma commands from the directory
containing `prisma.config.ts` (`packages/database`). A quick check:

    Get-Location
    # expect: ...\packages\database

### Prisma 6.19 generates client to `src/generated/prisma/`, not `node_modules`

**Cause:** The `prisma-client` generator (as opposed to the older
`prisma-client-js`) writes to an explicit `output` path. This is the
newer ESM-friendly generator and is correct for this project.

**Implication:** the generated output must be gitignored, since it's
a build artifact:

    packages/database/src/generated/

Imports in other workspaces resolve through `@persona/database`, not
`@prisma/client`. The package's `src/index.ts` re-exports `PrismaClient`
from `./generated/prisma/client.js`.