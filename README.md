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

# Delegate to cloud (like Claude Code --cloud "task")
cpc --cloud "Fix the login bug"
# → copilot -i "/delegate Fix the login bug"

# --remote is a deprecated Claude Code alias for --cloud
cpc --remote "Fix the login bug"
# → copilot -i "/delegate Fix the login bug"

# Resume a cloud session locally (like Claude Code --teleport)
cpc --teleport
# → copilot --resume

# Select model
cpc --model sonnet "fix the bug"       # → copilot --model sonnet -i "fix the bug"
cpc --model gemini-3.6-flash "fix it"  # → copilot --model gemini-3.6-flash -i "fix it"

# Shell sandbox for this session only (Copilot CLI-only, experimental mode)
cpc --sandbox -p "run the test suite"  # → copilot --sandbox -p "run the test suite"
cpc --no-sandbox -p "run the build"    # → copilot --no-sandbox -p "run the build"

# Plan mode
cpc --permission-mode plan             # → copilot --plan

# Code review (Claude Code /review is an alias for /code-review; its effort
# level, --fix, and --comment have no Copilot equivalent and are stripped)
cpc -p "/review high --fix pr#123"     # → copilot -p "/review pr#123"

# Isolated Git worktree (experimental in Copilot CLI)
cpc --worktree feature-auth            # → copilot --worktree=feature-auth
cpc -w                                 # → copilot --worktree (auto-generated name)
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
| `/autocompact [auto\|<tokens>]` | — | ❌ Claude Code-only (v2.1.221+, sets the auto-compact threshold; Copilot's `/compact` only compacts on demand) |
| `/clear` | `/clear` | ✅ — note: Claude Code's optional `[name]` labels the previous conversation in `/resume`; Copilot's optional `[PROMPT]` starts the new conversation |
| `/context [all]` | `/context` | ✅ Claude Code's optional `all` expands the per-item breakdown in fullscreen; Copilot's `/context` takes no arguments |
| `/diff` | `/diff` | ✅ |
| `/model` | `/model` | ✅ |
| `/plan` | `/plan` | ✅ |
| `/resume` | `/resume` (`/continue`) | ✅ |
| `/review [low\|medium\|high\|xhigh\|max\|ultra] [--fix] [--comment] [target]` | `/review [PROMPT]` | ⚠️ Same name, different arguments — Claude Code's `/review` is now an alias for `/code-review`; Copilot's takes a free-form prompt, so `cpc` strips effort levels, `--fix`, and `--comment` |
| `/tasks` | `/tasks` | ✅ |
| `/agents` | `/agent` (`/subagents`) | ⚠️ Renamed — `/agent` browses agents; `/subagents` (`/agents`) configures per-agent subagent models |
| `/security-review` | `/security-review [PROMPT]` | ✅ Direct match — both run a security review agent over pending changes |
| `/background` (`/bg`) | — | ❌ Claude Code-only (detach to background agent; closest: Ctrl+X then b) |
| `/fork [prompt]` | `/fork [NAME]` (experimental) | ✅ Aligned in Claude Code v2.1.212+ — both copy the session into a new independent session; the forked-subagent behavior moved to `/subtask` |
| `/subtask <task>` | `/fleet <task>` | ⚠️ Best-effort — Claude Code v2.1.212+ spawns a forked subagent that inherits the conversation; Copilot's `/fleet` runs parallel subagents (not 1:1) |
| `/branch [name]` | `/branch [NAME]` | ✅ Aligned — fork the session into a new one (experimental in Copilot CLI) |
| `/btw [question]` | `/ask` (experimental) | ⚠️ Renamed — side question without adding to history; the question argument is optional in Claude Code v2.1.212+ |
| `/code-review` (`/simplify`, `/review`) | `/review` | ⚠️ Renamed — `/simplify` and `/review` are now aliases; `--fix`, `--comment`, and effort levels have no Copilot equivalent |
| `/cost` | `/usage` | ⚠️ Renamed |
| `/permissions` | `/permissions [default\|assisted\|allow-all\|show]` (`/permissions reset`) | ⚠️ Aligned — Copilot's `/permissions` now switches permission modes (`default`/`assisted`/`allow-all`) in addition to `show`; `/permissions reset` clears in-memory tool and path approvals |
| `/allow-all` (`/yolo`) | `/allow-all [off\|auto\|show]` (`/yolo`) | ⚠️ Alias for `/permissions allow-all` — the `on` option was replaced with `auto` |
| `/sandbox` | `/sandbox [enable\|disable]` | ⚠️ Aligned — both now have `/sandbox`; Copilot uses explicit `enable`/`disable` |
| `/deep-research <question>` | `/research TOPIC` | ⚠️ Best-effort — Claude Code fans out web searches; Copilot uses GitHub + web sources |
| `/export` | `/share` (`/export`) | ⚠️ Renamed — `/export` now also a Copilot alias |
| `/extra-usage` → `/usage-credits` | — | ❌ Claude Code-only (configure usage credits; closest: `/usage` for stats only) |
| `/goal` | `/autopilot [OBJECTIVE]` (`/goal [OBJECTIVE]`) | ⚠️ Aligned — Copilot's `/autopilot [OBJECTIVE]` (alias `/goal`, experimental) starts/refocuses autopilot mode with an optional objective (`--max-ai-credits N` caps spend); `/goal on`/`/goal off` toggle without an objective, closing the gap for Claude Code's `/goal <condition>` / `/goal clear` |
| `/radio` | — | ❌ Claude Code-only (Claude FM lo-fi radio) |
| `/remote-control` | `/remote [on\|off]` | ⚠️ Renamed — no args shows status; `on`/`off` toggles |
| `/run`, `/run-skill-generator`, `/verify` | — | ❌ Claude Code-only (build/launch/drive the project's app; v2.1.145+) |
| `/memory` | `/memory [on\|off\|show]` | ✅ Both have it — Copilot CLI added `/memory on\|off\|show` in v1.0.49 |
| `/scroll-speed` | — | ❌ Claude Code-only (interactive scroll speed adjustment) |
| `/stop` | — | ❌ Claude Code-only (stop current background session) |
| `/autofix-pr` | — | ❌ Not available |
| `/import [codex\|gemini] [--dry-run] [--yes]` | — | ❌ Claude Code-only (v2.1.213+, import Codex or Gemini CLI config into Claude Code) |
| `/list-agents` (`/peers`) | — | ❌ Claude Code-only (v2.1.224+, list subagents and sessions Claude can message; `/subagents` only configures models) |
| `/doctor` (`/checkup`) | — | ❌ Claude Code-only (installation health check) |
| `/web-setup` | — | ❌ Not available |
| `/team-onboarding` | — | ❌ Not available |
| `/fewer-permission-prompts` | — | ❌ Not available |
| `/loop` (`/proactive`) | — | ❌ Not available |
| — | `/ask QUESTION` | 🆕 Copilot CLI only (experimental) |
| — | `/env` | 🆕 Copilot CLI only — show loaded environment details |
| — | `/chronicle` | 🆕 Copilot CLI only (experimental) — session history tools |
| — | `/research TOPIC` | 🆕 Copilot CLI only |
| — | `/rubber-duck [PROMPT]` | 🆕 Copilot CLI only — rubber duck agent for a second opinion |
| — | `/update` (`/upgrade`) | 🆕 Copilot CLI only |
| — | `/version` | 🆕 Copilot CLI only |
| — | `/streamer-mode` (`/on-air`) | 🆕 Copilot CLI only — hide preview model names and quota details for streaming |
| — | `/after [DELAY PROMPT]` / `/every [INTERVAL PROMPT]` | 🆕 Copilot CLI only (experimental) — schedule a one-shot or recurring prompt/skill for this session |
| — | `/app` | 🆕 Copilot CLI only — launch the GitHub Copilot app (or show its download URL) |
| — | `/extensions` (`/extension`) `[manage\|mode]` | 🆕 Copilot CLI only — manage CLI extensions |
| — | `/settings [show\|[KEY VALUE]\|reset KEY]` | 🆕 Copilot CLI only — open the settings dialog or set/reset a setting inline (≈ Claude Code `/config`) |
| — | `/refine [TEXT]` | 🆕 Copilot CLI only — rewrite a rough prompt into a clear one for review before sending (no args cleans up the current input box) |
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
- **Subagent system prompts** (`--append-subagent-system-prompt`) can't be injected in Copilot CLI; the flag and its text are ignored with a warning
- **Cloud web sessions** (`--cloud`, and its deprecated alias `--remote`) map to `/delegate` when a task is provided; bare web-session launch has no Copilot CLI equivalent
- **MCP configs** have different JSON schemas — migrate manually
- **Settings** (`~/.claude/settings.json` vs `~/.copilot/config.json`) have different formats
- **Windows symlinks** may require running PowerShell as Administrator or enabling Developer Mode
- **Budget limits** (`--max-budget-usd`) aren't available in Copilot CLI
- **Plugin URL loading** (`--plugin-url`) is a Claude Code-only feature — Copilot CLI only supports local plugins via `copilot plugin install <dir>`
- **`/team-onboarding`** is a Claude Code–only command (generates team onboarding guides from session history) — no Copilot CLI equivalent
- **`/loop`** (`/proactive`) is a Claude Code–only command (runs a prompt repeatedly while the session stays open) — no Copilot CLI equivalent
- **`--bg`** / **`--background`** flag (start session as a background agent) is Claude Code-only — closest: Ctrl+X then b to promote a running task to the background
- **`--teammate-mode`** flag (set how agent team teammates display: `in-process` (default), `auto`, `tmux`, or `iterm2` (added in v2.1.186); default changed from `auto` to `in-process` in v2.1.179) is Claude Code-only — Copilot CLI has no agent team display modes, so `cpc` drops the flag with a warning
- **`--advisor <model>`** flag (enable the server-side advisor tool; accepts `opus`, `sonnet`, or a full model ID — the `fable` alias was removed in v2.1.212 and now errors out) is Claude Code-only — no direct Copilot CLI equivalent
- **`--safe-mode`** flag (start with all customizations disabled for troubleshooting: `CLAUDE.md`, skills, plugins, hooks, MCP servers, custom commands/agents, output styles, etc.) is Claude Code-only — no direct Copilot CLI equivalent; closest is `--no-custom-instructions`, though the semantics differ significantly
- **Background agent session management** (`attach`, `logs`, `respawn`, `rm`, `stop` subcommands) is Claude Code-only — Copilot CLI manages sessions via `/session` and `--resume`. Note: `claude respawn` restarts a running or stopped background session (`--all` restarts every running session)
- **`claude daemon status`** is Claude Code-only — reports the state of Claude Code's background-session supervisor (version, socket directory, worker count); no Copilot CLI counterpart
- **`/code-review`** (which replaces `/simplify` in Claude Code; `/simplify` and `/review` are now aliases) maps to Copilot CLI `/review`. The `--fix` flag (apply the suggested fixes), the `--comment` flag (post inline PR comments), and effort levels (`low|medium|high|xhigh|max|ultra`) have no Copilot equivalent. Copilot CLI's `/review [PROMPT]` takes a free-form prompt, so `cpc` strips those arguments when `/review ...` is passed as the initial prompt (e.g. `cpc -p "/review high --fix pr#123"` → `copilot -p "/review pr#123"`)
- **`/ultraplan`** was **removed** from Claude Code — use plan mode (`/plan`), which exists in both CLIs
- **`/autocompact [auto|<tokens>]`** (Claude Code v2.1.221+, sets how full the context window gets before Claude Code compacts automatically and saves it to user settings) has **no Copilot CLI equivalent** — Copilot's `/compact` is a one-shot compaction command, not a threshold setting
- **`--autocompact <auto|tokens>`** (the session-only launch-flag form of `/autocompact`) is Claude Code-only — `cpc` drops the flag and its value with a warning
- **`--environment <environment-id>`** (with `-p`, create a new Claude Code cloud session on a named environment and exit; self-hosted IDs look like `ccpool_...`; cannot be combined with `--cloud`) and **`--ref <branch>`** (base that cloud session's checkout on a named ref instead of local `HEAD`) are Claude Code-only — `cpc` drops both flags and their values with a warning; the closest Copilot CLI workflow is `/delegate` inside a session
- **`/claude-api [migrate|managed-agents-onboard|prompt-audit]`** is a Claude Code-only skill (`prompt-audit`, v2.1.221+, flags instructions written for older models in prompts, skills, and tool descriptions and proposes fixes as a diff) — no Copilot CLI equivalent
- **`/usage-credits`** (renamed from `/extra-usage` in Claude Code) is Claude Code-only — configure usage credits to keep working when you hit a limit; closest in Copilot CLI is `/usage` (stats only)
- **`/run`, `/run-skill-generator`, `/verify`** are Claude Code-only skills (v2.1.145+) that build, launch, and drive the project's app to observe a change running — no Copilot CLI equivalent
- **`/radio`** is a Claude Code-only command (opens Claude FM lo-fi radio in the browser) — no Copilot CLI equivalent
- **`/dataviz [request]`** is a Claude Code-only skill (v2.1.198+) offering design guidance for charts, graphs, and dashboards (picks the chart form, assigns color by role, validates the palette for colorblind safety) — no Copilot CLI equivalent
- **`/design-login`** is a Claude Code-only command (authorize design-system access for `/design-sync` with your claude.ai account; requires a claude.ai subscription) — no Copilot CLI equivalent
- **`/design-sync [hint]`** is a Claude Code-only skill (convert your repo's React design system and upload it to Claude Design so generated designs use real components) — **only available on the Anthropic API** (not on Amazon Bedrock, Google Cloud Vertex AI, or Microsoft Foundry) and no Copilot CLI equivalent
- **`/background`** (`/bg`) slash command (detach current session to background) is Claude Code-only — closest: Ctrl+X then b
- **`/goal [condition|clear]`** (Claude Code: set a goal for a multi-turn agentic loop) maps to Copilot CLI's `/autopilot [OBJECTIVE]` (alias `/goal`, experimental) — with no objective it infers intent from context, and `--max-ai-credits N` caps autopilot spend; `/goal on`/`/goal off` toggle autopilot without setting an objective, so Claude Code's `clear`/`stop`/`off`/`cancel` variants map to Copilot's `/goal off`. This closes a previous gap where Copilot had no equivalent for Claude Code's autonomous goal-tracking
- **`/stop`** slash command (stop current background session while attached) is Claude Code-only — no Copilot CLI equivalent
- **`/scroll-speed`** is a Claude Code-only UI command — no Copilot CLI equivalent
- **`claude install [version]`** is Claude Code-only — use `copilot update` (no version pinning)
- **`claude setup-token`** is Claude Code-only — use `gh auth token` for CI/script authentication
- **`claude project purge [path]`** is Claude Code-only — use `/session cleanup` or `/session prune` in Copilot CLI
- **`/tui`**, **`/focus`**, **`/heapdump`**, **`/recap`** are Claude Code–only UI/debugging commands — no Copilot CLI equivalents
- **`/ultrareview [PR]`** is a Claude Code–only command (deep cloud-based code review) — use `/review` in Copilot CLI for local reviews
- **`/keep-alive [on|off|busy|DURATION]`** (`/caffeinate`) is a Copilot CLI-only slash command (prevent machine sleep; duration accepts bare numbers, `30m`, `2h`, `1d`) — no Claude Code equivalent
- **`/research`**, **`/update`** (`/upgrade`), **`/version`** are Copilot CLI-only slash commands — Claude Code's closest analog to `/research` is `/deep-research <question>` (best-effort mapping; the research pipelines differ)
- **`/bug [report]`** is now the primary bug-reporting command in Claude Code, with **`/share`** as its alias (before v2.1.212 both `/bug` and `/share` were aliases of `/feedback`); `/feedback` still opens the same dialog, and in the VS Code extension `/bug` opens the extension's own feedback dialog (v2.1.229+). The `/share` alias collides in name with Copilot CLI's `/share [file|html|gist] [session|research] [PATH]` (session export). Same name, different action — `/share` submits a bug report in Claude Code but exports the session in Copilot CLI
- **`/import [codex|gemini] [--dry-run] [--yes]`** is a Claude Code-only command (v2.1.213+) that imports another coding agent's configuration — instruction files, MCP servers, commands, subagents, and skills — from OpenAI Codex or Google Gemini CLI. Not available on Amazon Bedrock, Google Cloud's Agent Platform, Microsoft Foundry, or Claude Platform on AWS. `--dry-run` previews without writing, `--yes` skips the picker. Copilot CLI is not a supported source, so there is nothing for `cpc` to map
- **`/list-agents`** (`/peers`) is a Claude Code-only command (v2.1.224+) that lists the subagents and other Claude Code sessions Claude can message, and is only available when cross-session messaging is enabled. Copilot CLI has no equivalent — `/subagents` (`/agents`) configures subagent models, and the `list_agents` tool only covers background agents started from the current session
- **`/doctor`** (alias `/checkup`) is a Claude Code-only command (installation and auto-updater health check) — no Copilot CLI equivalent
- **`/deep-research <question>`** is a Claude Code workflow (fan out web searches, cross-check sources, synthesize a cited report) — the `cpc` wrapper treats it as a best-effort mapping to Copilot CLI's `/research TOPIC`, which uses GitHub search + web sources
- **`/advisor [model|off]`** is a Claude Code-only command (enable/disable the server-side advisor tool; accepts `opus`, `sonnet`, or a full model ID — the `fable` alias was removed in v2.1.212) — no Copilot CLI equivalent
- **`/cd <path>`** (Claude Code v2.1.169+, move the session to a new working directory) maps to Copilot CLI's `/cd [PATH]` (combined with `/cwd`)
- **`/reload-skills`** (Claude Code v2.1.152+, re-scan skill/command directories without restarting) maps to Copilot CLI's `/skills reload`
- **`/fork`** changed semantics again in Claude Code v2.1.212 — `/fork [prompt]` now copies the current conversation into a new **background session** while the original keeps running (the two are independent afterwards), which matches Copilot CLI's own `/fork [NAME]` / `/branch [NAME]` (experimental). The forked-subagent behavior it had on v2.1.161–v2.1.211 moved to `/subtask`
- **`/subtask <task>`** (Claude Code v2.1.212+) spawns a **forked subagent** that inherits the full conversation and works on the task while you keep working; the result returns to the conversation when it finishes. Copilot CLI has no 1:1 equivalent — the closest is `/fleet <task>` (parallel subagent execution)
- **`/search [QUERY]`** (`/find`) is a Copilot CLI-only experimental command (search the conversation timeline) — no Claude Code equivalent
- **`--effort` / `--reasoning-effort`** is now supported in both CLIs and passes straight through — Copilot CLI accepts the same five levels as Claude Code (`low`, `medium`, `high`, `xhigh`, `max`; `max` is the highest-depth tier for Anthropic models), so `cpc` forwards it to Copilot's `--effort=LEVEL` unchanged. Claude Code's `ultracode` level (v2.1.203+: `xhigh` reasoning + automatic workflow orchestration) has no Copilot equivalent — `cpc` maps it to `max` with a warning
- **`--ax-screen-reader`** (Claude Code v2.1.181+, renders screen-reader-friendly output and forces the classic renderer) maps to Copilot CLI's `--screen-reader`
- **`--worktree` / `-w [NAME]`** (create or reuse an isolated Git worktree) now maps to Copilot CLI's `--worktree[=NAME]` (`-w`) flag — `cpc` forwards `claude --worktree NAME` → `copilot --worktree=NAME`. Copilot's worktree flag is **experimental**, so enable Copilot CLI's experimental mode for it to take effect; `cpc` prints a warning as a reminder
- **`/config`** gained inline `key=value` support in Claude Code v2.1.181 (e.g. `/config thinking=false`, also works in `-p` mode) — the closest Copilot CLI equivalent is `/settings [KEY VALUE]`
- **`/clikit [COMPONENT]`** is a Copilot CLI-only internal/debug command — no Claude Code equivalent
- **`/tuikit [colors|icons|select|tabbar]`** is a Copilot CLI-only internal/debug command (preview TUIkit design-system components and color tokens) — no Claude Code equivalent
- **`/env`** is a Copilot CLI-only slash command (show loaded environment details) — no Claude Code equivalent
- **`/rubber-duck [PROMPT]`** is a Copilot CLI-only slash command (consult the rubber duck agent for a second opinion on plans, code, and tests) — no Claude Code equivalent
- **`/sandbox`** exists in both CLIs but with different syntax — Claude Code's `/sandbox` toggles sandbox mode, while Copilot CLI's `/sandbox [enable|disable]` configures shell command sandboxing explicitly. Copilot CLI also has **`--sandbox`** / **`--no-sandbox`** launch flags (experimental mode only) that enable or disable the OS-level shell sandbox for a single session without changing the saved setting (handy with `-p`) — Claude Code has no launch-flag equivalent, and `cpc` passes both through unchanged
- **`/permissions`** differs between the CLIs — Claude Code manages persistent allow/ask/deny rules with `/permissions`; Copilot CLI's `/permissions [default|assisted|allow-all|show]` now switches between permission modes (`default`, `assisted`, `allow-all`), and `/permissions reset` clears in-memory tool and path approvals. `/allow-all` (`/yolo`) is documented as an alias for `/permissions allow-all` — its `on` option was replaced with `auto` (`/allow-all [off|auto|show]`)
- **`/compact [FOCUS-INSTRUCTIONS]`** now accepts optional focus instructions in both CLIs (e.g. `/compact focus on the auth module`); `cpc` passes in-session slash commands through unchanged
- **`/chronicle`** is a Copilot CLI-only experimental command (session history tools) — no Claude Code equivalent
- **`/streamer-mode`** (`/on-air`) is a Copilot CLI-only command that hides preview model names and quota details for streaming — no Claude Code equivalent
- **`--connect[=SESSION-ID]`** is a Copilot CLI-only flag for remote session joining — no direct Claude Code equivalent (see `--remote` and `--teleport`)
- **`--attachment PATH`** is a Copilot CLI-only flag that attaches a file to the initial prompt (image files accepted if model/org policy allows vision input; repeatable). `cpc` passes it through and consumes its value, e.g. `cpc --attachment image.png "describe this"`. Claude Code has no launch-flag equivalent
- **`--context default|long_context`** is a Copilot CLI-only flag that sets the context window tier (overrides the persisted setting). `cpc` passes it through unchanged; Claude Code manages context via `/compact` and `/context` instead
- **`-C DIRECTORY`** is a Copilot CLI-only flag that changes the working directory before launch. `cpc` passes it through unchanged; Claude Code uses `--add-dir` / `--worktree` instead
- **`--acp`**, **`--allow-all-mcp-server-instructions`**, **`--enable-memory`**, and **`--extension-sdk-path DIRECTORY`** are Copilot CLI-only flags with no Claude Code equivalent — `cpc` passes them through as-is
- **`--mode=MODE`** and **`--plan`** are Copilot CLI-only flags — `cpc` maps `--permission-mode plan` → `--plan`; Claude Code's `--permission-mode manual` alias maps like `default` and needs no Copilot flag
- **`COPILOT_SUBAGENT_MAX_DEPTH`** (default `4`, range `1`–`128`) and **`COPILOT_SUBAGENT_MAX_CONCURRENT`** (default `32`, range `1`–`256`) are Copilot CLI-only environment variables for tuning subagent behavior
- **`GITHUB_COPILOT_PROMPT_MODE_EXTENSIONS`**, **`GITHUB_COPILOT_PROMPT_MODE_REPO_HOOKS`**, and **`GITHUB_COPILOT_PROMPT_MODE_WORKSPACE_MCP`** control whether prompt mode (`-p`) loads repository-provided extensions, hooks, and MCP sources (all disabled by default for security). Set to `true` explicitly when using `cpc -p` with repo hooks or MCP servers
- **`copilot logout`** subcommand has been removed — use `/logout` in an interactive session instead
- **`/security-review`** is now a **direct match** — both Claude Code and Copilot CLI (`/security-review [PROMPT]`) run a security review agent that analyzes pending changes for vulnerabilities
- **`/after [DELAY PROMPT]`** and **`/every [INTERVAL PROMPT]`** are Copilot CLI-only experimental commands (schedule a one-shot or recurring prompt, skill, or schedulable slash command for the session; no args opens the schedule manager) — Claude Code's `/schedule` (`/routines`) only partially overlaps
- **`/extensions`** (`/extension`) `[manage|mode]` is a Copilot CLI-only command for managing CLI extensions — Claude Code's `/plugin` is a conceptually similar but distinct system
- **`/app`** is a Copilot CLI-only command (launch the GitHub Copilot desktop app, or show its download URL) — no Claude Code equivalent
- **`/settings [show|[KEY VALUE]|reset KEY]`** is the closest Copilot CLI equivalent to Claude Code's `/config [key=value]` — open the settings dialog, set a setting inline, or reset one to its default
- **`/subagents`** (alias `/agents`) configures default and per-agent subagent models in Copilot CLI — a richer counterpart to Claude Code's `/agents` than `/agent`
- **`/mcp`** gained a `search` subcommand in Copilot CLI (`/mcp [show|add|edit|delete|disable|enable|auth|reload|search] [SERVER-NAME]`) for searching available MCP servers
- **`/refine [TEXT]`** is a Copilot CLI-only slash command (rewrite a roughly composed prompt into a clear one for review before sending; no args — via `Ctrl+X` then `/refine` — cleans up the current input box) — no Claude Code equivalent, and `cpc` can't translate it because it is in-session only
- **`$`** (a lone `$` on an empty prompt) is a Copilot CLI-only shortcut that hands the terminal over to a real interactive shell (`$SHELL` on Unix, `%COMSPEC%` on Windows), suspending the CLI UI so job control, full-screen apps, tab completion, and colors work natively. **Disabled by default** — enable it with the `shellShortcut` setting; only available for local, trusted, idle sessions on a real TTY, and it can be disabled in enterprise managed settings
- **`copilot plugins [list|enable|disable|remove] [--plugin|--mcp|--skill] NAME`** (note the plural) is a Copilot CLI-only subcommand for non-interactively inspecting, enabling, disabling, or uninstalling plugins, MCP servers, and skills. `enable`/`disable` persist to configuration; `remove` can only delete personal and project skills (disable plugin-provided or built-in ones instead). `cpc plugins ...` passes through to `copilot plugins ...` (`cpc plugin ...` still maps to `copilot plugin ...`)
- **`mai-code-1-flash`** is a Copilot CLI model (fast, adaptive coding tasks); pass it through with `cpc --model mai-code-1-flash`
- **`gemini-3.6-flash`** is a Copilot CLI model (fast Google Gemini responses), joining `gemini-3.1-pro-preview` and `gemini-3.5-flash`; pass it through with `cpc --model gemini-3.6-flash`
- **`COPILOT_MCP_TOOL_CACHE`** (set to `false` to disable loading and persisting local MCP server tool snapshots for the whole process; existing cache files are left untouched) and **`COPILOT_TASK_WAIT_TIMEOUT_SECONDS`** (default `600`; maximum seconds `-p`, including `-p --autopilot`, waits for pending background agents or shell commands before exiting — `0` exits immediately) are Copilot CLI-only environment variables. `COPILOT_TASK_WAIT_TIMEOUT_SECONDS` is worth setting for scripted `cpc -p` pipelines
- **`COPILOT_COMPUTER_USE_LINUX`** (opt in to the `computer-use` MCP server on supported Linux distributions; not available on Alpine Linux / musl libc) and **`COLORFGBG`** (fallback for dark/light terminal background detection) are **no longer listed** in the Copilot CLI reference docs — they may still work, but treat them as undocumented. **`COPILOT_ENABLE_HTTP2`** (set to `1`/`true` to opt into HTTP/2 transport; HTTP/1.1 is the default) remains a documented Copilot CLI-only environment variable
- **`copilot help [TOPIC]`** now supports a `sandbox` topic in addition to `billing`, `config`, `commands`, `environment`, `logging`, `monitoring`, `permissions`, and `providers`

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
