# Claude Code Developer Course Plugin

> **Learn Claude Code by DOING Claude Code** — An interactive course where developers learn by building real configurations for their own repositories.

## What is This?

This is a Claude Code plugin that provides a 5-module interactive course teaching software developers how to use Claude Code effectively. Unlike traditional tutorials:

- **You work on YOUR repository** — not toy examples
- **Claude teaches you inside Claude Code** — meta-learning!
- **Validators check your work** — know when you're done
- **Role-specific guidance** — frontend, backend, QA, DevOps, data

## Installation

### Option 1: Plugin Install (Recommended)

```bash
# Install the plugin
claude plugin install github:SeleznovIvan/claude-code-course-plugin

# Initialize the bundled MCP server
cd ~/.claude/plugins/cc-course
git submodule update --init --recursive
```

### Option 2: Manual Installation

```bash
# Clone with submodules to your plugins directory
git clone --recurse-submodules https://github.com/SeleznovIvan/claude-code-course-plugin.git ~/.claude/plugins/cc-course
```

### Option 3: Development Mode

```bash
# Clone the repository
git clone --recurse-submodules https://github.com/SeleznovIvan/claude-code-course-plugin.git

# Run Claude Code with the plugin
claude --plugin-dir ./claude-code-course-plugin
```

## Quick Start

Once installed, start Claude Code and run:

```
/cc-course:start 1
```

That's it! Claude will guide you from there.

## Commands

| Command | Description |
|---------|-------------|
| `/cc-course:start 1` to `/cc-course:start 5` | Begin a specific module |
| `/cc-course:status` | See your progress |
| `/cc-course:validate` | Check if current module is complete |
| `/cc-course:hint` | Get help with current task |

## Course Structure

| Module | Topic | Duration | What You'll Build |
|--------|-------|----------|-------------------|
| 1 | **Foundations & Commands** | 120 min | CLAUDE.md, custom slash command |
| 2 | **Skills** | 90 min | Custom skills in `.claude/skills/` |
| 3 | **Extensions** | 120 min | Hooks, MCP config, advanced commands |
| 4 | **Agents** | 120 min | Multi-agent patterns, git worktrees |
| 5 | **Workflows** | 120 min | GitHub Actions, automation scripts |

**Total time**: ~9-10 hours (at your own pace)

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

## Bundled MCP Server

This plugin bundles the **cclogviewer** MCP server for session tracking and analysis during the course:

- Track learning sessions per module
- Export session logs on module completion
- Generate visual HTML reports of your progress
- Search and analyze your Claude Code usage

### MCP Tools Available

- `mcp__cclogviewer__list_sessions` — List sessions for a project
- `mcp__cclogviewer__get_session_summary` — Get session statistics
- `mcp__cclogviewer__get_session_logs` — Get full session logs
- `mcp__cclogviewer__get_session_timeline` — Get session timeline
- `mcp__cclogviewer__get_session_errors` — Get session errors
- `mcp__cclogviewer__generate_html` — Generate visual HTML report
- `mcp__cclogviewer__search_logs` — Search across sessions

## Configuration

### Plugin Manifest

The plugin is configured via `.claude-plugin/plugin.json`:

```json
{
  "name": "cc-course",
  "version": "1.0.0",
  "description": "Interactive Claude Code developer course",
  "skills": "./skills/",
  "mcpServers": "./.mcp.json"
}
```

### MCP Configuration

The bundled cclogviewer MCP is configured via `.mcp.json`:

```json
{
  "mcpServers": {
    "cclogviewer": {
      "command": "npx",
      "args": ["tsx", "${CLAUDE_PLUGIN_ROOT}/mcp/cclogviewer/src/index.ts"],
      "env": {}
    }
  }
}
```

## Troubleshooting

### Plugin not loading

1. Verify the plugin is installed:
   ```bash
   ls ~/.claude/plugins/cc-course
   ```

2. Check Claude Code recognizes it:
   ```bash
   claude --debug
   ```
   Look for plugin loading messages.

### MCP server not starting

1. Ensure submodules are initialized:
   ```bash
   cd ~/.claude/plugins/cc-course
   git submodule update --init --recursive
   ```

2. Verify the cclogviewer source exists:
   ```bash
   ls ~/.claude/plugins/cc-course/mcp/cclogviewer/src/index.ts
   ```

3. Check if `npx tsx` works:
   ```bash
   npx tsx --version
   ```

### Commands not found

If `/cc-course:*` commands don't appear:

1. Restart Claude Code
2. Verify skills directory exists:
   ```bash
   ls ~/.claude/plugins/cc-course/skills/
   ```

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

This structure allows Claude to:
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
