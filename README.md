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
claude plugin marketplace add https://github.com/SeleznovIvan/claude-code-education
claude plugin install cc-course@claude-code-education
```

### Option 2: Manual Installation

```bash
git clone https://github.com/SeleznovIvan/claude-code-course-plugin.git ~/.claude/plugins/cc-course
```

### Option 3: Development Mode

```bash
git clone https://github.com/SeleznovIvan/claude-code-course-plugin.git
claude --plugin-dir ./claude-code-course-plugin
```

## Post-Installation Setup

After installing the plugin, run the setup command to install the required MCP server:

```
/cc-course:setup
```

This will automatically download and install the `cclogviewer-mcp` binary needed for session tracking.

### Manual MCP Installation

If the automatic setup fails, you can install manually:

```bash
# Option 1: Download pre-built binary (no Go required)
curl -L https://github.com/SeleznovIvan/cclogviewer/releases/latest/download/cclogviewer-mcp-darwin-arm64 -o ~/.local/bin/cclogviewer-mcp
chmod +x ~/.local/bin/cclogviewer-mcp

# Option 2: Install via Go (requires Go 1.21+)
go install github.com/SeleznovIvan/cclogviewer/cmd/cclogviewer-mcp@latest

# Then add to Claude Code
claude mcp add cclogviewer cclogviewer-mcp
```

Available binaries:
- `cclogviewer-mcp-darwin-arm64` (Mac Apple Silicon)
- `cclogviewer-mcp-darwin-amd64` (Mac Intel)
- `cclogviewer-mcp-linux-amd64` (Linux x64)
- `cclogviewer-mcp-linux-arm64` (Linux ARM)
- `cclogviewer-mcp-windows-amd64.exe` (Windows)

See all releases: https://github.com/SeleznovIvan/cclogviewer/releases

## Getting Started

Complete these steps to start the course:

```bash
# 1. Add the marketplace and install the plugin
claude plugin marketplace add https://github.com/SeleznovIvan/claude-code-education
claude plugin install cc-course@claude-code-education

# 2. Start Claude Code in your project directory
cd /path/to/your/repo
claude

# 3. Install the MCP server (one-time setup)
/cc-course:setup

# 4. Start the course!
/cc-course:start 1
```

That's it! Claude will guide you from there.

## Commands

| Command | Description |
|---------|-------------|
| `/cc-course:setup` | Install the required MCP server (run once after installation) |
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

The cclogviewer MCP is configured via `.mcp.json`:

```json
{
  "mcpServers": {
    "cclogviewer": {
      "command": "cclogviewer-mcp"
    }
  }
}
```

**Note:** The `cclogviewer-mcp` binary must be installed and in your PATH. Run `/cc-course:setup` to install it automatically.

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

1. Run the setup command:
   ```
   /cc-course:setup
   ```

2. Or install manually:
   ```bash
   # Download pre-built binary
   curl -L https://github.com/SeleznovIvan/cclogviewer/releases/latest/download/cclogviewer-mcp-darwin-arm64 -o ~/.local/bin/cclogviewer-mcp
   chmod +x ~/.local/bin/cclogviewer-mcp

   # Add to Claude Code
   claude mcp add cclogviewer cclogviewer-mcp
   ```

3. Verify the binary works:
   ```bash
   which cclogviewer-mcp
   echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | cclogviewer-mcp
   ```

4. Check MCP is configured in Claude:
   ```bash
   claude mcp list
   ```

5. **Advanced fallback** (if download and go install both fail):
   ```bash
   # Initialize submodule and build from source (requires Go 1.21+)
   cd ~/.claude/plugins/cc-course
   git submodule update --init --recursive
   cd mcp/cclogviewer
   make build-mcp
   cp bin/cclogviewer-mcp ~/.local/bin/
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
