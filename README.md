<h1 align=center>Dockette / Memzero</h1>

<p align=center>
   🐳 <a href="https://github.com/mem0ai/mem0">Mem0</a> self-hosted memory layer (API + dashboard + pgvector) in a single stack.
</p>

<p align=center>
🕹 <a href="https://f3l1x.io">f3l1x.io</a> | 💻 <a href="https://github.com/f3l1x">f3l1x</a> | 🐦 <a href="https://twitter.com/xf3l1x">@xf3l1x</a>
</p>

-----

## Images

Mem0 ships a self-hosted server, but no maintained prebuilt images. This repository
builds multiarch (`amd64`, `arm64`) images from upstream mem0 releases.

| Tag                                   | Description                                 |
|---------------------------------------|---------------------------------------------|
| `dockette/memzero:server`             | Mem0 REST API (FastAPI), latest build       |
| `dockette/memzero:server-<version>`   | Mem0 REST API pinned to mem0 `<version>`    |
| `dockette/memzero:dashboard`          | Mem0 dashboard (Next.js), latest build      |
| `dockette/memzero:dashboard-<version>`| Mem0 dashboard pinned to mem0 `<version>`   |

Use the versioned tags (e.g. `server-2.2.1`) in production. The unversioned tags
move with every rebuild.

## Usage

1. Download [`docker-compose.yml`](https://github.com/dockette/memzero/blob/master/docker-compose.yml),
   [`postgres/init-db.sh`](https://github.com/dockette/memzero/blob/master/postgres/init-db.sh) and
   [`.env.dist`](https://github.com/dockette/memzero/blob/master/.env.dist).

2. Copy `.env.dist` to `.env`, then set `OPENAI_API_KEY` and change `JWT_SECRET` and `POSTGRES_PASSWORD`.

3. Start the stack.

```
docker compose up
```

4. Open `http://localhost:3000` and finish the setup wizard. It creates the first admin account and API key.

5. Use the API (OpenAPI docs on `http://localhost:8888/docs`).

```
curl -X POST http://localhost:8888/memories \
	-H "X-API-Key: your-api-key" \
	-H "Content-Type: application/json" \
	-d '{"messages":[{"role":"user","content":"I love hiking"}],"user_id":"alice"}'
```

| Service     | Port   | Description                          |
|-------------|--------|--------------------------------------|
| `mem0`      | `8888` | REST API, runs migrations on start   |
| `dashboard` | `3000` | Web UI (memories, entities, API keys)|
| `postgres`  | `8432` | pgvector storage + app database      |

Data is persisted in `.docker/postgres` and `.docker/history`.

## Configuration

All variables are listed in [`.env.dist`](https://github.com/dockette/memzero/blob/master/.env.dist). The most important ones:

| Variable                      | Description                                                         |
|-------------------------------|---------------------------------------------------------------------|
| `OPENAI_API_KEY`              | LLM + embedder key, required (`ANTHROPIC_API_KEY`, `GOOGLE_API_KEY` also supported) |
| `JWT_SECRET`                  | Secret for dashboard sessions, required                             |
| `POSTGRES_PASSWORD`           | Postgres password, required                                         |
| `ADMIN_API_KEY`               | Optional master key for `X-API-Key`                                 |
| `MEM0_DEFAULT_LLM_MODEL`      | Default LLM model (`gpt-5-mini`)                                    |
| `MEM0_DEFAULT_EMBEDDER_MODEL` | Default embedder model (`text-embedding-3-small`)                   |
| `MEM0_TELEMETRY`              | Upstream anonymous telemetry, `false` by default here               |
| `AUTH_DISABLED`               | Local development only, never in production                         |
| `SKIP_MIGRATIONS`             | Set to skip `alembic upgrade head` on start                         |

See the [Mem0 documentation](https://docs.mem0.ai/) for more.

## Build

```
make build      # build both images
make test       # smoke test both images
make push       # push both images
make up         # start the stack
make health     # check the stack
make clean      # stop the stack and drop data
```

To upgrade mem0, bump `MEM0_VERSION` in `.env.dist`, `Dockerfile` and `dashboard/Dockerfile`. CI fails if they differ.

## Development

See [how to contribute](https://contributte.org/contributing.html) to this package.

This package is currently maintaining by these authors.

<a href="https://github.com/f3l1x">
    <img width="80" height="80" src="https://avatars2.githubusercontent.com/u/538058?v=3&s=80">
</a>

-----

Consider to [support](https://github.com/sponsors/f3l1x) **f3l1x**. Also thank you for using this package.
