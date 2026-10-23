# SurrealDB on Railway — one-click deploy wrapper (single service)
#
# Base is the official prebuilt image (surrealdb/surrealdb), pinned to
# v3.2.6: the single Rust binary bundles the database engine, HTTP/RPC API
# and WebSocket endpoint — the wrapper only adapts it to Railway, never
# rebuilds it.
#
# Why each non-default setting exists:
#   Multi-stage shell stage ... The upstream image contains ONLY the
#                               /surreal binary plus a glibc base — no
#                               /bin/sh at all, so neither `RUN chmod` nor
#                               a shell entrypoint can execute in it. The
#                               binary is copied into a pinned Debian slim
#                               stage that provides /bin/sh for
#                               entrypoint.sh. The binary is dynamically
#                               linked against glibc (needs <= GLIBC_2.34),
#                               so the shell stage must be glibc-based
#                               (Debian bookworm, glibc 2.36) — a musl
#                               base such as Alpine fails with
#                               `/surreal: not found` (missing ELF
#                               interpreter). Verified in e2e 2026-10-22.
#   USER root ................. Railway mounts persistent volumes
#                               root-owned; keep root explicit so
#                               surrealkv:///data/db is always writable.
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
#   HEALTHCHECK NONE .......... Railway's external healthcheckPath
#                               ("/health") in railway.json is the
#                               readiness gate.
#
# Upstream: https://github.com/surrealdb/surrealdb (BSL 1.1)
# Base image: surrealdb/surrealdb v3.2.6 (amd64)
# Digest: sha256:516880cf27ee605f026cbd4f9381d154bc6d7c46a7d1d128205c9686ef234ff3
# Shell stage: debian bookworm-slim (glibc 2.36)
# Digest: sha256:7ff6ba31527b9e336162fa061746c366c4b2032f4d2cff2078bea43f78efe3f8

FROM surrealdb/surrealdb@sha256:516880cf27ee605f026cbd4f9381d154bc6d7c46a7d1d128205c9686ef234ff3 AS upstream

FROM debian@sha256:7ff6ba31527b9e336162fa061746c366c4b2032f4d2cff2078bea43f78efe3f8

USER root

HEALTHCHECK NONE

# The upstream binary is glibc-linked, so it runs unmodified on Debian.
COPY --from=upstream /surreal /surreal

# CA certificates: the binary builds an HTTP client at startup and refuses
# to boot when no system CA bundle is loaded ("No CA certificates were
# loaded from the system" — verified in e2e 2026-10-22). Debian slim ships
# none, so copy the bundle from the upstream (Wolfi) image and point
# SSL_CERT_FILE at it, matching upstream's own env.
COPY --from=upstream /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/ca-certificates.crt
ENV SSL_CERT_FILE=/etc/ssl/certs/ca-certificates.crt

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
