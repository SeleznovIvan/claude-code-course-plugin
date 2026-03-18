# Seminar 3: Extensions

**Duration**: 120 minutes (80 min guided + 40 min implementation)

**Seminar ID**: `3-extensions`

---

## Before You Begin

**Prerequisites**: You must have completed Modules 1-2 (Foundations & Commands, Skills). Specifically:
- CLAUDE.md exists in your repository
- You've created custom commands in `.claude/commands/`
- You've created skills in `.claude/skills/`
- You understand slash commands, plan mode, and the codify workflow

If you haven't completed earlier modules, run `/cc-course:start 1` or `/cc-course:start 2` first.

---

## How This Course Works

This is an interactive course — Claude guides you through each chapter step by step. Here are the commands you'll use:

| Command | When to Use |
|---------|-------------|
| `/cc-course:start N` | Begin a module (1-5) |
| `/cc-course:continue` | Signal you're done with the current step and ready to move on |
| `/cc-course:hint` | Get help when you're stuck on a task |
| `/cc-course:status` | Check your overall progress across all modules |
| `/cc-course:validate` | Verify your work at the end of a module |
| `/cc-course:submit` | Package your completed work for instructor review |

**The flow**: Claude presents a concept → checks your understanding → gives you a hands-on task → you do it → Claude verifies → repeat. Use `/cc-course:continue` to tell Claude you're ready for the next step.

---

## Learning Objectives

By the end of this seminar, participants will:
- Understand the 4 hook events and 4 handler types for event-driven automation
- Create hooks with the correct 3-level configuration structure (event → matcher group → handler array)
- Configure MCP servers in `.mcp.json` with proper transport types
- Use MCP tools naturally in Claude Code sessions
- Build advanced custom commands with `$ARGUMENTS` and multi-step workflows
- Understand the extension ecosystem and how hooks, MCP, and commands work together

---

## Chapter Phase Map

Quick reference showing which interactive phases each chapter has:

| Chapter | PRESENT | CHECKPOINT | ACTION | VERIFY |
|---------|---------|------------|--------|--------|
| 1 — Understanding Hooks | yes | yes | — | — |
| 2 — Creating Hooks | yes | yes | yes | yes |
| 3 — Testing Hooks | yes | yes | yes | yes |
| 4 — MCP Overview | yes | yes | — | — |
| 5 — Configuring MCP | yes | yes | yes | yes |
| 6 — Using MCP | yes | yes | yes | yes |
| 7 — Advanced Commands | yes | yes | yes | yes |
| 8 — Commit Extensions | yes | — | yes | yes |

---

## Chapter Progress Map

Data for the table of contents and progress bar (see teaching.md).

| Step | Chapter Label | Short Title |
|------|---------------|-------------|
| 1 | Chapter 1 | Understanding Hooks |
| 2 | Chapter 2 | Creating Hooks |
| 3 | Chapter 3 | Testing Hooks |
| 4 | Chapter 4 | MCP Overview |
| 5 | Chapter 5 | Configuring MCP |
| 6 | Chapter 6 | Using MCP |
| 7 | Chapter 7 | Advanced Commands |
| 8 | Chapter 8 | Commit Extensions |

**Total steps**: 8 | **Module title**: Extensions | **Module number**: 3

---

## Chapter 1: Understanding Hooks

**Chapter ID**: `3.1-understanding-hooks`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 3.1](./KNOWLEDGE.md#chapter-31-understanding-hooks) for the complete hook event lifecycle, handler type details, and advanced use cases.

### Content

#### What Are Hooks?

Hooks are **event-driven automation triggers** that run shell commands (or other actions) when Claude performs certain actions. They let you inject custom logic into Claude's workflow — formatting code after writes, validating inputs before execution, sending notifications when tasks complete.

#### The 4 Hook Events

These are the events you can hook into. Focus on learning these four:

| Event | When It Fires | Can Block? | Common Uses |
|-------|---------------|------------|-------------|
| `PreToolUse` | **Before** a tool executes | Yes (exit code 2) | Input validation, preventing writes to protected files, enforcing policies |
| `PostToolUse` | **After** a tool succeeds | No | Auto-formatting, linting, logging, notifications |
| `Notification` | When Claude needs user attention | No | Desktop notifications, sound alerts |
| `Stop` | When Claude finishes responding | No | Task completion notifications, session logging, cleanup |

**Key distinction**: `PreToolUse` is the only event that can **block** an action. If your hook exits with code 2, Claude receives the stderr as feedback and the tool call is prevented. This is powerful for enforcing policies (e.g., "never write to `/dist`").

#### The 4 Hook Handler Types

Each hook can use one of four handler types:

| Handler Type | What It Does | When to Use |
|-------------|--------------|-------------|
| `command` | Runs a shell command | Most common — formatting, linting, validation scripts |
| `http` | Sends a webhook request | External service notifications (Slack, PagerDuty) |
| `prompt` | Asks the LLM to make a decision | Dynamic decisions based on context |
| `agent` | Spawns a subagent with tool access | Complex multi-step hook logic |

#### Use Case Matrix

| Scenario | Event | Handler Type | Why |
|----------|-------|-------------|-----|
| Auto-format code after writes | `PostToolUse` | `command` | Run prettier/black after file saves |
| Block writes to protected files | `PreToolUse` | `command` | Exit code 2 to prevent writing to `/dist`, `/build` |
| Run linter after edits | `PostToolUse` | `command` | Run eslint/pylint on changed files |
| Notify on task completion | `Stop` | `command` | Send desktop notification or webhook |
| Validate config syntax before save | `PreToolUse` | `command` | Parse YAML/JSON, block on syntax error |
| Log all tool usage | `PostToolUse` | `http` | Send usage data to analytics endpoint |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Can you explain when PreToolUse vs PostToolUse would trigger, and when you'd use exit code 2 to block an action?"
- **Options**: "Yes, I understand — let's continue" / "I have a question" / "I need more explanation"
- On questions: answer them, then re-ask
- On "need more explanation": elaborate on the difference between Pre (before, can block with exit 2) and Post (after, for side effects), give a concrete example of blocking a write to a protected directory, then re-ask

### Checklist

- [ ] Understand what hooks are (event-driven automation triggers)
- [ ] Know the four hook events (PreToolUse, PostToolUse, Notification, Stop)
- [ ] Understand that PreToolUse can block actions with exit code 2
- [ ] Know the four handler types (command, http, prompt, agent)
- [ ] Can identify which event + handler type to use for common scenarios

---

## Chapter 2: Creating Hooks

**Chapter ID**: `3.2-creating-hooks`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 3.2](./KNOWLEDGE.md#chapter-32-creating-hooks) for the complete hook configuration reference, all environment variables, stdin JSON schema, and advanced matcher patterns.

### Content

#### Hook Configuration Location

Hooks are configured in your Claude settings files:

| Scope | File | When to Use |
|-------|------|-------------|
| Project | `.claude/settings.json` | Shared with team (committed to git) |
| Global | `~/.claude/settings.json` | Personal, applies to all projects |

#### The 3-Level Configuration Structure

Hook configuration uses a **3-level hierarchy**: event name → array of matcher groups → each group has a `matcher` and a `hooks` array.

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "echo 'A file is about to be written or edited'"
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "npx prettier --write \"$CLAUDE_PROJECT_DIR/$(echo $INPUT | jq -r '.tool_input.file_path')\""
          }
        ]
      }
    ]
  }
}
```

**Structure breakdown:**

1. **Level 1** — `"hooks"` object with event names as keys (`PreToolUse`, `PostToolUse`, etc.)
2. **Level 2** — Each event has an array of **matcher groups**. Each group has:
   - `"matcher"`: regex pattern matching tool names
   - `"hooks"`: array of handler objects
3. **Level 3** — Each handler object has:
   - `"type"`: handler type (`"command"`, `"http"`, `"prompt"`, `"agent"`)
   - Handler-specific fields (`"command"` for command type, `"url"` for http type, etc.)

#### Matcher Field

The `matcher` is a **regex pattern** that matches against tool names. Tool names in Claude Code are:

| Tool Name | What It Does |
|-----------|-------------|
| `Bash` | Shell command execution |
| `Write` | File creation/overwrite |
| `Edit` | File editing (find-replace) |
| `Read` | File reading |
| `Glob` | File pattern search |
| `Grep` | Content search |
| `mcp__.*` | Any MCP tool (regex pattern) |

**Matcher examples:**
- `"Write|Edit"` — matches file write or edit operations
- `"Bash"` — matches shell command execution
- `""` (empty string) — matches **all** tools
- `"mcp__github__.*"` — matches all GitHub MCP tools

#### Hook Input (stdin)

Hooks receive JSON on stdin with context about the event:

```json
{
  "session_id": "abc-123",
  "cwd": "/path/to/project",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "src/index.ts",
    "content": "..."
  }
}
```

Parse it in your command with `jq`: `echo $INPUT | jq -r '.tool_input.file_path'`

#### Exit Codes (PreToolUse only)

| Exit Code | Meaning | Behavior |
|-----------|---------|----------|
| `0` | Success | Tool call proceeds normally |
| `2` | Block | Tool call is **prevented**; stderr is sent to Claude as feedback |
| Other | Error | Non-blocking error; tool call still proceeds |

#### Environment Variables

| Variable | Description |
|----------|-------------|
| `$CLAUDE_PROJECT_DIR` | Root directory of the project |
| `$CLAUDE_SESSION_ID` | Current session identifier |

#### Handler Type Examples

**Command handler** (most common):
```json
{
  "type": "command",
  "command": "npx prettier --write \"$CLAUDE_PROJECT_DIR/$(echo $INPUT | jq -r '.tool_input.file_path')\""
}
```

**HTTP handler** (webhooks):
```json
{
  "type": "http",
  "url": "https://hooks.slack.com/services/T00/B00/xxx",
  "method": "POST"
}
```

**Prompt handler** (LLM decision):
```json
{
  "type": "prompt",
  "prompt": "Review this file write and decide if it follows our coding standards. If not, explain why."
}
```

**Agent handler** (subagent with tools):
```json
{
  "type": "agent",
  "prompt": "Analyze the written file for security vulnerabilities and report findings."
}
```

#### Role-Specific Hook Ideas

| Role | Hook | Event & Matcher | What It Does |
|------|------|----------------|--------------|
| Frontend | Auto-format with Prettier | `PostToolUse`, matcher: `Write\|Edit` | Runs prettier on saved files |
| Backend | Type-check after changes | `PostToolUse`, matcher: `Write\|Edit` | Runs mypy/pyright on Python files |
| QA | Auto-run related tests | `PostToolUse`, matcher: `Write` | Runs test runner when test files change |
| DevOps | Validate config syntax | `PreToolUse`, matcher: `Write` | Validates YAML/JSON, blocks on syntax error |
| Data | Validate schema | `PostToolUse`, matcher: `Write\|Edit` | Runs schema validation on model files |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand the 3-level hook structure (event → matcher group → handler array) and how matchers use regex to match tool names?"
- **Options**: "Yes, I understand the structure" / "I have a question about the format" / "Can you show the structure breakdown again?"
- On questions: answer them, then re-ask
- On "show again": re-present the 3-level breakdown with the JSON example, highlighting each level, then re-ask

### Instructor: Action

#### Discover hook opportunities from session history

Before asking the student to pick a hook, analyze their recent Claude Code sessions to find patterns worth automating.

**Use cclogviewer MCP tools** (read `student.mcp_project_name` from progress.json for the `project` parameter):

```
# Get recent sessions
mcp__cclogviewer__list_sessions(project=<project_name>, days=30, limit=10)

# Search for formatting/linting/testing patterns
mcp__cclogviewer__search_logs(project=<project_name>, query="format|lint|test|validate|check|prettier|eslint|mypy")

# Get tool usage to see what tools are used most
mcp__cclogviewer__get_tool_usage_stats(project=<project_name>, days=30)
```

**Analyze the results** for:
- Frequently repeated formatting or linting commands after file writes
- Manual validation steps that could be automated
- Repeated tool sequences (e.g., Write → Bash with linting)
- Patterns where Claude was asked to check or fix something post-write

**Present 3-5 discovered patterns** to the student via AskUserQuestion:

"Based on your recent Claude Code sessions, here are automation opportunities I found that would make great hooks:

1. **[Pattern Name]** — [Description]. Found in [N] sessions. [Why automating this as a hook saves time].
2. **[Pattern Name]** — [Description]. Found in [N] sessions. [Why this is a good candidate].
3. **[Pattern Name]** — [Description]. Found in [N] sessions. [What makes this automatable].

Which one would you like to create as a hook?"

- **Options**: The discovered patterns + "I have my own idea"
- If the student picks their own idea, proceed with that

**Fallback** — if cclogviewer MCP is unavailable, the project has no session history, or no meaningful patterns are found, fall back to role-based suggestions:

| Role | Suggested Hook |
|------|---------------|
| Frontend | Auto-format with Prettier after file writes (PostToolUse) |
| Backend | Run type checker after Python/Go file changes (PostToolUse) |
| QA | Auto-run related tests after test file changes (PostToolUse) |
| DevOps | Validate YAML/JSON syntax on config writes (PreToolUse + exit 2) |
| Data | Validate schema after model file changes (PostToolUse) |

#### Create the hook

Tell the student:
"Now let's create your hook. Based on your choice, here's what we need to do:

1. **Create or update** `.claude/settings.json` in your repository
2. **Add the hook configuration** using the correct 3-level structure

Here's the template for your hook — I'll fill in the details based on your choice:

```json
{
  \"hooks\": {
    \"[Event]\": [
      {
        \"matcher\": \"[ToolRegex]\",
        \"hooks\": [
          {
            \"type\": \"command\",
            \"command\": \"[your command here]\"
          }
        ]
      }
    ]
  }
}
```

Create this file now. Use the {cc-course:continue} Skill tool when you've created the hook configuration."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks in the student's repository:

1. **file_exists**: Use Glob to check `.claude/settings.json` exists
2. **content_check**: Use Read to verify the file contains:
   - A `"hooks"` key
   - At least one event name (`PreToolUse`, `PostToolUse`, `Notification`, or `Stop`)
   - The 3-level structure: event → matcher group array → hooks array with `type` field

**On failure**: Tell the student what's missing or incorrectly structured. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `create_hook` to `true`, set `current_task` to `"test_hook"`

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
- [ ] Hook uses the correct 3-level structure (event → matcher group → handler array)
- [ ] Matcher uses correct tool name regex (e.g., `Write|Edit`, not `write_file`)
- [ ] Handler has a `type` field (`command`, `http`, `prompt`, or `agent`)
- [ ] Command is appropriate for the chosen automation

---

## Chapter 3: Testing Hooks

**Chapter ID**: `3.3-testing-hooks`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 3.3](./KNOWLEDGE.md#chapter-33-testing-hooks) for the complete debugging guide, verbose mode details, and common hook errors.

### Content

#### The Fresh Session Requirement

> **Critical**: Hooks are loaded at session start. After creating or modifying hooks in `.claude/settings.json`, you **must start a new Claude session** for changes to take effect. Changes are NOT picked up in the current session.

#### Testing Workflow

1. **Exit the current session**: Type `exit`
2. **Start a fresh Claude session**: Run `claude`
3. **Trigger the hooked action**: Perform the action your hook is listening for
   - For `PostToolUse` on `Write|Edit`: Ask Claude to create or edit a file
   - For `PreToolUse` on `Write`: Ask Claude to write to a protected path
   - For `Stop`: Just have Claude respond to any prompt
4. **Observe the output**: Claude shows when hooks execute

#### What to Look For

Claude displays hook execution in its output:
```
Running hook: npx prettier --write src/index.ts
```

For `PreToolUse` hooks that block (exit code 2), you'll see Claude acknowledge the block and adjust its behavior based on the stderr feedback.

#### Debugging Checklist

If your hook doesn't trigger, check these in order:

1. **Is the matcher regex correct?** Tool names are case-sensitive: `Write` (not `write_file`), `Bash` (not `bash`), `Edit` (not `edit`)
2. **Is the command available in PATH?** Try running the command manually in your terminal
3. **Does the command have execute permissions?** Check with `ls -la` for custom scripts
4. **Is stdin JSON being parsed correctly?** Test your `jq` command manually: `echo '{"tool_input":{"file_path":"test.ts"}}' | jq -r '.tool_input.file_path'`
5. **Is the exit code correct?** For PreToolUse: exit 2 blocks, exit 0 proceeds. Other codes are non-blocking errors.
6. **Did you start a fresh session?** Hooks only load at session start.

#### Verbose Mode

Toggle verbose mode with `Ctrl+O` to see detailed hook execution logs, including:
- Which hooks matched the current tool call
- The full command being executed
- Exit codes and output

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you know how to test and debug hooks? Key points: exit and restart Claude for hooks to load, trigger the hooked action, look for 'Running hook:' in output, and use the debugging checklist if something doesn't work."
- **Options**: "Yes, I'm ready to test" / "I have a question" / "What if my hook doesn't trigger?"
- On questions: answer them, then re-ask
- On "doesn't trigger": walk through the debugging checklist step by step, then re-ask

### Instructor: Action

> **IMPORTANT**: Before restarting, save progress to progress.json. Update:
> - `current_module`: `"3-extensions"`
> - `current_task`: `"test_hook"`

Tell the student:
"Time to test your hook in a real session. Here's the plan:

1. **Exit this session** (type `exit`)
2. **Start a fresh Claude session** (`claude`)
3. **Trigger your hook**: [Describe the specific action based on the hook they created — e.g., 'Ask Claude to create a TypeScript file' for a PostToolUse formatter hook]
4. **Observe**: Look for the 'Running hook:' message in Claude's output
5. **Verify**: Check that the hook's effect was applied (e.g., file was formatted)
6. **Return to the course**: Run `/cc-course:continue`

> **Before you exit**: I'll save your progress now so the course resumes cleanly.

Use the {cc-course:continue} Skill tool when you've tested your hook and are ready to discuss the results."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

After the student returns:

Ask using AskUserQuestion:
- **Question**: "How did testing go? Did your hook trigger and work as expected?"
- **Options**: "It worked perfectly" / "It triggered but didn't work correctly" / "It didn't trigger at all" / "I got an error"

For hooks that didn't work:
1. Walk through the debugging checklist from the Content section
2. Help them identify the specific issue (matcher, command path, exit code, etc.)
3. Have them fix the hook configuration
4. Tell them to test again in a fresh session
5. Repeat until the hook works

**On success** (student confirms hook works): Update progress.json: set task `test_hook` to `true`, set `current_task` to `"configure_mcp"`

### Verification

```yaml
chapter: 3.3-testing-hooks
type: manual
verification:
  questions:
    - "Trigger your hook by having Claude perform the matched action"
    - "Verify the hook command executed (look for 'Running hook:' output)"
    - "Check that the hook's effect was applied correctly"
  task_key: test_hook
```

### Checklist

- [ ] Started a fresh Claude session (hooks load at startup)
- [ ] Triggered the hooked action
- [ ] Saw hook execution in Claude's output
- [ ] Verified the hook's effect was applied correctly
- [ ] Hook works as expected

---

## Chapter 4: MCP Overview

**Chapter ID**: `3.4-mcp-overview`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 3.4](./KNOWLEDGE.md#chapter-34-mcp-overview) for the MCP protocol specification, JSON-RPC details, transport comparison, and the full MCP ecosystem.

### Content

#### What is MCP?

MCP (Model Context Protocol) is a **standardized protocol for tool integration**. It uses JSON-RPC over stdio or HTTP to let Claude communicate with external services through a unified interface.

Think of MCP as a **universal adapter** — instead of teaching Claude how to use each service's unique API, MCP servers expose tools, resources, and prompts through a standard protocol that Claude already understands.

#### MCP vs Direct Commands

| Aspect | MCP | Direct Commands (Bash) |
|--------|-----|----------------------|
| Discovery | Claude discovers available tools automatically | You must tell Claude what commands exist |
| Interface | Standardized JSON-RPC protocol | Raw shell commands with varied output |
| Type Safety | Typed parameters and return values | String inputs/outputs |
| Integration | Purpose-built for AI workflows | Generic shell — requires prompt engineering |
| Security | Permission system, project-scoped approval | Full shell access |

#### What MCP Servers Provide

MCP servers can expose three types of capabilities:

| Capability | Description | Example |
|------------|-------------|---------|
| **Tools** | Actions Claude can perform | `create_issue`, `run_query`, `take_screenshot` |
| **Resources** | Data Claude can read | Database schemas, API docs, project metadata |
| **Prompts** | Pre-built templates | Code review template, deployment checklist |

#### Popular MCP Servers

| Server | Transport | Purpose |
|--------|-----------|---------|
| GitHub (`https://api.githubcopilot.com/mcp/`) | HTTP | PRs, issues, code reviews, repository management |
| PostgreSQL (`@bytebase/dbhub`) | stdio | SQL queries, schema analysis, migrations |
| Filesystem (`@modelcontextprotocol/server-filesystem`) | stdio | Safe, scoped file operations |
| Playwright (`@anthropic-ai/mcp-server-playwright`) | stdio | Browser automation and testing |
| Sentry (`https://mcp.sentry.dev/mcp`) | HTTP | Error monitoring, issue tracking |

#### How Claude Code Discovers MCP

1. **Reads config**: Claude reads `.mcp.json` (project root) and `~/.claude.json` (user scope)
2. **Starts servers**: Launches configured MCP servers as child processes or connects to URLs
3. **Discovers tools**: Each server reports its available tools, resources, and prompts
4. **Makes tools available**: Tools appear in Claude's tool list, usable in natural language

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand what MCP is and why it's useful? Key points: it's a standardized protocol (JSON-RPC) for tool integration, servers provide tools/resources/prompts, and Claude discovers them automatically from config files."
- **Options**: "Yes, I understand — let's configure one" / "I have a question" / "What's the difference from just using Bash to call APIs?"
- On questions: answer them, then re-ask
- On "difference from Bash": explain that MCP tools have typed parameters, structured outputs, and are discoverable — Claude knows what parameters a tool needs without you explaining it. With Bash, you'd need to prompt-engineer every API call, handle auth, parse responses, etc. MCP abstracts all of that.

### Checklist

- [ ] Understand what MCP is (standardized protocol for tool integration)
- [ ] Know the three MCP capabilities (tools, resources, prompts)
- [ ] Understand MCP vs direct Bash commands
- [ ] Aware of popular MCP servers (GitHub, PostgreSQL, Playwright, etc.)
- [ ] Understand how Claude discovers MCP tools from config files

---

## Chapter 5: Configuring MCP Servers

**Chapter ID**: `3.5-mcp-configuration`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 3.5](./KNOWLEDGE.md#chapter-35-configuring-mcp-servers) for the complete configuration reference, all transport types, environment variable interpolation, and the CLI shortcut details.

### Content

#### Configuration Location

MCP servers are configured in JSON files at specific locations:

| Scope | File | Committed to Git? | When to Use |
|-------|------|--------------------|-------------|
| Project | `.mcp.json` (project root) | Yes | Team-shared servers (GitHub, database) |
| User | `~/.claude.json` | No | Personal servers, personal API keys |

> **IMPORTANT**: The project-level config is `.mcp.json` in the **project root**, NOT `.claude/mcp.json`.

#### Configuration Structure

Each server entry requires a `type` field specifying the transport:

```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@package/mcp-server"],
      "env": {
        "API_KEY": "${API_KEY}"
      }
    }
  }
}
```

#### Transport Types

| Transport | `type` Value | Connection | When to Use |
|-----------|-------------|------------|-------------|
| Standard I/O | `"stdio"` | Local process (command + args) | Most MCP servers — runs as child process |
| HTTP | `"http"` | Remote URL | Cloud-hosted servers (GitHub, Sentry) |
| SSE | `"sse"` | Server-Sent Events URL | Legacy — deprecated in favor of HTTP |

**stdio example** (local process):
```json
{
  "mcpServers": {
    "playwright": {
      "type": "stdio",
      "command": "npx",
      "args": ["-y", "@anthropic-ai/mcp-server-playwright"]
    }
  }
}
```

**HTTP example** (remote server):
```json
{
  "mcpServers": {
    "github": {
      "type": "http",
      "url": "https://api.githubcopilot.com/mcp/"
    }
  }
}
```

#### Configuration Fields Reference

| Field | Required | Description | Used With |
|-------|----------|-------------|-----------|
| `type` | Yes | Transport type: `stdio`, `http`, or `sse` | All |
| `command` | Yes (stdio) | Command to start the server | `stdio` |
| `args` | No | Arguments for the command | `stdio` |
| `env` | No | Environment variables for the process | `stdio` |
| `url` | Yes (http/sse) | URL of the remote server | `http`, `sse` |

#### CLI Shortcut

You can add MCP servers from the command line instead of editing JSON:

```bash
# stdio server
claude mcp add --transport stdio <name> -- <command> [args...]

# HTTP server
claude mcp add --transport http <name> <url>

# Examples
claude mcp add --transport stdio playwright -- npx @anthropic-ai/mcp-server-playwright
claude mcp add --transport http github https://api.githubcopilot.com/mcp/
claude mcp add --transport stdio db -- npx @bytebase/dbhub --dsn "postgresql://localhost:5432/mydb"
```

#### Environment Variable Interpolation

For sensitive values like API keys, use environment variable references:

```json
{
  "env": {
    "API_KEY": "${API_KEY}",
    "DATABASE_URL": "${DATABASE_URL:-postgresql://localhost:5432/dev}"
  }
}
```

- `${VAR}` — reads from environment; fails if not set
- `${VAR:-default}` — reads from environment; uses `default` if not set

Set variables in your shell: `export API_KEY=your_key_here`

#### Discover MCP opportunities from session history

**Use cclogviewer MCP tools** (read `student.mcp_project_name` from progress.json for the `project` parameter):

```
# Search for external service interactions
mcp__cclogviewer__search_logs(project=<project_name>, query="github|database|api|browser|file|slack|deploy|sentry")

# Get recent sessions for context
mcp__cclogviewer__list_sessions(project=<project_name>, days=30, limit=10)

# Get tool usage to see what external tools are being called via Bash
mcp__cclogviewer__get_tool_usage_stats(project=<project_name>, days=30)
```

**Analyze the results** for:
- Bash commands calling external APIs (curl, gh, aws, etc.)
- Database queries being run manually
- Browser testing commands
- GitHub CLI usage patterns
- Any external service interaction that could be replaced by an MCP server

#### Role-Specific MCP Recommendations

| Role | Recommended MCP | CLI Command |
|------|----------------|-------------|
| Frontend | Playwright | `claude mcp add --transport stdio playwright -- npx @anthropic-ai/mcp-server-playwright` |
| Backend | GitHub, PostgreSQL | `claude mcp add --transport http github https://api.githubcopilot.com/mcp/` |
| QA | Playwright, GitHub | `claude mcp add --transport stdio playwright -- npx @anthropic-ai/mcp-server-playwright` |
| DevOps | GitHub, AWS | `claude mcp add --transport http github https://api.githubcopilot.com/mcp/` |
| Data | PostgreSQL, S3 | `claude mcp add --transport stdio db -- npx @bytebase/dbhub --dsn "postgresql://..."` |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand MCP configuration? Key points: servers go in `.mcp.json` (project root, not `.claude/mcp.json`), each needs a `type` field (`stdio`/`http`/`sse`), stdio servers need `command`/`args`, HTTP servers need `url`, and sensitive values use `${ENV_VAR}` interpolation."
- **Options**: "Yes, let's configure one" / "I'm confused about the transport types" / "Where exactly does the file go?"
- On "transport types": explain that `stdio` runs a local process (like npx), `http` connects to a remote URL (like GitHub), and `sse` is legacy. Most servers are `stdio`.
- On "where does file go": emphasize it's `.mcp.json` in the project root directory (same level as `package.json`, `CLAUDE.md`, etc.), NOT inside `.claude/`

### Instructor: Action

**Present discovered MCP opportunities** to the student via AskUserQuestion:

If cclogviewer data is available, present discovered patterns:

"Based on your recent Claude Code sessions, here are external services you interact with that could benefit from MCP integration:

1. **[Service/Pattern]** — [Description]. I noticed [evidence]. [Recommended MCP server].
2. **[Service/Pattern]** — [Description]. I noticed [evidence]. [Recommended MCP server].
3. **[Service/Pattern]** — [Description]. I noticed [evidence]. [Recommended MCP server].

Which MCP server would you like to set up?"

- **Options**: The discovered options + "I have my own idea"
- If the student picks their own, proceed with that

**Fallback** — if cclogviewer MCP is unavailable or no meaningful patterns are found, use the Role-Specific MCP table from the Content section.

#### Configure the MCP server

Tell the student:
"Now let's configure your MCP server. You have two options:

**Option A — CLI** (quick):
```bash
claude mcp add --transport [type] [name] [-- command args | url]
```

**Option B — Manual** (more control):
Create `.mcp.json` in your project root:
```json
{
  \"mcpServers\": {
    \"[name]\": {
      \"type\": \"[stdio|http]\",
      ...
    }
  }
}
```

Choose whichever method you prefer. Use the {cc-course:continue} Skill tool when your MCP server is configured."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks in the student's repository:

1. **file_exists**: Use Glob to check `.mcp.json` exists in the project root
2. **content_check**: Use Read to verify the file contains:
   - A `"mcpServers"` key
   - At least one server with a `"type"` field

**On failure**: Tell the student what's missing. Common issues: file in wrong location (`.claude/mcp.json` instead of `.mcp.json`), missing `type` field. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `configure_mcp` to `true`, set `current_task` to `"test_mcp"`

### Verification

```yaml
chapter: 3.5-mcp-configuration
type: automated
verification:
  checks:
    - file_exists: ".mcp.json"
      contains: "mcpServers"
      task_key: configure_mcp
```

### Checklist

- [ ] Created `.mcp.json` in project root (not `.claude/mcp.json`)
- [ ] Configured at least one MCP server
- [ ] Server has `type` field (`stdio`, `http`, or `sse`)
- [ ] Environment variables properly referenced (if needed)
- [ ] Understand the difference between project and user scope config

---

## Chapter 6: Using MCP in Practice

**Chapter ID**: `3.6-mcp-usage`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 3.6](./KNOWLEDGE.md#chapter-36-using-mcp-in-practice) for MCP security details, permission model, tool call lifecycle, and advanced troubleshooting.

### Content

#### Verifying MCP Connection

After configuring an MCP server, verify it connects when Claude starts:

1. **Start Claude**: Run `claude` in your project directory
2. **Check startup messages**: Claude reports connected MCP servers:
   ```
   Connected to MCP server: github
   Available tools: create_issue, list_issues, create_pr, ...
   ```
3. **Use `claude mcp list`**: Shows all configured servers and their status

#### Using MCP Tools Naturally

MCP tools are used naturally in prompts — you don't need special syntax:

**GitHub MCP example:**
```
You: "Create an issue for the login validation bug we found"
Claude: Using github.create_issue...
Created issue #123: "Fix login validation bug"
```

**Database MCP example:**
```
You: "Show me the schema for the users table"
Claude: Using db.query...
[Shows table schema with columns, types, constraints]
```

**Playwright MCP example:**
```
You: "Navigate to our app and take a screenshot of the login page"
Claude: Using playwright.navigate... playwright.screenshot...
[Shows screenshot]
```

#### MCP Prompts as Commands

Some MCP servers expose prompts — pre-built instruction templates you can invoke:

```
You: "Use the code-review prompt on my latest changes"
Claude: [Follows the MCP server's code review template]
```

#### MCP Security Model

- **Project-scoped servers** (`.mcp.json`): Require user approval on first use in a session
- **Tool calls**: Go through Claude's permission system — you'll be asked to approve sensitive operations
- **Environment variables**: Only available to the server process, not exposed to Claude
- **Scoped access**: Each server only has access to what you configure (e.g., specific database, specific repo)

#### Troubleshooting

| Problem | Diagnosis | Fix |
|---------|-----------|-----|
| Server not connecting | Check `claude mcp list` | Verify command/URL is correct, check PATH |
| "Server not found" | Config file in wrong location | Move to `.mcp.json` (project root) |
| Auth errors | Missing environment variable | Set `export API_KEY=...` before starting Claude |
| Tools not appearing | Server crashed on startup | Check server logs, try running command manually |
| Timeout errors | Server takes too long to start | Increase timeout or check server health |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you know how to verify MCP is working? Key steps: start Claude, check startup messages for connected servers, use `claude mcp list` to see status, and test by asking Claude to use a tool naturally."
- **Options**: "Yes, I'm ready to test" / "How do I troubleshoot if it doesn't connect?" / "I have a question"
- On "troubleshoot": walk through the troubleshooting table, emphasizing checking the command path and environment variables
- On questions: answer them, then re-ask

### Instructor: Action

> **IMPORTANT**: Before restarting, save progress to progress.json. Update:
> - `current_module`: `"3-extensions"`
> - `current_task`: `"test_mcp"`

Tell the student:
"Time to test your MCP server in a real session. Here's the plan:

1. **Exit this session** (type `exit`)
2. **Start a fresh Claude session** (`claude`)
3. **Check startup messages**: Look for your MCP server in the connection list
4. **Verify with `claude mcp list`**: Confirm the server is connected
5. **Use a tool**: Ask Claude to perform an action using your MCP server
6. **Return to the course**: Run `/cc-course:continue`

> **Before you exit**: I'll save your progress now so the course resumes cleanly.

Use the {cc-course:continue} Skill tool when you've tested your MCP server and are ready to discuss the results."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

After the student returns:

Ask using AskUserQuestion:
- **Question**: "Did your MCP server connect and tools work? How did testing go?"
- **Options**: "Everything worked great" / "Server connected but tools didn't work right" / "Server didn't connect" / "I got an error"

For connection issues:
1. Ask what error message they saw
2. Walk through the troubleshooting table
3. Help them fix the configuration
4. Have them test again in a fresh session
5. Repeat until working

**On success** (student confirms MCP works): Update progress.json: set task `test_mcp` to `true`, set `current_task` to `"create_advanced_command"`

### Verification

```yaml
chapter: 3.6-mcp-usage
type: manual
verification:
  questions:
    - "Start Claude and verify MCP server connects"
    - "Use an MCP tool in a natural language request"
    - "Confirm tool executed successfully"
  task_key: test_mcp
```

### Checklist

- [ ] MCP server connects when Claude starts
- [ ] Can see available MCP tools (via startup message or `claude mcp list`)
- [ ] Successfully used an MCP tool in a natural language request
- [ ] Understand MCP security model (project-scoped approval, permission system)

---

## Chapter 7: Advanced Custom Commands

**Chapter ID**: `3.7-advanced-commands`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 3.7](./KNOWLEDGE.md#chapter-37-advanced-custom-commands) for the complete `$ARGUMENTS` reference, dynamic context injection details, and command design patterns.

### Content

#### Commands vs Skills Reminder

Before diving into advanced commands, remember the key difference:

| Feature | Commands | Skills |
|---------|----------|--------|
| Location | `.claude/commands/` | `.claude/skills/` |
| Invocation | Always user-invoked via `/name` | Auto-detected by Claude or user-invoked |
| Purpose | Explicit tasks with arguments | Reusable instructions and procedures |
| Format | Markdown with frontmatter | SKILL.md with frontmatter |

Advanced commands build on what you learned in Module 1, adding argument handling, multi-step workflows, and dynamic context.

#### `$ARGUMENTS` Substitution

Commands support argument substitution:

| Variable | Resolves To | Example |
|----------|-------------|---------|
| `$ARGUMENTS` | Full argument string | `/deploy staging us-east-1` → `staging us-east-1` |
| `$ARGUMENTS[0]` or `$0` | First positional argument | `/deploy staging` → `staging` |
| `$ARGUMENTS[1]` or `$1` | Second positional argument | `/deploy staging us-east-1` → `us-east-1` |

**Auto-append behavior**: If `$ARGUMENTS` does not appear anywhere in the command content, the full argument string is automatically appended to the end of the prompt. So a simple command without `$ARGUMENTS` still receives arguments.

#### Example: Multi-Step Workflow Command

```markdown
---
name: pr-ready
description: Prepare branch for PR — lint, test, generate description
---

# Command: PR Ready

## Instructions

1. **Check for uncommitted changes**
   - Run `git status`
   - If found, ask user what to do

2. **Run tests**
   - Execute the project's test suite
   - If tests fail, stop and report failures

3. **Run linting**
   - Execute the project's linter
   - Auto-fix if possible

4. **Update branch**
   - Fetch latest from main: `git fetch origin main`
   - Rebase if needed: `git rebase origin/main`

5. **Generate PR description**
   - Summarize commits since branch point: !`git log --oneline origin/main..HEAD`
   - List files changed: !`git diff --name-only origin/main`
   - Suggest reviewers based on CODEOWNERS (if exists)

## Output

Provide a summary ready to paste into a PR description, including:
- What changed and why
- Test results
- Files modified
```

#### Dynamic Context Injection

Commands can include real-time data using backtick-bang syntax:

```markdown
## Current State

Branch: !`git branch --show-current`
Last 5 commits:
!`git log --oneline -5`
Changed files:
!`git diff --name-only`
```

The shell commands execute when the command loads, injecting live data into the instructions.

#### Command Design Patterns

| Pattern | Description | Example |
|---------|-------------|---------|
| **Validation-first** | Check preconditions before acting | `/deploy` checks branch, tests, lint before deploying |
| **Multi-step** | Sequential steps with checkpoints | `/pr-ready` runs lint → test → rebase → generate description |
| **Report** | Gather data and present a summary | `/health-check` checks API status, DB connections, queues |
| **Parameterized** | Different behavior based on arguments | `/deploy staging` vs `/deploy production` |

#### Discover command opportunities from session history

**Use cclogviewer MCP tools** (read `student.mcp_project_name` from progress.json for the `project` parameter):

```
# Search for multi-step workflow patterns
mcp__cclogviewer__search_logs(project=<project_name>, query="review|deploy|test|build|release|pr|migrate|check")

# Get recent sessions for context
mcp__cclogviewer__list_sessions(project=<project_name>, days=30, limit=10)

# Get tool usage patterns
mcp__cclogviewer__get_tool_usage_stats(project=<project_name>, days=30)
```

**Analyze the results** for:
- Multi-step workflows that appear across sessions
- Repeated Bash command sequences
- Tasks where the student manually ran several steps in order
- Workflows that could benefit from argument parameterization

#### Role-Specific Command Ideas

| Role | Suggested Command | Description |
|------|------------------|-------------|
| Frontend | `/pr-ready` | Lint, test, generate PR description |
| Backend | `/deploy <env>` | Environment-aware deployment with validation |
| QA | `/test-suite <module>` | Parameterized test runner for specific modules |
| DevOps | `/provision <service>` | Infrastructure setup with environment checks |
| Data | `/pipeline-check` | Validate data pipeline health and dependencies |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand advanced command features? Key points: `$ARGUMENTS` (and `$0`, `$1`) for parameterization, dynamic context injection with `` !`command` ``, and design patterns like validation-first and multi-step workflows."
- **Options**: "Yes, let's create one" / "Can you explain `$ARGUMENTS` again?" / "Show me the dynamic context injection syntax"
- On "$ARGUMENTS": re-explain with a concrete example — `/deploy staging` passes "staging" as `$ARGUMENTS` and `$0`, so the command can reference it in instructions
- On "dynamic context": show the backtick-bang syntax with `!`git branch --show-current`` and explain it executes at command load time

### Instructor: Action

**Present discovered command opportunities** to the student via AskUserQuestion:

If cclogviewer data is available, present discovered patterns:

"Based on your recent Claude Code sessions, here are multi-step workflows I found that would make great advanced commands:

1. **[Workflow Name]** — [Description]. Found in [N] sessions. [Why automating this as a command saves time].
2. **[Workflow Name]** — [Description]. Found in [N] sessions. [Why this is a good candidate].
3. **[Workflow Name]** — [Description]. Found in [N] sessions. [What makes this repeatable].

Which one would you like to create as an advanced command?"

- **Options**: The discovered workflows + "I have my own idea"
- If the student picks their own, proceed with that

**Fallback** — if cclogviewer MCP is unavailable or no meaningful patterns are found, use the Role-Specific Command Ideas table from the Content section.

#### Create the advanced command

Tell the student:
"Now let's create your advanced command. Create a new `.md` file in `.claude/commands/`:

1. Add frontmatter with `name` and `description`
2. Include `$ARGUMENTS` if the command accepts parameters
3. Write multi-step instructions
4. Add dynamic context injection where useful (`` !`command` ``)

Note: You should now have at least 2 commands total in `.claude/commands/` (the one from Module 1 plus this new one).

Create the command now. Use the {cc-course:continue} Skill tool when you've created your advanced command."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks in the student's repository:

1. **file_pattern**: Use Glob for `.claude/commands/*.md` — at least 2 files must exist
2. **content_check**: Use Read to verify the newest command file has:
   - Frontmatter with `name:` and `description:`
   - Multi-step instructions or `$ARGUMENTS` usage
   - Meaningful content (more than 10 lines)

**On failure**: Tell the student what's missing. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `create_advanced_command` to `true`, set `current_task` to `"commit_extensions"`

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

- [ ] Created a new command in `.claude/commands/`
- [ ] Command has proper frontmatter (name, description)
- [ ] Command uses `$ARGUMENTS` or multi-step workflow (or both)
- [ ] Command uses dynamic context injection where appropriate
- [ ] At least 2 total commands exist in `.claude/commands/`

---

## Chapter 8: Commit Your Extensions

**Chapter ID**: `3.8-commit`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 3.8](./KNOWLEDGE.md#chapter-38-commit-your-extensions) for security review guidelines, `.gitignore` recommendations, and team sharing best practices.

### Content

#### What to Commit

```
.claude/
├── settings.json          # Hook configurations
└── commands/
    └── *.md               # Custom commands (including new advanced command)

.mcp.json                  # MCP server configurations (project root!)
```

> **Note**: `.mcp.json` lives in the project root, not inside `.claude/`. Make sure you stage it separately.

#### What NOT to Commit

| File | Why Not |
|------|---------|
| `.claude/settings.local.json` | Personal overrides, not for the team |
| MCP configs with hardcoded secrets | Use `${ENV_VAR}` interpolation instead |
| `~/.claude/settings.json` | Global/personal settings |
| `~/.claude.json` | User-scope MCP config |

#### Security Review Before Committing

Before committing, verify:
- No API keys or tokens are hardcoded in `.mcp.json` (use `${ENV_VAR}`)
- No personal paths in hook commands (use `$CLAUDE_PROJECT_DIR`)
- No sensitive data in command files

#### Commit Commands

```bash
# Stage hook configuration
git add .claude/settings.json

# Stage MCP configuration (project root)
git add .mcp.json

# Stage new/updated commands
git add .claude/commands/

# Commit with descriptive message
git commit -m "Add Claude Code extensions

- Add hooks for [describe your hook]
- Configure [MCP server name] MCP integration
- Add [command name] advanced command"
```

### Instructor: Action

Tell the student:
"Let's commit your extensions to the repository.

1. **Security review** — Check your files for hardcoded secrets:
   - `.mcp.json`: Are API keys using `${ENV_VAR}` syntax?
   - `.claude/settings.json`: Are hook commands using `$CLAUDE_PROJECT_DIR`?

2. **Stage your files**:
   ```bash
   git add .claude/settings.json
   git add .mcp.json
   git add .claude/commands/
   ```

3. **Commit** with a descriptive message:
   ```bash
   git commit -m \"Add Claude Code extensions

   - Add [your-hook] automation hook
   - Configure [your-mcp] MCP integration
   - Add [your-command] advanced command\"
   ```

Run these commands now and use the {cc-course:continue} Skill tool when done."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks:

1. Use Bash (read-only) to run `git log --oneline -5` in the student's repository
2. Check that the latest commit includes `.claude` files or `.mcp.json`
3. Alternatively, run `git show --name-only HEAD` to verify committed files

**On failure**: Tell the student what's not committed yet. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `commit_extensions` to `true`, set `current_task` to `null`

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

- [ ] Reviewed files for hardcoded secrets
- [ ] Hook configuration committed (`.claude/settings.json`)
- [ ] MCP configuration committed (`.mcp.json` in project root)
- [ ] Advanced command committed (`.claude/commands/`)
- [ ] Commit message describes what was added

---

## Module Completion

### Instructor: Final Validation

After Chapter 8 is complete, tell the student:

"You've finished all the chapters! Let's validate your work and package it for submission.

**Step 1 — Validate**: Run the {cc-course:validate} Skill tool now. This checks that all required files exist, your hooks and MCP are properly configured, and your work is committed."

**Wait for the student to run validate.** If validation fails, help them fix issues and re-run.

**After validation passes**, tell the student:

"All checks passed!

**Step 2 — Submit**: Run the {cc-course:submit} Skill tool to package your work into a submission archive. This bundles your extensions, progress data, and session logs for instructor review."

**Wait for the student to run submit.**

After submission completes or if the student declines, proceed to the Seminar Summary below. Note: validation is required to unlock the next module. Submission is optional but recommended.

---

## Seminar Summary

### What You Learned

1. **Hook Events**: The 4 events (PreToolUse, PostToolUse, Notification, Stop) and when to use each
2. **Hook Configuration**: The 3-level structure (event → matcher group → handler array) in `.claude/settings.json`
3. **Hook Handler Types**: command, http, prompt, and agent handlers
4. **MCP Protocol**: Standardized tool integration via JSON-RPC (tools, resources, prompts)
5. **MCP Configuration**: `.mcp.json` in project root with transport types (stdio, http)
6. **Advanced Commands**: `$ARGUMENTS` substitution, dynamic context injection, multi-step workflows

### Files Created/Modified

| File | Purpose |
|------|---------|
| `.claude/settings.json` | Hook configurations |
| `.mcp.json` | MCP server configurations (project root) |
| `.claude/commands/*.md` | Advanced custom commands |

### Next Seminar Preview

In **Seminar 4: Agents**, you'll learn to orchestrate multiple Claude instances working in parallel using subagents and git worktrees.

---

## Session Export (Post-Completion)

After completing this seminar, you can export your session logs for review or portfolio purposes.

### Export Workflow

When module validation passes, the course engine offers to:

1. **Export session logs** to `exports/seminar3-session-{uuid}.json`
2. **Export summary stats** to `exports/seminar3-summary-{uuid}.json`
3. **Generate HTML report** (optional) for visual review

### Export Commands (via MCP cclogviewer)

The course engine uses these MCP calls:

```
mcp__cclogviewer__get_session_logs(
  session_id="<your-session-id>",
  output_path="./exports/seminar3-session.json"
)

mcp__cclogviewer__get_session_summary(
  session_id="<your-session-id>",
  output_path="./exports/seminar3-summary.json"
)

mcp__cclogviewer__generate_html(
  session_id="<your-session-id>",
  output_path="./exports/seminar3-report.html",
  open_browser=true
)
```

### What's Captured

| Data | Description |
|------|-------------|
| Session ID | Unique identifier for your learning session |
| Duration | Time spent on the module |
| Tool usage | Read, Write, Bash, Glob calls |
| Tasks completed | Which verification steps passed |
| Errors | Any issues encountered |

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
    check: "file_contains:.mcp.json:mcpServers"

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
