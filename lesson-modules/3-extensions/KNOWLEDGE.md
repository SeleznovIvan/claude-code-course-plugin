# Seminar 3: Extensions — Knowledge Base

## How to Use This File

This file complements `SCRIPT.md` with:
- **Deep dive explanations** — detailed background on each topic
- **External resources** — curated links to official docs and community content
- **Links verified** as of March 2026

**Separation of concerns:**
- `SCRIPT.md` = Teaching flow, validations, checklists (instructor guide)
- `KNOWLEDGE.md` = Deep content, external links, conceptual foundations (knowledge base)

---

## Chapter 3.1: Understanding Hooks

### Deep Dive

#### What Are Hooks?

Hooks are **event-driven automation triggers** that execute code in response to specific events during a Claude Code session. They provide a way to extend Claude's behavior without modifying Claude itself — running shell commands, calling webhooks, injecting LLM decisions, or spawning subagents at precisely the right moment in Claude's workflow.

Hooks are the most powerful extension mechanism in Claude Code because they operate at the system level: they can intercept tool calls before they happen, react to tool results after they complete, and integrate with any external system reachable from the shell.

#### Complete Hook Event Reference

Claude Code defines 22 hook events. Each event fires at a specific point in the session lifecycle:

**Session lifecycle events:**

| Event | When It Fires | Typical Use |
|-------|--------------|-------------|
| `SessionStart` | A new Claude session begins | Initialize logging, set up environment, send "session started" notification |
| `SessionEnd` | A Claude session is ending | Clean up temp files, flush logs, send summary notification |
| `InstructionsLoaded` | CLAUDE.md and skills have been loaded | Validate instructions, inject dynamic context |
| `ConfigChange` | Claude Code configuration changes | Reload dependent services, update caches |

**User interaction events:**

| Event | When It Fires | Typical Use |
|-------|--------------|-------------|
| `UserPromptSubmit` | User submits a prompt (before Claude processes it) | Log prompts, validate input, inject context |
| `Stop` | Claude stops generating a response | Send "task complete" notification, trigger follow-up actions |
| `StopFailure` | Turn ends due to API error (rate_limit, authentication_failed, server_error) | Alert on failures, retry logic, error logging |

**Tool lifecycle events:**

| Event | When It Fires | Typical Use |
|-------|--------------|-------------|
| `PreToolUse` | Before Claude executes a tool | Block dangerous operations, validate inputs, enforce policies |
| `PostToolUse` | After a tool executes successfully | Run formatters, linters, tests; log actions |
| `PostToolUseFailure` | After a tool execution fails | Log errors, suggest fixes, alert on repeated failures |
| `PermissionRequest` | When Claude requests permission for a tool | Auto-approve safe operations, enforce stricter rules |

**Notification events:**

| Event | When It Fires | Typical Use |
|-------|--------------|-------------|
| `Notification` | Claude sends a notification (e.g., task complete) | Forward to Slack, email, or desktop notification |

**Agent events:**

| Event | When It Fires | Typical Use |
|-------|--------------|-------------|
| `SubagentStart` | A subagent (forked skill) begins execution | Log subagent activity, set up subagent-specific config |
| `SubagentStop` | A subagent completes | Aggregate subagent results, clean up |
| `TeammateIdle` | A teammate agent becomes idle | Reassign work, notify user |
| `TaskCompleted` | A task has been completed | Trigger downstream workflows, update tracking |

**Worktree events:**

| Event | When It Fires | Typical Use |
|-------|--------------|-------------|
| `WorktreeCreate` | A git worktree is created | Set up worktree-specific config, install dependencies |
| `WorktreeRemove` | A git worktree is removed | Clean up resources, archive logs |

**Context events:**

| Event | When It Fires | Typical Use |
|-------|--------------|-------------|
| `PreCompact` | Before context compaction occurs | Save important context, flag critical information |
| `PostCompact` | After context compaction completes | Verify critical context survived, log compaction details |

**Elicitation events:**

| Event | When It Fires | Typical Use |
|-------|--------------|-------------|
| `Elicitation` | MCP server requests user input | Log elicitation requests, auto-respond in CI |
| `ElicitationResult` | User responds to MCP elicitation | Log responses, audit user decisions |

#### What Each Event Matches On

Different events use different matching criteria:

| Event | Matches On | Example Matcher |
|-------|-----------|----------------|
| `PreToolUse` | Tool name (regex) | `"Write"`, `"Write\|Edit"`, `"Bash"`, `"mcp__.*"` |
| `PostToolUse` | Tool name (regex) | `"Write"`, `"Bash"` |
| `PostToolUseFailure` | Tool name (regex) | `"Bash"`, `".*"` |
| `PermissionRequest` | Tool name (regex) | `"Write"`, `"Bash"` |
| `SessionStart` | Session source | `""` (matches all) |
| `Notification` | Notification type | `""` (matches all) |
| `Stop` | Empty string | `""` (matches all stops) |
| `StopFailure` | Error type | `"rate_limit"`, `"authentication_failed"`, `"server_error"` |
| `SubagentStart` | Agent identifier | `""` (matches all) |
| `SubagentStop` | Agent identifier | `""` (matches all) |
| `PostCompact` | Compaction type | `"manual"`, `"auto"` |
| `Elicitation` | MCP server name | `"mcp__github"`, `""` (matches all) |
| `ElicitationResult` | MCP server name | `"mcp__github"`, `""` (matches all) |
| Others | Varies | `""` (matches all) |

#### Hook Execution Model

Hooks run in the same environment as Claude Code: same working directory, same user permissions, full shell access. Multiple hooks on the same event run sequentially in definition order. PreToolUse hooks can block tool execution; other hooks run alongside.

#### Security Considerations

Hooks inherit the full permissions of the Claude Code process — they can read/write any file, execute any command, and make any network request. Project-scoped hooks (`.claude/settings.json`) run for everyone on the project, so always review hook changes in PRs before merging.

#### PreToolUse vs PostToolUse Decision Framework

The most commonly used hook events are PreToolUse and PostToolUse. Choosing between them requires understanding what is available at each point:

| Scenario | Use PreToolUse | Use PostToolUse |
|----------|---------------|-----------------|
| Prevent writes to protected files | Exit 2 to block | Too late — file already written |
| Auto-format after file writes | Cannot — file not written yet | Run formatter on the written file |
| Validate tool input before execution | Parse stdin JSON, validate, exit 2 if bad | Cannot prevent — already executed |
| Log what happened | Do not know outcome yet | Full context available (input + output) |
| Run tests after code changes | Premature — changes not applied yet | Good timing — code is written |
| Enforce naming conventions on new files | Check file_path in tool_input | Too late to rename |
| Notify on command execution | Know intent, not result | Know both intent and result |
| Block dangerous shell commands | Parse command from tool_input, exit 2 | Command already ran |

**Rule of thumb**: Use PreToolUse to **prevent** or **validate**. Use PostToolUse to **react** or **enhance**.

#### Handler Types: When to Use Each

Hooks support four handler types, each suited to different use cases:

**`command` — Shell command execution**
- Best for: Fast, deterministic logic — formatting, validation, file operations, logging
- Execution: Runs as a shell command in the project directory
- Input: Receives event context as JSON on stdin
- Output: Exit code determines behavior; stderr feeds back to Claude on exit 2
- Timeout: 600 seconds (default)
- Example: `"command": "npx prettier --write \"$(cat /dev/stdin | jq -r '.tool_input.file_path')\""`

**`http` — Webhook to external service**
- Best for: Notifications to Slack/Teams, CI triggers, audit logging to external systems
- Execution: Sends HTTP POST with event context as JSON body
- Input: Event context sent as request body
- Output: Response status determines behavior (2xx = success)
- Timeout: 30 seconds (default)
- Example: `"url": "https://hooks.slack.com/services/T.../B.../xxx"`

**`prompt` — LLM yes/no decision**
- Best for: Context-dependent decisions where rigid rules are insufficient
- Execution: Sends prompt to Claude with event context; expects yes/no response
- Input: The prompt text plus event context
- Output: Yes = allow, No = block
- Timeout: 30 seconds (default)
- Example: `"prompt": "Should this file be modified? It is in the protected/ directory. Respond yes or no."`

**`agent` — Subagent for complex reasoning**
- Best for: Multi-step analysis, code review before commits, security scanning
- Execution: Spawns a subagent that can use tools and reason about the situation
- Input: The prompt text plus full event context
- Output: Agent's conclusion determines behavior
- Timeout: 60 seconds (default)
- Example: `"prompt": "Review these changes for security issues. Check for hardcoded credentials, SQL injection, and XSS vulnerabilities."`

**Decision guide:** Binary/deterministic logic -> `command`. Needs external service -> `http`. Needs file inspection or complex reasoning -> `agent`. Simple contextual yes/no -> `prompt`.

### External Resources

- **[Claude Code Hooks Documentation](https://docs.anthropic.com/en/docs/claude-code/hooks)** — Official hooks reference with all events and configuration options
- **[Awesome Claude Code (GitHub)](https://github.com/hesreallyhim/awesome-claude-code)** — Community hook examples and patterns

---

## Chapter 3.2: Creating Hooks

### Deep Dive

#### Complete Hook Handler Schema

Each hook event contains an array of hook entries. Each entry has a `matcher` and one or more handlers:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "python3 /path/to/validate.py"
          }
        ]
      }
    ]
  }
}
```

The four handler type schemas:

```json
// command type — run a shell command
{
  "type": "command",
  "command": "shell-command-here",
  "timeout": 600
}

// http type — call a webhook
{
  "type": "http",
  "url": "https://example.com/webhook",
  "headers": { "Authorization": "Bearer ${TOKEN}" },
  "timeout": 30
}

// prompt type — ask the LLM a yes/no question
{
  "type": "prompt",
  "prompt": "Should this action be allowed? Respond yes/no.",
  "timeout": 30
}

// agent type — spawn a subagent for complex reasoning
{
  "type": "agent",
  "prompt": "Review these changes for security issues.",
  "timeout": 60
}
```

#### Optional Handler Fields

All handler types support these additional optional fields:

| Field | Type | Applies To | Description |
|-------|------|-----------|-------------|
| `timeout` | number | All types | Override the default timeout in seconds |
| `statusMessage` | string | All types | Custom spinner message displayed while the hook runs (e.g., `"Running security scan..."`) |
| `async` | boolean | `command` only | When `true`, the hook runs in the background without blocking Claude. Useful for logging, notifications, or other fire-and-forget operations |

**Example with optional fields:**
```json
{
  "type": "command",
  "command": "python3 /path/to/audit-log.py",
  "timeout": 10,
  "statusMessage": "Logging action to audit trail...",
  "async": true
}
```

#### Full Matcher Reference

The `matcher` field is a regular expression matched against a value that depends on the event type:

| Event | Matcher Matches Against | Example Matchers |
|-------|------------------------|-----------------|
| `PreToolUse` | Tool name | `"Write"`, `"Write\|Edit"`, `"Bash"`, `"mcp__.*"`, `".*"` |
| `PostToolUse` | Tool name | `"Write"`, `"Bash"`, `"Grep"` |
| `PostToolUseFailure` | Tool name | `"Bash"`, `".*"` |
| `PermissionRequest` | Tool name | `"Write"`, `"Bash"` |
| `SessionStart` | Session source | `""` (empty matches all) |
| `Notification` | Notification type | `""` (empty matches all) |
| `Stop` | Empty string | `""` (always matches) |
| `SubagentStart` | Agent identifier | `""` |
| `SubagentStop` | Agent identifier | `""` |
| `WorktreeCreate` | Worktree path | `""` |
| `WorktreeRemove` | Worktree path | `""` |
| `PreCompact` | Empty | `""` |
| `SessionEnd` | Empty | `""` |

**Important**: Tool names are case-sensitive. The tool name is `Write`, not `write` or `write_file`. Common tool names: `Write`, `Edit`, `Read`, `Bash`, `Glob`, `Grep`, `WebFetch`, `WebSearch`, `EnterWorktree`, `ExitWorktree`, `NotebookEdit`. MCP tools follow the pattern `mcp__servername__toolname`.

#### Official Hook-Development Skill

Anthropic provides a comprehensive `hook-development` skill in the `plugin-dev` plugin ([source](https://github.com/anthropics/claude-code/blob/main/plugins/plugin-dev/skills/hook-development/SKILL.md)). Install via `/plugins` → Discover → `plugin-dev`. It covers:

- Prompt-based hooks (recommended for complex validation)
- Security patterns (input validation, path safety)
- Debugging with `claude --debug`
- Plugin vs settings hook format differences
- Complete examples for all event types

**Prompt-based hooks** are recommended over command hooks for most use cases. They use LLM reasoning for context-aware decisions without bash scripting:

```json
{
  "type": "prompt",
  "prompt": "Validate file write safety. Check: system paths, credentials, path traversal. Return 'approve' or 'deny'.",
  "timeout": 30
}
```

Reserve `command` type hooks for fast, deterministic checks (formatting, linting).

#### Stdin JSON Format by Event

Hooks receive event context as JSON on stdin. The structure varies by event:

**PreToolUse stdin:**
```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/transcript.jsonl",
  "cwd": "/path/to/project",
  "permission_mode": "default",
  "hook_event_name": "PreToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/project/src/app.ts",
    "content": "console.log('hello');"
  }
}
```

**PostToolUse stdin (adds `tool_output`):**
```json
{
  "session_id": "abc123",
  "transcript_path": "/path/to/transcript.jsonl",
  "cwd": "/path/to/project",
  "permission_mode": "default",
  "hook_event_name": "PostToolUse",
  "tool_name": "Write",
  "tool_input": {
    "file_path": "/path/to/project/src/app.ts",
    "content": "console.log('hello');"
  },
  "tool_output": {
    "filePath": "/path/to/project/src/app.ts",
    "content": "console.log('hello');"
  }
}
```

Other events (Stop, SessionStart, etc.) follow the same pattern with `session_id`, `transcript_path`, `cwd`, `permission_mode`, and `hook_event_name`, plus event-specific fields (e.g., `stop_hook_active` for Stop).

**Common fields in all stdin JSON:**

| Field | Description |
|-------|-------------|
| `session_id` | Unique identifier for the current session |
| `transcript_path` | Path to the session transcript JSONL file |
| `cwd` | Current working directory |
| `permission_mode` | Current permission mode: `default`, `plan`, `acceptEdits`, `dontAsk`, or `bypassPermissions` |
| `hook_event_name` | Name of the event that triggered the hook |

#### `tool_input` Structure per Tool

Each tool sends different fields in `tool_input`. Knowing the structure is essential for writing hooks that parse the input correctly:

| Tool | `tool_input` Fields |
|------|-------------------|
| `Bash` | `{ "command": "npm test" }` |
| `Write` | `{ "file_path": "/abs/path/file.ts", "content": "..." }` |
| `Edit` | `{ "file_path": "/abs/path/file.ts", "old_string": "...", "new_string": "..." }` |
| `Read` | `{ "file_path": "/abs/path/file.ts" }` |
| `Glob` | `{ "pattern": "**/*.ts" }` |
| `Grep` | `{ "pattern": "TODO", "path": "/abs/path" }` |
| `WebFetch` | `{ "url": "https://example.com" }` |
| `NotebookEdit` | `{ "notebook_path": "...", "cell_id": "...", "new_source": "..." }` |

#### Exit Code Behavior

For command-type hooks, the exit code determines what happens next:

| Exit Code | Meaning | Effect |
|-----------|---------|--------|
| `0` | Success | Tool execution proceeds (PreToolUse) or hook completes normally (PostToolUse) |
| `2` | Block | **PreToolUse only**: Tool execution is blocked; stderr content is fed back to Claude as feedback so it can adjust |
| Any other | Non-blocking error | Logged but does not stop tool execution; treated as a warning |

**Example: Blocking writes to protected files**
```bash
#!/bin/bash
# Hook script: block-protected.sh
INPUT=$(cat /dev/stdin)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path')

if [[ "$FILE_PATH" == */protected/* ]]; then
  echo "Cannot modify files in protected/ directory" >&2
  exit 2
fi
exit 0
```

#### Structured JSON Output

Beyond exit codes, PreToolUse command hooks can output structured JSON to stdout for finer-grained control:

```json
// Allow the action (equivalent to exit 0)
{"permissionDecision": "allow"}

// Deny the action with a reason (equivalent to exit 2 + stderr)
{"permissionDecision": "deny", "reason": "File is in the protected directory"}

// Ask the user (show the standard permission prompt)
{"permissionDecision": "ask"}
```

This is more expressive than exit codes because you can choose to escalate to user confirmation (`"ask"`) rather than making a binary allow/deny decision.

#### Hook Storage Locations and Scopes

Hooks can be defined at multiple levels, each with different scope and visibility:

| Location | File | Scope | Use For |
|----------|------|-------|---------|
| Global | `~/.claude/settings.json` | All projects, all sessions | Personal workflow automation |
| Project | `.claude/settings.json` | This project, all team members | Team standards and policies |
| Local | `.claude/settings.local.json` | This project, only you | Personal project overrides |
| Plugin | Installed plugin config | Projects using the plugin | Plugin-provided automation |
| Skill | Skill frontmatter `hooks` field | When the skill is active | Skill-specific lifecycle hooks |
| Managed | Enterprise configuration | Organization-wide | Compliance and security policies |

**Priority order (highest to lowest):** Managed > Global > Project > Local > Plugin > Skill

When hooks at multiple levels match the same event and matcher, all matching hooks run. They do not override each other — they accumulate. This means a project hook and a global hook on the same event both execute.

#### Timeout Defaults

Each handler type has a default timeout. You can override these in the handler configuration:

| Handler Type | Default Timeout | Configurable |
|-------------|----------------|-------------|
| `command` | 600 seconds (10 min) | Yes, via `"timeout"` field |
| `http` | 30 seconds | Yes, via `"timeout"` field |
| `agent` | 60 seconds (1 min) | Yes, via `"timeout"` field |
| `prompt` | 30 seconds | Yes, via `"timeout"` field |

#### Real-World Hook Examples by Role

**Frontend — Auto-format TypeScript after writes (PostToolUse):**
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "FILE=$(cat /dev/stdin | jq -r '.tool_input.file_path'); if [[ \"$FILE\" == *.ts || \"$FILE\" == *.tsx ]]; then npx prettier --write \"$FILE\"; fi"
      }]
    }]
  }
}
```

**Backend — Block writes to migration files (PreToolUse, exit 2):**
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "FILE=$(cat /dev/stdin | jq -r '.tool_input.file_path'); if [[ \"$FILE\" == */migrations/* ]]; then echo 'Migration files require manual review' >&2; exit 2; fi"
      }]
    }]
  }
}
```

**QA — Run related tests after test file changes (PostToolUse):**
```json
{
  "hooks": {
    "PostToolUse": [{
      "matcher": "Write|Edit",
      "hooks": [{
        "type": "command",
        "command": "FILE=$(cat /dev/stdin | jq -r '.tool_input.file_path'); if [[ \"$FILE\" == *.test.* || \"$FILE\" == *.spec.* ]]; then npx jest \"$FILE\" --no-coverage 2>&1 | tail -20; fi"
      }]
    }]
  }
}
```

**DevOps — Validate YAML syntax on config writes (PreToolUse, exit 2):**
```json
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Write",
      "hooks": [{
        "type": "command",
        "command": "INPUT=$(cat /dev/stdin); FILE=$(echo \"$INPUT\" | jq -r '.tool_input.file_path'); CONTENT=$(echo \"$INPUT\" | jq -r '.tool_input.content'); if [[ \"$FILE\" == *.yaml || \"$FILE\" == *.yml ]]; then echo \"$CONTENT\" | python3 -c 'import yaml,sys; yaml.safe_load(sys.stdin)' 2>&1 || { echo 'Invalid YAML syntax' >&2; exit 2; }; fi"
      }]
    }]
  }
}
```

### External Resources

- **[Claude Code Hooks Documentation](https://docs.anthropic.com/en/docs/claude-code/hooks)** — Complete configuration reference with schema details
- **[Claude Code Settings Reference](https://docs.anthropic.com/en/docs/claude-code/settings)** — Settings file locations and structure

---

## Chapter 3.3: Testing Hooks

### Deep Dive

#### The Test-Debug-Iterate Loop

Hooks load at session start, so testing requires restarting: edit hook -> exit Claude -> start fresh session -> trigger the hooked action -> observe -> repeat if needed.

**Key insight**: Unlike skills, hooks are triggered implicitly by Claude's tool use. Craft prompts that cause the specific tool your hook targets:

| Hook Target | Prompt to Trigger |
|------------|------------------|
| `Write` matcher | "Create a new file called test-hook.ts with a hello world function" |
| `Edit` matcher | "In file X, change Y to Z" |
| `Bash` matcher | "Run the test suite" or "Check the git status" |
| `Read` matcher | "Read the contents of package.json" |
| `Stop` event | Any prompt — Claude always stops at the end |

#### Common Failure Modes

**1. Wrong matcher regex**
- Tool names are case-sensitive: `Write` not `write` or `write_file`
- The matcher is a regex, so `"Write"` also matches `"mcp__fs__WriteFile"` — use `"^Write$"` for exact match
- Test your regex: `echo "Write" | grep -E "^Write|Edit$"` should match

**2. Command not in PATH**
- Hooks run in a shell, but the PATH may differ from your interactive terminal
- Use full paths when in doubt: `/usr/local/bin/npx` instead of `npx`
- Test your command outside Claude first: paste the exact command in a terminal

**3. Incorrect stdin parsing**
- `jq` must be installed for JSON parsing (not available by default on all systems)
- The JSON structure varies by event — verify you are reading the correct fields
- Test with: `echo '{"tool_input":{"file_path":"test.ts"}}' | jq -r '.tool_input.file_path'`

**4. Wrong exit code**
- Exit code `1` is a non-blocking error (logged but does not stop anything)
- Exit code `2` blocks the action (PreToolUse only)
- Many scripts default to exit 1 on error — explicitly use `exit 2` when you want to block

**5. File permissions**
- If your hook calls a script file, it must be executable: `chmod +x hook-script.sh`
- Git does not preserve file permissions reliably across platforms — add `chmod` to setup instructions

**6. Stdin not consumed**
- If your hook command does not read stdin, the JSON is discarded — this is fine
- But if your command partially reads stdin and then exits, behavior may be unpredictable

#### Hook Output Interpretation

| Output Channel | Exit 0 | Exit 2 | Other |
|---------------|--------|--------|-------|
| **stdout** | Checked for structured JSON (`permissionDecision`); otherwise logged | Logged | Logged |
| **stderr** | Logged | Fed back to Claude as feedback | Logged |

When a PreToolUse hook exits with code 2, stderr becomes feedback to Claude. For example, `echo "Use the migration generator instead" >&2; exit 2` causes Claude to adjust its approach and use the suggested alternative.

#### Performance Considerations

- Hook execution time adds directly to Claude's response time
- A slow hook (e.g., running a full test suite) on `PostToolUse` for `Write` means every file write waits for the test suite
- Use targeted matchers to avoid running hooks unnecessarily
- Consider async notification hooks (http type to a webhook) for non-blocking logging
- Measure hook execution time: wrap commands with `time` during testing

#### Disabling Hooks and Verbose Mode

- **Disable all hooks**: Add `"disableAllHooks": true` to settings.json (remove to re-enable)
- **Verbose mode**: Press **Ctrl+O** during a session to see detailed hook execution logs — which hooks matched, commands executed, stdin/stdout/stderr content, exit codes, and timing

### External Resources

- **[Claude Code Hooks Documentation](https://docs.anthropic.com/en/docs/claude-code/hooks)** — Troubleshooting section and exit code reference
- **[jq Manual](https://jqlang.github.io/jq/manual/)** — JSON processing tool essential for parsing hook stdin

---

## Chapter 3.4: MCP Overview

### Deep Dive

#### What Is the Model Context Protocol?

MCP (Model Context Protocol) is an **open standard** for connecting AI assistants to external tools and data sources. It defines a structured communication protocol that allows Claude to discover, understand, and invoke tools provided by external servers — without requiring custom integration code for each tool.

Think of MCP as a USB standard for AI tools: any tool that speaks MCP can plug into any AI assistant that supports MCP, with automatic discovery and type-safe invocation.

#### Protocol Architecture

MCP uses **JSON-RPC 2.0** as its wire protocol. The lifecycle is: Startup (Claude launches server) -> Initialize (capability negotiation) -> Discovery (server reports tools/resources/prompts) -> Ready (tools available) -> Execution (Claude calls tools) -> Shutdown (session ends, server terminated).

#### Three MCP Primitives

MCP servers can expose three types of capabilities:

**1. Tools** — Actions the server can perform

Tools are the most commonly used primitive. Each tool has a name, description, and input schema. Claude invokes tools by sending structured input and receiving structured output.

Examples:
- `github.create_issue` — Creates a GitHub issue with title, body, labels
- `postgres.query` — Executes a SQL query and returns results
- `playwright.screenshot` — Takes a screenshot of a web page

**2. Resources** — Data that can be attached to context

Resources are references to data the server can provide. They can be attached to Claude's context using the `@` syntax:

```
@github:repo/owner/name/file.ts
@postgres:schema/users
```

Resources are read-only data injections — they add information to Claude's context without performing actions.

**3. Prompts** — Template prompts exposed as slash commands

MCP servers can expose prompt templates that become available as slash commands:

```
/mcp__github__create_pr_template
/mcp__postgres__explain_query
```

These provide guided workflows with pre-structured prompts that the server defines.

#### MCP vs REST APIs vs Shell Commands

Understanding where MCP fits in the tool integration landscape:

| Aspect | MCP | REST API | Shell Command |
|--------|-----|----------|---------------|
| Discovery | Automatic at startup | Manual documentation lookup | Manual, needs prior knowledge |
| Interface | Structured JSON-RPC with schemas | HTTP verbs + JSON | Text streams, ad-hoc parsing |
| Type Safety | Tool input schemas validate inputs | OpenAPI/JSON Schema (optional) | None |
| AI Integration | Purpose-built for LLM tool use | Requires wrapper/adapter | Requires output parsing |
| Security | Permission-gated per tool call | Token-based authentication | Full shell access |
| State | Server maintains connection state | Stateless per request | Process-based state |
| Error Handling | Structured error responses | HTTP status codes | Exit codes + stderr |
| Tool Count | Scales to many tools per server | One endpoint per action | One command per action |

**When to use each:**
- **MCP**: When you want Claude to discover and use tools automatically with type safety
- **REST API**: When building traditional web integrations outside of Claude
- **Shell commands (Bash tool)**: When you need quick, one-off operations or the tool has no MCP server

#### Security Model

MCP implements layered security: project-scoped servers (`.mcp.json`) require user approval on first use; each tool call goes through Claude's permission system; servers run as isolated child processes; user-scoped servers (`~/.claude.json`) are auto-approved.

#### Tool Search

When MCP tools exceed ~10% of the context window, Claude Code enables **Tool Search** — using tool descriptions to find relevant tools on demand. This makes tool descriptions critical: poorly described tools may not surface when needed.

#### The MCP Ecosystem

**Official Anthropic servers:**
- `@anthropic-ai/mcp-server-filesystem` — Safe file operations with directory restrictions
- `@anthropic-ai/mcp-server-playwright` — Browser automation and testing
- `@anthropic-ai/mcp-server-memory` — Persistent memory across sessions

**Popular community servers:**
- GitHub (OAuth-based, via Copilot endpoint)
- PostgreSQL, MySQL, SQLite (database querying)
- Slack, Linear, Jira (project management)
- Sentry (error tracking)
- Obsidian (note-taking)

**Custom servers**: Anyone can build an MCP server using official SDKs (TypeScript, Python, Go, Rust, and others).

### External Resources

- **[Model Context Protocol Specification](https://modelcontextprotocol.io)** — Official protocol specification and documentation
- **[MCP GitHub Organization](https://github.com/modelcontextprotocol)** — Official repositories, SDKs, and reference implementations
- **[Claude Code MCP Documentation](https://docs.anthropic.com/en/docs/claude-code/mcp)** — Claude Code-specific MCP configuration and usage
- **[MCP Server Registry](https://github.com/modelcontextprotocol/servers)** — Directory of available MCP servers

---

## Chapter 3.5: Configuring MCP Servers

### Deep Dive

#### Complete Configuration Schema

```json
{
  "mcpServers": {
    "server-name": {
      "type": "stdio",          // "stdio" (default), "http", or "sse"
      "command": "executable",   // stdio only
      "args": ["arg1", "arg2"], // stdio only
      "env": { "KEY": "${VAR}" } // optional, all types
    },
    "remote-server": {
      "type": "http",
      "url": "https://mcp.example.com/api",
      "headers": { "Authorization": "Bearer ${TOKEN}" }  // http only
    }
  }
}
```

| Field | Required | Applies To | Description |
|-------|----------|-----------|-------------|
| `type` | No | All | Transport: `"stdio"` (default), `"http"`, `"sse"` |
| `command` | Yes (stdio) | stdio | Executable to run |
| `args` | No | stdio | Arguments for the command |
| `url` | Yes (http/sse) | http, sse | Server endpoint URL |
| `env` | No | All | Environment variables |
| `headers` | No | http | HTTP headers |

#### Configuration File Locations and Priority

MCP configuration can live in multiple places. The priority order (highest to lowest):

| Priority | Location | File | Scope | Committed to Git? |
|----------|----------|------|-------|--------------------|
| 1 | Managed | Enterprise config | Organization-wide | N/A |
| 2 | User | `~/.claude.json` | All projects, personal | No |
| 3 | Project | `.mcp.json` (project root) | This project, all team members | Yes |
| 4 | Local | Personal project overrides | This project, only you | No |

**Key distinction**: `.mcp.json` at the project root is the team-shared configuration committed to git. User configuration in `~/.claude.json` is personal and applies across all projects.

When the same server name appears at multiple levels, the higher-priority configuration wins. This allows personal overrides of team-shared server configurations.

#### Transport Comparison

| Transport | When to Use | Pros | Cons |
|-----------|------------|------|------|
| `stdio` | Local servers, custom tools, most use cases | Fast (no network), simple setup, works offline | Must install server locally |
| `http` | Cloud/remote servers, SaaS integrations | No local install, OAuth support, serverless | Requires network, latency |
| `sse` | Legacy remote servers (pre-HTTP transport) | Streaming support | Deprecated in favor of http |

**Recommendation**: Use `stdio` for local tools and development. Use `http` for cloud services and team-shared remote servers.

#### Environment Variable Interpolation

Use `${VAR}` to read from environment (fails if not set) or `${VAR:-default}` for a fallback. Supported in: `command`, `args`, `env` values, `url`, and `headers` values.

**Security practice**: Never hardcode tokens in `.mcp.json`. Always use `${VAR}` interpolation so secrets live in the user's environment, not in git.

#### `claude mcp` CLI Reference

```bash
claude mcp add --transport stdio <name> -- <command> [args...]   # Add stdio server
claude mcp add --transport http <name> <url>                      # Add http server
claude mcp add --transport sse <name> <url>                       # Add SSE server (legacy)
claude mcp add-from-claude-desktop                                # Import from Claude Desktop
claude mcp list                                                   # List configured servers
claude mcp remove <name>                                          # Remove a server
```

#### Setup Guides for Popular Servers

**GitHub (OAuth):** `claude mcp add --transport http github https://api.githubcopilot.com/mcp/` — triggers browser OAuth flow, no token management needed.

**PostgreSQL:** `claude mcp add --transport stdio db -- npx @bytebase/dbhub --dsn "${DATABASE_URL}"` — for production, always use env vars.

**Filesystem:** `claude mcp add --transport stdio fs -- npx @anthropic-ai/mcp-server-filesystem /path/to/dir` — restricts file access to the specified directory.

**Playwright:** `claude mcp add --transport stdio playwright -- npx @anthropic-ai/mcp-server-playwright` — browser automation for E2E testing.

#### Multi-Server Configuration

A single `.mcp.json` can configure multiple servers, each with a unique name. All servers start when Claude launches. Tools are namespaced: `mcp__github__create_issue`, `mcp__db__query`, `mcp__playwright__screenshot`.

#### OAuth Authentication for Remote Servers

For `http` transport with OAuth-enabled servers (like GitHub), Claude Code handles the full OAuth flow automatically: opens a browser for authentication, stores tokens securely, and refreshes them on expiration. This eliminates manual token management entirely.

### External Resources

- **[Claude Code MCP Documentation](https://docs.anthropic.com/en/docs/claude-code/mcp)** — Configuration reference and setup guides
- **[MCP Server Registry](https://github.com/modelcontextprotocol/servers)** — Directory of available MCP servers with installation instructions
- **[MCP TypeScript SDK](https://github.com/modelcontextprotocol/typescript-sdk)** — Build your own MCP server in TypeScript
- **[MCP Python SDK](https://github.com/modelcontextprotocol/python-sdk)** — Build your own MCP server in Python

---

## Chapter 3.6: Using MCP in Practice

### Deep Dive

#### Verifying MCP Connections

Three methods to verify MCP servers are working:

1. **`claude mcp list`** (outside a session) — Shows configured servers, transport type, and connection status
2. **Startup messages** (when starting a session) — Claude reports each connected server with tool count: `Connected to MCP server: github (12 tools)`. Failed connections are also reported.
3. **`/context` command** (inside a session) — Shows all loaded MCP tools in the context window, confirming tools are available for use

#### MCP Prompts and Resources

**Prompts as slash commands:** MCP servers can expose prompt templates that become `/mcp__<server>__<prompt>` commands. Example: `/mcp__github__create_pr` for guided PR creation.

**Resources as context:** Resources can be attached using `@servername:protocol://path` syntax. Example: `@github:file://owner/repo/path/to/file.ts`. Resources are read-only context injections.

#### `MAX_MCP_OUTPUT_TOKENS` Configuration

MCP tool outputs are truncated at 25,000 tokens by default. For servers that return large results (database queries, log dumps, file listings), you may need to increase this:

```bash
export MAX_MCP_OUTPUT_TOKENS=50000
```

Set this in your shell profile (`.zshrc`, `.bashrc`) to persist across sessions. Increase conservatively — large tool outputs consume context window space.

#### `MCP_TIMEOUT` Configuration

Some MCP servers take time to start (e.g., servers that need to install npm packages or connect to databases). If you see timeout errors on first tool call:

```bash
export MCP_TIMEOUT=30000  # 30 seconds in milliseconds
```

This gives the server more time to initialize before the first tool call.

#### Error Handling When MCP Tools Fail

When an MCP tool call fails, Claude receives the error information and can retry with different parameters, fall back to alternative approaches (e.g., use the Bash tool), ask the user for guidance, or report the error with context. MCP errors are never silently swallowed.

#### Performance Considerations

- **Server startup time**: First tool call may be slow while the server initializes; subsequent calls reuse the running process
- **npx overhead**: Servers launched via `npx` incur package resolution on first run; install globally for frequently used servers (`npm install -g @package/server`)
- **Connection reuse**: MCP servers maintain persistent connections for the session duration
- **Context cost**: Each tool's schema occupies context window space; configure only servers needed for the current project

### External Resources

- **[Claude Code MCP Documentation](https://docs.anthropic.com/en/docs/claude-code/mcp)** — Usage patterns and troubleshooting
- **[Model Context Protocol Specification](https://modelcontextprotocol.io)** — Protocol details for advanced usage
- **[MCP Inspector](https://github.com/modelcontextprotocol/inspector)** — Debug tool for MCP server development

---

## Chapter 3.7: Advanced Custom Commands

### Deep Dive

#### Complete `$ARGUMENTS` Substitution Spec

Custom commands (`.claude/commands/*.md`) support argument substitution through template variables:

| Variable | Meaning | Example |
|----------|---------|---------|
| `$ARGUMENTS` | Full argument string after command name | `/deploy staging --force` → `"staging --force"` |
| `$ARGUMENTS[0]` or `$0` | First positional argument | `"staging"` |
| `$ARGUMENTS[1]` or `$1` | Second positional argument | `"--force"` |
| `$ARGUMENTS[2]` or `$2` | Third positional argument | (empty if not provided) |
| `${CLAUDE_SESSION_ID}` | Current session ID | `"abc-123-def"` |
| `${CLAUDE_SKILL_DIR}` | Directory containing the skill/command | `"/path/to/.claude/commands"` |

**If `$ARGUMENTS` is NOT present in the command content**, Claude auto-appends the raw arguments as `ARGUMENTS: <value>` at the end of the loaded content. This means simple commands that just need to know what arguments were passed do not need to explicitly reference `$ARGUMENTS` — the value is appended automatically.

**Explicit is better than implicit**: For clarity, always include `$ARGUMENTS` in your command content so it is clear where and how arguments are used.

#### Auto-Append Behavior

When `$ARGUMENTS` does not appear anywhere in the command markdown content, Claude appends the following to the end of the loaded content:

```
ARGUMENTS: staging --force
```

This is a convenience for simple commands where the argument meaning is obvious from context. However, for commands with structured arguments (multiple positional args, flags), explicit substitution with `$ARGUMENTS[0]`, `$ARGUMENTS[1]` etc. is strongly recommended.

#### Dynamic Context Injection with `` !`command` `` Syntax

Commands can embed shell command output that executes at load time:

```markdown
---
name: review
description: Review current branch changes
---

# Code Review
Branch: !`git branch --show-current`
Changed files: !`git diff --name-only main...HEAD`
Recent commits: !`git log --oneline main...HEAD`

Review all changed files for code quality, missing tests, and documentation gaps.
```

Every invocation injects fresh data, enabling branch-aware workflows, change-scoped reviews, environment detection, and timestamp injection.

**Security note**: These commands run with Claude Code's permissions. Do not include user-controlled input in the expressions.

#### Available Variables

Beyond `$ARGUMENTS`, commands have access to:

| Variable | Description | Example Value |
|----------|-------------|---------------|
| `${CLAUDE_SESSION_ID}` | Current session ID, unique per session | `"session-abc-123"` |
| `${CLAUDE_SKILL_DIR}` | Directory containing the command file | `"/home/user/project/.claude/commands"` |

These are useful for:
- **Session tracking**: Include `${CLAUDE_SESSION_ID}` in log file names
- **Relative file references**: Use `${CLAUDE_SKILL_DIR}` to reference files adjacent to the command

#### Command Design Patterns

**Pattern 1: Validation-First** — Check preconditions before acting. Verify branch, clean worktree, passing tests, and valid arguments before proceeding. If any check fails, stop and report. This prevents partial execution of multi-step workflows.

**Pattern 2: Multi-Step Workflow** — Ordered steps with error handling at each stage. Steps typically include: clean state check, quality checks (tests, lint, typecheck), branch update (fetch, rebase), and output generation. Each step that fails stops the pipeline.

**Pattern 3: Confirmation Pattern** — Discover what will be affected (list files, branches, resources), present the full list to the user, ask for explicit confirmation, then execute only if confirmed. Essential for any destructive operation.

**Pattern 4: Report Pattern** — Gather data from multiple sources, analyze and classify each metric (green/yellow/red), generate a summary report, and save as a persistent artifact using `${CLAUDE_SESSION_ID}` in the filename for uniqueness.

#### Commands vs Skills Decision Guide

Both commands (`.claude/commands/`) and skills (`.claude/skills/`) create `/slash-commands` for the user. When to use which:

| Consideration | Commands | Skills |
|--------------|----------|--------|
| File format | Single `.md` file | `SKILL.md` (optionally with supporting files) |
| Invocation | Always user-invoked with `/` | Can be user-invoked or auto-triggered |
| Auto-trigger | Never | Yes, via description matching |
| Frontmatter | Minimal (name, description) | Full (10 fields: model, context, agent, allowed-tools, etc.) |
| Subagent execution | No | Yes, via `context: fork` |
| Supporting files | No built-in mechanism | Directory with supporting files |
| Tool restrictions | No | Yes, via `allowed-tools` |
| Legacy support | Original mechanism | Newer, more capable |

**Use commands when:**
- Simple, single-purpose workflow
- Always user-invoked (never auto-triggered)
- No need for subagent execution or tool restrictions
- Quick to create — just a markdown file

**Use skills when:**
- Needs supporting files (examples, templates, references)
- Should auto-trigger based on context (via description matching)
- Benefits from subagent execution (`context: fork`)
- Needs tool restrictions (`allowed-tools`)
- Is part of a plugin

#### Supporting Files and Nested Discovery

Commands in nested directories become namespaced: `.claude/commands/dir/name.md` -> `/dir:name`. Keep the main command file under 500 lines; reference supporting files that Claude can read on demand.

### External Resources

- **[Claude Code Commands Documentation](https://docs.anthropic.com/en/docs/claude-code/slash-commands)** — Official commands reference
- **[Claude Code Skills Documentation](https://docs.anthropic.com/en/docs/claude-code/skills)** — Skills reference for comparison
- **[Awesome Claude Code (GitHub)](https://github.com/hesreallyhim/awesome-claude-code)** — Community command and skill examples

---

## Chapter 3.8: Commit Your Extensions

### Deep Dive

#### What to Commit — The Decision Matrix

Not all extension files belong in your repository. Here is the complete decision matrix:

| File / Directory | Commit? | Reason |
|-----------------|---------|--------|
| `.claude/settings.json` | Yes | Shared hook configurations for the team |
| `.claude/settings.local.json` | **No** | Personal overrides, never commit |
| `.mcp.json` (project root) | Yes | Shared MCP server configurations |
| `.claude/commands/*.md` | Yes | Custom commands shared with the team |
| MCP configs with hardcoded tokens | **No** | Security risk — use `${VAR}` interpolation |
| `~/.claude/settings.json` | **No** | Personal global settings, not in project |
| `~/.claude.json` | **No** | Personal MCP configuration, not in project |

#### What NOT to Commit

**`.claude/settings.local.json`** — Personal hook overrides: disabling team hooks, personal notification hooks, testing new hooks before proposing them.

**MCP configs with hardcoded secrets** — Never commit raw credentials. Always use `${VAR}` interpolation (e.g., `"${DATABASE_URL}"` instead of `"postgresql://admin:password123@prod.db/mydb"`).

#### `.gitignore` Recommendations

Add to your `.gitignore`:
```gitignore
# Claude Code personal files — do NOT share
.claude/settings.local.json

# Claude Code team files — SHOULD be shared (do not gitignore these)
# .claude/settings.json    <-- intentionally NOT ignored (hooks)
# .claude/commands/        <-- intentionally NOT ignored (commands)
# .mcp.json                <-- intentionally NOT ignored (MCP config)
# CLAUDE.md                <-- intentionally NOT ignored (project context)
```

**Common mistake**: Adding `.claude/` to `.gitignore` wholesale. This blocks all Claude Code configuration from being shared, including hooks, commands, and skills that the team needs.

#### Sensitive Data Handling

Use `${VAR}` interpolation in committed configs, document required environment variables in onboarding docs, and never use `${VAR:-default}` with real secrets (the default value would be committed).

#### Team Review Considerations

Hooks in `.claude/settings.json` affect everyone. Best practices: discuss proposed hooks (especially blocking PreToolUse hooks), test on a feature branch first, document hook behavior in CLAUDE.md, start with PostToolUse (observe) before adding PreToolUse (block), and document how to override via `.claude/settings.local.json`.

#### Crafting a Good Commit for Extensions

When committing extensions, the commit message should communicate what was added and why:

```
feat(.claude): add TypeScript formatting hooks and GitHub MCP

- Add PostToolUse hook to auto-format .ts/.tsx files with Prettier
- Add PreToolUse hook to block writes to migrations/ without review
- Configure GitHub MCP server via OAuth for issue/PR management
- Add /pr-ready command for branch preparation workflow

Hooks run automatically on file writes; MCP requires GITHUB_TOKEN.
```

Include context about:
- What hooks do and when they trigger
- What MCP servers are configured and what they require
- What commands were added and their purpose
- Any environment setup teammates need to do

#### Versioning and Backwards Compatibility

Pin MCP server versions in `npx` configs (e.g., `"@bytebase/dbhub@1.2.3"`) to avoid breaking changes. Test hooks after Claude Code upgrades. Document hook assumptions about tool names and stdin formats for future maintainers.

### External Resources

- **[Conventional Commits](https://www.conventionalcommits.org/)** — Commit message standard used throughout this course
- **[Claude Code Settings Reference](https://docs.anthropic.com/en/docs/claude-code/settings)** — Settings file locations and gitignore guidance
- **[Awesome Claude Code (GitHub)](https://github.com/hesreallyhim/awesome-claude-code)** — Community examples of hook and MCP configurations

---

## Additional Resources

### Official Documentation

- **[Claude Code Hooks](https://docs.anthropic.com/en/docs/claude-code/hooks)** — Complete hooks reference with all events, handler types, and configuration options
- **[Claude Code MCP](https://docs.anthropic.com/en/docs/claude-code/mcp)** — MCP configuration, transport types, and server management
- **[Claude Code Slash Commands](https://docs.anthropic.com/en/docs/claude-code/slash-commands)** — Custom commands reference
- **[Claude Code Settings](https://docs.anthropic.com/en/docs/claude-code/settings)** — Settings file locations and structure

### Protocol Specifications

- **[Model Context Protocol](https://modelcontextprotocol.io)** — Official MCP specification and documentation
- **[MCP GitHub Organization](https://github.com/modelcontextprotocol)** — SDKs, reference servers, and tooling
- **[MCP Server Registry](https://github.com/modelcontextprotocol/servers)** — Directory of available MCP servers

### Curated Collections

- **[Awesome Claude Code (GitHub)](https://github.com/hesreallyhim/awesome-claude-code)** — Hooks, commands, skills, and plugins
- **[Awesome MCP Servers (GitHub)](https://github.com/punkpeye/awesome-mcp-servers)** — Community-maintained list of MCP servers

### Official Channels

- **[Claude Code GitHub Issues](https://github.com/anthropics/claude-code/issues)** — Bug reports and feature requests
- **[Claude Code Changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)** — Version history and new features
