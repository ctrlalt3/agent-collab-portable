# agent-collab

Two-agent collaborative coding pipeline: **Claude Code** (planner+tester) + **OpenCode** (coder). Communication via filesystem — no network, no APIs.

```
Claude (Planner+Tester)         OpenCode (Coder)
─────────────────────────       ─────────────────
1. Read task.md
2. Write plan.md        ──────> 3. Read plan.md
                                4. Implement code
5. Wait...              <────── 5. Write code-done.flag
6. Run tests
7. Write results.md
```

---

## Requirements

- [Claude Code](https://claude.ai/code) (`claude`)
- [OpenCode](https://opencode.ai) (`opencode`)
- `tmux`

---

## Quickstart

```bash
git clone https://github.com/YOUR_USERNAME/agent-collab.git
cd agent-collab
./install.sh

# Set your task
./set-task.sh "Build a CLI tool that..."

# Launch from Claude Code:
/sync
```

Claude plans, OpenCode codes, Claude tests. Results in `docs/results.md`.

---

## `/sync` — The Two-Agent Pipeline

Type `/sync` in any Claude Code session to launch the full pipeline:

### Phase 0 — Context (optional)
Claude asks which source paths to review. If you provide paths, OpenCode reads them and writes a technical summary to `shared/channel/planner_inbox.md`. Type `ninguno` to skip.

### Phase 1 — Plan
Claude writes an exhaustive plan to `shared/plan.md` with exact file paths, function signatures, data structures, error handling, and test commands.

### Phase 2 — Code
OpenCode polls for `shared/plan-ready.flag`, then implements every file exactly as specified in the plan.

### Phase 3 — Test
Claude runs every test command from the plan and writes results to `docs/results.md`.

### Pipeline Signals

| Flag | Set by | Means |
|------|--------|-------|
| `plan-ready.flag` | Claude (Phase 1) | Plan ready, start coding |
| `code-done.flag` | OpenCode | Implementation complete |
| `error.flag` | OpenCode | Fatal error during coding |
| `context-ready.flag` | OpenCode (ctx) | Context summary ready |

### Mid-flight communication

```bash
# Send message to OpenCode while it's coding
./ask.sh -c "Use async/await instead of callbacks"

# Send message to Claude
./ask.sh -p "Add error handling to the plan"

# Send to both
./ask.sh -b "The API endpoint changed to /v2/users"
```

---

## Changing the OpenCode Model

The coder model is independent from Claude. Change it any time:

```bash
# Interactive menu
./set-opencode-model.sh

# Direct selection (model ID suffix)
./set-opencode-model.sh deepseek
./set-opencode-model.sh r1
./set-opencode-model.sh sonnet
./set-opencode-model.sh opus
./set-opencode-model.sh gpt4o
./set-opencode-model.sh gpt41
./set-opencode-model.sh gemini
```

Full model table:

| # | Display Name | Model ID | Best For |
|---|-------------|----------|----------|
| 1 | Claude Sonnet 4.5 | `anthropic/claude-sonnet-4-5` | Balanced quality/speed |
| 2 | Claude Opus 4.5 | `anthropic/claude-opus-4-5` | Complex reasoning |
| 3 | Deepseek R1 | `deepseek/deepseek-r1-0528` | Reasoning-heavy tasks |
| 4 | Deepseek V3 | `deepseek/deepseek-chat-v3-0324` | Default, fast general coding |
| 5 | GPT-4o | `openai/gpt-4o` | Strong instruction following |
| 6 | GPT-4.1 | `openai/gpt-4.1` | Latest GPT-4 variant |
| 7 | Gemini 2.5 Pro | `google/gemini-2.5-pro` | Large context windows |

The selected model persists in `shared/opencode-model.txt` across resets.

**Claude's model** is auto-selected: Sonnet for normal tasks, Opus for complex ones (>=80 words or keywords like `architect`, `refactor`, `system`). Override manually:

```bash
echo '{"model":"claude-opus-4-7"}' > planner/.claude/settings.json
```

---

## Commands

| Command | Purpose |
|---------|---------|
| `./install.sh` | One-time setup: dependencies, skill templates, config |
| `./set-task.sh "task"` | Set the task description |
| `./set-opencode-model.sh` | Change the OpenCode coder model |
| `./sync.sh` | Launch both agents in tmux split panes |
| `./reset.sh` | Clean run artifacts for a fresh start |
| `./ask.sh -c "msg"` | Send message to coder (-p planner, -b both) |
| `./status.sh` | Show pipeline state (flags, logs, inboxes) |
| `./token-summary.sh` | Report token usage (this run + all runs) |
| `./doc-updater.sh` | Update persistent docs after a pipeline run |

---

## Files

```
agent-collab/
├── install.sh                # One-time setup
├── sync.sh                   # tmux launcher (terminal-based alternative to /sync)
├── reset.sh                  # Clean run artifacts
├── set-task.sh               # Set task description
├── set-opencode-model.sh     # Switch coder model
├── ask.sh                    # Mid-flight messages to agents
├── status.sh                 # Pipeline state snapshot
├── token-summary.sh          # Token usage report
├── doc-updater.sh            # Update docs after code changes
├── planner/
│   ├── CLAUDE.md.template    # Role definition (expanded at install)
│   ├── start.sh              # Launch Claude planner (auto-selects model)
│   └── .claude/              # Claude config (settings.json)
├── coder/
│   ├── start.sh              # Launch OpenCode coder (polls plan-ready.flag)
│   └── interactive.sh        # Interactive OpenCode session
├── skills/
│   └── sync/
│       └── SKILL.md.template # /sync skill injected into Claude Code
├── shared/
│   ├── task.md               # Your task (edit this)
│   ├── opencode-model.txt    # Active OpenCode model ID
│   ├── plan.md               # Claude writes this → OpenCode reads
│   ├── code-done.flag         # OpenCode creates → Claude tests
│   ├── plan-ready.flag        # Claude creates → OpenCode codes
│   ├── error.flag             # OpenCode creates on fatal error
│   ├── usage.jsonl            # Token usage for current run
│   ├── run.log                # Timestamped pipeline activity
│   ├── output/                # All generated code goes here
│   └── channel/
│       ├── planner_inbox.md   # Messages OpenCode → Claude
│       ├── opencode_inbox.md  # Messages Claude → OpenCode
│       └── chat.log           # Append-only audit trail
└── docs/                      # Persistent documentation (survives reset)
```

---

## How It Works

- **`/sync` skill** is installed to `~/.claude/skills/sync/SKILL.md` by `install.sh`. It defines the full 4-phase pipeline workflow for Claude Code.
- **`planner/CLAUDE.md`** is generated from its `.template` at install time, with the absolute path baked in. Defines the planner+tester role for VS Code/tmux use.
- **`coder/start.sh`** polls for `plan-ready.flag`, then runs `opencode run` with the plan attached and the model from `opencode-model.txt`.
- **OpenCode tokens are not charged to your Claude Code session.** Usage is tracked in `usage.jsonl` per run and accumulated to `~/.agent-collab/usage-all.jsonl` across all runs.
- **Communication** is entirely filesystem-based: flags act as semaphores, inbox files carry messages, `chat.log` is the append-only audit trail.

## Reset Between Runs

```bash
./reset.sh
```

Clears plan, flags, output, and usage. Preserves `task.md`, `chat.log`, and `opencode-model.txt`.
