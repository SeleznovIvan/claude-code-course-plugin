# Submission System

Submission logic shared by course subcommands.

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

### Path Resolution

```python
student_repo = progress["student"]["repository"]
course_data_dir = f"{student_repo}/.claude/claude-course"
progress_path = f"{course_data_dir}/progress.json"
sessions_dir = f"{course_data_dir}/sessions"
submissions_dir = f"{course_data_dir}/submissions"
```

---

## Manifest Schema

Each submission includes a manifest.json with metadata for instructor review:

```json
{
  "submission_version": "1.0",
  "seminar": "1-foundations-and-commands",
  "submitted_at": "2026-02-10T14:30:00Z",
  "student": {
    "name": "Jane Doe",
    "role": "frontend",
    "repository": "/path/to/repo"
  },
  "validation": {
    "passed": true,
    "passed_at": "2026-02-10T14:28:00Z",
    "tasks": {
      "create_claude_md": true,
      "claude_md_quality": true,
      "add_project_overview": true,
      "add_tech_stack": true,
      "add_conventions": true,
      "test_claude_understanding": true,
      "explore_slash_commands": true,
      "test_session_commands": true,
      "use_plan_mode": true,
      "create_custom_command": true,
      "commit_work": true
    }
  },
  "artifacts": {
    "claude_md": {
      "included": true,
      "line_count": 127,
      "char_count": 4532
    },
    "commands": {
      "count": 2,
      "files": ["new-component.md", "deploy.md"]
    }
  },
  "sessions": {
    "count": 2,
    "total_duration_minutes": 95,
    "files": [
      {
        "id": "abc-123",
        "logs": "abc-123-logs.json",
        "summary": "abc-123-summary.json"
      },
      {
        "id": "def-456",
        "logs": "def-456-logs.json",
        "summary": "def-456-summary.json"
      }
    ]
  }
}
```

---

## Artifacts by Module

### Module 1: Foundations & Commands

| Artifact | Source Path | Required |
|----------|-------------|----------|
| CLAUDE.md | `{repo}/CLAUDE.md` | Yes |
| Custom Commands | `{repo}/.claude/commands/*.md` | Yes (min 1) |
| Progress Snapshot | `progress.json` | Yes |
| Session Logs | via MCP `get_session_logs` | Yes |
| Session Summary | via MCP `get_session_summary` | Yes |

### Module 2: Skills

| Artifact | Source Path | Required |
|----------|-------------|----------|
| Skills Directory | `{repo}/.claude/skills/` | Yes |
| Reference Skill | `{repo}/.claude/skills/*.md` | Yes (min 1) |
| Action Skill | `{repo}/.claude/skills/*.md` | Yes (min 2 total) |
| Progress Snapshot | `progress.json` | Yes |
| Session Data | via MCP | Yes |

### Module 3: Extensions

| Artifact | Source Path | Required |
|----------|-------------|----------|
| Hooks | `{repo}/.claude/settings.json` or hooks config | Yes |
| MCP Config | `{repo}/.claude/mcp.json` | Yes |
| Advanced Command | `{repo}/.claude/commands/*.md` | Yes |
| Progress Snapshot | `progress.json` | Yes |
| Session Data | via MCP | Yes |

### Module 4: Agents

| Artifact | Source Path | Required |
|----------|-------------|----------|
| Agent Documentation | `{repo}/CLAUDE.md` (agents section) | Yes |
| Worktree Config | documentation of setup | Yes |
| Progress Snapshot | `progress.json` | Yes |
| Session Data | via MCP | Yes |

### Module 5: Workflows

| Artifact | Source Path | Required |
|----------|-------------|----------|
| GitHub Action | `{repo}/.github/workflows/*.yml` | Yes |
| Automation Script | `{repo}/scripts/claude-*.sh` | Yes |
| Progress Snapshot | `progress.json` | Yes |
| Session Data | via MCP | Yes |

---

## Zip Structure

```
seminar{N}-{name}-{date}.zip
├── manifest.json              # Metadata for instructor review
├── student-work/
│   ├── CLAUDE.md              # Module 1+
│   └── .claude/
│       ├── commands/          # Module 1+
│       │   └── *.md
│       ├── skills/            # Module 2+
│       │   └── *.md
│       ├── mcp.json           # Module 3+
│       └── settings.json      # Module 3+ (hooks)
├── progress/
│   └── progress.json          # Current progress snapshot
└── sessions/
    ├── {session-id-1}-logs.json
    ├── {session-id-1}-summary.json
    ├── {session-id-2}-logs.json
    └── {session-id-2}-summary.json
```

---

## Filename Sanitization

### sanitize_filename(name)

Convert student name to safe filename:

```python
def sanitize_filename(name):
    if not name:
        return "anonymous"

    # Convert to lowercase
    name = name.lower()

    # Replace spaces and special chars with hyphens
    name = re.sub(r'[^a-z0-9]+', '-', name)

    # Remove leading/trailing hyphens
    name = name.strip('-')

    # Limit length
    name = name[:30]

    return name or "anonymous"
```

### Examples

| Input | Output |
|-------|--------|
| "Jane Doe" | "jane-doe" |
| "John O'Brien" | "john-o-brien" |
| "María García" | "mar-a-garc-a" |
| "" | "anonymous" |
| null | "anonymous" |

---

## Submission Filename Format

```
seminar{module-number}-{sanitized-name}-{YYYY-MM-DD}.zip
```

Examples:
- `seminar1-jane-doe-2026-02-10.zip`
- `seminar2-john-smith-2026-02-15.zip`
- `seminar1-anonymous-2026-02-10.zip`

---

## Session Data Collection

### Getting Session IDs

Session IDs are stored in progress.json:

```python
module_key = "1-foundations-and-commands"
sessions = progress["modules"][module_key]["sessions"]
session_ids = [s["session_id"] for s in sessions]
```

### MCP Calls for Each Session

For each session ID, call:

```
mcp__cclogviewer__get_session_logs(
    session_id=session_id,
    project=student_repo
)
```

```
mcp__cclogviewer__get_session_summary(
    session_id=session_id,
    project=student_repo
)
```

### Save to Files

Save MCP responses to:
- `sessions/{session-id}-logs.json`
- `sessions/{session-id}-summary.json`

---

## Error Handling

| Scenario | Behavior |
|----------|----------|
| Module not completed | "Run /cc-course:validate first to verify completion" |
| CLAUDE.md missing | Error: "CLAUDE.md is required for submission" |
| No commands (Module 1) | Warning: "No custom commands found, proceeding with partial submission" |
| Student name not set | Use "anonymous" |
| Already submitted | "Previous submission exists. Overwrite? [Yes/No]" |
| MCP unavailable | Warning: "Session data unavailable - proceeding without session logs" |
| No sessions recorded | Error: "At least 1 session must be recorded in progress.json" |
| Zip creation fails | Error with specific message |

---

## Progress Update After Submission

Add submission record to module:

```json
"submission": {
  "submitted_at": "2026-02-10T14:30:00Z",
  "file_path": "{student-repo}/.claude/claude-course/submissions/seminar1-jane-doe-2026-02-10.zip",
  "file_size_bytes": 45678
}
```
