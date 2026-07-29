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
| — | `copilot plugins [list\|enable\|disable\|remove] [--plugin\|--mcp\|--skill] NAME` | ℹ️ Copilot-only CLI subcommand (note the plural): non-interactively inspect, enable, disable, or uninstall plugins, MCP servers, and skills. `enable`/`disable` persist to configuration and apply to future sessions; `remove` can only delete personal and project skills (not plugin-provided or built-in ones — disable those instead). `cpc plugins ...` passes through to `copilot plugins ...` |
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
| — | `copilot skill` | ℹ️ Copilot-only CLI subcommand: manage agent skills (list, add, remove). Claude Code manages skills via slash commands (`/skills`, `/reload-skills`) or the `--tools` flag, not a CLI subcommand |
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
| `--effort` / `--reasoning-effort` | Same — both CLIs accept `low`, `medium`, `high`, `xhigh`, `max` (`max` is the highest-depth tier for Anthropic models). Passed through to Copilot's `--effort=LEVEL`. Claude Code's `ultracode` level (v2.1.203+: xhigh reasoning + automatic workflow orchestration) has no Copilot equivalent — `cpc` maps it to `max` with a warning |

### Translated (different name or syntax)
| Claude Code | Copilot CLI | Notes |
|---|---|---|
| `--dangerously-skip-permissions` | `--allow-all` | Also `--yolo` |
| `--allowedTools "Bash(cmd)"` | `--allow-tool=shell(cmd)` | Tool syntax differs. `--allowed-tools` (kebab-case alias) maps the same way |
| `--disallowedTools "Tool"` | `--deny-tool=tool` | Tool syntax differs. `--disallowed-tools` (kebab-case alias) maps the same way |
| `--max-turns N` | `--max-autopilot-continues=N` | |
| `--mcp-config <path>` | `--additional-mcp-config=@<path>` | Path gets `@` prefix |
| `--tools "Bash,Edit,Read"` | `--available-tools=bash,edit,view` | Name mapping differs |
| `--permission-mode bypassPermissions` | `--allow-all` | |
| `--permission-mode auto` | `--autopilot` | |
| `--permission-mode plan` | `--plan` (or `--mode plan`) | |
| `--permission-mode default` / `manual` | No flag needed | `manual` is a v2.1.200+ alias for `default` |
| `--enable-auto-mode` | `--autopilot` | Removed in Claude Code v2.1.111 — use `--permission-mode auto` |
| `--debug` | `--log-level=debug` | Category filtering not supported |
| `--verbose` | `--log-level=info` | |
| `--debug-file <path>` | `--log-dir=<dir> --log-level=debug` | |
| `--cloud "task"` | `/delegate task` (interactive) | Delegate specific task to cloud |
| `--cloud` | No equivalent | Bare launch creates a claude.ai web session |
| `--remote ["task"]` | Same as `--cloud` | Deprecated Claude Code alias |
| `--no-remote` | `--no-remote` | Disable remote access |
| `--teleport` | `--resume` | Resume cloud session locally |
| `--ax-screen-reader` | `--screen-reader` | Accessibility: screen-reader-friendly output (Claude Code v2.1.181+; forces classic renderer) |
| `--worktree` / `-w [NAME]` | `--worktree[=NAME]` / `-w` | Create or reuse an isolated Git worktree. **Experimental in Copilot CLI** (requires experimental mode). Omit `NAME` to auto-generate a branch name |

### Unsupported (no Copilot equivalent)
| Claude Code | Suggested Alternative |
|---|---|
| `--system-prompt` | Use `.github/copilot-instructions.md` files |
| `--append-system-prompt` | Use `.github/copilot-instructions.md` files |
| `--append-subagent-system-prompt` | Not available (subagent prompt injection is Claude Code-only; ignored with a warning) |
| `--bare` | Try `--no-custom-instructions` |
| `--safe-mode` | Try `--no-custom-instructions` (Claude Code's `--safe-mode` disables all customizations: `CLAUDE.md`, skills, plugins, hooks, MCP servers, custom commands/agents, output styles, etc.; semantics differ) |
| `--advisor <model>` | Not available (server-side advisor tool is Claude Code-only; accepts `opus`, `sonnet`, or a full model ID — the `fable` alias was removed in v2.1.212 and now exits with an error) |
| `--chrome` | Copilot has built-in Playwright MCP |
| `--max-budget-usd` | Not available |
| `--from-pr` | Reference PR URL in your prompt |
| `--fork-session` | Not available |
| `--fallback-model` | Not available |
| `--json-schema` | Use `--output-format=json` |
| `--plugin-url` | Not available (URL-based plugin loading is Claude Code-only; use `copilot plugin install <dir>` for local plugins) |
| `--tmux` | Not available |
| `--teammate-mode` | Not available (Claude Code-only agent team display mode: `in-process` (default), `auto`, `tmux`, `iterm2` (added v2.1.186); default changed from `auto` to `in-process` in v2.1.179. Copilot CLI has no agent team display modes) |
| `--remote-control-session-name-prefix` | Not available (Remote Control is not supported) |
| `--bg` / `--background` | Not available (starts session as background agent; closest: Ctrl+X then b to promote to background). `--background` is a long-form alias for `--bg` |

### Copilot CLI Only (no Claude Code equivalent)
| Copilot CLI | Notes |
|---|---|
| `--mode=MODE` | Set initial agent mode: `interactive`, `plan`, `autopilot`. Cannot combine with `--autopilot` or `--plan` |
| `--plan` | Start in plan mode. Shorthand for `--mode plan`. Cannot combine with `--mode` or `--autopilot` |
| `--connect[=SESSION-ID]` | Connect directly to a remote session (optionally specify session/task ID). Conflicts with `--resume` and `--continue`. Requires remote sessions feature |
| `--banner` | Show the startup banner (Copilot CLI also has `--no-color`, `--screen-reader`, and `--no-ask-user`) |
| `--attachment PATH` | Attach a file to the initial prompt (image files accepted if model/org policy allows vision input; repeatable). `cpc` passes it through and consumes its value. Claude Code has no launch-flag equivalent |
| `--context TIER` | Set the context window tier: `default` or `long_context` (overrides the persisted setting). `cpc` passes it through unchanged; Claude Code manages context via `/compact` and `/context` instead |
| `-C DIRECTORY` | Change the working directory before doing anything else. `cpc` passes it through unchanged; Claude Code uses `--add-dir` / `--worktree` instead |
| `--acp` | Start as Agent Client Protocol server. Passed through unchanged |
| `--allow-all-mcp-server-instructions` | Include initialization instructions from all MCP servers in the system prompt (by default only allowlisted server instructions are included up front). Passed through unchanged |
| `--enable-memory` | Enable memory in prompt mode (disabled by default). Conceptually related to Claude Code's `/memory` and `auto-memory`, but there is no Claude Code launch-flag equivalent. Passed through unchanged |
| `--extension-sdk-path DIRECTORY` | Override the bundled `@github/copilot-sdk` injected into extension subprocesses with a local `copilot-sdk/` folder; invalid paths fall back to the bundled SDK. Passed through unchanged |

## Slash Command Mapping

### Direct Matches (same in both CLIs)
`/add-dir`, `/clear` (`/new`, `/reset`), `/compact`, `/context`, `/copy`, `/diff`, `/exit`, `/feedback`,
`/help`, `/ide`, `/init`, `/login`, `/logout`, `/mcp`, `/memory`, `/model`, `/plan`,
`/plugin`, `/rename`, `/resume` (`/continue`), `/review`, `/security-review`, `/skills`, `/tasks`, `/terminal-setup`,
`/theme`, `/undo` (`/rewind`), `/usage`, `/voice`, `/quit`

### Renamed Commands
| Claude Code | Copilot CLI | Notes |
|---|---|---|
| `/agents` | `/agent` (`/subagents` for per-agent models) | Copilot CLI's `/agent` browses agents; `/subagents` (alias `/agents`) configures the default and per-agent subagent models |
| `/btw [question]` | `/ask` | Side question without adding to conversation history. The question argument is **optional** in Claude Code v2.1.212+ — with no argument it reopens the overlay on the session's most recent side question. `/ask` requires experimental mode in Copilot CLI |
| `/code-review [low\|medium\|high\|xhigh\|max] [--comment] [target]` | `/review [PROMPT]` | `/simplify` is a backward-compatible alias in Claude Code. Effort levels and `--comment` (post inline PR comments) have no Copilot equivalent — strip those arguments |
| `/simplify [focus]` | `/review [PROMPT]` | Now an alias for `/code-review` in Claude Code |
| `/cost` | `/usage` | |
| `/cd <path>` | `/cd [PATH]` (`/cwd`) | Both move the session to a new working directory. Copilot CLI combines it with `/cwd` (display current dir); Claude Code's `/cd` is standalone (v2.1.169+) |
| `/reload-skills` | `/skills reload` | Re-scan skill/command directories so changes on disk become available without restarting (Claude Code v2.1.152+) |
| `/fork [prompt]` | `/fork [NAME]` | **Behavior changed again in Claude Code v2.1.212+:** `/fork` now copies the current conversation into a new **background session** while the original session keeps running; the two are independent after the copy. This matches Copilot CLI's `/fork [NAME]` (**experimental**), which forks the current session into a new independent session. On v2.1.161–v2.1.211 `/fork <directive>` instead spawned a forked subagent — that behavior is now `/subtask` |
| `/subtask <task>` | `/fleet <task>` | **New in Claude Code v2.1.212+:** spawns a **forked subagent** that inherits the full conversation and works on the task while you keep working; its result returns to the conversation when it finishes. Best-effort mapping: Copilot CLI's `/fleet` runs parallel subagents but is not a 1:1 equivalent. This behavior was `/fork` on v2.1.161–v2.1.211 |
| `/branch [name]` | `/branch [NAME]` | Fork the current session into a new session, optionally named (**experimental in Copilot CLI**). Copilot's `/fork [NAME]` is an alias with the same semantics |
| `/goal [condition\|clear]` | `/autopilot <objective>` (`/goal`) | Copilot CLI's `/autopilot <objective>` (alias `/goal`, v1.0.55) sets an explicit objective to keep autopilot focused across turns — the closest analog to Claude Code's `/goal` |
| `/deep-research <question>` | `/research [TOPIC]` | Best-effort: Claude Code's `/deep-research` fans out web searches and synthesizes a cited report; Copilot's `/research` uses GitHub search + web sources. The research pipelines differ |
| `/export` | `/share` (`/export`) | `/export` is now also a Copilot CLI alias for `/share` |
| `/extra-usage` | — | Renamed to `/usage-credits` in Claude Code; no Copilot equivalent (closest: `/usage` for stats only) |
| `/usage-credits` | — | Configure usage credits to keep working when you hit a limit. No Copilot equivalent (closest: `/usage` for stats only) |
| `/permissions` | `/allow-all`, `/reset-allowed-tools` | Claude Code manages persistent allow/ask/deny rules. Copilot CLI has no single `/permissions` command — `/allow-all` grants all tool/path/URL permissions for the session and `/reset-allowed-tools` clears the session's allowed-tools list |
| `/release-notes` | `/changelog` (`/release-notes`) | `/release-notes` is now a Copilot CLI alias for `/changelog` |
| `/rewind` / `/checkpoint` / `/undo` | `/undo` (`/rewind`) | Copilot CLI has native `/undo` (alias `/rewind`): opens a timeline picker to roll back the conversation and revert file changes. `/session checkpoints` lists session checkpoints |
| `/remote-control` (`/rc`) | `/remote [on\|off]` | No args shows status; `on` enables; `off` ends connection |
| `/sandbox` | `/sandbox [enable\|disable]` | Both CLIs now have `/sandbox`. Claude Code toggles sandbox mode; Copilot CLI configures shell command sandboxing with explicit `enable`/`disable` |
| `/ultrareview [PR]` | `/review [PROMPT]` | Cloud-based deep review; `/review` in Claude Code is the local equivalent |

### Claude Code Only (no Copilot equivalent)
`/advisor [model|off]`, `/autofix-pr`, `/background` (`/bg`), `/chrome`, `/color`, `/config`, `/dataviz`, `/design-login`, `/design-sync`, `/desktop`, `/doctor`,
`/effort`, `/fast`, `/fewer-permission-prompts`, `/focus`, `/heapdump`, `/hooks`, `/loop` (`/proactive`), `/radio`, `/recap`,
`/run`, `/run-skill-generator`, `/verify`,
`/schedule` (`/routines`), `/scroll-speed`, `/setup-bedrock`,
`/stats`, `/stop`, `/team-onboarding`, `/tui`, `/web-setup`

### Copilot CLI Only (not in Claude Code)
`/after [DELAY PROMPT]` / `/every [INTERVAL PROMPT]` (experimental: schedule a one-shot or recurring prompt, skill, or schedulable slash command for this session, e.g. `/after 30m remind me` or `/every 1h run tests`; no args opens the schedule manager),
`/app` (launch the GitHub Copilot app, or show the download URL if it isn't installed),
`/ask` (experimental), `/autopilot <objective>` (`/goal`), `/changelog` (`/release-notes`), `/chronicle` (experimental: `standup|tips|improve|reindex` — session history tools and insights),
`/clikit [COMPONENT]` (internal/debug: preview CLI business components),
`/downgrade <VERSION>` (download and restart into a specific CLI version; team accounts only),
`/env`, `/extensions` (`/extension`) `[manage|mode]` (manage CLI extensions), `/fleet`, `/list-dirs`, `/cwd` (`/cd`), `/lsp`, `/research`, `/restart`,
`/refine [TEXT]` (rewrite a roughly composed prompt into a clear one for review before sending),
`/rubber-duck [PROMPT]` (consult the rubber duck agent for a second opinion on plans, code, and tests),
`/settings [show\|[KEY VALUE]\|reset KEY]` (open the settings dialog, set a setting inline, or reset one to its default),
`/sidekicks` (view running sidekick agents), `/streamer-mode` (`/on-air`), `/subagents` (`/agents`) (configure default and per-agent subagent models), `/user`,
`/search [QUERY]` (`/find [QUERY]`) (experimental: search the conversation timeline),
`/session` (`/sessions`) with subcommands: `info|checkpoints [n]|files|plan|rename [NAME]|cleanup|prune|delete [ID]|delete-all`,
`/statusline` (`/footer`), `/experimental`, `/remote [on|off]`, `/keep-alive [on|off|busy|DURATION]` (`/caffeinate`),
`/tuikit [colors|icons|select|tabbar]` (internal/debug: preview TUIkit design-system components and color tokens),
`/update` (`/upgrade`), `/version`

Note: Copilot CLI has no `/worktree` slash command, but it does have a `--worktree` (`-w`) launch flag (experimental) that creates or reuses an isolated Git worktree under `<repo>.worktrees/` at startup — matching Claude Code's `--worktree` (`-w`) flag. `cpc` maps `claude --worktree NAME` → `copilot --worktree=NAME`. Because Copilot's flag is experimental, enable experimental mode for it to take effect.

Note: `/delegate` is the Copilot equivalent of Claude Code's `--cloud "task"` flag. `--remote` is a deprecated alias for `--cloud`.

Note: `/on-air` (`/streamer-mode`) toggles streamer mode in Copilot CLI (hides preview model names and quota details for streaming). No Claude Code equivalent.

Note: `/background` (`/bg`) detaches the current session to run as a background agent. No direct Copilot equivalent; closest is Ctrl+X then b to promote to background.

Note: Copilot CLI's **Agent and task delegation** tools are `task` (delegate work to a background agent), `list_agents` (list running background agents), `read_agent` (read a background agent's output), and `write_agent` (send a message to a running background agent). Claude Code manages background agents through the `claude` CLI (`attach`, `logs`, `respawn`, `stop`) rather than these tools, so there is no direct `cpc` mapping — the workflows differ.

Note: `/goal [condition|clear]` sets a goal so Claude keeps working across turns until the condition is met. The closest Copilot CLI equivalent is `/autopilot <objective>` (alias `/goal`, v1.0.55), which sets an explicit objective to keep autopilot focused.

Note: `/stop` stops the current background session (only available while attached). No Copilot CLI equivalent.

Note: `/scroll-speed` adjusts mouse wheel scroll speed interactively. No Copilot CLI equivalent.

Note: `/theme` options changed to `[default|github|dim|high-contrast|colorblind]`.

Note: `/code-review` (Claude Code v2.1.x) replaces `/simplify`; `/simplify` remains as a backward-compatible alias. Both map to Copilot CLI's `/review`. The `--comment` flag (post inline PR comments) and effort levels (`low|medium|high|xhigh|max`) have no Copilot equivalent.

Note: `/usage-credits` is the renamed `/extra-usage` (Claude Code v2.1.x): "configure usage credits to keep working when you hit a limit". No Copilot CLI equivalent — the closest is `/usage` which only shows usage stats.

Note: `/run`, `/run-skill-generator`, and `/verify` (Claude Code v2.1.145+) are skills that build, launch, and drive the project's app to observe a change running. No Copilot CLI equivalent.

Note: `/radio` opens Claude FM lo-fi radio in the browser (not available on Bedrock, Vertex, or Foundry). No Copilot CLI equivalent.

Note: `/dataviz [request]` (Claude Code v2.1.198+) is a skill that provides design guidance for charts, graphs, and dashboards — Claude picks the chart form, assigns color by role, and validates the palette for colorblind safety. No Copilot CLI equivalent.

Note: `/design-login` authorizes design-system access for `/design-sync` using your claude.ai account (requires a claude.ai subscription). No Copilot CLI equivalent.

Note: `/design-sync [hint]` is a skill that converts your repo's React design system and uploads it to Claude Design so generated designs use real components (a first-time sync can take a few hours on a large repo). **Only available on the Anthropic API** — not on Amazon Bedrock, Google Cloud Vertex AI, or Microsoft Foundry. No Copilot CLI equivalent.

Note: `/compact [FOCUS-INSTRUCTIONS]` now accepts optional focus instructions in both CLIs (e.g. `/compact focus on the auth module`). The `cpc` wrapper doesn't touch in-session slash commands, so the focus argument passes through to Copilot CLI unchanged.

Note: `/sandbox` exists in both CLIs but with different syntax. Claude Code's `/sandbox` toggles sandbox mode; Copilot CLI's `/sandbox [enable|disable]` configures shell command sandboxing explicitly.

Note: `/permissions` differs between the CLIs. Claude Code manages persistent allow/ask/deny tool rules with `/permissions`. Copilot CLI has no `/permissions` command — use `/allow-all` to grant all tool/path/URL permissions for the session, or `/reset-allowed-tools` to clear the session's allowed-tools list.

Note: `/rubber-duck [PROMPT]` is a Copilot CLI-only agent for a second opinion on plans, code, and tests. No Claude Code equivalent.

Note: `/feedback [report]` (aliases `/bug`, `/share`) gained the `/share` alias in Claude Code. This collides in name with Copilot CLI's `/share [file|html|gist] [session|research] [PATH]` (session export). Same name, different action — `/share` submits feedback in Claude Code but exports the session in Copilot CLI.

Note: `/clear [name]` in Claude Code accepts an optional name to label the previous conversation in the `/resume` picker. Copilot CLI's `/clear [PROMPT]` instead takes an optional prompt to start the new conversation. The optional argument has different semantics on each CLI.

Note: `/deep-research <question>` (Claude Code workflow: "fan out web searches on a question, fetch and cross-check sources, and synthesize a cited report") has no exact Copilot CLI equivalent. Closest is `/research [TOPIC]`, which uses GitHub search + web sources rather than fanned-out web search. The `cpc` wrapper treats this as a best-effort translation.

Note: `/fork` changed semantics twice. It was originally an alias for `/branch`; in v2.1.161 it became a forked-subagent command; and in **v2.1.212** it changed again — `/fork [prompt]` now copies the current conversation into a new **background session** while the original session keeps running, and the two sessions are independent after the copy. That matches Copilot CLI's own `/fork [NAME]` (experimental; added v1.0.45), which forks the current session into a new independent session, so the two CLIs are now aligned. The forked-subagent behavior moved to `/subtask` (see below). On v2.1.161–v2.1.211, `/fork <directive>` still spawns a forked subagent.

Note: `/subtask <task>` (Claude Code v2.1.212+) spawns a **forked subagent** that inherits the full conversation and works on the task while you keep working in the main session; its result returns to the conversation when the subagent finishes. Copilot CLI has no 1:1 equivalent — the closest is `/fleet <task>` (parallel subagent execution), so `cpc` treats it as a best-effort mapping. Use `/fork` in Claude Code to copy the conversation into a separate background session instead.

Note: `/btw [question]` (Claude Code) asks a side question without adding it to the conversation history. The question argument became **optional** in v2.1.212 — running `/btw` with no argument reopens the overlay on the session's most recent side question. Copilot CLI's `/ask` (experimental) is the equivalent.

Note: `/advisor [model|off]` enables or disables the Claude Code server-side advisor tool interactively (accepts `opus`, `sonnet`, or a full model ID; no argument opens a picker; requires v2.1.98+). The `fable` alias was removed in v2.1.212 and is no longer accepted. No Copilot CLI equivalent.

Note: `/cd <path>` moves the current session to a new working directory (Claude Code v2.1.169+; preserves the prompt cache and appends the new directory's `CLAUDE.md` as a message). Copilot CLI's `/cd [PATH]` (combined with `/cwd`) covers the same action.

Note: `/reload-skills` (Claude Code v2.1.152+) re-scans skill and command directories so skills added or changed on disk become available without restarting. Maps to Copilot CLI's `/skills reload`.

Note: `/config` (Claude Code v2.1.181+) now accepts inline `key=value` pairs (e.g. `/config thinking=false`) to set a setting directly without opening the Settings interface; the `key=value` form also works in non-interactive mode (`-p`) and from Remote Control. The closest Copilot CLI equivalent is `/settings [KEY VALUE]`, which similarly sets a setting inline without opening a dialog.

Note: `/effort [low|medium|high|xhigh|max|ultracode|auto]` gained the `ultracode` level in Claude Code v2.1.203 (combines `xhigh` reasoning with automatic workflow orchestration; like `max`, it's a session-only option). Copilot CLI has no `ultracode` level — `cpc` maps the `--effort`/`--reasoning-effort ultracode` flag to `max` with a warning.

Note: `/settings [show|[KEY VALUE]|reset KEY]` opens the Copilot CLI settings dialog, sets a setting inline with a `KEY VALUE` pair, or resets a setting to its default. This is the closest equivalent to Claude Code's `/config [key=value]`.

Note: `/security-review [PROMPT]` is now a **direct match**: both Claude Code and Copilot CLI run a security review agent that analyzes pending changes for vulnerabilities. The `cpc` wrapper passes in-session slash commands through unchanged.

Note: `/subagents` (alias `/agents`) configures the default and per-agent subagent models in Copilot CLI. It's a richer counterpart to Claude Code's `/agents` than `/agent` (which only browses agents).

Note: `/after [DELAY PROMPT]` and `/every [INTERVAL PROMPT]` are Copilot CLI-only experimental commands that schedule a one-shot or recurring prompt, skill, or schedulable slash command for the current session (e.g. `/after 1h /chronicle standup`, `/every 1d run tests`); no arguments opens the schedule manager. Claude Code's `/schedule` (`/routines`) only partially overlaps — there is no exact equivalent.

Note: `/extensions` (alias `/extension`) `[manage|mode]` manages Copilot CLI extensions. Claude Code's `/plugin` is conceptually similar but refers to a distinct plugin system, so there is no exact mapping.

Note: `/app` launches the GitHub Copilot desktop app (or shows the download URL if it isn't installed). No Claude Code equivalent.

Note: `/mcp` gained a `search` subcommand in Copilot CLI (`/mcp [show|add|edit|delete|disable|enable|auth|reload|search] [SERVER-NAME]`) for searching available MCP servers.

Note: `/refine TEXT` is a Copilot CLI-only command that rewrites a roughly composed prompt into a clear one so you can review it before sending. Run it with no arguments (via `Ctrl+X` then `/refine`) to clean up whatever is already in the input box — particularly useful for prompts entered by speaking. Claude Code has no equivalent, and because it is an in-session slash command the `cpc` wrapper can't translate it.

## Keyboard Shortcuts

### Global
| Shortcut | Purpose |
|---|---|
| `# NUMBER` | Include a GitHub issue or pull request in the context |
| `$` | Type a lone `$` on an empty prompt to hand the terminal over to a real interactive shell (`$SHELL` on Unix, `%COMSPEC%` on Windows) rooted at the session's working directory. Unlike `!` shell mode it suspends the CLI UI entirely, so job control, full-screen apps, tab completion, and colors work natively; exit the shell (`exit`, or `Ctrl+D` on Unix) to return. Only for local, trusted, idle sessions on a real TTY. **Disabled by default** — enable it with the `shellShortcut` setting; can be disabled in enterprise managed settings |
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
| `COPILOT_SUBAGENT_MAX_DEPTH` | `4` | `1`–`128` | Maximum subagent nesting depth |
| `COPILOT_SUBAGENT_MAX_CONCURRENT` | `32` | `1`–`256` | Maximum concurrent subagents across the session tree |
| `COPILOT_GH_HOST` | — | — | GitHub hostname for Copilot CLI only, overriding `GH_HOST`. Use when `GH_HOST` targets GHES but Copilot needs to authenticate against GitHub.com or GHEC |
| `COPILOT_PROMPT_FRAME` | — | `0` / `1` | Set to `1` to enable the decorative UI frame around the input prompt, or `0` to disable it. Overrides the `PROMPT_FRAME` experimental feature flag |
| `GITHUB_COPILOT_PROMPT_MODE_EXTENSIONS` | `false` | `true` / `false` | Set to `true` to load project extensions and allow extension management tools in prompt mode (`-p`). Disabled by default for security |
| `GITHUB_COPILOT_PROMPT_MODE_REPO_HOOKS` | `false` | `true` / `false` | Set to `true` to load repository hooks in prompt mode (`-p`). Disabled by default for security |
| `GITHUB_COPILOT_PROMPT_MODE_WORKSPACE_MCP` | `false` | `true` / `false` | Set to `true` to load workspace MCP sources in prompt mode (`-p`). Disabled by default for security |
| `COPILOT_COMPUTER_USE_LINUX` | — | set / unset | Set to opt in to the `computer-use` MCP server on supported Linux distributions (not available on Alpine Linux / musl libc) |
| `COPILOT_ENABLE_HTTP2` | — | `1` / `true` | Set to `1` or `true` to opt into HTTP/2 transport. HTTP/1.1 is the default |

## Supported Models

The `--model` / `/model` value is passed straight through in both CLIs. Copilot CLI currently supports:

| Model | Notes |
|---|---|
| `claude-sonnet-4.6` | |
| `claude-haiku-4.5` | |
| `gpt-5.4` | |
| `gpt-5.3-codex` | |
| `gemini-3.1-pro-preview` | |
| `gemini-3.5-flash` | |
| `mai-code-1-flash` | Fast, adaptive coding tasks |

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
