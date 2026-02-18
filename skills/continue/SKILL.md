---
name: cc-course:continue
description: Signal that you've completed the current step and are ready to proceed
---

# Continue

The student is signaling they are ready to proceed to the next phase.

## Instructions

> **PROGRESS DISCOVERY** (works after `/clear`):
>
> 1. `Read` the file `{cwd}/.claude/claude-course/progress.json` where `{cwd}` is your current working directory — this is the student's project repo
> 2. If not found, run `Bash: git rev-parse --show-toplevel` to get the git root, then `Read` `{git-root}/.claude/claude-course/progress.json`
> 3. If neither exists, ask the user for their repository path
>
> **NEVER** read a `progress.json` from any path containing `plugins/` or `cache/` — those are blank templates, not student data.

1. Find and read `progress.json` using the discovery block above
2. Extract `current_module` and `current_task`
3. If found, output: **Continuing — Module: [current_module], Task: [current_task]**
4. If `progress.json` is missing or fields are empty, output: **Ready to continue.**

## Session Tracking

Before resuming, check if the session has changed (e.g., student closed and reopened Claude Code):

### Session Check Flow

```python
mcp_project = progress["student"]["mcp_project_name"]

if mcp_project:
    try:
        # Get the most recent session
        latest = mcp__cclogviewer__list_sessions(
            project=mcp_project,
            days=1,
            limit=1
        )

        latest_session_id = latest[0]["session_id"]
        current_session_id = progress.get("current_session_id")

        if latest_session_id != current_session_id:
            # Session changed — close old, start new
            close_old_session(progress, current_session_id)
            create_new_session(progress, latest_session_id)
        # else: same session, no action needed

    except Exception:
        # MCP unavailable — skip session tracking, log warning
        pass
```

### Closing Old Session

```python
def close_old_session(progress, old_session_id):
    """Set ended_at on the old session record."""
    if old_session_id is None:
        return
    module_key = progress["current_module"]
    if module_key:
        for session in progress["modules"][module_key].get("sessions", []):
            if session["session_id"] == old_session_id:
                session["ended_at"] = current_iso_timestamp()
                break
```

### Creating New Session

```python
def create_new_session(progress, new_session_id):
    """Create a new session record and update current_session_id."""
    module_key = progress["current_module"]
    if module_key:
        progress["modules"][module_key]["sessions"].append({
            "session_id": new_session_id,
            "started_at": current_iso_timestamp(),
            "ended_at": None,
            "tasks_completed": []
        })
    progress["current_session_id"] = new_session_id
```

### MCP Unavailable

If `mcp_project_name` is null or MCP calls fail:
- Skip session tracking silently
- Do **not** block the teaching flow
- The student can still proceed normally

## Post-Completion Check

Before resuming the teaching flow, check the current module's state:

### All tasks done but module not yet validated (status is still `in_progress`)
If all task values in `modules[current_module].tasks` are `true` but `status != "completed"`:

Tell the student:
```
You've finished all the chapters! Time to validate your work.

Run /cc-course:validate to check everything passes.
```

Do NOT resume the teaching flow — direct them to validate instead.

### Module validated but no submission
If `status == "completed"` and `submission` is null:

Tell the student:
```
Module [N] is validated! You can optionally package your work for review.

Run /cc-course:submit to create a submission archive, or /cc-course:start [N+1] to continue to the next module.
```

### Module validated and submitted
If `status == "completed"` and `submission` is non-null:

Tell the student:
```
Module [N] is complete and submitted!

Run /cc-course:start [N+1] to begin the next module.
```

---

## Resume Teaching Flow

After session tracking and post-completion checks, proceed to the next phase for the current chapter:

- After **ACTION** phase → run **VERIFY**
- After failed **VERIFY** → re-run **VERIFY**
- After **CHECKPOINT** "I need more time" → resume where the student left off
- After **CHECKLIST** → advance to the next chapter
