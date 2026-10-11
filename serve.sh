#!/usr/bin/env bash
# Local dev server. No build step: the files are static.
set -euo pipefail
PORT="${PORT:-8765}"
HOST="${HOST:-0.0.0.0}"
cd "$(dirname "$0")"
echo "crypt-dashboard: http://localhost:${PORT}/public/"
exec python3 -m http.server "$PORT" --bind "$HOST"
