# Seminar 3: Extensions

**Duration**: 120 minutes (80 min guided + 40 min implementation)

**Seminar ID**: `3-extensions`

**Prerequisites**: Completed Seminars 1-2 (CLAUDE.md, commands, and skills exist)

---

## Learning Objectives

By the end of this seminar, participants will:
- Create hooks for automating pre/post actions
- Configure MCP servers for external tool integration
- Build advanced custom commands
- Understand the extension ecosystem and possibilities

---

## Chapter 1: Understanding Hooks

**Chapter ID**: `3.1-understanding-hooks`

### Content

#### What Are Hooks?

Hooks are **event-driven automation triggers**. They run shell commands automatically when Claude performs certain actions.

#### Hook Events

| Event | Triggered When |
|-------|---------------|
| `PreToolUse` | Before Claude uses a tool (file write, command run) |
| `PostToolUse` | After Claude uses a tool |
| `Notification` | When Claude sends a notification |
| `Stop` | When Claude stops execution |

#### Use Cases

| Hook Type | Example Use Case |
|-----------|-----------------|
| PreToolUse (write_file) | Run formatter before saving |
| PostToolUse (write_file) | Run linter after saving |
| PostToolUse (bash) | Log all commands executed |
| Stop | Send notification when task completes |

### Verification

```yaml
chapter: 3.1-understanding-hooks
type: conceptual
verification: manual
question: "Can you explain when PreToolUse vs PostToolUse would trigger?"
```

### Checklist

- [ ] Understand what hooks are
- [ ] Know the four hook event types
- [ ] Can identify use cases for each event type

---

## Chapter 2: Creating Hooks

**Chapter ID**: `3.2-creating-hooks`

### Content

#### Hook Configuration Location

Hooks are configured in your Claude settings, not in separate files. You can configure them via:

1. **Global settings**: `~/.claude/settings.json`
2. **Project settings**: `.claude/settings.json`

#### Hook Configuration Structure

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "write_file",
        "pattern": "**/*.ts",
        "command": "npx prettier --write ${file}"
      }
    ],
    "PostToolUse": [
      {
        "matcher": "write_file",
        "pattern": "**/*.ts",
        "command": "npx eslint ${file}"
      }
    ]
  }
}
```

#### Hook Configuration Fields

| Field | Required | Description |
|-------|----------|-------------|
| `matcher` | Yes | Tool to match (`write_file`, `bash`, etc.) |
| `pattern` | No | Glob pattern for files (optional filter) |
| `command` | Yes | Shell command to run |

#### Available Variables

| Variable | Description |
|----------|-------------|
| `${file}` | Path to the file being written |
| `${tool}` | Name of the tool being used |
| `${input}` | Input provided to the tool |

#### Example: Auto-Format Hook

Create/update `.claude/settings.json`:

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "write_file",
        "pattern": "**/*.{ts,tsx,js,jsx}",
        "command": "npx prettier --write ${file}"
      }
    ]
  }
}
```

### Role-Specific Hook Ideas

| Role | Suggested Hook |
|------|---------------|
| Frontend | Auto-run Prettier/ESLint after file writes |
| Backend | Run type checker after Python/Go file changes |
| QA | Auto-run related tests after test file changes |
| DevOps | Validate YAML/JSON syntax on config changes |
| Data | Validate schema after model file changes |

### Verification

```yaml
chapter: 3.2-creating-hooks
type: automated
verification:
  checks:
    - file_exists: ".claude/settings.json"
      contains: "hooks"
      task_key: create_hook
```

### Checklist

- [ ] Created `.claude/settings.json` (or updated existing)
- [ ] Added at least one hook configuration
- [ ] Hook has correct matcher and command
- [ ] Tested that hook triggers correctly

---

## Chapter 3: Testing Hooks

**Chapter ID**: `3.3-testing-hooks`

### Content

#### How to Test Hooks

1. **Start Claude session**:
   ```bash
   claude
   ```

2. **Trigger the hooked action**:
   ```
   Create a new TypeScript file called test-hook.ts with a simple function
   ```

3. **Observe hook execution**:
   - Look for hook command output
   - Verify the file was processed (formatted, linted, etc.)

#### Debugging Hooks

If hooks don't trigger:

1. **Check matcher**: Does it match the tool Claude used?
2. **Check pattern**: Does the file path match the glob?
3. **Check command**: Is the command available in PATH?
4. **Check permissions**: Can the command execute?

#### Hook Execution Log

Claude shows when hooks run:
```
Running PostToolUse hook: npx prettier --write src/test-hook.ts
```

### Verification

```yaml
chapter: 3.3-testing-hooks
type: manual
verification:
  questions:
    - "Trigger your hook by having Claude write a file"
    - "Verify the hook command executed"
    - "Check that the file was processed correctly"
  task_key: test_hook
```

### Checklist

- [ ] Triggered hook by asking Claude to write a file
- [ ] Saw hook execution in Claude's output
- [ ] Verified the file was processed by the hook
- [ ] Hook works as expected

---

## Chapter 4: MCP (Model Context Protocol)

**Chapter ID**: `3.4-mcp-overview`

### Content

#### What is MCP?

MCP (Model Context Protocol) is a **standardized protocol for tool integration**. It allows Claude to use external tools and services through a unified interface.

#### MCP vs. Direct Commands

| Aspect | MCP | Direct Commands |
|--------|-----|-----------------|
| Discovery | Claude discovers available tools | You tell Claude what to run |
| Interface | Standardized JSON protocol | Raw shell commands |
| Safety | Sandboxed execution | Full shell access |
| Integration | Purpose-built for AI | Generic shell |

#### Popular MCP Servers

| Server | Purpose |
|--------|---------|
| `@anthropic-ai/mcp-server-filesystem` | Safe file operations |
| `@anthropic-ai/mcp-server-github` | GitHub integration |
| `@modelcontextprotocol/server-postgres` | PostgreSQL queries |
| `@modelcontextprotocol/server-slack` | Slack messaging |
| `@anthropic-ai/mcp-server-playwright` | Browser automation |

### Verification

```yaml
chapter: 3.4-mcp-overview
type: conceptual
verification: manual
question: "Can you explain what MCP is and why it's useful?"
```

### Checklist

- [ ] Understand what MCP is
- [ ] Know the difference between MCP and direct commands
- [ ] Aware of available MCP servers

---

## Chapter 5: Configuring MCP Servers

**Chapter ID**: `3.5-mcp-configuration`

### Content

#### MCP Configuration Location

MCP servers are configured in: `.claude/mcp.json`

#### Configuration Structure

```json
{
  "mcpServers": {
    "server-name": {
      "command": "npx",
      "args": ["-y", "@package/mcp-server", "arg1", "arg2"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

#### Configuration Fields

| Field | Required | Description |
|-------|----------|-------------|
| `command` | Yes | Command to start the server |
| `args` | Yes | Arguments for the command |
| `env` | No | Environment variables |

#### Example: Filesystem Server

Create `.claude/mcp.json`:

```json
{
  "mcpServers": {
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-filesystem", "/path/to/allowed/directory"]
    }
  }
}
```

#### Example: GitHub Server

```json
{
  "mcpServers": {
    "github": {
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

#### Using Environment Variables

For sensitive values, use environment variable references:
- `${VAR_NAME}` - Reads from environment
- Set in your shell: `export GITHUB_TOKEN=your_token`

### Verification

```yaml
chapter: 3.5-mcp-configuration
type: automated
verification:
  checks:
    - file_exists: ".claude/mcp.json"
      contains: "mcpServers"
      task_key: configure_mcp
```

### Checklist

- [ ] Created `.claude/mcp.json`
- [ ] Configured at least one MCP server
- [ ] Environment variables properly referenced (if needed)
- [ ] Server starts without errors

---

## Chapter 6: Using MCP in Practice

**Chapter ID**: `3.6-mcp-usage`

### Content

#### Verifying MCP Connection

After configuring MCP, Claude will show available tools:
```
Connected to MCP server: github
Available tools: create_issue, list_issues, create_pr, ...
```

#### Example Usage: GitHub MCP

With GitHub MCP configured:

```
You: "Create an issue for the bug we discussed"
Claude: Using github.create_issue tool...
Created issue #123: "Fix login validation bug"
```

#### Example Usage: Database MCP

With PostgreSQL MCP configured:

```
You: "Show me the schema for the users table"
Claude: Using postgres.query tool...
[Shows table schema]
```

#### MCP Security

- MCP servers run in **sandboxed contexts**
- They can only access what you configure
- Sensitive operations still require approval

### Role-Specific MCP Setup

| Role | Recommended MCP Servers |
|------|------------------------|
| Frontend | Filesystem, Playwright (for testing) |
| Backend | GitHub, PostgreSQL/MySQL |
| QA | Playwright, GitHub |
| DevOps | GitHub, AWS, Kubernetes |
| Data | PostgreSQL, BigQuery, S3 |

### Verification

```yaml
chapter: 3.6-mcp-usage
type: manual
verification:
  questions:
    - "Start Claude and verify MCP server connects"
    - "Use an MCP tool in a request"
    - "Confirm tool executed successfully"
  task_key: test_mcp
```

### Checklist

- [ ] MCP server connects when Claude starts
- [ ] Can see available MCP tools
- [ ] Successfully used an MCP tool
- [ ] Understand MCP security model

---

## Chapter 7: Advanced Custom Commands

**Chapter ID**: `3.7-advanced-commands`

### Content

#### Command with Arguments

Commands can accept arguments using `$ARGUMENTS`:

```markdown
---
name: deploy
description: Deploy to specified environment
---

# Command: Deploy

## Arguments

Expects: `environment` (staging, production)

Usage: `/deploy staging` or `/deploy production`

## Instructions

1. Read the environment from: $ARGUMENTS
2. Validate it's either "staging" or "production"
3. Run the appropriate deployment script
4. Report the deployment status
```

#### Command with Multi-Step Workflow

```markdown
---
name: pr-ready
description: Prepare branch for PR
---

# Command: PR Ready

## Instructions

1. **Check for uncommitted changes**
   - If found, ask user what to do

2. **Run tests**
   - Execute: `npm test`
   - If tests fail, stop and report

3. **Run linting**
   - Execute: `npm run lint`
   - Auto-fix if possible

4. **Update branch**
   - Fetch latest from main
   - Rebase if needed

5. **Generate PR description**
   - Summarize commits since branch point
   - List files changed
   - Suggest reviewers based on CODEOWNERS

## Output

Provide a summary ready to paste into PR description.
```

#### Command with Skill Integration

```markdown
---
name: new-feature
description: Create a full feature with tests
---

# Command: New Feature

## Arguments

Feature name from: $ARGUMENTS

## Instructions

1. **Apply skill**: Use the `create-component` skill
2. **Apply skill**: Use the `coding-standards` skill
3. **Create tests**: Following our test patterns
4. **Update docs**: Add to feature documentation
```

### Verification

```yaml
chapter: 3.7-advanced-commands
type: automated
verification:
  checks:
    - file_pattern: ".claude/commands/*.md"
      min_count: 2
      task_key: create_advanced_command
```

### Checklist

- [ ] Created a command that accepts arguments
- [ ] Command has multi-step workflow
- [ ] Command integrates with existing skills (optional)
- [ ] Tested command works as expected

---

## Chapter 8: Commit Your Extensions

**Chapter ID**: `3.8-commit`

### Content

#### What to Commit

```
.claude/
├── settings.json    # Hook configurations
├── mcp.json         # MCP server configurations
└── commands/
    └── *.md         # Custom commands
```

#### Commit Commands

```bash
git add .claude/
git commit -m "Add Claude Code extensions

- Add formatting hooks for TypeScript files
- Configure MCP servers
- Add advanced custom commands"
```

### Verification

```yaml
chapter: 3.8-commit
type: automated
verification:
  checks:
    - git_committed: ".claude"
      task_key: commit_extensions
```

### Checklist

- [ ] Settings with hooks committed
- [ ] MCP configuration committed
- [ ] New commands committed
- [ ] Commit message is descriptive

---

## Seminar Summary

### What You Learned

1. **Hooks**: Event-driven automation for file operations
2. **MCP**: Standardized protocol for external tool integration
3. **Advanced Commands**: Arguments, multi-step workflows, skill integration

### Files Created/Modified

| File | Purpose |
|------|---------|
| `.claude/settings.json` | Hook configurations |
| `.claude/mcp.json` | MCP server configurations |
| `.claude/commands/*.md` | Advanced custom commands |

### Next Seminar Preview

In **Seminar 4: Agents**, you'll learn to orchestrate multiple Claude instances working in parallel using subagents and git worktrees.

---

## Validation Summary

```yaml
seminar: 3-extensions
tasks:
  create_hook:
    chapter: 3.2
    type: automated
    check: "file_contains:.claude/settings.json:hooks"

  test_hook:
    chapter: 3.3
    type: manual
    check: "student_confirms"

  configure_mcp:
    chapter: 3.5
    type: automated
    check: "file_contains:.claude/mcp.json:mcpServers"

  test_mcp:
    chapter: 3.6
    type: manual
    check: "student_confirms"

  create_advanced_command:
    chapter: 3.7
    type: automated
    check: "glob_count:.claude/commands/*.md:>=2"

  commit_extensions:
    chapter: 3.8
    type: automated
    check: "git_log:.claude"
```
