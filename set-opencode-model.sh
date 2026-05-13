#!/usr/bin/env bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED="$ROOT/shared"
MODEL_FILE="$SHARED/opencode-model.txt"

# OpenCode Go subscription models
MODELS=(
  "opencode-go/deepseek-v4-flash"
  "opencode-go/deepseek-v4-pro"
  "opencode-go/kimi-k2.5"
  "opencode-go/kimi-k2.6"
  "opencode-go/qwen3.5-plus"
  "opencode-go/qwen3.6-plus"
  "opencode-go/minimax-m2.5"
  "opencode-go/minimax-m2.7"
  "opencode-go/mimo-v2.5"
  "opencode-go/mimo-v2.5-pro"
  "opencode-go/glm-5"
  "opencode-go/glm-5.1"
)

DISPLAY_NAMES=(
  "Deepseek V4 Flash"
  "Deepseek V4 Pro"
  "Kimi K2.5"
  "Kimi K2.6"
  "Qwen 3.5 Plus"
  "Qwen 3.6 Plus"
  "MiniMax M2.5"
  "MiniMax M2.7"
  "Mimo V2.5"
  "Mimo V2.5 Pro"
  "GLM-5"
  "GLM-5.1"
)

# If argument provided, match by display name or model ID
if [ -n "$1" ]; then
  ARG=$(echo "$1" | tr '[:upper:]' '[:lower:]')
  FOUND=""
  for i in "${!DISPLAY_NAMES[@]}"; do
    DN=$(echo "${DISPLAY_NAMES[$i]}" | tr '[:upper:]' '[:lower:]')
    MID=$(echo "${MODELS[$i]}" | tr '[:upper:]' '[:lower:]')
    if echo "$DN" | grep -qi "$ARG" || echo "$MID" | grep -qi "$ARG"; then
      FOUND="${MODELS[$i]}"
      break
    fi
  done

  if [ -z "$FOUND" ]; then
    echo "[ERROR] Model '$1' not found. Available models:"
    for i in "${!DISPLAY_NAMES[@]}"; do
      echo "  ${DISPLAY_NAMES[$i]} (${MODELS[$i]})"
    done
    exit 1
  fi

  echo "$FOUND" > "$MODEL_FILE"
  echo "[CONFIG] OpenCode model set to: $(basename "$FOUND")"
  exit 0
fi

# Interactive menu
echo "Select OpenCode model (OpenCode Go subscription):"
for i in "${!MODELS[@]}"; do
  echo "  $((i+1)). ${DISPLAY_NAMES[$i]} (${MODELS[$i]})"
done
echo ""
read -r -p "Choice [1-${#MODELS[@]}]: " choice
if [[ "$choice" =~ ^[0-9]+$ ]] && [ "$choice" -ge 1 ] && [ "$choice" -le "${#MODELS[@]}" ]; then
  idx=$((choice-1))
  echo "${MODELS[$idx]}" > "$MODEL_FILE"
  echo "OpenCode model set to: ${DISPLAY_NAMES[$idx]} (${MODELS[$idx]})"
else
  echo "Invalid choice"
  exit 1
fi
