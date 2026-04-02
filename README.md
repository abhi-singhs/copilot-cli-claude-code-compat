# claude-compat — Claude Code Compatibility for Copilot CLI

A **Copilot CLI plugin** + companion wrapper script that lets you use Claude Code CLI syntax with GitHub Copilot CLI, without shadowing your real `claude` binary.

## What's Included

| Component | Type | Purpose |
|---|---|---|
| `plugin.json` | Plugin manifest | Registers this as a Copilot CLI plugin |
| `skills/claude-compat/SKILL.md` | Plugin skill | `/claude-help` — full mapping reference inside Copilot sessions |
| `hooks.json` | Plugin hook | Shows a reminder on session start |
| `cpc` | Companion script | Translates Claude Code CLI flags → Copilot CLI flags |
| `setup-claude-copilot-compat.sh` | Setup script (bash) | Symlinks config dirs + installs the plugin |
| `setup-claude-copilot-compat.ps1` | Setup script (PowerShell) | Same as above, for Windows/PowerShell |
| `cpc.ps1` | PowerShell wrapper | Invokes the `cpc` Python script from PowerShell |
| `cpc.cmd` | CMD wrapper | Invokes the `cpc` Python script from cmd.exe |

## Prerequisites

- [GitHub Copilot CLI](https://docs.github.com/en/copilot/how-tos/set-up/install-copilot-cli) installed (`copilot --version`)
- Python 3.6+ (ships with macOS; install from python.org on Windows)

## Installation

### Option A: Plugin only (no `cpc` wrapper)

If you just want the `/claude-help` reference skill inside Copilot CLI:

```bash
copilot plugin install ./
```

### Option B: Full setup (plugin + wrapper + config sync)

**macOS / Linux (bash):**
```bash
# 1. Make scripts executable
chmod +x cpc setup-claude-copilot-compat.sh

# 2. Put cpc on your PATH (pick one)
cp cpc /usr/local/bin/
# or: ln -s "$(pwd)/cpc" ~/bin/cpc
# or: add this directory to PATH

# 3. Run setup (installs plugin + symlinks config dirs)
./setup-claude-copilot-compat.sh
```

**Windows (PowerShell):**
```powershell
# 1. Put cpc on your PATH (pick one)
Copy-Item cpc, cpc.ps1, cpc.cmd -Destination "$env:USERPROFILE\bin\"
# or: add this directory to your PATH

# 2. Run setup (installs plugin + symlinks config dirs)
#    Note: Run as Administrator if symlink creation requires elevated privileges.
.\setup-claude-copilot-compat.ps1
```

### Option C: Install from a GitHub repo

```bash
copilot plugin install OWNER/REPO
```

## Usage Examples

```bash
# Start interactive session
cpc                                    # → copilot

# Start with a prompt
cpc "explain this project"             # → copilot -i "explain this project"

# Non-interactive mode
cpc -p "summarize README.md"           # → copilot -p "summarize README.md"

# Continue last conversation
cpc -c                                 # → copilot --continue

# Resume a session
cpc -r my-session "keep going"         # → copilot --resume=my-session -i "keep going"

# Auth
cpc auth login                         # → copilot login
cpc auth logout                        # → copilot logout

# Update
cpc update                             # → copilot update

# Skip permissions
cpc --dangerously-skip-permissions     # → copilot --allow-all

# Tool permissions (syntax is auto-converted)
cpc --allowedTools "Bash(git log *)" "Bash(npm test)" -p "check history"
# → copilot --allow-tool=shell(git log *) --allow-tool=shell(npm test) -p "check history"

# Limit turns
cpc --max-turns 5 -p "fix all lint errors"
# → copilot --max-autopilot-continues=5 -p "fix all lint errors"

# MCP config
cpc --mcp-config ./my-servers.json     # → copilot --additional-mcp-config=@./my-servers.json

# Tool availability
cpc --tools "Bash,Edit,Read" -p "q"    # → copilot --available-tools=bash,edit,view -p "q"

# Delegate to cloud (like Claude Code --remote)
cpc --remote "Fix the login bug"
# → copilot -i "/delegate Fix the login bug"

# Resume a cloud session locally (like Claude Code --teleport)
cpc --teleport
# → copilot --resume

# Select model
cpc --model sonnet "fix the bug"       # → copilot --model sonnet -i "fix the bug"
```

## Debugging

Use `--dry-run` to see what `copilot` command would be executed:

```bash
cpc --dry-run --dangerously-skip-permissions --max-turns 3 -p "fix tests"
# Output: copilot --allow-all --max-autopilot-continues=3 -p fix tests
```

## Interactive Slash Commands

Slash commands are in-session only and can't be aliased externally. Type `/claude-help` inside a Copilot CLI session to see the full mapping table.

Quick reference for the most common ones:

| Claude Code | Copilot CLI | Same? |
|---|---|---|
| `/clear` | `/clear` | ✅ |
| `/compact` | `/compact` | ✅ |
| `/context` | `/context` | ✅ |
| `/diff` | `/diff` | ✅ |
| `/model` | `/model` | ✅ |
| `/plan` | `/plan` | ✅ |
| `/resume` | `/resume` | ✅ |
| `/review` | `/review` | ✅ |
| `/agents` | `/agent` | ⚠️ Renamed |
| `/cost` | `/usage` | ⚠️ Renamed |
| `/export` | `/share` | ⚠️ Renamed |
| `/memory` | — | ❌ Not available |
| `/vim` | — | ❌ Not available |

## Config Sharing

The setup script symlinks these directories so both tools share the same files:

| Directory | Shared? |
|---|---|
| `agents/` | ✅ Symlinked between `~/.claude/` and `~/.copilot/` |
| `skills/` | ✅ Symlinked (Copilot also reads `~/.claude/skills/` natively) |
| `commands/` | ✅ Copilot reads `.claude/commands/` natively |
| `AGENTS.md` | ✅ Copilot reads natively |
| Settings (`settings.json` / `config.json`) | ❌ Different schemas |
| MCP config | ❌ Different formats |

## Limitations

- **Slash commands** can't be aliased — use `/claude-help` for the reference
- **System prompts** (`--system-prompt`, `--append-system-prompt`) don't exist in Copilot CLI — use `.github/copilot-instructions.md` or `.instructions.md` files
- **MCP configs** have different JSON schemas — migrate manually
- **Settings** (`~/.claude/settings.json` vs `~/.copilot/config.json`) have different formats
- **Worktree mode** (`-w`) isn't available — use `git worktree` directly
- **Windows symlinks** may require running PowerShell as Administrator or enabling Developer Mode
- **Budget limits** (`--max-budget-usd`) aren't available in Copilot CLI

## Architecture

This project has two parts:

### Copilot CLI Plugin (`plugin.json`)
Installed via `copilot plugin install`. Provides:
- **`/claude-help` skill** — type it in any Copilot session for the full mapping reference
- **sessionStart hook** — shows a reminder that the plugin is active

### `cpc` Companion Wrapper
A standalone Python script (not part of the plugin — plugins can't intercept CLI invocation). It:
1. Checks for subcommands (`update`, `auth login`, `plugin`, etc.)
2. Translates flags that differ between the two CLIs
3. Warns on flags with no Copilot equivalent
4. Passes through all unknown/matching flags unchanged
5. On Unix, calls `os.execvp("copilot", ...)` to replace the process — TTY, stdin, and signals are inherited transparently. On Windows, uses `subprocess.run()` and forwards the exit code

**Why can't `cpc` be a plugin?** Copilot CLI plugins can provide skills, agents, hooks, and MCP servers — but they cannot intercept or modify how `copilot` itself is invoked from the shell. Flag translation must happen *before* copilot starts, which only an external wrapper can do.
