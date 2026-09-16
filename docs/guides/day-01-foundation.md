# Day 01 — Foundation & Development Environment

> **Status:** ✅ Verified
> **Prerequisite:** none
> **Objective:** Monorepo skeleton with three runnable services.

## End state

    persona/
    ├── apps/web/          Next.js :3000
    ├── services/api/      Node + TS :4000
    ├── services/ai/       FastAPI :8000
    ├── packages/          six empty domain folders
    ├── docs/
    ├── .env.example
    ├── .gitignore
    ├── README.md
    └── package.json       npm workspaces root

## Concepts

Everything is one repo, one `npm install`. npm workspaces hoist shared
deps to the root `node_modules`, so TypeScript, ESLint, and Prettier are
installed once and symlinked into every workspace. The Python service
sits outside npm — it has its own venv and is orchestrated separately.

The three services are deliberately not wired to each other yet. The
frontend does not call the API. The API does not call the AI service.
That belongs to later days.

## Definition of Done

- [x] GitHub repo created (`project-persona`, private)
- [x] Monorepo structure: `apps/`, `services/`, `packages/`, `docs/`
- [x] Next.js runs on :3000
- [x] Node API runs on :4000, `/health` returns `{"service":"persona-api","status":"ok"}`
- [x] Python venv works; FastAPI on :8000, `/health` returns `{"service":"persona-ai","status":"ok"}`
- [x] FastAPI `/docs` shows Swagger UI
- [x] `.env.example` exists with dev URLs and ports
- [x] `.gitignore` excludes `node_modules/`, `.venv/`, `.env*` (except `.env.example`), `dist/`, `.next/`, model files
- [x] `README.md` describes architecture + dev commands
- [x] `docs/architecture/system-overview.md` exists
- [x] No secrets or model files tracked; no nested `.git`
- [x] First commit pushed to `origin/main`

## Verification

    npm ls --depth=0
    # expect three workspace lines: @persona/api, web, (database after Day 3)

    cd apps/web && npm run dev          # :3000 loads
    cd services/api && npm run dev      # :4000/health → ok
    cd services/ai && uvicorn app.main:app --reload --port 8000
                                        # :8000/health → ok, :8000/docs → Swagger

## Decisions made this day

- **React Compiler: No.** Boilerplate-heavy Day 1 gains nothing from it.
  Revisit when the Avatar Studio UI exists. (Consider adding
  `eslint-plugin-react-hooks` for the diagnostic rules without the
  build-time cost.)
- **`src/` directory: Yes.** Convention matches Next 16 defaults.
- **Express 5.** Current `latest` tag; handler signatures are compatible.

## Known issues & fixes

See [`troubleshooting.md`](./troubleshooting.md) — sections *npm/workspaces*
and *Environment variables*.

## Rollback

    git reset --hard <first-commit>^     # destructive — read git help first
    git push --force-with-lease

Only if you intend to rewrite history. Prefer patching forward.

## Next

Day 02 — Docker infrastructure for PostgreSQL and Redis.