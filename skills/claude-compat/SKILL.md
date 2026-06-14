---
name: claude-help
description: Show Claude Code to Copilot CLI command, flag, and slash-command mapping reference
user-invocable: true
disable-model-invocation: true
---

# Claude Code → Copilot CLI Reference

Use this reference when you know a Claude Code command and want the Copilot CLI equivalent.

## CLI Subcommand Mapping

| Claude Code | Copilot CLI | Status |
|---|---|---|
| `claude` | `copilot` | ✅ Same |
| `claude "query"` | `copilot -i "query"` | ✅ Mapped |
| `claude -p "query"` | `copilot -p "query"` | ✅ Same |
| `claude -c` | `copilot --continue` | ✅ Same |
| `claude -r <id> "query"` | `copilot --resume=<id> -i "query"` | ✅ Mapped |
| `claude update` | `copilot update` | ✅ Same |
| `claude init` | `copilot init` | ✅ Same |
| `claude auth login` | `copilot login` | ✅ Mapped |
| `claude auth logout` | `/logout` (interactive) | ⚠️ `copilot logout` subcommand removed; use `/logout` in-session |
| `claude auth status` | `copilot version` | ⚠️ Partial |
| `claude plugin ...` | `copilot plugin ...` | ✅ Same |
| `claude agents` | `/agent` (interactive) | ⚠️ Interactive only — Claude Code now opens an agent view to monitor/dispatch parallel background sessions |
| `claude mcp` | `copilot mcp` | ✅ Same |
| `claude auto-mode defaults` | — | ❌ Not available |
| `claude auto-mode config` | — | ❌ Not available |
| `claude remote-control` | `--remote` or `/remote` (interactive) | ⚠️ Mapped |
| `claude attach <id>` | — | ❌ Not available (background agent session management; closest: `copilot --resume`) |
| `claude logs <id>` | — | ❌ Not available (background agent session management) |
| `claude respawn <id>` | — | ❌ Not available (background agent session management; restarts a running or stopped session, `--all` restarts every running session; closest: `copilot --resume`) |
| `claude rm <id>` | — | ❌ Not available (use `/session delete <ID>` in Copilot CLI) |
| `claude stop <id>` | — | ❌ Not available (background agent session management) |
| `claude daemon status` | — | ❌ Not available (reports Claude Code's background-session supervisor state; no Copilot CLI counterpart) |
| `claude ultrareview [target]` | `/review` (interactive) | ⚠️ Partial (cloud-based deep review; `/review` is local only) |
| `claude project purge [path]` | — | ❌ Not available (use `/session cleanup` or `/session prune`) |
| `claude setup-token` | — | ❌ Not available (use `gh auth token` for CI/scripts) |
| `claude install [version]` | `copilot update` | ⚠️ Partial (no version pinning; update only) |
| — | `copilot completion SHELL` | ℹ️ Copilot-only (print shell completion script for bash/zsh/fish) |

## CLI Flag Mapping

### Direct Match (no translation needed)
| Flag | Notes |
|---|---|
| `--model` | Same in both |
| `--add-dir` | Same in both |
| `--agent` | Same in both |
| `--output-format` | Same (text, json) |
| `--version` / `-v` | Same |
| `--resume` / `-r` | Same |
| `--continue` / `-c` | Same |
| `-p` / `--print` | Same (non-interactive mode) |
| `--name` / `-n` | Same — set a session name |

### Translated (different name or syntax)
| Claude Code | Copilot CLI | Notes |
|---|---|---|
| `--dangerously-skip-permissions` | `--allow-all` | Also `--yolo` |
| `--allowedTools "Bash(cmd)"` | `--allow-tool=shell(cmd)` | Tool syntax differs |
| `--disallowedTools "Tool"` | `--deny-tool=tool` | Tool syntax differs |
| `--max-turns N` | `--max-autopilot-continues=N` | |
| `--mcp-config <path>` | `--additional-mcp-config=@<path>` | Path gets `@` prefix |
| `--tools "Bash,Edit,Read"` | `--available-tools=bash,edit,view` | Name mapping differs |
| `--permission-mode bypassPermissions` | `--allow-all` | |
| `--permission-mode auto` | `--autopilot` | |
| `--permission-mode plan` | `--plan` (or `--mode plan`) | |
| `--enable-auto-mode` | `--autopilot` | Removed in Claude Code v2.1.111 — use `--permission-mode auto` |
| `--debug` | `--log-level=debug` | Category filtering not supported |
| `--verbose` | `--log-level=info` | |
| `--debug-file <path>` | `--log-dir=<dir> --log-level=debug` | |
| `--remote` | `--remote` | Enable remote access (no task) |
| `--remote "task"` | `/delegate task` (interactive) | Delegate specific task to cloud |
| `--no-remote` | `--no-remote` | Disable remote access |
| `--teleport` | `--resume` | Resume cloud session locally |

### Unsupported (no Copilot equivalent)
| Claude Code | Suggested Alternative |
|---|---|
| `--system-prompt` | Use `.github/copilot-instructions.md` files |
| `--append-system-prompt` | Use `.github/copilot-instructions.md` files |
| `--bare` | Try `--no-custom-instructions` |
| `--safe-mode` | Try `--no-custom-instructions` (Claude Code's `--safe-mode` disables all customizations: `CLAUDE.md`, skills, plugins, hooks, MCP servers, custom commands/agents, output styles, etc.; semantics differ) |
| `--advisor <model>` | Not available (server-side advisor tool is Claude Code-only; accepts `opus`, `sonnet`, `fable`, or a full model ID) |
| `--chrome` | Copilot has built-in Playwright MCP |
| `--worktree` / `-w` | Use `git worktree` manually |
| `--max-budget-usd` | Not available |
| `--from-pr` | Reference PR URL in your prompt |
| `--fork-session` | Not available |
| `--fallback-model` | Not available |
| `--json-schema` | Use `--output-format=json` |
| `--effort` | Set `effortLevel` in `~/.copilot/config.json` (`xhigh` is Claude Code-only; Copilot supports `low`, `medium`, `high`) |
| `--plugin-url` | Not available (URL-based plugin loading is Claude Code-only; use `copilot plugin install <dir>` for local plugins) |
| `--tmux` | Not available |
| `--remote-control-session-name-prefix` | Not available (Remote Control is not supported) |
| `--bg` | Not available (starts session as background agent; closest: Ctrl+X then b to promote to background) |

### Copilot CLI Only (no Claude Code equivalent)
| Copilot CLI | Notes |
|---|---|
| `--mode=MODE` | Set initial agent mode: `interactive`, `plan`, `autopilot`. Cannot combine with `--autopilot` or `--plan` |
| `--plan` | Start in plan mode. Shorthand for `--mode plan`. Cannot combine with `--mode` or `--autopilot` |
| `--connect[=SESSION-ID]` | Connect directly to a remote session (optionally specify session/task ID). Conflicts with `--resume` and `--continue`. Requires remote sessions feature |
| `--no-banner` | Suppress the startup banner (pair: `--banner` / `--no-banner`) |

## Slash Command Mapping

### Direct Matches (same in both CLIs)
`/add-dir`, `/clear` (`/new`, `/reset`), `/compact`, `/context`, `/diff`, `/exit`, `/feedback`,
`/help`, `/ide`, `/init`, `/login`, `/logout`, `/mcp`, `/model`, `/plan`,
`/plugin`, `/rename`, `/resume` (`/continue`), `/review`, `/skills`, `/tasks`, `/terminal-setup`,
`/theme`, `/usage`, `/quit`

### Renamed Commands
| Claude Code | Copilot CLI | Notes |
|---|---|---|
| `/agents` | `/agent` | |
| `/btw` | `/ask` | Side question without adding to conversation history. `/ask` requires experimental mode in Copilot CLI |
| `/code-review [low\|medium\|high\|xhigh\|max] [--comment] [target]` | `/review [PROMPT]` | `/simplify` is a backward-compatible alias in Claude Code. Effort levels and `--comment` (post inline PR comments) have no Copilot equivalent — strip those arguments |
| `/simplify [focus]` | `/review [PROMPT]` | Now an alias for `/code-review` in Claude Code |
| `/cost` | `/usage` | |
| `/cd <path>` | `/cd [PATH]` (`/cwd`) | Both move the session to a new working directory. Copilot CLI combines it with `/cwd` (display current dir); Claude Code's `/cd` is standalone (v2.1.169+) |
| `/reload-skills` | `/skills reload` | Re-scan skill/command directories so changes on disk become available without restarting (Claude Code v2.1.152+) |
| `/fork <directive>` | `/fleet <directive>` | **Breaking change (Claude Code v2.1.161+):** `/fork <directive>` now spawns a background subagent that inherits the conversation and works on the directive. Previously `/fork` was an alias for `/branch`. To switch into a copy of the conversation yourself, use `/branch` |
| `/deep-research <question>` | `/research [TOPIC]` | Best-effort: Claude Code's `/deep-research` fans out web searches and synthesizes a cited report; Copilot's `/research` uses GitHub search + web sources. The research pipelines differ |
| `/export` | `/share` (`/export`) | `/export` is now also a Copilot CLI alias for `/share` |
| `/extra-usage` | — | Renamed to `/usage-credits` in Claude Code; no Copilot equivalent (closest: `/usage` for stats only) |
| `/usage-credits` | — | Configure usage credits to keep working when you hit a limit. No Copilot equivalent (closest: `/usage` for stats only) |
| `/permissions` | `/permissions [show\|reset]` | Claude Code manages persistent allow/ask/deny rules; Copilot's is session-scoped (in-memory) — `show` views, `reset` clears the current session's tool/path approvals. `/allow-all` and `/reset-allowed-tools` remain related Copilot commands |
| `/release-notes` | `/changelog` (`/release-notes`) | `/release-notes` is now a Copilot CLI alias for `/changelog` |
| `/rewind` / `/checkpoint` / `/undo` | `/session checkpoints` | |
| `/remote-control` (`/rc`) | `/remote [on\|off]` | No args shows status; `on` enables; `off` ends connection |
| `/sandbox` | `/sandbox [enable\|disable]` | Both CLIs now have `/sandbox`. Claude Code toggles sandbox mode; Copilot CLI configures shell command sandboxing with explicit `enable`/`disable` |
| `/ultrareview [PR]` | `/review [PROMPT]` | Cloud-based deep review; `/review` in Claude Code is the local equivalent |

### Claude Code Only (no Copilot equivalent)
`/advisor [model|off]`, `/autofix-pr`, `/background` (`/bg`), `/chrome`, `/color`, `/config`, `/copy`, `/desktop`, `/doctor`,
`/effort`, `/fast`, `/fewer-permission-prompts`, `/focus`, `/goal`, `/heapdump`, `/hooks`, `/loop` (`/proactive`), `/memory`, `/radio`, `/recap`,
`/run`, `/run-skill-generator`, `/verify`,
`/schedule` (`/routines`), `/scroll-speed`, `/security-review`, `/setup-bedrock`,
`/stats`, `/stop`, `/team-onboarding`, `/tui`, `/voice`, `/web-setup`

### Copilot CLI Only (not in Claude Code)
`/ask` (experimental), `/changelog` (`/release-notes`), `/chronicle` (experimental: `standup|tips|improve|reindex` — session history tools and insights),
`/clikit [COMPONENT]` (internal/debug: preview CLI business components),
`/collect-debug-logs [file\|gist] [PATH]` (collect debug logs to an archive file or GitHub gist),
`/diagnose [PROMPT]` (analyze the current session log and optionally prompt the agent about diagnostics),
`/downgrade <VERSION>` (download and restart into a specific CLI version; team accounts only),
`/env`, `/fleet`, `/list-dirs`, `/cwd` (`/cd`), `/lsp`, `/research`,
`/rubber-duck [PROMPT]` (consult the rubber duck agent for a second opinion on plans, code, and tests),
`/user`,
`/search [QUERY]` (`/find [QUERY]`) (experimental: search the conversation timeline),
`/session` (`/sessions`) with subcommands: `info|checkpoints [n]|files|plan|rename [NAME]|cleanup|prune|delete [ID]|delete-all`,
`/statusline` (`/footer`), `/experimental`, `/remote [on|off]`, `/keep-alive [on|off|busy|DURATION]` (`/caffeinate`),
`/update` (`/upgrade`), `/version`

Note: `/delegate` is the Copilot equivalent of Claude Code's `--remote "task"` flag.

Note: `/on-air` (`/streamer-mode`) has been removed from Copilot CLI.

Note: `/background` (`/bg`) detaches the current session to run as a background agent. No direct Copilot equivalent; closest is Ctrl+X then b to promote to background.

Note: `/goal [condition|clear]` sets a goal so Claude keeps working across turns until the condition is met. No Copilot CLI equivalent.

Note: `/stop` stops the current background session (only available while attached). No Copilot CLI equivalent.

Note: `/scroll-speed` adjusts mouse wheel scroll speed interactively. No Copilot CLI equivalent.

Note: `/theme` options changed to `[default|dim|high-contrast|colorblind]`.

Note: `/code-review` (Claude Code v2.1.x) replaces `/simplify`; `/simplify` remains as a backward-compatible alias. Both map to Copilot CLI's `/review`. The `--comment` flag (post inline PR comments) and effort levels (`low|medium|high|xhigh|max`) have no Copilot equivalent.

Note: `/usage-credits` is the renamed `/extra-usage` (Claude Code v2.1.x): "configure usage credits to keep working when you hit a limit". No Copilot CLI equivalent — the closest is `/usage` which only shows usage stats.

Note: `/run`, `/run-skill-generator`, and `/verify` (Claude Code v2.1.145+) are skills that build, launch, and drive the project's app to observe a change running. No Copilot CLI equivalent.

Note: `/radio` opens Claude FM lo-fi radio in the browser (not available on Bedrock, Vertex, or Foundry). No Copilot CLI equivalent.

Note: `/compact [FOCUS-INSTRUCTIONS]` now accepts optional focus instructions in both CLIs (e.g. `/compact focus on the auth module`). The `cpc` wrapper doesn't touch in-session slash commands, so the focus argument passes through to Copilot CLI unchanged.

Note: `/sandbox` exists in both CLIs but with different syntax. Claude Code's `/sandbox` toggles sandbox mode; Copilot CLI's `/sandbox [enable|disable]` configures shell command sandboxing explicitly.

Note: `/permissions` differs in scope. Claude Code manages persistent allow/ask/deny tool rules; Copilot CLI's `/permissions [show|reset]` is session-scoped (in-memory) — `show` views and `reset` clears the current session's tool and path approvals.

Note: `/rubber-duck [PROMPT]` is a Copilot CLI-only agent for a second opinion on plans, code, and tests. No Claude Code equivalent.

Note: `/diagnose [PROMPT]` and `/collect-debug-logs [file|gist] [PATH]` are Copilot CLI-only debugging commands (analyze the session log; export debug logs to a file or gist). Partial analogs in Claude Code are `/heapdump` and the `/debug` skill.

Note: `/feedback [report]` (aliases `/bug`, `/share`) gained the `/share` alias in Claude Code. This collides in name with Copilot CLI's `/share [file|html|gist] [session|research] [PATH]` (session export). Same name, different action — `/share` submits feedback in Claude Code but exports the session in Copilot CLI.

Note: `/clear [name]` in Claude Code accepts an optional name to label the previous conversation in the `/resume` picker. Copilot CLI's `/clear [PROMPT]` instead takes an optional prompt to start the new conversation. The optional argument has different semantics on each CLI.

Note: `/deep-research <question>` (Claude Code workflow: "fan out web searches on a question, fetch and cross-check sources, and synthesize a cited report") has no exact Copilot CLI equivalent. Closest is `/research [TOPIC]`, which uses GitHub search + web sources rather than fanned-out web search. The `cpc` wrapper treats this as a best-effort translation.

Note: `/fork` changed semantics in Claude Code v2.1.161. It was previously an alias for `/branch` (branch the conversation for the user to switch into). Now `/fork <directive>` spawns a background **forked subagent** that inherits the full conversation and works on the directive while you continue; its result returns when finished. The closest Copilot CLI equivalent is `/fleet <directive>` (parallel subagent execution). Use `/branch` to switch into a copy of the conversation yourself. The old `/fork` = `/branch` alias only applies to versions before v2.1.161.

Note: `/advisor [model|off]` enables or disables the Claude Code server-side advisor tool interactively (accepts `opus`, `sonnet`, `fable`, or a full model ID; no argument opens a picker; requires v2.1.98+). No Copilot CLI equivalent.

Note: `/cd <path>` moves the current session to a new working directory (Claude Code v2.1.169+; preserves the prompt cache and appends the new directory's `CLAUDE.md` as a message). Copilot CLI's `/cd [PATH]` (combined with `/cwd`) covers the same action.

Note: `/reload-skills` (Claude Code v2.1.152+) re-scans skill and command directories so skills added or changed on disk become available without restarting. Maps to Copilot CLI's `/skills reload`.

## Keyboard Shortcuts

### Global
| Shortcut | Purpose |
|---|---|
| `# NUMBER` | Include a GitHub issue or pull request in the context |
| `?` | Open quick help (on an empty prompt) |
| `Ctrl+G` | Edit the prompt in an external editor (`$EDITOR`) |
| `Ctrl+Enter` or `Ctrl+Q` | Queue a message to send while the agent is busy |
| `Ctrl+R` | Reverse search through command history |
| `Ctrl+V` | Paste from clipboard as an attachment |
| `Ctrl+X then b` | Promote the running task or shell command to the background |
| `Ctrl+X then e` | Edit the prompt in an external editor (`$EDITOR`) |
| `Ctrl+X then o` | Open the most recent link from the timeline |
| `Ctrl+Z` | Suspend the process to the background (Unix) |
| `Shift+Enter` / `Option+Enter` (Mac) / `Alt+Enter` (Windows/Linux) | Insert a newline in the input |

### Timeline
| Shortcut | Purpose |
|---|---|
| `Ctrl+F` | Open timeline search |
| `Page Up / Page Down` | Scroll the timeline up or down by one page |

### Navigation
| Shortcut | Purpose |
|---|---|
| `Home / End` | Move to start/end of text |
| `Alt+←/→` (Windows/Linux) / `Option+←/→` (Mac) | Move cursor one word left/right |

### Session Picker (opened via `/resume` or `--continue`)
| Shortcut | Purpose |
|---|---|
| ↑/↓ | Move selection up or down |
| Enter | Open the selected session |
| `s` | Cycle sort order: relevance → created → name → last used |
| Tab | Switch between local and remote tabs |
| `d` | Delete the selected session |
| Esc | Close the picker |

## Environment Variables

### Copilot CLI Only
| Variable | Default | Range | Description |
|---|---|---|---|
| `COPILOT_SUBAGENT_MAX_DEPTH` | `6` | `1`–`256` | Maximum subagent nesting depth |
| `COPILOT_SUBAGENT_MAX_CONCURRENT` | `32` | `1`–`256` | Maximum concurrent subagents across the session tree |
| `COPILOT_GH_HOST` | — | — | GitHub hostname for Copilot CLI only, overriding `GH_HOST`. Use when `GH_HOST` targets GHES but Copilot needs to authenticate against GitHub.com or GHEC |
| `COPILOT_PROMPT_FRAME` | — | `0` / `1` | Set to `1` to enable the decorative UI frame around the input prompt, or `0` to disable it. Overrides the `PROMPT_FRAME` experimental feature flag |
| `GITHUB_COPILOT_PROMPT_MODE_EXTENSIONS` | `false` | `true` / `false` | Set to `true` to load project extensions and allow extension management tools in prompt mode (`-p`). Disabled by default for security |
| `GITHUB_COPILOT_PROMPT_MODE_REPO_HOOKS` | `false` | `true` / `false` | Set to `true` to load repository hooks in prompt mode (`-p`). Disabled by default for security |
| `GITHUB_COPILOT_PROMPT_MODE_WORKSPACE_MCP` | `false` | `true` / `false` | Set to `true` to load workspace MCP sources in prompt mode (`-p`). Disabled by default for security |

## Config Directory Mapping

| Purpose | Claude Code | Copilot CLI |
|---|---|---|
| Agents | `~/.claude/agents/` | `~/.copilot/agents/` (also reads `~/.claude/agents/`) |
| Skills | `~/.claude/skills/` | `~/.copilot/skills/` (also reads `~/.claude/skills/`) |
| Commands | `.claude/commands/` | Read natively from `.claude/commands/` |
| Instructions | `CLAUDE.md` | `.github/copilot-instructions.md` + `AGENTS.md` |
| Settings | `~/.claude/settings.json` | `~/.copilot/config.json` (**different schema**) |
| MCP servers | `~/.claude/` | `~/.copilot/mcp-config.json` (**different format**) |

## Tool Permission Syntax

| Claude Code | Copilot CLI |
|---|---|
| `Bash(cmd)` | `shell(cmd)` |
| `Read` | `read` |
| `Edit` | `write` |
| `Write` | `write` |
| `WebFetch` | `url` |
| `ListFiles` | `glob` |
| `Grep` | `grep` |
| `mcp__SERVER__TOOL` | `SERVER(TOOL)` |
