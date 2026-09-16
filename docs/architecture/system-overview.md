# Project Persona — System Overview

## Current Architecture

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

## Services

### Web

Responsible for:

- User interface
- Avatar Studio
- Dashboard
- Media management UI
- Generation UI

### API

Responsible for:

- Business logic
- Authentication
- Avatar management
- Media management
- Generation orchestration
- Database access

### AI

Responsible for:

- Computer vision
- Audio processing
- Voice processing
- Avatar generation
- Model inference
- AI evaluation

## Future Infrastructure

The platform is intended to evolve toward a more scalable service architecture with:

- Next.js frontend
- Node.js API layer
- PostgreSQL database
- Redis cache
- Object storage for media
- Background queue workers
- Python-based AI inference and generation services

This document will evolve throughout the project.

---

## Phase 7 — First commit (Task 11)

```powershell
git status
```
