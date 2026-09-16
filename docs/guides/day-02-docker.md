# Day 02 — Docker Development Infrastructure

> **Status:** ✅ Verified
> **Prerequisite:** Day 01 ✅
> **Objective:** PostgreSQL 17 and Redis 7 running as persistent
> containers, available to later days but not yet connected to any
> service.

## End state

    persona/
    ├── infrastructure/docker/         (empty, placeholder for later)
    ├── docker-compose.yml             postgres + redis, named volumes
    ├── docs/architecture/docker.md
    └── .env.example                   + DATABASE_URL, REDIS_URL

Two containers:

- `persona-postgres`  postgres:17        :5432  named volume `persona_postgres_data`
- `persona-redis`     redis:7-alpine     :6379  named volume `persona_redis_data`, AOF

Both `restart: unless-stopped` with healthchecks.

## Concepts

The infrastructure runs *next to* the app, not inside it. No service
code references the DB or Redis on this day — that starts Day 3. The
point is reproducibility: anyone who clones the repo can bring up the
exact same Postgres 17 and Redis 7 with one command.

Named volumes (not bind mounts) are chosen so the data survives
container re-creation. Bind mounts would tie the data to a host path,
which is fragile across OSes and WSL boundary cases.

## Definition of Done

- [x] `docker info` succeeds (daemon reachable)
- [x] `docker-compose.yml` at repo root, both services healthy
- [x] `persona` database exists (`\l` output)
- [x] `pg_isready` returns `accepting connections`
- [x] Redis responds `PONG`
- [x] `set`/`get` round-trips
- [x] Named volumes exist (`docker volume ls`)
- [x] `down` + `up` preserves a Redis key — proves volume, not container FS
- [x] `.env.example` extended with `DATABASE_URL`, `REDIS_URL`
- [x] `docs/architecture/docker.md` exists
- [x] Root scripts `docker:up`, `docker:down`, `docker:logs`, `docker:ps`
- [x] `docker-compose.yml` tracked; no secrets tracked

## Verification

    docker compose ps
    # both Up (healthy)

    docker exec persona-postgres pg_isready -U persona -d persona
    # /var/run/postgresql:5432 - accepting connections

    docker exec persona-postgres psql -U persona -d persona -c "\l"
    # persona database present, owner persona, UTF8

    docker exec persona-redis redis-cli ping                  # PONG
    docker exec persona-redis redis-cli set persona:test hello
    docker exec persona-redis redis-cli get persona:test      # hello

    docker compose down && docker compose up -d
    docker exec persona-redis redis-cli get persona:test      # hello (persisted)

    docker volume ls
    # persona_persona_postgres_data
    # persona_persona_redis_data

## Corrections to the original Day 2 doc

1. **`restart` is a weak persistence test.** It doesn't recreate the
   container, so it would pass even without named volumes. Use
   `down` + `up` instead. Do NOT use `down -v` — that deletes the volumes.
2. **`.env` must also be updated**, not just `.env.example`. Day 3's API
   will read `DATABASE_URL` from `process.env`; if it's only in the
   example file, the API can't connect.
3. **`docker info` is the real daemon check.** `docker --version` can
   succeed while the daemon is down.

## Known issues & fixes

See [`troubleshooting.md`](./troubleshooting.md) — section *Docker*, especially
the 6379 port-allocation case.

## Rollback

    docker compose down          # keeps volumes
    docker compose down -v       # nukes volumes — read twice before running

## Next

Day 03 — `@persona/database` package, Prisma install, first schema.