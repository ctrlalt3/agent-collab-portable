# agent-collab

Two-agent collaborative coding pipeline: Claude Code (planner+tester) + OpenCode (coder).

## Requirements
- [Claude Code](https://claude.ai/code) (`claude`)
- [OpenCode](https://opencode.ai) (`opencode`)
- `tmux`

## Installation

```bash
git clone https://github.com/YOUR_USERNAME/agent-collab.git
cd agent-collab
./install.sh
```

## Usage

```bash
./set-task.sh "Your task description"
./sync.sh         # opens tmux with planner + coder
# or via Claude Code: /sync
```

## Commands
| Command | Purpose |
|---------|---------|
| `./set-task.sh "task"` | Set the task |
| `./sync.sh` | Launch full pipeline |
| `./reset.sh` | Clean run artifacts |
| `./status.sh` | Show pipeline state |
| `./ask.sh "message"` | Send message to planner |
| `./set-opencode-model.sh` | Switch OpenCode model |
| `./token-summary.sh` | Show token usage |
