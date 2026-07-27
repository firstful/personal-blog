#!/usr/bin/env bash
# Build the site and serve it locally for Playwright testing.
#
# Usage:
#   ./scripts/test-local.sh            # build + serve + run tests
#   ./scripts/test-local.sh serve      # build + serve only (manual testing)
#   ./scripts/test-local.sh test       # assume site/ is built, run tests only
set -euo pipefail

PORT="${PORT:-8000}"
BASE_URL="http://localhost:${PORT}"

serve_sw() {
  if command -v swa &>/dev/null; then
    echo "→ Serving with swa on port ${PORT}..."
    swa start site --port "${PORT}" --app-location site --api-location "" &
  else
    echo "→ swa not found, falling back to python http.server on port ${PORT}..."
    python3 -m http.server "${PORT}" --directory site &
  fi
  SERVER_PID=$!
  trap "kill ${SERVER_PID} 2>/dev/null" EXIT

  echo "→ Waiting for server..."
  for i in $(seq 1 30); do
    if curl -s -o /dev/null "${BASE_URL}" 2>/dev/null; then
      echo "→ Server ready at ${BASE_URL}"
      return 0
    fi
    sleep 1
  done
  echo "✗ Server failed to start"
  exit 1
}

run_tests() {
  echo "→ Running Playwright tests against ${BASE_URL}..."
  BASE_URL="${BASE_URL}" npx playwright test "$@"
}

case "${1:-all}" in
  build)
    echo "→ Building site..."
    npm run build
    ;;
  serve)
    npm run build
    serve_sw
    echo "Server running at ${BASE_URL} — press Ctrl+C to stop"
    wait
    ;;
  test)
    run_tests "${@:2}"
    ;;
  all)
    echo "→ Building site..."
    npm run build
    serve_sw
    run_tests "${@:2}"
    ;;
  *)
    echo "Usage: $0 [build|serve|test|all]"
    exit 1
    ;;
esac
