#!/usr/bin/env bash
# setup-claude-copilot-compat.sh
#
# One-time setup to share agents, skills, and commands between
# Claude Code (~/.claude/) and GitHub Copilot CLI (~/.copilot/).
#
# Safe to run multiple times (idempotent).
# Does NOT touch: settings/config files, MCP configs, project memory.

set -euo pipefail

CLAUDE_HOME="${CLAUDE_HOME:-$HOME/.claude}"
COPILOT_HOME="${COPILOT_HOME:-$HOME/.copilot}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

# ---------------------------------------------------------------------------
# sync_directory — bidirectional symlink for a named subdirectory
# ---------------------------------------------------------------------------
sync_directory() {
    local dir_name="$1"
    local claude_dir="$CLAUDE_HOME/$dir_name"
    local copilot_dir="$COPILOT_HOME/$dir_name"

    # Already symlinked (Copilot → Claude)
    if [[ -L "$copilot_dir" ]]; then
        local target
        target="$(readlink "$copilot_dir")"
        if [[ "$target" == "$claude_dir" ]]; then
            echo "✓ $dir_name: $copilot_dir → $claude_dir (already linked)"
            return
        fi
    fi

    # Already symlinked (Claude → Copilot)
    if [[ -L "$claude_dir" ]]; then
        local target
        target="$(readlink "$claude_dir")"
        if [[ "$target" == "$copilot_dir" ]]; then
            echo "✓ $dir_name: $claude_dir → $copilot_dir (already linked)"
            return
        fi
    fi

    # Both exist as real directories — don't overwrite
    if [[ -d "$claude_dir" ]] && [[ ! -L "$claude_dir" ]] && \
       [[ -d "$copilot_dir" ]] && [[ ! -L "$copilot_dir" ]]; then
        echo "⚠ $dir_name: Both $claude_dir and $copilot_dir exist as real directories."
        echo "  Merge them manually, then remove one and re-run this script."
        return
    fi

    # Only Claude dir exists → symlink Copilot to it
    if [[ -d "$claude_dir" ]] && [[ ! -L "$claude_dir" ]]; then
        mkdir -p "$(dirname "$copilot_dir")"
        ln -s "$claude_dir" "$copilot_dir"
        echo "✓ $dir_name: Created symlink $copilot_dir → $claude_dir"
        return
    fi

    # Only Copilot dir exists → symlink Claude to it
    if [[ -d "$copilot_dir" ]] && [[ ! -L "$copilot_dir" ]]; then
        mkdir -p "$(dirname "$claude_dir")"
        ln -s "$copilot_dir" "$claude_dir"
        echo "✓ $dir_name: Created symlink $claude_dir → $copilot_dir"
        return
    fi

    echo "· $dir_name: Neither $claude_dir nor $copilot_dir exists. Skipping."
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

echo "=== Claude Code ↔ Copilot CLI Config Sync ==="
echo ""
echo "Claude home:  $CLAUDE_HOME"
echo "Copilot home: $COPILOT_HOME"
echo ""

# Sync agents and skills directories
sync_directory "agents"
sync_directory "skills"

echo ""
echo "Note: Copilot CLI natively reads .claude/commands/ and AGENTS.md — no sync needed."
echo ""

# ---------------------------------------------------------------------------
# Per-project CLAUDE.md symlink (optional, interactive)
# ---------------------------------------------------------------------------
if [[ -f "./CLAUDE.md" ]] && [[ ! -f "./.github/copilot-instructions.md" ]]; then
    echo "Found CLAUDE.md in the current directory."
    read -rp "  Symlink it to .github/copilot-instructions.md? [y/N] " yn
    if [[ "$yn" =~ ^[Yy] ]]; then
        mkdir -p .github
        ln -s "$(pwd)/CLAUDE.md" ".github/copilot-instructions.md"
        echo "  ✓ Symlinked .github/copilot-instructions.md → CLAUDE.md"
    else
        echo "  · Skipped."
    fi
    echo ""
elif [[ -f "./.github/copilot-instructions.md" ]]; then
    echo "· .github/copilot-instructions.md already exists. Skipping CLAUDE.md symlink."
    echo ""
fi

# ---------------------------------------------------------------------------
# Install claude-compat Copilot CLI plugin
# ---------------------------------------------------------------------------
if command -v copilot &>/dev/null; then
    PLUGIN_DIR="$SCRIPT_DIR"
    if [[ -f "$PLUGIN_DIR/plugin.json" ]]; then
        echo "Installing claude-compat plugin via Copilot CLI..."
        copilot plugin install "$PLUGIN_DIR" 2>&1 | sed 's/^/  /'
        echo "✓ Plugin installed. Includes /claude-help skill and sessionStart hook."
        echo "  To verify: copilot plugin list"
    else
        echo "⚠ plugin.json not found at $PLUGIN_DIR — skipping plugin installation."
    fi
else
    echo "⚠ 'copilot' not found on PATH. Install Copilot CLI first, then re-run."
    echo "  Alternatively, install the plugin manually:"
    echo "    copilot plugin install $SCRIPT_DIR"
fi

echo ""
echo "=== Setup complete ==="
echo ""
echo "What was NOT synced (different formats — manual migration needed):"
echo "  • Settings:   ~/.claude/settings.json ≠ ~/.copilot/config.json"
echo "  • MCP config: ~/.claude/ MCP ≠ ~/.copilot/mcp-config.json"
echo "  • Memory:     ~/.claude/projects/ (Claude-specific, no Copilot equivalent)"
