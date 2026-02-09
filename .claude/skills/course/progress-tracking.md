# Progress Tracking

State management logic shared by course subcommands.

## progress.json Schema

```json
{
  "student": {
    "name": "string | null",
    "role": "frontend | backend | QA | DevOps | data | fullstack | null",
    "repository": "string | null",
    "started_at": "ISO timestamp | null"
  },
  "modules": {
    "1-foundations-and-commands": {
      "status": "not_started | unlocked | in_progress | completed",
      "started_at": "ISO timestamp | null",
      "completed_at": "ISO timestamp | null",
      "sessions": [
        {
          "session_id": "uuid",
          "started_at": "ISO timestamp",
          "ended_at": "ISO timestamp | null",
          "tasks_completed": ["task_key", ...]
        }
      ],
      "tasks": {
        "install_claude_code": false,
        "create_claude_md": false,
        "claude_md_quality": false,
        "add_project_overview": false,
        "add_tech_stack": false,
        "add_conventions": false,
        "test_claude_understanding": false,
        "explore_slash_commands": false,
        "test_session_commands": false,
        "use_plan_mode": false,
        "create_custom_command": false,
        "commit_work": false
      }
    },
    "2-skills": { ... },
    "3-extensions": { ... },
    "4-agents": { ... },
    "5-workflows": { ... }
  },
  "current_module": "module-key | null",
  "current_task": "task_key | null",
  "current_session_id": "uuid | null",
  "total_time_spent_minutes": 0,
  "exports": [
    {
      "module": "module-key",
      "session_id": "uuid",
      "exported_at": "ISO timestamp",
      "files": ["path/to/file.json", ...]
    }
  ],
  "graduation": {
    "completed": false,
    "completed_at": "ISO timestamp | null",
    "certificate_generated": false
  }
}
```

---

## Module State Machine

```
not_started → unlocked → in_progress → completed
     ↓
   locked (if prerequisites not met)
```

### State Transitions

| From | To | Trigger |
|------|-----|---------|
| not_started | unlocked | Previous module completed (or Module 1) |
| unlocked | in_progress | User runs /course:start N |
| in_progress | completed | All tasks pass validation |
| locked | unlocked | Prerequisites completed |

---

## Session Recording

### Recording Session Start

When a module is started (e.g., `/course:start 1`):

1. **Get current session ID** using MCP cclogviewer:
   ```
   mcp__cclogviewer__list_sessions(
     project=<auto-detect-from-cwd>,
     days=1,
     limit=1
   )
   ```

2. **Create session record**:
   ```json
   {
     "session_id": "<uuid>",
     "started_at": "<ISO timestamp>",
     "ended_at": null,
     "tasks_completed": []
   }
   ```

3. **Add to progress.json**:
   - Append to `modules[module].sessions`
   - Set `current_session_id`

### Recording Session End

When validation runs or session ends:
1. Find current session by `current_session_id`
2. Set `session.ended_at = <ISO timestamp>`
3. Clear `current_session_id` if module complete

### MCP Unavailable

If cclogviewer MCP is not available:
- Skip session tracking gracefully
- Show message: "Session tracking unavailable - cclogviewer MCP not configured"
- Continue with validation without export features
- Use fallback session ID: `fallback-{timestamp}`

---

## Task Update Operations

### After Each Completed Task

```python
task_name = "create_claude_md"
module = "1-foundations-and-commands"

# Mark task complete
progress["modules"][module]["tasks"][task_name] = True

# Add to current session's tasks_completed
current_session = find_session(progress["current_session_id"])
current_session["tasks_completed"].append(task_name)

# Check if module is complete
all_tasks_done = all(progress["modules"][module]["tasks"].values())
if all_tasks_done:
    progress["modules"][module]["status"] = "completed"
    progress["modules"][module]["completed_at"] = current_timestamp
    # Unlock next module
    next_module = get_next_module(module)
    if next_module:
        progress["modules"][next_module]["status"] = "unlocked"
```

---

## Module Unlocking Rules

| Module | Prerequisite |
|--------|--------------|
| 1-foundations-and-commands | None (always unlocked) |
| 2-skills | Module 1 completed |
| 3-extensions | Module 2 completed |
| 4-agents | Module 3 completed |
| 5-workflows | Module 4 completed |

---

## Export Workflow

### When to Offer Export

Export is offered when:
1. A module is completed (all tasks pass)
2. User runs `/course:validate` on a completed module
3. User explicitly requests export

### Export Process

1. **Gather session IDs** from `modules[module].sessions`

2. **Export each session**:
   ```
   mcp__cclogviewer__get_session_logs(
     session_id=session_id,
     output_path="./exports/seminar[N]-session-{session_id}.json"
   )

   mcp__cclogviewer__get_session_summary(
     session_id=session_id,
     output_path="./exports/seminar[N]-summary-{session_id}.json"
   )
   ```

3. **Generate visual report** (optional):
   ```
   mcp__cclogviewer__generate_html(
     session_id=primary_session,
     output_path="./exports/seminar[N]-report.html",
     open_browser=true
   )
   ```

4. **Record export** in progress.json under `exports[]`

---

## Helper Functions

### find_session(session_id)
```python
for module in progress["modules"].values():
    for session in module.get("sessions", []):
        if session["session_id"] == session_id:
            return session
return None
```

### get_next_module(current_module)
```python
order = [
    "1-foundations-and-commands",
    "2-skills",
    "3-extensions",
    "4-agents",
    "5-workflows"
]
idx = order.index(current_module)
if idx < len(order) - 1:
    return order[idx + 1]
return None
```

### get_first_incomplete_task(module)
```python
tasks = progress["modules"][module]["tasks"]
for task_key, completed in tasks.items():
    if not completed:
        return task_key
return None
```
