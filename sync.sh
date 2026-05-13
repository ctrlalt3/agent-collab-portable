#!/usr/bin/env bash
ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# Reset workspace
"$ROOT/reset.sh"
# Create channel if needed
mkdir -p "$ROOT/shared/channel"
# Launch tmux session 'collab': left pane = planner, right pane = coder
tmux new-session -d -s collab -x 220 -y 50
tmux send-keys -t collab "cd '$ROOT/planner' && ./start.sh" Enter
tmux split-window -h -t collab
tmux send-keys -t collab "cd '$ROOT/coder' && ./start.sh" Enter
tmux attach -t collab
