# Verification

Run these checks after a fresh clone + `npm install` + `docker compose up -d`
to confirm your environment matches the expected Day-N state.

## One-command check

    docker compose ps
    # expect: persona-postgres Up (healthy), persona-redis Up (healthy)

    npm ls --depth=0
    # expect: @persona/api, @persona/database, web all linked as workspaces

## Per-service health

### Web

    cd apps/web && npm run dev
    # http://localhost:3000 → Next.js welcome page

### API

    cd services/api && npm run dev
    # http://localhost:4000/health → {"service":"persona-api","status":"ok"}

### AI

    cd services/ai
    .\.venv\Scripts\Activate.ps1
    uvicorn app.main:app --reload --port 8000
    # http://localhost:8000/health → {"service":"persona-ai","status":"ok"}
    # http://localhost:8000/docs   → Swagger UI

### PostgreSQL

    docker exec persona-postgres pg_isready -U persona -d persona
    # /var/run/postgresql:5432 - accepting connections

### Redis

    docker exec persona-redis redis-cli ping
    # PONG

## Git hygiene

    git status
    # expect: nothing to commit, working tree clean

    git ls-files | Select-String -Pattern 'node_modules|\.venv|\.env$'
    # expect: no output

    git check-ignore -v .env
    # expect: a .gitignore rule matching .env