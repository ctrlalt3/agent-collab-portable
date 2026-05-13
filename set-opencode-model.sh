#!/usr/bin/env bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SHARED="$ROOT/shared"
MODEL_FILE="$SHARED/opencode-model.txt"

MODELS=(
  "anthropic/claude-sonnet-4-5"
  "anthropic/claude-opus-4-5"
  "deepseek/deepseek-r1-0528"
  "deepseek/deepseek-chat-v3-0324"
  "openai/gpt-4o"
  "openai/gpt-4.1"
  "google/gemini-2.5-pro"
)

DISPLAY_NAMES=(
  "Claude Sonnet 4.5"
  "Claude Opus 4.5"
  "Deepseek R1"
  "Deepseek V3 (Chat)"
  "GPT-4o"
  "GPT-4.1"
  "Gemini 2.5 Pro"
)

# If argument provided, set directly
if [ -n "$1" ]; then
  echo "$1" > "$MODEL_FILE"
  echo "OpenCode model set to: $1"
  exit 0
fi

# Interactive menu
echo "Select OpenCode model:"
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
