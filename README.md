<h1 align=center>Dockette / Memzero</h1>

<p align=center>
   🐳 <a href="https://github.com/mem0ai/mem0">Mem0</a> self-hosted memory layer (API + dashboard + pgvector) in a single stack.
</p>

<p align=center>
🕹 <a href="https://f3l1x.io">f3l1x.io</a> | 💻 <a href="https://github.com/f3l1x">f3l1x</a> | 🐦 <a href="https://twitter.com/xf3l1x">@xf3l1x</a>
</p>

-----

## Motivation

Mem0 ships a self-hosted server, but no maintained prebuild images (the last
`mem0/mem0-api-server` push is from 2025 and predates auth + dashboard).
This repository provides prebuild multiarch images and a ready-to-run stack.

- `dockette/memzero:server` - Mem0 REST API (FastAPI + Alembic migrations)
- `dockette/memzero:dashboard` - Mem0 dashboard (Next.js)

Both images are built from a pinned upstream tag (`MEM0_VERSION`).

## Usage

1. Create `.env` file.

```env
# Docker images
DOCKER_SERVER_IMAGE=dockette/memzero:server
DOCKER_DASHBOARD_IMAGE=dockette/memzero:dashboard

# Docker: ports
MEM0_PORT=8888
DASHBOARD_PORT=3000
POSTGRES_PORT=8432

# Docker: mem0
OPENAI_API_KEY=sk-...
JWT_SECRET=change-me
AUTH_DISABLED=false
MEM0_TELEMETRY=false
MEM0_DEFAULT_LLM_MODEL=gpt-5-mini
MEM0_DEFAULT_EMBEDDER_MODEL=text-embedding-3-small

# Docker: dashboard
DASHBOARD_URL=http://localhost:3000
DASHBOARD_API_URL=http://localhost:8888
DASHBOARD_INSTANCE_NAME=Memzero

# Docker: postgres
POSTGRES_DB=postgres
POSTGRES_USER=postgres
POSTGRES_PASSWORD=change-me
POSTGRES_COLLECTION_NAME=memories
APP_DB_NAME=mem0_app
```

> [!IMPORTANT]
> `OPENAI_API_KEY`, `JWT_SECRET` and `POSTGRES_PASSWORD` are required.
> The API refuses to boot without a key for the default LLM / embedder provider.

2. Create `docker-compose.yml` file.

Copy [`docker-compose.yml`](./docker-compose.yml) and [`postgres/init-db.sh`](./postgres/init-db.sh) files.

3. Start Docker services.

```
docker compose up
```

4. Open `http://localhost:3000` in your browser and finish the setup wizard.

It creates the first admin account and the first API key.

5. Use the API.

```
curl -X POST http://localhost:8888/memories \
	-H "X-API-Key: your-api-key" \
	-H "Content-Type: application/json" \
	-d '{"messages":[{"role":"user","content":"I love hiking"}],"user_id":"alice"}'
```

OpenAPI docs are on `http://localhost:8888/docs`.

## Services

| Service     | Image                         | Port   | Description                                |
|-------------|-------------------------------|--------|--------------------------------------------|
| `mem0`      | `dockette/memzero:server`     | `8888` | REST API, runs migrations on start         |
| `dashboard` | `dockette/memzero:dashboard`  | `3000` | Web UI (memories, entities, API keys)      |
| `postgres`  | `pgvector/pgvector:pg17`      | `8432` | Vector storage + app database              |

Data is persisted in `.docker/postgres` (Postgres) and `.docker/history` (SQLite history db).

## Configuration

**Server**

| Variable                      | Default                  | Description                                             |
|-------------------------------|--------------------------|---------------------------------------------------------|
| `OPENAI_API_KEY`              |                          | LLM + embedder key (`ANTHROPIC_API_KEY`, `GOOGLE_API_KEY` are bundled too) |
| `MEM0_DEFAULT_LLM_MODEL`      | `gpt-5-mini`             | Default LLM model                                       |
| `MEM0_DEFAULT_EMBEDDER_MODEL` | `text-embedding-3-small` | Default embedder model                                  |
| `JWT_SECRET`                  |                          | Secret for dashboard sessions, required                 |
| `ADMIN_API_KEY`               |                          | Optional master key for `X-API-Key`                     |
| `AUTH_DISABLED`               | `false`                  | Local development only, never in production             |
| `MEM0_TELEMETRY`              | `false`                  | Upstream anonymous telemetry (on by default upstream)   |
| `WORKERS`                     | `1`                      | Uvicorn workers                                         |
| `HISTORY_DB_PATH`             | `/app/history/history.db`| SQLite memory history db                                |
| `SKIP_MIGRATIONS`             |                          | Set to skip `alembic upgrade head` on start             |

**Postgres**

| Variable                   | Default    | Description                            |
|----------------------------|------------|----------------------------------------|
| `POSTGRES_HOST`            | `postgres` | Host                                   |
| `POSTGRES_PORT`            | `5432`     | Port                                   |
| `POSTGRES_DB`              | `postgres` | Database used by pgvector for memories |
| `POSTGRES_USER`            | `postgres` | User                                   |
| `POSTGRES_PASSWORD`        |            | Password, required                     |
| `POSTGRES_COLLECTION_NAME` | `memories` | Vector collection                      |
| `APP_DB_NAME`              | `mem0_app` | Database for users / api keys / config |

> [!TIP]
> For more detailed configuration options, please refer to the [Mem0 official documentation](https://docs.mem0.ai/).

## Build

```
make build      # build both images
make push       # push both images
make up         # start the stack
make health     # check the stack
make clean      # stop the stack and drop data
```

Bump `MEM0_VERSION` in `.env.dist` to build a newer upstream release.

## Development

See [how to contribute](https://contributte.org/contributing.html) to this package.

This package is currently maintaining by these authors.

<a href="https://github.com/f3l1x">
    <img width="80" height="80" src="https://avatars2.githubusercontent.com/u/538058?v=3&s=80">
</a>

-----

Consider to [support](https://github.com/sponsors/f3l1x) **f3l1x**. Also thank you for using this package.
