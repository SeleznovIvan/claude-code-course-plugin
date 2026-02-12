# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Claude Code Developer Course Plugin

> **Learn Claude Code by DOING Claude Code** — An interactive course where you build real Claude Code configurations for your own repository.

## Plugin Overview

This is a Claude Code plugin that provides a 5-module interactive course teaching software developers how to use Claude Code effectively. Unlike traditional tutorials, you'll work on YOUR OWN GitHub repository throughout the course, building real configurations you'll actually use.

## Installation

### Via Plugin Install (Recommended)

```bash
claude plugin install github:SeleznovIvan/claude-code-course-plugin
```

### Manual Installation

```bash
git clone https://github.com/SeleznovIvan/claude-code-course-plugin.git ~/.claude/plugins/cc-course
```

### Development Mode

```bash
claude --plugin-dir /path/to/cc-course
```

## How This Course Works

1. **Start any module** by typing `/cc-course:start 1` through `/cc-course:start 5`
2. **Claude guides you** through concepts and hands-on tasks
3. **You implement** everything in your own repository
4. **Validators check** your work automatically
5. **Progress is tracked** in `progress.json`

## Quick Start

```
/cc-course:setup      # Install MCP server (one-time setup)
/cc-course:start 1    # Begin with Foundations & Commands
/cc-course:status     # Check your progress
/cc-course:validate   # Verify current module completion
/cc-course:hint       # Get help with current task
```

## Module Overview

| Module | Topic | Duration | You'll Create |
|--------|-------|----------|---------------|
| 1 | Foundations & Commands | 120 min | CLAUDE.md, custom command |
| 2 | Skills | 90 min | Custom skills in `.claude/skills/` |
| 3 | Extensions | 120 min | Hooks, MCP config, advanced commands |
| 4 | Agents | 120 min | Multi-agent workflows with git worktrees |
| 5 | Workflows | 120 min | GitHub Actions, automation scripts |

**Total time**: ~9-10 hours (at your own pace)

## Your Role

When you start the course, tell Claude your role so guidance can be customized:

- **Frontend** — React, Vue, Angular, CSS, component libraries
- **Backend** — APIs, databases, microservices, server-side
- **QA/Testing** — Test automation, E2E, integration testing
- **DevOps** — Infrastructure, CI/CD, containers, cloud
- **Data** — Pipelines, analytics, ML, data engineering
- **Fullstack** — Mix of frontend and backend

## Course Philosophy

- **Do real work**: Every task uses your actual repository
- **Build lasting value**: Everything you create, you keep and use
- **Learn by doing**: Concepts are taught through immediate application
- **Role-agnostic**: Guidance adapts to your specific domain

## Important Notes for Claude

When teaching this course:

1. **Always check progress.json** before starting a module — this tracks student info, module status, and task completion
2. **Detect the user's role** from their repository or ask them
3. **Adapt examples** to their tech stack and domain
4. **Run validators** before marking modules complete — use the validation checks defined in each module's SCRIPT.md
5. **Be encouraging** but also verify actual completion
6. **Update progress.json** after each completed task — mark tasks as `true`, update module status, and unlock next module when complete
7. **Reference lesson-modules/** for detailed teaching scripts — each chapter has verification criteria and checklists

### State Management

The `progress.json` file tracks:
- `student`: name, role, repository path, start time
- `modules`: status (`not_started`, `locked`, `unlocked`, `completed`) and task completion booleans
- `current_module` / `current_task`: active work context
- `graduation`: course completion state

### Validation Structure

Each seminar SCRIPT.md contains:
- **Chapter ID**: Unique identifier for the chapter
- **Verification blocks**: YAML with automated or manual checks
- **Checklists**: Task completion lists after each subtheme
- **task_key**: Maps to progress.json task fields

## File Structure

```
cc-course/                       # Plugin root
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest
├── skills/                      # Course commands
│   ├── start/SKILL.md           # → /cc-course:start
│   ├── hint/SKILL.md            # → /cc-course:hint
│   ├── status/SKILL.md          # → /cc-course:status
│   ├── validate/SKILL.md        # → /cc-course:validate
│   ├── teaching.md              # Shared teaching methodology
│   ├── validation.md            # Shared validation logic
│   ├── hints.md                 # Shared hint system
│   ├── status.md                # Shared dashboard rendering
│   └── progress-tracking.md     # Shared state management
├── mcp/
│   └── cclogviewer/             # Bundled MCP server (git submodule)
├── .mcp.json                    # MCP server configuration
├── lesson-modules/              # Course content
│   ├── 1-foundations-and-commands/
│   │   └── SCRIPT.md
│   ├── 2-skills/
│   │   └── SCRIPT.md
│   ├── 3-extensions/
│   │   └── SCRIPT.md
│   ├── 4-agents/
│   │   └── SCRIPT.md
│   └── 5-workflows/
│       └── SCRIPT.md
├── progress.json                # State tracking
├── CLAUDE.md                    # You are here
└── README.md                    # Installation & usage docs
```

## Bundled MCP Server

This plugin includes the **cclogviewer** MCP server for session tracking and analysis:

### Available Tools

- `mcp__cclogviewer__list_sessions` — List sessions for a project
- `mcp__cclogviewer__get_session_summary` — Get session statistics
- `mcp__cclogviewer__get_session_logs` — Get full session logs
- `mcp__cclogviewer__get_session_timeline` — Get session timeline
- `mcp__cclogviewer__get_session_errors` — Get session errors
- `mcp__cclogviewer__generate_html` — Generate visual HTML report
- `mcp__cclogviewer__search_logs` — Search across sessions

### Usage in Course

The cclogviewer MCP is used to:
- Track learning sessions per module
- Export session logs on module completion
- Generate visual reports of learning progress

## Getting Help

- `/cc-course:hint` — Get contextual help for your current task
- `/cc-course:status` — See your overall progress
- `/cc-course:validate` — Check if current module is complete

## Architecture

This course uses Claude Code's plugin system:

- **Plugin Manifest** (`.claude-plugin/plugin.json`): Defines plugin metadata, skills, and MCP config
- **Skills** (`skills/`): Subcommand skills using colon namespace (`/cc-course:start`, `/cc-course:hint`, etc.)
- **Shared Logic**: Common functionality extracted to markdown files
- **Bundled MCP** (`mcp/cclogviewer/`): Git submodule providing session tracking
- **Progress tracking** (`progress.json`): Persistent state across sessions
- **Lesson Scripts** (`lesson-modules/*/SCRIPT.md`): Detailed teaching content with verification criteria

The course teaches learners to build these same features in their own repositories.
