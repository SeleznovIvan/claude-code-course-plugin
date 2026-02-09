# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

# Claude Code Developer Course

> **Learn Claude Code by DOING Claude Code** — An interactive course where you build real Claude Code configurations for your own repository.

## Course Overview

This is a 5-seminar interactive course that teaches software developers how to use Claude Code effectively. Unlike traditional tutorials, you'll work on YOUR OWN GitHub repository throughout the course, building real configurations you'll actually use.

## How This Course Works

1. **Start any module** by typing `/start-1` through `/start-5`
2. **Claude guides you** through concepts and hands-on tasks
3. **You implement** everything in your own repository
4. **Validators check** your work automatically
5. **Progress is tracked** in `progress.json`

## Quick Start

```
/start-1    # Begin with Foundations & Commands
/status     # Check your progress
/validate   # Verify current module completion
/hint       # Get help with current task
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
claude-code-dev-course/
├── CLAUDE.md                    # You are here
├── progress.json                # Tracks completion state
├── curriculum/                  # Original curriculum document
├── .claude/
│   ├── commands/                # Slash commands (/start-1, etc.)
│   └── skills/
│       └── course-tutor/        # The teaching skill
└── lesson-modules/
    ├── 1-foundations-and-commands/
    │   └── SCRIPT.md            # Teaching script with verification
    ├── 2-skills/
    │   └── SCRIPT.md
    ├── 3-extensions/
    │   └── SCRIPT.md
    ├── 4-agents/
    │   └── SCRIPT.md
    └── 5-workflows/
        └── SCRIPT.md
```

## Getting Help

- `/hint` — Get contextual help for your current task
- `/status` — See your overall progress
- `/validate` — Check if current module is complete

## Architecture

This course uses Claude Code's extensibility features:

- **Skills** (`.claude/skills/course-tutor/SKILL.md`): Defines the tutor persona and teaching methodology
- **Commands** (`.claude/commands/*.md`): Slash commands for `/start-1` through `/start-5`, `/status`, `/validate`, `/hint`
- **Progress tracking** (`progress.json`): Persistent state across sessions
- **Lesson Scripts** (`lesson-modules/*/SCRIPT.md`): Detailed teaching content with verification criteria

The course teaches learners to build these same features in their own repositories.
