# Project Persona

Project Persona is a personal digital avatar platform designed to let users create, own, improve, and use a private digital representation of themselves.

## Architecture

- `apps/web` — Next.js frontend
- `services/api` — Node.js/TypeScript backend
- `services/ai` — Python/FastAPI AI service
- `packages/` — shared infrastructure and domain packages
- `docs/` — project documentation

## Development

### Web

```bash
cd apps/web
npm run dev
```

### API

```bash
cd services/api
npm run dev
# http://localhost:4000
```

### AI

```bash
cd services/ai
.\.venv\Scripts\Activate.ps1
uvicorn app.main:app --reload --port 8000
# http://localhost:8000
```

### All at once (web + api)

```bash
npm run dev
```

## System Overview

The platform is organized into three primary layers:

- Frontend: Next.js web app
- API: Node.js service for business logic and integrations
- AI: Python/FastAPI service for generation and model processing

```text
User
  │
  ▼
Next.js Web Application
  │
  ▼
Node.js API
  │
  ├── PostgreSQL
  ├── Redis
  ├── Object Storage
  └── Queue
        │
        ▼
   Python AI Workers
        │
        ▼
      AI Models
```

This document will evolve throughout the project.

For the full architecture notes, see [docs/architecture/system-overview.md](docs/architecture/system-overview.md).

## Development journal

Day-by-day build notes live in [`docs/guides/`](./docs/guides/).
Start with [`docs/guides/README.md`](./docs/guides/README.md),
or check [`docs/guides/progress.md`](./docs/guides/progress.md)
for the current state.