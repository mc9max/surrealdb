# SurrealDB on Railway — one-click deploy wrapper (single service)
#
# Base is the official prebuilt image (surrealdb/surrealdb), pinned to
# v3.2.6: the single Rust binary bundles the database engine, HTTP/RPC API
# and WebSocket endpoint — the wrapper only adapts it to Railway, never
# rebuilds it.
#
# Why each non-default setting exists:
#   USER root ................. The stock image runs as `nonroot`, but
#                               Railway mounts persistent volumes root-owned;
#                               keep root explicit so surrealkv:///data/db
#                               is always writable.
#   entrypoint.sh ............. Execs the upstream /surreal binary with
#                               Railway-aware flags: binds 0.0.0.0 on the
#                               injected PORT (via --bind, the documented
#                               SURREAL_BIND equivalent), creates the root
#                               user from SURREAL_USER/SURREAL_PASS on first
#                               boot only, and stores data on the volume.
#   ENV defaults .............. SURREAL_USER, SURREAL_DEFAULT_NAMESPACE and
#                               SURREAL_DEFAULT_DATABASE are baked literals
#                               so they stay off the one-click deploy form.
#                               Only SURREAL_PASS is a template variable
#                               (auto-generated ${{secret(32)}}).
#   HEALTHCHECK NONE .......... The stock image has no healthcheck; Railway's
#                               external healthcheckPath ("/health") in
#                               railway.json is the readiness gate.
#
# Upstream: https://github.com/surrealdb/surrealdb (BSL 1.1)
# Base image: surrealdb/surrealdb v3.2.6 (amd64)
# Digest: sha256:516880cf27ee605f026cbd4f9381d154bc6d7c46a7d1d128205c9686ef234ff3

FROM surrealdb/surrealdb@sha256:516880cf27ee605f026cbd4f9381d154bc6d7c46a7d1d128205c9686ef234ff3

USER root

HEALTHCHECK NONE

# Baked literal defaults — kept off the one-click deploy form.
ENV SURREAL_USER=root \
    SURREAL_DEFAULT_NAMESPACE=main \
    SURREAL_DEFAULT_DATABASE=main \
    SURREAL_LOG=info

EXPOSE 8000

LABEL org.opencontainers.image.source="https://github.com/mc9max/surrealdb"

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]
