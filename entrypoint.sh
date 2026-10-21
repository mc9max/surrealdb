#!/bin/sh
# Compose the upstream flags from Railway's environment, then exec the
# stock binary. PORT is injected by Railway; everything else has sane baked
# defaults and stays off the one-click deploy form (zero fields).
#
# Notes:
#   - v3 CLI is `surreal db start` (the old `surreal start` was removed).
#   - `--user/--pass` create the root user ONLY when the datastore is new;
#     on restarts the stored credentials win, so rotating SURREAL_PASS later
#     requires ALTER USER inside the DB.
#   - `surrealkv:///data/db` (three slashes) is the absolute-path form;
#     /data is the Railway volume mount.
set -e

if [ -z "${SURREAL_PASS}" ]; then
  echo "ERROR: SURREAL_PASS is not set. The template auto-generates it; set a strong value manually if deploying outside the template." >&2
  exit 1
fi

exec /surreal db start \
  --bind "0.0.0.0:${PORT:-8000}" \
  --user "${SURREAL_USER:-root}" \
  --pass "${SURREAL_PASS}" \
  --log "${SURREAL_LOG:-info}" \
  "surrealkv:///data/db"
