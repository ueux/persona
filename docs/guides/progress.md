# Progress

Last updated: Day 3 verified (reduced scope)

| Day | Title                          | Status | Date       |
|-----|--------------------------------|--------|------------|
| 1   | Foundation & environment       | ✅     | 2026-09-?? |
| 2   | Docker infrastructure          | ✅     | 2026-09-?? |
| 3   | Database architecture (Prisma) | ✅     | 2026-09-?? |
| 4   | _TBD_                          | 🔒     | —          |

## Day 3 — what verified, what didn't

**Verified:**

- `@persona/database` package with Prisma 6.19.3
- `schema.prisma` — 7 models, 4 enums, all relations
- First migration applied — tables live in Postgres
- Prisma Client generated to `src/generated/prisma/`
- Singleton `client.ts` (hot-reload safe)
- `@persona/database` re-exports the client

**Not done — folded into a later day:**

- `prisma/seed.ts`
- `services/api` GET `/health/db`
- End-to-end query from the API

## Current architecture

    Next.js :3000  ·  Node API :4000  ·  Python AI :8000
                          │
                          ▼
                  Docker infrastructure
                    ├── PostgreSQL :5432   ← @persona/database owns schema
                    └── Redis      :6379

Application code still does not use Postgres or Redis at runtime. The
API-side connection lands on a later day.

## Next milestone

Day 4 — _TBD_. Seed and API health endpoint remain open questions.

## Local environment notes

- **Native Windows PostgreSQL must be stopped** (or remapped to a
  non-5432 port) or Docker Postgres can't bind. See troubleshooting.
- Each workspace that runs Prisma has its own `.env`. Prisma CLI reads
  from `process.cwd()`, not from the schema path.
- **Prisma is pinned to 6.19.3.** Do not `npm update prisma` — the
  `latest` tag resolves to a Prisma 8 release candidate.
- Prisma Client lives at `packages/database/src/generated/prisma/`, not
  `node_modules`. Consume via `@persona/database`.