#!/usr/bin/env bash
# Local dev server for both surfaces. No build step: the files are static.
set -euo pipefail
PORT="${PORT:-8765}"
HOST="${HOST:-0.0.0.0}"
cd "$(dirname "$0")"
echo "public: http://localhost:${PORT}/public/"
echo "secure: http://localhost:${PORT}/secure/"
exec python3 -m http.server "$PORT" --bind "$HOST"
