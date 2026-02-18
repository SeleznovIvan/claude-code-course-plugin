# Progress Tracking

State management logic shared by course subcommands.

## Student Data Location

All student-specific data is stored in the student's repository:

```
{student-repo}/.claude/claude-course/
├── progress.json                    # Student progress tracking
├── sessions/                        # Session exports from MCP
│   ├── {session-id}-logs.json
│   └── {session-id}-summary.json
└── submissions/                     # Homework archives
    └── seminar1-jane-doe-2026-02-10.zip
```

### Progress Discovery

When any skill needs to find the student's progress.json, use this algorithm.
**This works after `/clear`** because the working directory persists even when conversation history is wiped.

#### Step 1: Check working directory

Use Glob to look for `.claude/claude-course/progress.json` relative to the current working directory.

```bash
# Check cwd
Glob: .claude/claude-course/progress.json
```

If found → use it. Set `student_repo = cwd`.

#### Step 2: Check git root

If cwd check fails (e.g., student is in a subdirectory):

```bash
git rev-parse --show-toplevel
# Then check {git-root}/.claude/claude-course/progress.json
```

If found → use it. Set `student_repo = git root`.

#### Step 3: Ask the user

If both checks fail, ask the student using AskUserQuestion:
- **Question**: "I can't find your course progress. What's the path to your project repository?"
- Let the student provide the path, then check `{path}/.claude/claude-course/progress.json`

#### Important

- **NEVER fall back to the plugin's own `progress.json`** — that is a blank template
- The plugin folder (`~/.claude/plugins/cc-course/progress.json`) must NEVER be used as the student's progress file
- After discovery, set `student_repo` from the `progress["student"]["repository"]` field for all subsequent path resolution

### Path Resolution

After running Progress Discovery above:

```python
student_repo = progress["student"]["repository"]  # from discovered progress.json
course_data_dir = f"{student_repo}/.claude/claude-course"
progress_path = f"{course_data_dir}/progress.json"
sessions_dir = f"{course_data_dir}/sessions"
submissions_dir = f"{course_data_dir}/submissions"
```

### Plugin vs Student Data

- **Plugin folder** (`~/.claude/plugins/cc-course/`): Skills, SCRIPT.md files, validation logic
- **Student repo** (`{student-repo}/.claude/claude-course/`): Progress, sessions, submissions

The plugin's `progress.json` is a template copied to the student repo on first `/cc-course:start`.

---

## Schema Versioning

The progress.json schema is versioned to support plugin updates and migrations.

### Schema Version Field

```json
{
  "schema_version": "1.0",
  ...
}
```

### Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-10 | Initial schema with 5 modules, session tracking, exports |
| 1.1 | 2026-02-13 | Add `mcp_project_name` to student, add `create_claudeignore` task to Module 1 |

### Migration System

When the plugin is updated with schema changes:
1. On `/cc-course:start`, version is checked
2. If student's version is older, migrations run automatically
3. Progress is preserved, new fields get default values
4. Backup is created at `progress.json.backup`

For full migration logic, see [migration.md](migration.md).

### Pre-Versioning Compatibility

For progress files created before versioning:
- Missing `schema_version` is treated as `"1.0"`
- All applicable migrations run on first start after plugin update

---

## progress.json Schema

```json
{
  "schema_version": "1.0",
  "student": {
    "name": "string | null",
    "role": "frontend | backend | QA | DevOps | data | fullstack | null",
    "repository": "string | null",
    "started_at": "ISO timestamp | null",
    "mcp_project_name": "string | null"
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
        "create_claude_md": false,
        "claude_md_quality": false,
        "add_project_overview": false,
        "add_tech_stack": false,
        "add_conventions": false,
        "create_claudeignore": false,
        "test_claude_understanding": false,
        "explore_slash_commands": false,
        "test_session_commands": false,
        "use_plan_mode": false,
        "create_custom_command": false,
        "commit_work": false
      },
      "submission": {
        "submitted_at": "ISO timestamp | null",
        "file_path": "string | null",
        "file_size_bytes": "number | null"
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

### Submission Field

Each module includes a `submission` object to track homework submissions:

```json
"submission": {
  "submitted_at": "2026-02-10T14:30:00Z",
  "file_path": "{student-repo}/.claude/claude-course/submissions/seminar1-jane-doe-2026-02-10.zip",
  "file_size_bytes": 45678
}
```

- `submitted_at`: ISO timestamp of when submission was created
- `file_path`: Absolute path to the submission zip file
- `file_size_bytes`: Size of the zip file in bytes

When no submission exists, the field is `null` or has null values.

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
| unlocked | in_progress | User runs /cc-course:start N |
| in_progress | completed | All tasks pass validation |
| locked | unlocked | Prerequisites completed |

---

## Session Recording

### Recording Session Start

When a module is started (e.g., `/cc-course:start 1`):

1. **Get current session ID** using MCP cclogviewer:
   ```
   mcp__cclogviewer__list_sessions(
     project=progress["student"]["mcp_project_name"],
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

### Session Continuity

When a student uses `/cc-course:continue`, the session may have changed (e.g., they closed Claude Code and reopened it). The `continue` skill handles this by:

1. **Checking the latest session** via `mcp__cclogviewer__list_sessions(project=mcp_project_name, days=1, limit=1)`
2. **Comparing** the returned session ID with `current_session_id` in progress.json
3. **If different**: Close the old session (set `ended_at`), create a new session record, update `current_session_id`
4. **If same**: No action needed
5. **If MCP unavailable**: Skip silently, do not block the teaching flow

This ensures session records accurately reflect actual Claude Code sessions, even when the student takes breaks.

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
| 2-skills | Module 1 completed (validated) |
| 3-extensions | Module 2 completed (validated) |
| 4-agents | Module 3 completed (validated) |
| 5-workflows | Module 4 completed (validated) |

**Note**: "completed" means the student ran `/cc-course:validate` and all tasks passed. Submission is optional but prompted if missing when starting the next module.

---

## Export Workflow

### When to Offer Export

Export is offered when:
1. A module is completed (all tasks pass)
2. User runs `/cc-course:validate` on a completed module
3. User explicitly requests export

### Export Process

1. **Gather session IDs** from `modules[module].sessions`

2. **Export each session** to student's data directory:
   ```
   mcp__cclogviewer__get_session_logs(
     session_id=session_id,
     project=student_repo
   )
   ```
   Save output to: `{student-repo}/.claude/claude-course/sessions/{session_id}-logs.json`

   ```
   mcp__cclogviewer__get_session_summary(
     session_id=session_id,
     project=student_repo
   )
   ```
   Save output to: `{student-repo}/.claude/claude-course/sessions/{session_id}-summary.json`

3. **Generate visual report** (optional):
   ```
   mcp__cclogviewer__generate_html(
     session_id=primary_session,
     output_path="{student-repo}/.claude/claude-course/sessions/seminar[N]-report.html",
     open_browser=true
   )
   ```

4. **Record export** in progress.json under `exports[]`

### Session Data in Submissions

When creating a submission, the session data files are included in the zip:
```
submissions/seminar1-jane-doe-2026-02-10.zip
└── sessions/
    ├── {session-id-1}-logs.json
    ├── {session-id-1}-summary.json
    ├── {session-id-2}-logs.json
    └── {session-id-2}-summary.json
```

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
