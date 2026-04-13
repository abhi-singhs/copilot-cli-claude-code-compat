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
| `claude auth logout` | `copilot logout` | ✅ Mapped |
| `claude auth status` | `copilot version` | ⚠️ Partial |
| `claude plugin ...` | `copilot plugin ...` | ✅ Same |
| `claude agents` | `/agent` (interactive) | ⚠️ Interactive only |
| `claude mcp` | `/mcp` (interactive) | ⚠️ Interactive only |
| `claude auto-mode defaults` | — | ❌ Not available |
| `claude auto-mode config` | — | ❌ Not available |
| `claude remote-control` | — | ❌ Not available |

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
| `--enable-auto-mode` | `--experimental` | |
| `--debug` | `--log-level=debug` | Category filtering not supported |
| `--verbose` | `--log-level=info` | |
| `--debug-file <path>` | `--log-dir=<dir> --log-level=debug` | |
| `--remote "task"` | `/delegate task` (interactive) | Cloud delegation |
| `--teleport` | `--resume` | Resume cloud session locally |

### Unsupported (no Copilot equivalent)
| Claude Code | Suggested Alternative |
|---|---|
| `--system-prompt` | Use `.github/copilot-instructions.md` files |
| `--append-system-prompt` | Use `.github/copilot-instructions.md` files |
| `--bare` | Try `--no-custom-instructions` |
| `--chrome` | Copilot has built-in Playwright MCP |
| `--worktree` / `-w` | Use `git worktree` manually |
| `--name` / `-n` | Use `/rename` in interactive mode |
| `--max-budget-usd` | Not available |
| `--from-pr` | Reference PR URL in your prompt |
| `--fork-session` | Not available |
| `--fallback-model` | Not available |
| `--json-schema` | Use `--output-format=json` |
| `--effort` | Set `effortLevel` in `~/.copilot/config.json` |
| `--tmux` | Not available |
| `--remote-control-session-name-prefix` | Not available (Remote Control is not supported) |

## Slash Command Mapping

### Direct Matches (same in both CLIs)
`/add-dir`, `/clear`, `/compact`, `/context`, `/diff`, `/exit`, `/feedback`,
`/help`, `/ide`, `/init`, `/login`, `/logout`, `/mcp`, `/model`, `/plan`,
`/plugin`, `/rename`, `/resume`, `/review`, `/skills`, `/terminal-setup`,
`/theme`, `/usage`, `/quit`

### Renamed Commands
| Claude Code | Copilot CLI |
|---|---|
| `/agents` | `/agent` |
| `/cost` | `/usage` |
| `/export` | `/share` |
| `/permissions` | `/allow-all` and `/reset-allowed-tools` |
| `/rewind` / `/checkpoint` | `/session checkpoints` |

### Claude Code Only (no Copilot equivalent)
`/autofix-pr`, `/btw`, `/chrome`, `/color`, `/config`, `/copy`, `/desktop`, `/doctor`,
`/effort`, `/fast`, `/hooks`, `/memory`, `/release-notes`,
`/sandbox`, `/security-review`, `/setup-bedrock`, `/stats`, `/voice`, `/web-setup`

### Copilot CLI Only (not in Claude Code)
`/fleet`, `/list-dirs`, `/cwd` (`/cd`), `/lsp`, `/user`,
`/session`, `/experimental`

Note: `/delegate` is the Copilot equivalent of Claude Code's `--remote` flag.

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
