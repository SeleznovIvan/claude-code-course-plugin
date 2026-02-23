# Migration System

Schema versioning and migration logic for progress.json.

## Current Schema Version

```
CURRENT_VERSION = "1.1"
```

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-10 | Initial schema with 5 modules, session tracking, exports |
| 1.1 | 2026-02-13 | Add `mcp_project_name` to student, add `create_claudeignore` task to Module 1 |

---

## Migration Check Flow

Run this check on every `/cc-course:start`:

```
/cc-course:start N
        │
        ▼
Read student progress.json
        │
        ▼
Get schema_version (default "1.0" if missing)
        │
        ▼
Compare with CURRENT_VERSION
        │
        ├── Same version → Continue normally
        │
        ├── Older version → Run migrations
        │
        └── Newer version → Warn user to update plugin
```

---

## Version Comparison

```python
def compare_versions(student_version, plugin_version):
    """
    Compare semantic versions.
    Returns: -1 (older), 0 (same), 1 (newer)
    """
    student_parts = [int(x) for x in student_version.split(".")]
    plugin_parts = [int(x) for x in plugin_version.split(".")]

    for s, p in zip(student_parts, plugin_parts):
        if s < p:
            return -1  # student is older
        if s > p:
            return 1   # student is newer

    # Handle different lengths (1.0 vs 1.0.1)
    if len(student_parts) < len(plugin_parts):
        return -1
    if len(student_parts) > len(plugin_parts):
        return 1

    return 0  # same version
```

---

## Migration Execution

### Run Migrations Sequentially

```python
VERSION_ORDER = ["1.0", "1.1", "1.2", "2.0"]  # Add new versions here

MIGRATIONS = {
    "1.0 → 1.1": migrate_1_0_to_1_1,
    # "1.1 → 1.2": migrate_1_1_to_1_2,
    # Add migrations as versions are released
}

def run_migrations(progress, from_version, to_version):
    """
    Run all migrations between versions sequentially.
    Returns updated progress object.
    """
    start_idx = VERSION_ORDER.index(from_version)
    end_idx = VERSION_ORDER.index(to_version)

    migrations_run = []

    for i in range(start_idx, end_idx):
        from_v = VERSION_ORDER[i]
        to_v = VERSION_ORDER[i + 1]
        migration_key = f"{from_v} → {to_v}"

        if migration_key in MIGRATIONS:
            progress = MIGRATIONS[migration_key](progress)
            migrations_run.append(migration_key)

    progress["schema_version"] = to_version
    return progress, migrations_run
```

---

## Migration Principles

1. **Additive by default**: New fields get default values, existing fields preserved
2. **Never delete user data**: Even if a task is removed, keep the old completion status
3. **Sequential migrations**: Always migrate through each version step (1.0 → 1.1 → 1.2, not 1.0 → 1.2)
4. **Idempotent**: Running the same migration twice produces same result
5. **Backup first**: Create backup before any migration

---

## Example Migrations

### Migration Template

```python
def migrate_X_to_Y(progress):
    """
    Migration from version X to Y.

    Changes:
    - [List what this migration does]
    """
    # Add new fields with defaults
    # Preserve all existing data
    # Return modified progress

    return progress
```

### Migration 1.0 → 1.1

```python
def migrate_1_0_to_1_1(progress):
    """
    Add MCP project name tracking and .claudeignore task.

    Changes:
    - Added student.mcp_project_name field (default: null)
    - Added task: create_claudeignore to Module 1
    """
    # Add mcp_project_name to student
    if "mcp_project_name" not in progress.get("student", {}):
        progress["student"]["mcp_project_name"] = None

    # Add create_claudeignore task to Module 1
    module_1 = progress["modules"]["1-foundations-and-commands"]
    if "create_claudeignore" not in module_1["tasks"]:
        module_1["tasks"]["create_claudeignore"] = False

    return progress
```

### Example: Adding New Module Field

```python
def migrate_1_1_to_1_2(progress):
    """
    Add feedback field to all modules.

    Changes:
    - Added optional feedback field to each module
    """
    for module_key in progress["modules"]:
        module = progress["modules"][module_key]
        if "feedback" not in module:
            module["feedback"] = None

    return progress
```

### Example: Renaming a Field

```python
def migrate_1_2_to_2_0(progress):
    """
    Rename 'submission' to 'homework' for clarity.

    Changes:
    - Renamed submission → homework in all modules
    """
    for module_key in progress["modules"]:
        module = progress["modules"][module_key]
        if "submission" in module:
            module["homework"] = module.pop("submission")

    return progress
```

---

## Migration Messages

### Success Message

```
Welcome back! The course plugin has been updated.

Migrating your progress from v{old} to v{new}...
✓ Migration 1.0 → 1.1: Added MCP project name tracking and .claudeignore task

Your progress is preserved:
- Module 1: Completed ✓
- Module 2: In Progress (5/7 tasks)
- Module 3-5: Locked

Continue with /cc-course:start {current_module}
```

### Newer Than Plugin Warning

```
Warning: Your progress file uses schema v{student_version},
but this plugin only supports up to v{plugin_version}.

Please update the plugin:
  claude plugin update cc-course

Or reinstall:
  claude plugin marketplace add https://github.com/SeleznovIvan/claude-code-education
  claude plugin install cc-course@claude-code-education
```

---

## Error Handling

### Migration Failure

If a migration fails:

1. **Preserve original**: Keep backup at `progress.json.backup`
2. **Report error**: Show what failed and why
3. **Offer options**: Restore, manual fix, or report issue

```
Migration failed during 1.0 → 1.1

Error: {error_message}

Your original progress has been backed up to:
  {student-repo}/.claude/claude-course/progress.json.backup

Options:
1. Restore backup: cp progress.json.backup progress.json
2. Start fresh: /cc-course:reset (WARNING: loses all progress)
3. Report issue: https://github.com/SeleznovIvan/claude-code-course-plugin/issues
```

### Missing Version Field

If `schema_version` is missing (pre-versioning progress.json):

```python
def get_schema_version(progress):
    """Get version, defaulting to 1.0 for pre-versioning files."""
    return progress.get("schema_version", "1.0")
```

### Unknown Version

If version is not in VERSION_ORDER:

```
Unknown schema version: {version}

This may indicate a corrupted progress file or incompatible plugin version.

Options:
1. Update plugin to latest version
2. Check progress.json for corruption
3. Report issue if problem persists
```

---

## Backup Strategy

### Before Migration

```python
def create_backup(progress_path):
    """Create backup before migration."""
    backup_path = f"{progress_path}.backup"
    # Copy progress.json to progress.json.backup
    return backup_path
```

### Backup Location

```
{student-repo}/.claude/claude-course/progress.json.backup
```

### Recommend Git Commit

Before updating the plugin, recommend users commit their progress:

```bash
cd {student-repo}
git add .claude/claude-course/progress.json
git commit -m "Backup course progress before plugin update"
```

---

## Testing Migrations

### Test Procedure

1. Create test progress.json without `schema_version` field
2. Update plugin with new version (e.g., "1.1")
3. Run `/cc-course:start 1`
4. Verify:
   - Migration message shown
   - progress.json now has `schema_version: "1.1"`
   - New fields/tasks added with defaults
   - Existing completed tasks still `true`
   - Backup created

### Idempotency Test

Run `/cc-course:start` twice after migration:
- Second run should NOT show migration message
- No duplicate fields or values
- Schema version unchanged

---

## Adding New Migrations

When releasing a new plugin version with schema changes:

1. **Increment version** in progress.json template
2. **Add to VERSION_ORDER** in this file
3. **Write migration function** following the template
4. **Register in MIGRATIONS** dict
5. **Update version history table**
6. **Test** on existing progress.json files
