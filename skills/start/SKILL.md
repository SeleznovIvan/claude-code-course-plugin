---
name: cc-course:start
description: "Start a Claude Code course module. Usage: /cc-course:start 1 (modules 1-5)"
argument-hint: "[module-number 1-5]"
---

# Start Course Module

Start module **$ARGUMENTS** of the Claude Code Developer Course.

## Before Starting

1. **Check MCP availability** (cclogviewer-mcp must be installed)
2. Initialize student data directory (if first start)
3. Read `progress.json` to check learner state
4. **Check schema version and run migrations if needed**
5. Verify prerequisites (previous modules completed)
6. **Read [teaching.md](../teaching.md)** for instructor persona and teaching methodology
7. Record session start via cclogviewer MCP

## MCP Availability Check

Before proceeding with any module, verify cclogviewer MCP is available:

```bash
# Check if binary exists
command -v cclogviewer-mcp &> /dev/null
```

If the binary is not found, display this message and stop:

```
The cclogviewer MCP server is required but not installed.

Run /cc-course:setup to install it automatically.

Or install manually:
  1. Download from: https://github.com/SeleznovIvan/cclogviewer/releases
  2. Or with Go 1.21+: go install github.com/SeleznovIvan/cclogviewer/cmd/cclogviewer-mcp@latest
  3. Add to Claude: claude mcp add cclogviewer cclogviewer-mcp
```

If the binary exists, test that it responds to JSON-RPC:

```bash
echo '{"jsonrpc":"2.0","id":1,"method":"tools/list"}' | cclogviewer-mcp 2>/dev/null | head -c 100
```

If this fails, warn but allow continuing with degraded session tracking.

## Student Data Directory Initialization

On first `/cc-course:start`, create the student data directory structure:

### Check if First Start

```python
student_repo = detect_student_repo()  # from cwd or ask user
course_data_dir = f"{student_repo}/.claude/claude-course"

if not os.path.exists(course_data_dir):
    initialize_student_data(student_repo)
```

### Initialize Structure

Create the following structure in the student's repository:

```
{student-repo}/.claude/claude-course/
├── progress.json    # Copy from plugin template and initialize
├── sessions/        # Empty directory for session exports
└── submissions/     # Empty directory for homework archives
```

### Initialize progress.json

1. Copy the template from the plugin's `progress.json`
2. Set initial student info:
   ```json
   {
     "student": {
       "name": null,
       "role": null,
       "repository": "{student-repo}",
       "started_at": "{ISO timestamp}"
     }
   }
   ```
3. Ask the user for their name and role (if not already set)

### Directory Creation

Using Bash:
```bash
mkdir -p {student-repo}/.claude/claude-course/sessions
mkdir -p {student-repo}/.claude/claude-course/submissions
```

### Progress Path

After initialization, always read/write progress from:
```
{student-repo}/.claude/claude-course/progress.json
```

NOT from the plugin's template `progress.json`.

## MCP Project Name Detection

On first start (when `student.mcp_project_name` is null), detect and save the MCP project name for reliable session tracking:

### Detection Flow

```python
if progress["student"]["mcp_project_name"] is None:
    detect_mcp_project_name(progress, student_repo)
```

### Detection Steps

1. **Call MCP** to list available projects:
   ```
   mcp__cclogviewer__list_projects(sort_by="last_modified")
   ```

2. **Match student's repository path** to a project name:
   - Compare `student.repository` path against project names/paths
   - Project names in cclogviewer are typically the absolute path to the project directory

3. **Save matched name** to progress.json:
   ```json
   {
     "student": {
       "mcp_project_name": "/Users/student/my-project"
     }
   }
   ```

4. **Fallback**: If MCP is unavailable or no match found, use the repository path:
   ```python
   progress["student"]["mcp_project_name"] = student_repo
   ```

### Usage in MCP Calls

After detection, **always** use `mcp_project_name` for MCP calls instead of auto-detecting from cwd:

```python
project_name = progress["student"]["mcp_project_name"]

# Example: list sessions
mcp__cclogviewer__list_sessions(project=project_name, days=1, limit=1)

# Example: search logs
mcp__cclogviewer__search_logs(project=project_name, query="...")
```

This ensures consistent session tracking even if the student's working directory changes between sessions.

---

## Schema Version Check and Migration

Before proceeding with the module start, check if the student's progress.json needs migration.

For the complete migration logic, see [migration.md](../migration.md).

### Migration Check Flow

```python
CURRENT_VERSION = "1.1"  # Plugin's current schema version

def check_and_migrate(progress, progress_path):
    """Check schema version and run migrations if needed."""

    student_version = progress.get("schema_version", "1.0")

    if student_version == CURRENT_VERSION:
        # Same version, no migration needed
        return progress, None

    if is_newer(student_version, CURRENT_VERSION):
        # Student has newer version than plugin
        return None, "plugin_outdated"

    # Student has older version, run migrations
    backup_path = create_backup(progress_path)
    try:
        progress, migrations_run = run_migrations(
            progress,
            from_version=student_version,
            to_version=CURRENT_VERSION
        )
        save_progress(progress, progress_path)
        return progress, migrations_run
    except Exception as e:
        return None, f"migration_failed: {e}"
```

### Handle Migration Results

```python
result = check_and_migrate(progress, progress_path)

if result[1] == "plugin_outdated":
    # Show warning
    print(f"""
Warning: Your progress file uses schema v{student_version},
but this plugin only supports up to v{CURRENT_VERSION}.

Please update the plugin:
  claude plugin update cc-course
""")
    # Allow continuing but warn about potential issues

elif result[1] and result[1].startswith("migration_failed"):
    # Show error and recovery options
    print(f"""
Migration failed: {result[1]}

Your original progress has been backed up to:
  {progress_path}.backup

Options:
1. Restore backup and try again
2. Report issue at https://github.com/SeleznovIvan/claude-code-course-plugin/issues
""")
    return  # Stop execution

elif result[1]:  # migrations_run list
    # Show success message
    print(f"""
Welcome back! The course plugin has been updated.

Migrating your progress from v{student_version} to v{CURRENT_VERSION}...
""")
    for migration in result[1]:
        print(f"✓ Migration {migration}")

    print("\nYour progress is preserved. Continuing...")
    progress = result[0]

else:
    # No migration needed
    progress = result[0]
```

### Pre-Versioning Compatibility

For students who started before versioning was added:
- If `schema_version` field is missing, treat as "1.0"
- Run all migrations from 1.0 to current version
- Add `schema_version` field after migration

## Session Tracking

When this command is invoked:

1. **Get current session ID** using MCP cclogviewer:
   ```
   mcp__cclogviewer__list_sessions(project=progress["student"]["mcp_project_name"], days=1, limit=1)
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
