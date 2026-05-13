#!/usr/bin/env bash
set -e

AGENT_COLLAB_DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
SHARED="$AGENT_COLLAB_DIR/shared"
CHANNEL="$SHARED/channel"
SKILL_DIR="$HOME/.claude/skills/sync"
SKILL_DEST="$SKILL_DIR/SKILL.md"
SKILL_TEMPLATE="$AGENT_COLLAB_DIR/skills/sync/SKILL.md.template"
CLAUDE_MD_TEMPLATE="$AGENT_COLLAB_DIR/planner/CLAUDE.md.template"
CLAUDE_MD_DEST="$AGENT_COLLAB_DIR/planner/CLAUDE.md"

# 1. Check dependencies
MISSING=""
command -v claude >/dev/null 2>&1 || MISSING="$MISSING claude"
command -v opencode >/dev/null 2>&1 || MISSING="$MISSING opencode"
command -v tmux >/dev/null 2>&1 || MISSING="$MISSING tmux"
if [ -n "$MISSING" ]; then
  echo "ERROR: Missing dependencies:$MISSING"
  exit 1
fi

# Detect opencode binary path
OPENCODE_BIN=$(which opencode 2>/dev/null || echo "opencode")

echo "AGENT_COLLAB_DIR=$AGENT_COLLAB_DIR"
echo "OPENCODE_BIN=$OPENCODE_BIN"

# 2. Create directories
mkdir -p "$SHARED" "$CHANNEL" "$SHARED/output" "$AGENT_COLLAB_DIR/docs"

# 3. Set all .sh scripts +x recursively
find "$AGENT_COLLAB_DIR" -name "*.sh" -exec chmod +x {} \;

# 4. Generate planner/CLAUDE.md from template
sed 's|{{AGENT_COLLAB_DIR}}|'"$AGENT_COLLAB_DIR"'|g' "$CLAUDE_MD_TEMPLATE" > "$CLAUDE_MD_DEST"
echo "Generated: $CLAUDE_MD_DEST"

# 5. Generate ~/.claude/skills/sync/SKILL.md from template
mkdir -p "$SKILL_DIR"
sed 's|{{AGENT_COLLAB_DIR}}|'"$AGENT_COLLAB_DIR"'|g' "$SKILL_TEMPLATE" > "$SKILL_DEST"
echo "Generated: $SKILL_DEST"

# 6. Generate .claude/settings.local.json with dynamic paths
mkdir -p "$AGENT_COLLAB_DIR/.claude"
cat > "$AGENT_COLLAB_DIR/.claude/settings.local.json" << EOF
{
  "permissions": {
    "allow": [
      "Bash(tmux:*)",
      "Bash($AGENT_COLLAB_DIR/reset.sh:*)",
      "Bash($AGENT_COLLAB_DIR/set-task.sh:*)",
      "Bash($AGENT_COLLAB_DIR/token-summary.sh:*)",
      "Bash(touch $CHANNEL/context-ready.flag)",
      "Bash(touch $CHANNEL/test-ready.flag)",
      "Bash(cat $CHANNEL/planner_inbox.md)",
      "Bash(> $CHANNEL/planner_inbox.md)",
      "Bash(cat $SHARED/task.md)",
      "Bash($OPENCODE_BIN:*)"
    ],
    "deny": []
  }
}
EOF
echo "Generated: $AGENT_COLLAB_DIR/.claude/settings.local.json"

# 7. Generate planner/.claude/settings.local.json with dynamic paths
mkdir -p "$AGENT_COLLAB_DIR/planner/.claude"
cat > "$AGENT_COLLAB_DIR/planner/.claude/settings.local.json" << EOF
{
  "permissions": {
    "allow": [
      "Bash(tmux:*)",
      "Bash($OPENCODE_BIN:*)",
      "Bash(cat $CHANNEL/planner_inbox.md)",
      "Bash(cat $CHANNEL/opencode_inbox.md)",
      "Bash(cat $CHANNEL/chat.log)",
      "Bash(cat $SHARED/task.md)",
      "Bash(touch *)",
      "Bash(ls *)"
    ],
    "deny": []
  }
}
EOF
echo "Generated: $AGENT_COLLAB_DIR/planner/.claude/settings.local.json"

# 8. Initialize shared/task.md with placeholder text
if [ ! -f "$SHARED/task.md" ]; then
  cat > "$SHARED/task.md" << 'EOF'
# Task

(Use ./set-task.sh "your task" to set the task)
EOF
  echo "Initialized: $SHARED/task.md"
fi

# 9. Initialize shared/opencode-model.txt with default
if [ ! -f "$SHARED/opencode-model.txt" ]; then
  echo "deepseek/deepseek-chat-v3-0324" > "$SHARED/opencode-model.txt"
  echo "Initialized: $SHARED/opencode-model.txt"
fi

echo ""
echo "=== agent-collab installed successfully ==="
echo ""
echo "Next steps:"
echo "  1. ./set-task.sh \"Your task description\""
echo "  2. ./sync.sh   (launches tmux with planner + coder)"
echo "  or run: claude and type /sync"
echo ""
echo "AGENT_COLLAB_DIR: $AGENT_COLLAB_DIR"
