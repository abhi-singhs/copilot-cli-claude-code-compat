# setup-claude-copilot-compat.ps1
#
# One-time setup to share agents, skills, and commands between
# Claude Code (~/.claude/) and GitHub Copilot CLI (~/.copilot/).
#
# Safe to run multiple times (idempotent).
# Does NOT touch: settings/config files, MCP configs, project memory.

#Requires -Version 5.1
Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'

$ClaudeHome = if ($env:CLAUDE_HOME) { $env:CLAUDE_HOME } else { Join-Path $HOME '.claude' }
$CopilotHome = if ($env:COPILOT_HOME) { $env:COPILOT_HOME } else { Join-Path $HOME '.copilot' }
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition

# ---------------------------------------------------------------------------
# Test-Symlink — check if a path is a symlink (junction or symbolic link)
# ---------------------------------------------------------------------------
function Test-Symlink {
    param([string]$Path)
    if (-not (Test-Path $Path)) { return $false }
    $item = Get-Item $Path -Force
    return ($item.Attributes -band [System.IO.FileAttributes]::ReparsePoint) -ne 0
}

# ---------------------------------------------------------------------------
# Get-SymlinkTarget — resolve the target of a symlink
# ---------------------------------------------------------------------------
function Get-SymlinkTarget {
    param([string]$Path)
    $item = Get-Item $Path -Force
    return $item.Target
}

# ---------------------------------------------------------------------------
# Sync-Directory — bidirectional symlink for a named subdirectory
# ---------------------------------------------------------------------------
function Sync-Directory {
    param([string]$DirName)

    $claudeDir = Join-Path $ClaudeHome $DirName
    $copilotDir = Join-Path $CopilotHome $DirName

    # Already symlinked (Copilot -> Claude)
    if (Test-Symlink $copilotDir) {
        $target = Get-SymlinkTarget $copilotDir
        if ($target -eq $claudeDir) {
            Write-Host "[OK] ${DirName}: $copilotDir -> $claudeDir (already linked)"
            return
        }
    }

    # Already symlinked (Claude -> Copilot)
    if (Test-Symlink $claudeDir) {
        $target = Get-SymlinkTarget $claudeDir
        if ($target -eq $copilotDir) {
            Write-Host "[OK] ${DirName}: $claudeDir -> $copilotDir (already linked)"
            return
        }
    }

    # Both exist as real directories — don't overwrite
    if ((Test-Path $claudeDir -PathType Container) -and -not (Test-Symlink $claudeDir) -and
        (Test-Path $copilotDir -PathType Container) -and -not (Test-Symlink $copilotDir)) {
        Write-Warning "${DirName}: Both $claudeDir and $copilotDir exist as real directories."
        Write-Warning "  Merge them manually, then remove one and re-run this script."
        return
    }

    # Only Claude dir exists -> symlink Copilot to it
    if ((Test-Path $claudeDir -PathType Container) -and -not (Test-Symlink $claudeDir)) {
        $parentDir = Split-Path $copilotDir -Parent
        if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
        New-Item -ItemType SymbolicLink -Path $copilotDir -Target $claudeDir | Out-Null
        Write-Host "[OK] ${DirName}: Created symlink $copilotDir -> $claudeDir"
        return
    }

    # Only Copilot dir exists -> symlink Claude to it
    if ((Test-Path $copilotDir -PathType Container) -and -not (Test-Symlink $copilotDir)) {
        $parentDir = Split-Path $claudeDir -Parent
        if (-not (Test-Path $parentDir)) { New-Item -ItemType Directory -Path $parentDir -Force | Out-Null }
        New-Item -ItemType SymbolicLink -Path $claudeDir -Target $copilotDir | Out-Null
        Write-Host "[OK] ${DirName}: Created symlink $claudeDir -> $copilotDir"
        return
    }

    Write-Host "[ ] ${DirName}: Neither $claudeDir nor $copilotDir exists. Skipping."
}

# ---------------------------------------------------------------------------
# Main
# ---------------------------------------------------------------------------

Write-Host "=== Claude Code <-> Copilot CLI Config Sync ==="
Write-Host ""
Write-Host "Claude home:  $ClaudeHome"
Write-Host "Copilot home: $CopilotHome"
Write-Host ""

# Sync agents and skills directories
Sync-Directory 'agents'
Sync-Directory 'skills'

Write-Host ""
Write-Host "Note: Copilot CLI natively reads .claude/commands/ and AGENTS.md -- no sync needed."
Write-Host ""

# ---------------------------------------------------------------------------
# Per-project CLAUDE.md symlink (optional, interactive)
# ---------------------------------------------------------------------------
$claudeMd = Join-Path $PWD 'CLAUDE.md'
$copilotInstructions = Join-Path $PWD '.github' 'copilot-instructions.md'

if ((Test-Path $claudeMd) -and -not (Test-Path $copilotInstructions)) {
    Write-Host "Found CLAUDE.md in the current directory."
    $yn = Read-Host "  Symlink it to .github/copilot-instructions.md? [y/N]"
    if ($yn -match '^[Yy]') {
        $githubDir = Join-Path $PWD '.github'
        if (-not (Test-Path $githubDir)) { New-Item -ItemType Directory -Path $githubDir -Force | Out-Null }
        New-Item -ItemType SymbolicLink -Path $copilotInstructions -Target $claudeMd | Out-Null
        Write-Host "  [OK] Symlinked .github/copilot-instructions.md -> CLAUDE.md"
    } else {
        Write-Host "  [ ] Skipped."
    }
    Write-Host ""
} elseif (Test-Path $copilotInstructions) {
    Write-Host "[ ] .github/copilot-instructions.md already exists. Skipping CLAUDE.md symlink."
    Write-Host ""
}

# ---------------------------------------------------------------------------
# Install claude-compat Copilot CLI plugin
# ---------------------------------------------------------------------------
if (Get-Command copilot -ErrorAction SilentlyContinue) {
    $pluginDir = $ScriptDir
    $pluginJson = Join-Path $pluginDir 'plugin.json'
    if (Test-Path $pluginJson) {
        Write-Host "Installing claude-compat plugin via Copilot CLI..."
        & copilot plugin install $pluginDir 2>&1 | ForEach-Object { "  $_" }
        Write-Host "[OK] Plugin installed. Includes /claude-help skill and sessionStart hook."
        Write-Host "  To verify: copilot plugin list"
    } else {
        Write-Warning "plugin.json not found at $pluginDir -- skipping plugin installation."
    }
} else {
    Write-Warning "'copilot' not found on PATH. Install Copilot CLI first, then re-run."
    Write-Host "  Alternatively, install the plugin manually:"
    Write-Host "    copilot plugin install $ScriptDir"
}

Write-Host ""
Write-Host "=== Setup complete ==="
Write-Host ""
Write-Host "What was NOT synced (different formats -- manual migration needed):"
Write-Host "  - Settings:   ~/.claude/settings.json != ~/.copilot/config.json"
Write-Host "  - MCP config: ~/.claude/ MCP != ~/.copilot/mcp-config.json"
Write-Host "  - Memory:     ~/.claude/projects/ (Claude-specific, no Copilot equivalent)"
