# Changelog

All notable changes to the Claude Code Developer Course are documented here.

Format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/). Versioning follows [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.1.0] - 2026-03-25

### Added
- **Teaching modes**: 3 selectable learning styles — Sensei (strict, never does work for you), Coach (balanced, default), Copilot (hands-on, demonstrates alongside you)
- Teaching mode selection during first-time course setup
- Mode-conditional behavior in ACTION phase, hint escalation, and "stuck" handling
- "Never skip failed tasks" rule in teaching methodology
- Command restart requirement note (commands load at session start)
- Statusline fallback for unsupported environments
- CLAUDE.md file reference loading clarity (what auto-loads vs on-demand)
- Official `hook-development` skill reference from Anthropic's plugin-dev plugin
- Prompt-based hooks recommended over command hooks
- Course website (Astro + Starlight) with CLI terminal theme
- Changelog page on website

### Changed
- Replaced `.claudeignore` (doesn't exist) with `permissions.deny` in `.claude/settings.json` — the official mechanism per [Claude Code docs](https://code.claude.com/docs/en/permissions)
- Fixed `/clear` task flow to prevent recursion (explicit save + simple confirmation after)

### Fixed
- Hook matcher format: confirmed as **string regex** (`"matcher": "Write|Edit"`) per [official Anthropic repo](https://github.com/anthropics/claude-code/blob/main/plugins/plugin-dev/skills/hook-development/SKILL.md) (18 examples, all strings)
- HTTP hook timeout default: 600s → **30s** (official default)
- `$CLAUDE_SESSION_ID` is not an env var — session ID comes via stdin JSON
- Added 4 missing hook events: StopFailure, PostCompact, Elicitation, ElicitationResult (22 total)
- Added missing handler fields: `timeout`, `statusMessage`, `async`
- Added missing stdin JSON fields: `transcript_path`, `permission_mode`
- Fixed `-p` / `--prompt` flag documentation (was incorrectly shown as `--print`)

## [1.0.2] - 2026-03-18

### Fixed
- Reverted incorrect object matcher format (`"matcher": {"tools": ["WriteTool"]}`) back to string format
- Removed all `BashTool`/`WriteTool`/`EditTool` references (correct names: `Bash`, `Write`, `Edit`)

## [1.0.1] - 2026-03-18

### Fixed
- HTTP hook timeout default corrected (600s → 30s)
- Added 4 missing hook events (StopFailure, PostCompact, Elicitation, ElicitationResult)
- Added handler optional fields documentation (timeout, statusMessage, async)
- Added missing stdin JSON fields (transcript_path, permission_mode)
- Added matcher format variants section (later reverted in v1.0.2)

## [1.0.0] - 2026-03-17

### Added
- Complete interactive course with all 5 modules
- SCRIPT.md rewritten for Modules 3-5 with interactive teaching flow (PRESENT → CHECKPOINT → ACTION → VERIFY)
- KNOWLEDGE.md companion files for Modules 3, 4, 5 (~3,300 lines of deep dive content)
- cclogviewer MCP session-based personalization (discovers student's repeated workflows)
- Student submission (`/cc-course:submit`) and AI-powered review (`/cc-course:review`)
- GitHub Pages deploy workflow

### Fixed
- Hook configuration to correct 3-level format (event → matcher → handler array)
- MCP config location to `.mcp.json` (project root, not `.claude/mcp.json`)
- Removed `/install-github-app` (not a real command)

[1.1.0]: https://github.com/SeleznovIvan/claude-code-course-plugin/compare/v1.0.2...v1.1.0
[1.0.2]: https://github.com/SeleznovIvan/claude-code-course-plugin/compare/v1.0.1...v1.0.2
[1.0.1]: https://github.com/SeleznovIvan/claude-code-course-plugin/compare/v1.0.0...v1.0.1
[1.0.0]: https://github.com/SeleznovIvan/claude-code-course-plugin/releases/tag/v1.0.0
