# SurrealDB

[![Deploy on Railway](https://railway.app/button.svg)](https://railway.com/deploy/surrealdb-1?utm_campaign=surrealdb)

**SurrealDB** — the ultimate multi-model database, now a one-click deploy. Document, graph, relational, vector and time-series data behind one SurrealQL interface, one binary, one Railway service. Deploys in one click with zero form fields; the root password is auto-generated.

On first boot the server binds Railway's injected `PORT`, creates the `root` user from the generated `SURREAL_PASS`, initializes the `main` namespace and `main` database on the persistent volume, and serves HTTP, RPC and WebSocket on the same port.

## Deploy and Host

One service, deployed with one click:

- **surrealdb** — the SurrealDB v3.2.6 server binary (pinned official image `surrealdb/surrealdb`, digest-pinned), healthcheck `GET /health`, binds Railway's injected `PORT`
- Persistent volume `surrealdb-data` at `/data` — SurrealKV storage engine at `/data/db`

No companion services: SurrealDB is its own storage engine. Point any SurrealDB SDK, the Surrealist UI, or plain HTTP at your Railway domain and it just works.

## Why Deploy

Self-hosting SurrealDB means your data never leaves your infrastructure — no per-query pricing, no row limits, no vendor lock-in. One engine covers the workloads that normally need four databases: flexible documents, graph traversals, full-text search, vector similarity for AI apps, and time-series. On Railway it is always on, so connections, live queries and scheduled events keep running around the clock.

## Common Use Cases

- Backend for AI apps: vector search + documents + graph relations in one query language
- Real-time apps with `LIVE SELECT` streaming changes over WebSocket
- A schemaless document store that grows into strict schemas when you need them
- Multi-model prototyping without running Postgres + Neo4j + Pinecone side by side

## Configuration

Zero form fields on deploy. After deploy, the knobs in the service's **Variables** panel:

- `SURREAL_PASS` — root password (auto-generated `${{secret(32)}}` per deployment; find it in Variables). Applied only on first boot — to rotate later, run `ALTER USER` inside the DB.
- `SURREAL_USER` — root username (default `root`)
- `SURREAL_DEFAULT_NAMESPACE` — namespace created on first boot (default `main`)
- `SURREAL_DEFAULT_DATABASE` — database created on first boot (default `main`)
- `SURREAL_LOG` — log level: `none`, `full`, `error`, `warn`, `info`, `debug`, `trace` (default `info`)
- `PORT` — injected by Railway automatically; the server binds `0.0.0.0:$PORT`

Useful upstream tunables you can add as variables (see [SurrealDB environment variables](https://docs.surrealdb.com/docs/cli/start/)):

- `SURREAL_QUERY_TIMEOUT` — max duration for a batch of statements (off by default)
- `SURREAL_STRICT` — strict mode for the database (off by default)
- `SURREAL_CAPS_ALLOW_ALL` — broadly enable all engine capabilities (restricted by default)

Connect: `https://<your-domain>` with user `root`, the generated password, namespace `main`, database `main`. Try Surrealist (https://surrealist.app) as a GUI, or `POST /sql` with `Accept: application/json`.

## Deployment Dependencies

Hobby plan or higher for the persistent volume. SurrealDB needs nothing at runtime beyond its volume — no external API keys, no companion services, no third-party accounts. `GET /health` returns 200 once the server is up.
