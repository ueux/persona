# Day 03 — Database Architecture (Prisma)

> **Status:** ✅ Verified (reduced scope — see "Scope" below)
> **Prerequisite:** Day 02 ✅
> **Objective:** Stand up `@persona/database` as the schema-owning
> package, with a validated Prisma model and a generated client that
> the rest of the monorepo can consume.

## Scope — what this day actually covered

The original Day 3 plan included three further steps that were **not**
completed this day:

- `prisma/seed.ts` and an idempotent seed run
- `services/api` GET `/health/db` endpoint
- API-side verification that a query round-trips

Those are deferred to a later day (see [Progress](./progress.md)).
This guide documents the reduced scope that was verified.

## End state

    packages/database/
    ├── prisma/
    │   ├── schema.prisma              ← 7 models, 4 enums
    │   ├── migrations/
    │   │   └── <ts>_init/migration.sql
    │   └── .env                       ← DATABASE_URL (gitignored)
    ├── prisma.config.ts
    ├── src/
    │   ├── generated/prisma/          ← Prisma Client (gitignored)
    │   ├── client.ts                  ← singleton, hot-reload safe
    │   └── index.ts                   ← re-exports prisma + PrismaClient
    ├── package.json
    └── tsconfig.json

Postgres (`persona` database) now contains the tables.

## Concepts

Prisma owns the schema. Migrations are the source of truth for the DB
shape — hand-editing tables in Postgres is forbidden from this day on.

The Prisma Client is generated into `src/generated/prisma/` rather than
`node_modules`, because Prisma 6.19's `prisma-client` generator (the
newer ESM-friendly one) writes to an explicit `output` path. That output
is a build artifact and is gitignored.

Other workspaces consume the client through `@persona/database`, never
through `@prisma/client` directly. This gives one place to change the
generator, add middleware, or swap the client library later.

**Windows port-5432 trap:** native PostgreSQL and Docker Postgres both
want the same port. See troubleshooting.

## Schema — the models and why

### `User`
Bare identity. No auth fields — that's the auth day. Only `email` for
now, plus timestamps. Cascades to `Avatar`.

### `Avatar`
Identity container owned by a user. Has `name`, `description`, and
cascades from `User`. Has many `AvatarVersion`, `MediaAsset`,
`ConsentRecord`.

### `AvatarVersion`
Immutable snapshot of a trained avatar. `@@unique([avatarId, version])`
ensures no two rows claim to be "v3 of avatar X". Has many `Generation`.

### `MediaAsset`
Source material for an avatar. Attaches to `Avatar` (not
`AvatarVersion`) — uploads are reused across retrains. `sizeBytes` is
`Int` (max ~2.1 GB), not `BigInt`, because JSON serialization of
`bigint` throws in JS and no dev asset approaches the limit.

### `ConsentRecord`
Legal consent per avatar, per scope. Attaches to `Avatar` — consent is
about the person, not a specific model snapshot.

### `Generation`
One AI job. Attaches to `AvatarVersion` — a generation *runs on* a
trained model, which is what a version represents.

Two deliberate choices worth knowing:

1. **`kind` uses `GenerationKind`, not `MediaKind`.** "What an AI job
   produces" is conceptually distinct from "what an uploaded asset is."
   Same values today, will diverge later (e.g. `SPEECH` vs `AUDIO`).
2. **`prompt` is nullable (`String?`).** Not every generation is
   text-driven. Image-to-image, voice cloning, upscaling, background
   removal — all take structured parameters or input assets, not text.
   `parameters Json @default("{}")` carries the structured side.

### `GenerationInput`
Join table: a generation may use multiple input assets, each with a
`role` (`face_ref`, `style_ref`, `audio_ref`, ...).

## Client — the singleton pattern

`packages/database/src/client.ts` pins the `PrismaClient` instance to
`globalThis` in non-production environments. This is required because
`tsx watch` (API dev) and Next's dev server re-evaluate modules on file
change. Without the global, every reload creates a new client and a new
connection pool, exhausting Postgres's connection limit within minutes.

`log: ["query", ...]` in dev prints SQL to the console. It is disabled
in production to avoid logging PII in query parameters.

## Deliberately deferred

- `VoiceProfile`, `PersonalityProfile`, `IdentityProfile`,
  `MotionProfile`, `ExpressionProfile` — later feature days
- `AIProvider`, `AIModel`, `UsageRecord` — provider integration day
- `AuthIdentity`, `Session` — auth day
- `AuditLog`, `WebhookEvent` — observability/webhooks day
- `Organization`, `Team`, `Subscription`, `Payment` — account infra day
- `GenerationOutput` — storage day (needs storage provider choice first)

## Definition of Done

- [x] Package scaffold correct
- [x] Prisma 6.19.3 installed (`@prisma/client` in deps, `prisma` in devDeps)
- [x] `prisma.config.ts` uses `process.env.DATABASE_URL`
- [x] `schema.prisma` written and validates
- [x] First migration applied — 7 tables in Postgres
- [x] Prisma Client generates to `src/generated/prisma/`
- [x] Singleton `client.ts` — hot-reload safe
- [x] `src/index.ts` re-exports `prisma` and `PrismaClient`
- [x] `npx tsc --noEmit` clean
- [x] Generated client path gitignored
- [x] No secrets committed
- [ ] Seed created and runs idempotently — **deferred**
- [ ] API `/health/db` returns live status — **deferred**

## Verification

    # From packages/database
    npx prisma validate
    # The schema at prisma\schema.prisma is valid 🚀

    npx prisma migrate status
    # Database schema is up to date

    # Tables in Postgres
    docker exec persona-postgres psql -U persona -d persona -c "\dt"
    # expect: users, avatars, avatar_versions, media_assets,
    #         consent_records, generations, generation_inputs,
    #         _prisma_migrations

    # Client is generated and gitignored
    Test-Path packages\database\src\generated\prisma
    git check-ignore -v packages\database\src\generated
    # expect a matching rule

    # Types compile
    cd packages\database
    npx tsc --noEmit
    # no output

## Known issues & fixes

See [`troubleshooting.md`](./troubleshooting.md). Issues hit this day:

- Prisma 8 RC silently installed by the `latest` tag → pinned to 6.19.3
- Docker Postgres vs native Windows PostgreSQL on port 5432 → P1000
- `prisma.config.ts` `env()` helper not resolving → use `process.env`
- `--datasource-provider` and `--schema` flags removed in Prisma 8 / not
  available in Prisma 6's `init`
- `prisma-client` generator output path differs from `prisma-client-js`

## Rollback

    # Undo the migration (keeps schema.prisma, drops tables)
    cd packages\database
    npx prisma migrate reset --force

    # Full reset (drops Docker volumes too — destructive)
    docker compose down -v
    docker compose up -d

`migrate reset` is a dev-only tool. Never run it against data you care
about.

## Next

Day 04 — _TBD_. Open items from this day (seed, API health endpoint)
will be folded into whichever day fits best.