# Docker Development Environment

## Infrastructure

Project Persona uses Docker Compose for local infrastructure.

## Services

### PostgreSQL

- Port: 5432
- Database: `persona`
- User: `persona`
- Purpose: application database

### Redis

- Port: 6379
- Purpose:
  - queues
  - caching
  - temporary state
  - rate limiting

## Persistent Volumes

- PostgreSQL: `persona_postgres_data`
- Redis: `persona_redis_data`

## Start infrastructure

```bash
docker compose up -d
```

## Stop infrastructure

```bash
docker compose down
```

## Stop and remove persistent data

```bash
docker compose down -v
```

> Do not use the `-v` option unless you intentionally want to delete the local development database and Redis data.

## Check service status

```bash
docker compose ps
```

You want output similar to:

```text
NAME                STATUS
persona-postgres    Up (healthy)
persona-redis       Up (healthy)
```

The exact formatting may differ depending on your Docker version.
