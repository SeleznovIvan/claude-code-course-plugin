---
name: cc-course:start
description: Start a Claude Code course module. Usage: /cc-course:start 1 (modules 1-5)
argument-hint: "[module-number 1-5]"
---

# Start Course Module

Start module **$ARGUMENTS** of the Claude Code Developer Course.

## Before Starting

1. Read `progress.json` to check learner state
2. Verify prerequisites (previous modules completed)
3. Record session start via cclogviewer MCP

## Session Tracking

When this command is invoked:

1. **Get current session ID** using MCP cclogviewer:
   ```
   mcp__cclogviewer__list_sessions(project=<cwd>, days=1, limit=1)
   ```

2. **Create session record** in progress.json:
   ```json
   {
     "session_id": "<uuid>",
     "started_at": "<ISO timestamp>",
     "ended_at": null,
     "tasks_completed": []
   }
   ```

3. **Update progress.json**:
   - Append session to `modules[module].sessions`
   - Set `current_session_id`
   - Set `current_module`
   - Set module `status = "in_progress"` if was `"not_started"`

## Module Mapping

| Argument | Module | Directory |
|----------|--------|-----------|
| 1 | Foundations & Commands | `1-foundations-and-commands` |
| 2 | Skills | `2-skills` |
| 3 | Extensions | `3-extensions` |
| 4 | Agents | `4-agents` |
| 5 | Workflows | `5-workflows` |

## Teaching Flow

For the complete teaching methodology and instructor persona, read [teaching.md](../teaching.md).

## Module Content

Read `lesson-modules/$ARGUMENTS-*/SCRIPT.md` for the teaching script.

Follow each chapter in order, running verification after each section.

## Progress Tracking

Update `progress.json` per [progress-tracking.md](../progress-tracking.md).

## Error Handling

### Module Locked
If the requested module is locked:
```
Module $ARGUMENTS is locked. Complete Module [previous] first.
Run /cc-course:start [previous] to continue.
```

### Invalid Argument
If $ARGUMENTS is not 1-5:
```
Invalid module number. Usage: /cc-course:start 1 (modules 1-5)
```

### MCP Unavailable
If cclogviewer MCP is not available:
- Log: "Session tracking unavailable - cclogviewer MCP not configured"
- Continue without session tracking
- Use fallback session ID based on timestamp
