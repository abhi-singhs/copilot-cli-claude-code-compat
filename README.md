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
copilot plugin install abhi-singhs/copilot-cli-claude-code-compat
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
cpc auth logout                        # → /logout (in interactive session; subcommand removed)

# Update
cpc update                             # → copilot update

# MCP server management
cpc mcp                                # → copilot mcp

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

# Enable remote access (like Claude Code --remote)
cpc --remote
# → copilot --remote

# Delegate to cloud (like Claude Code --remote "task")
cpc --remote "Fix the login bug"
# → copilot -i "/delegate Fix the login bug"

# Resume a cloud session locally (like Claude Code --teleport)
cpc --teleport
# → copilot --resume

# Select model
cpc --model sonnet "fix the bug"       # → copilot --model sonnet -i "fix the bug"

# Plan mode
cpc --permission-mode plan             # → copilot --plan
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
| `/compact` | `/compact [FOCUS-INSTRUCTIONS]` | ✅ Both accept optional focus instructions |
| `/clear` | `/clear` | ✅ — note: Claude Code's optional `[name]` labels the previous conversation in `/resume`; Copilot's optional `[PROMPT]` starts the new conversation |
| `/context` | `/context` | ✅ |
| `/diff` | `/diff` | ✅ |
| `/model` | `/model` | ✅ |
| `/plan` | `/plan` | ✅ |
| `/resume` | `/resume` (`/continue`) | ✅ |
| `/review` | `/review` | ✅ |
| `/tasks` | `/tasks` | ✅ |
| `/agents` | `/agent` | ⚠️ Renamed |
| `/background` (`/bg`) | — | ❌ Claude Code-only (detach to background agent; closest: Ctrl+X then b) |
| `/btw` | `/ask` (experimental) | ⚠️ Renamed — side question without adding to history |
| `/code-review` (`/simplify`) | `/review` | ⚠️ Renamed — `/simplify` is now an alias; `--comment` and effort levels have no Copilot equivalent |
| `/cost` | `/usage` | ⚠️ Renamed |
| `/permissions` | `/allow-all`, `/reset-allowed-tools` | ⚠️ No `/permissions` command in Copilot CLI; `/allow-all` grants all permissions, `/reset-allowed-tools` clears them |
| `/sandbox` | `/sandbox [enable\|disable]` | ⚠️ Aligned — both now have `/sandbox`; Copilot uses explicit `enable`/`disable` |
| `/deep-research <question>` | `/research TOPIC` | ⚠️ Best-effort — Claude Code fans out web searches; Copilot uses GitHub + web sources |
| `/export` | `/share` (`/export`) | ⚠️ Renamed — `/export` now also a Copilot alias |
| `/extra-usage` → `/usage-credits` | — | ❌ Claude Code-only (configure usage credits; closest: `/usage` for stats only) |
| `/goal` | `/autopilot <objective>` (`/goal`) | ⚠️ Aligned — Copilot's `/autopilot <objective>` (alias `/goal`, v1.0.55) keeps autopilot focused on an objective |
| `/radio` | — | ❌ Claude Code-only (Claude FM lo-fi radio) |
| `/remote-control` | `/remote [on\|off]` | ⚠️ Renamed — no args shows status; `on`/`off` toggles |
| `/run`, `/run-skill-generator`, `/verify` | — | ❌ Claude Code-only (build/launch/drive the project's app; v2.1.145+) |
| `/memory` | `/memory [on\|off\|show]` | ✅ Both have it — Copilot CLI added `/memory on\|off\|show` in v1.0.49 |
| `/scroll-speed` | — | ❌ Claude Code-only (interactive scroll speed adjustment) |
| `/stop` | — | ❌ Claude Code-only (stop current background session) |
| `/autofix-pr` | — | ❌ Not available |
| `/web-setup` | — | ❌ Not available |
| `/team-onboarding` | — | ❌ Not available |
| `/fewer-permission-prompts` | — | ❌ Not available |
| `/loop` (`/proactive`) | — | ❌ Not available |
| — | `/ask QUESTION` | 🆕 Copilot CLI only (experimental) |
| — | `/env` | 🆕 Copilot CLI only — show loaded environment details |
| — | `/chronicle` | 🆕 Copilot CLI only (experimental) — session history tools |
| — | `/research TOPIC` | 🆕 Copilot CLI only |
| — | `/rubber-duck [PROMPT]` | 🆕 Copilot CLI only — rubber duck agent for a second opinion |
| — | `/diagnose [PROMPT]` | 🆕 Copilot CLI only — analyze the session log for diagnostics |
| — | `/collect-debug-logs [file\|gist] [PATH]` | 🆕 Copilot CLI only — export debug logs to a file or gist |
| — | `/update` (`/upgrade`) | 🆕 Copilot CLI only |
| — | `/version` | 🆕 Copilot CLI only |
| — | `/streamer-mode` (`/on-air`) | 🆕 Copilot CLI only — hide preview model names and quota details for streaming |
| — | `/tuikit [colors\|icons\|select\|tabbar]` | 🆕 Copilot CLI only — preview TUIkit design-system components and color tokens |

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
- **Worktree mode** (`-w` / `--worktree`) has no equivalent in Copilot CLI — there is no worktree launch flag or slash command, so run `git worktree` directly
- **Windows symlinks** may require running PowerShell as Administrator or enabling Developer Mode
- **Budget limits** (`--max-budget-usd`) aren't available in Copilot CLI
- **Plugin URL loading** (`--plugin-url`) is a Claude Code-only feature — Copilot CLI only supports local plugins via `copilot plugin install <dir>`
- **`/team-onboarding`** is a Claude Code–only command (generates team onboarding guides from session history) — no Copilot CLI equivalent
- **`/loop`** (`/proactive`) is a Claude Code–only command (runs a prompt repeatedly while the session stays open) — no Copilot CLI equivalent
- **`--bg`** flag (start session as a background agent) is Claude Code-only — closest: Ctrl+X then b to promote a running task to the background
- **`--advisor <model>`** flag (enable the server-side advisor tool; accepts `opus`, `sonnet`, `fable`, or a full model ID) is Claude Code-only — no direct Copilot CLI equivalent
- **`--safe-mode`** flag (start with all customizations disabled for troubleshooting: `CLAUDE.md`, skills, plugins, hooks, MCP servers, custom commands/agents, output styles, etc.) is Claude Code-only — no direct Copilot CLI equivalent; closest is `--no-custom-instructions`, though the semantics differ significantly
- **Background agent session management** (`attach`, `logs`, `respawn`, `rm`, `stop` subcommands) is Claude Code-only — Copilot CLI manages sessions via `/session` and `--resume`. Note: `claude respawn` restarts a running or stopped background session (`--all` restarts every running session)
- **`claude daemon status`** is Claude Code-only — reports the state of Claude Code's background-session supervisor (version, socket directory, worker count); no Copilot CLI counterpart
- **`/code-review`** (which replaces `/simplify` in Claude Code; `/simplify` is now an alias) maps to Copilot CLI `/review`. The `--comment` flag (post inline PR comments) and effort levels (`low|medium|high|xhigh|max`) have no Copilot equivalent
- **`/usage-credits`** (renamed from `/extra-usage` in Claude Code) is Claude Code-only — configure usage credits to keep working when you hit a limit; closest in Copilot CLI is `/usage` (stats only)
- **`/run`, `/run-skill-generator`, `/verify`** are Claude Code-only skills (v2.1.145+) that build, launch, and drive the project's app to observe a change running — no Copilot CLI equivalent
- **`/radio`** is a Claude Code-only command (opens Claude FM lo-fi radio in the browser) — no Copilot CLI equivalent
- **`/background`** (`/bg`) slash command (detach current session to background) is Claude Code-only — closest: Ctrl+X then b
- **`/goal [condition|clear]`** (Claude Code: set a goal for a multi-turn agentic loop) maps to Copilot CLI's `/autopilot <objective>` (alias `/goal`, v1.0.55), which sets an explicit objective to keep autopilot focused across turns
- **`/stop`** slash command (stop current background session while attached) is Claude Code-only — no Copilot CLI equivalent
- **`/scroll-speed`** is a Claude Code-only UI command — no Copilot CLI equivalent
- **`claude install [version]`** is Claude Code-only — use `copilot update` (no version pinning)
- **`claude setup-token`** is Claude Code-only — use `gh auth token` for CI/script authentication
- **`claude project purge [path]`** is Claude Code-only — use `/session cleanup` or `/session prune` in Copilot CLI
- **`/tui`**, **`/focus`**, **`/heapdump`**, **`/recap`** are Claude Code–only UI/debugging commands — no Copilot CLI equivalents
- **`/ultrareview [PR]`** is a Claude Code–only command (deep cloud-based code review) — use `/review` in Copilot CLI for local reviews
- **`/keep-alive [on|off|busy|DURATION]`** (`/caffeinate`) is a Copilot CLI-only slash command (prevent machine sleep; duration accepts bare numbers, `30m`, `2h`, `1d`) — no Claude Code equivalent
- **`/research`**, **`/update`** (`/upgrade`), **`/version`** are Copilot CLI-only slash commands — Claude Code's closest analog to `/research` is `/deep-research <question>` (best-effort mapping; the research pipelines differ)
- **`/feedback`** alias `/share` (added in Claude Code, alongside `/bug`) collides in name with Copilot CLI's `/share [file|html|gist] [session|research] [PATH]` (session export). Same name, different action — `/share` submits feedback in Claude Code but exports the session in Copilot CLI
- **`/deep-research <question>`** is a Claude Code workflow (fan out web searches, cross-check sources, synthesize a cited report) — the `cpc` wrapper treats it as a best-effort mapping to Copilot CLI's `/research TOPIC`, which uses GitHub search + web sources
- **`/advisor [model|off]`** is a Claude Code-only command (enable/disable the server-side advisor tool; accepts `opus`, `sonnet`, `fable`, or a full model ID) — no Copilot CLI equivalent
- **`/cd <path>`** (Claude Code v2.1.169+, move the session to a new working directory) maps to Copilot CLI's `/cd [PATH]` (combined with `/cwd`)
- **`/reload-skills`** (Claude Code v2.1.152+, re-scan skill/command directories without restarting) maps to Copilot CLI's `/skills reload`
- **`/fork`** changed semantics in Claude Code v2.1.161 — it was an alias for `/branch`, but now `/fork <directive>` spawns a background forked subagent that inherits the conversation; the closest Copilot CLI equivalent for that is `/fleet <directive>`. Note that Copilot CLI also has its own `/fork` (v1.0.45) that forks the session into a new independent session, matching Claude Code's *old* `/fork`=`/branch` behavior. Use `/branch` in Claude Code to switch into a copy of the conversation yourself
- **`/search [QUERY]`** (`/find`) is a Copilot CLI-only experimental command (search the conversation timeline) — no Claude Code equivalent
- **`--effort` / `--reasoning-effort`** is now supported in both CLIs and passes straight through — Copilot CLI accepts the same five levels as Claude Code (`low`, `medium`, `high`, `xhigh`, `max`; `max` is the highest-depth tier for Anthropic models), so `cpc` forwards it to Copilot's `--effort=LEVEL` unchanged
- **`/clikit [COMPONENT]`** is a Copilot CLI-only internal/debug command — no Claude Code equivalent
- **`/tuikit [colors|icons|select|tabbar]`** is a Copilot CLI-only internal/debug command (preview TUIkit design-system components and color tokens) — no Claude Code equivalent
- **`/env`** is a Copilot CLI-only slash command (show loaded environment details) — no Claude Code equivalent
- **`/rubber-duck [PROMPT]`** is a Copilot CLI-only slash command (consult the rubber duck agent for a second opinion on plans, code, and tests) — no Claude Code equivalent
- **`/diagnose [PROMPT]`** and **`/collect-debug-logs [file\|gist] [PATH]`** are Copilot CLI-only debugging commands (analyze the current session log; export debug logs to an archive file or GitHub gist) — partial Claude Code analogs are `/heapdump` and the `/debug` skill
- **`/sandbox`** exists in both CLIs but with different syntax — Claude Code's `/sandbox` toggles sandbox mode, while Copilot CLI's `/sandbox [enable|disable]` configures shell command sandboxing explicitly
- **`/permissions`** differs between the CLIs — Claude Code manages persistent allow/ask/deny rules with `/permissions`; Copilot CLI has no `/permissions` command, instead offering `/allow-all` (grant all tool/path/URL permissions for the session) and `/reset-allowed-tools` (clear the session's allowed-tools list)
- **`/compact [FOCUS-INSTRUCTIONS]`** now accepts optional focus instructions in both CLIs (e.g. `/compact focus on the auth module`); `cpc` passes in-session slash commands through unchanged
- **`/chronicle`** is a Copilot CLI-only experimental command (session history tools) — no Claude Code equivalent
- **`/streamer-mode`** (`/on-air`) is a Copilot CLI-only command that hides preview model names and quota details for streaming — no Claude Code equivalent
- **`--connect[=SESSION-ID]`** is a Copilot CLI-only flag for remote session joining — no direct Claude Code equivalent (see `--remote` and `--teleport`)
- **`--mode=MODE`** and **`--plan`** are Copilot CLI-only flags — `cpc` maps `--permission-mode plan` → `--plan`
- **`COPILOT_SUBAGENT_MAX_DEPTH`** and **`COPILOT_SUBAGENT_MAX_CONCURRENT`** are Copilot CLI-only environment variables for tuning subagent behavior
- **`GITHUB_COPILOT_PROMPT_MODE_EXTENSIONS`**, **`GITHUB_COPILOT_PROMPT_MODE_REPO_HOOKS`**, and **`GITHUB_COPILOT_PROMPT_MODE_WORKSPACE_MCP`** control whether prompt mode (`-p`) loads repository-provided extensions, hooks, and MCP sources (all disabled by default for security). Set to `true` explicitly when using `cpc -p` with repo hooks or MCP servers
- **`copilot logout`** subcommand has been removed — use `/logout` in an interactive session instead

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
