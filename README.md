# Claude Code Developer Course

> **Learn Claude Code IN Claude Code** — An interactive course where developers learn by building real configurations for their own repositories.

## What is This?

This is a 5-seminar interactive course that teaches software developers how to use Claude Code effectively. Unlike traditional tutorials:

- 📁 **You work on YOUR repository** — not toy examples
- 🤖 **Claude teaches you inside Claude Code** — meta-learning!
- ✅ **Validators check your work** — know when you're done
- 🎯 **Role-specific guidance** — frontend, backend, QA, DevOps, data

## Quick Start

1. **Clone this course** to your machine:
   ```bash
   git clone https://github.com/your-org/claude-code-dev-course.git
   cd claude-code-dev-course
   ```

2. **Start Claude Code**:
   ```bash
   claude
   ```

3. **Begin the course**:
   ```
   /start-1
   ```

That's it! Claude will guide you from there.

## Course Structure

| Module | Topic | Duration | What You'll Build |
|--------|-------|----------|-------------------|
| 1 | **Foundations & Commands** | 120 min | CLAUDE.md, custom slash command |
| 2 | **Skills** | 90 min | Custom skills in `.claude/skills/` |
| 3 | **Extensions** | 120 min | Hooks, MCP config, advanced commands |
| 4 | **Agents** | 120 min | Multi-agent patterns, git worktrees |
| 5 | **Workflows** | 120 min | GitHub Actions, automation scripts |

**Total time**: ~9-10 hours (at your own pace)

## Commands

| Command | Description |
|---------|-------------|
| `/start-1` to `/start-5` | Begin a specific module |
| `/status` | See your progress |
| `/validate` | Check if current module is complete |
| `/hint` | Get help with current task |

## Who Is This For?

- **Frontend developers** — React, Vue, Angular, etc.
- **Backend developers** — APIs, databases, services
- **QA engineers** — Test automation, E2E, coverage
- **DevOps engineers** — Infrastructure, CI/CD, cloud
- **Data engineers** — Pipelines, analytics, ML

The course adapts examples and guidance to your role.

## Prerequisites

- Basic familiarity with Claude/ChatGPT (you've used AI chat tools)
- A GitHub repository you can work on (real project preferred)
- Claude Code installed (the course will verify this)
- ~10 hours over 1-4 weeks

## What You'll Have When Done

Your repository will be equipped with:

```
your-repo/
├── CLAUDE.md                    # Project context and memory
├── .claude/
│   ├── settings.json            # Hook configurations
│   ├── mcp.json                 # External tool integrations
│   ├── skills/                  # Custom team standards and procedures
│   └── commands/                # Custom slash commands
├── .github/workflows/
│   └── claude-*.yml             # CI/CD with Claude reviews
└── scripts/
    └── claude-*.sh              # Headless automation
```

Plus the knowledge to use all of it effectively!

## Course Philosophy

1. **Do real work** — Every task applies to your actual project
2. **Build lasting value** — Everything you create, you keep and use
3. **Learn by doing** — Concepts taught through immediate application
4. **Validate progress** — Know definitively when you've mastered each skill

## Course Architecture

Each module has a detailed teaching script in `lesson-modules/[module]/SCRIPT.md` containing:

- **Chapters**: Sequential learning content
- **Verification blocks**: YAML criteria for checking completion
- **Checklists**: Task lists after each subtheme
- **Task keys**: Mapping to progress.json for tracking

This structure allows the course-tutor skill to:
- Verify what was done
- Explain content systematically
- Track granular progress

## Adapting This Course

This course is open source. You can:

- **Fork it** for your team with company-specific examples
- **Add modules** for advanced topics
- **Customize guidance** for your tech stack
- **Share improvements** via pull requests

## Acknowledgments

Inspired by [Claude Code for Product Managers](https://github.com/carlvellotti/claude-code-pm-course) by Carl Vellotti.

## License

MIT License — use freely, attribution appreciated.
