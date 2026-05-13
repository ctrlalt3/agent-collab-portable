#!/usr/bin/env bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SHARED="$ROOT/shared"
OC_MODEL=$(cat "$SHARED/opencode-model.txt" 2>/dev/null || echo "opencode-go/deepseek-v4-flash")

echo "Starting OpenCode interactive session..."
cd "$SHARED/output"
exec opencode --model "$OC_MODEL"
