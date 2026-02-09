# Status Dashboard

Dashboard rendering logic shared by course subcommands.

## Dashboard Layout

```
╔═══════════════════════════════════════════════════════════════╗
║              CLAUDE CODE DEVELOPER COURSE                     ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  Student: [name]                                              ║
║  Role: [role]                                                 ║
║  Repository: [path]                                           ║
║  Started: [date]                                              ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║  MODULE PROGRESS                                              ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  [icon] Module 1: Foundations & Commands  [status]            ║
║      Tasks: [completed]/[total]                               ║
║                                                               ║
║  [icon] Module 2: Skills                  [status]            ║
║      Tasks: [completed]/[total]                               ║
║                                                               ║
║  [icon] Module 3: Extensions              [status]            ║
║      Tasks: [completed]/[total]                               ║
║                                                               ║
║  [icon] Module 4: Agents                  [status]            ║
║      Tasks: [completed]/[total]                               ║
║                                                               ║
║  [icon] Module 5: Workflows               [status]            ║
║      Tasks: [completed]/[total]                               ║
║                                                               ║
╠═══════════════════════════════════════════════════════════════╣
║  OVERALL: [X]/5 modules complete                              ║
║  TIME SPENT: ~[X] minutes                                     ║
║  SESSIONS: [X] recorded                                       ║
║                                                               ║
║  [Current status message based on progress]                   ║
║                                                               ║
║  Next step: /cc-course:start [next-module]                    ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## Status Icons

| Status | Icon | Meaning |
|--------|------|---------|
| completed | Done | Module finished |
| in_progress | In Progress | Currently working |
| unlocked | Ready | Available to start |
| locked | Locked | Prerequisites not met |
| skipped | Skipped | Marked as skipped |

---

## Status Messages

Based on progress, show encouraging message:

| Progress | Message |
|----------|---------|
| Just started | "Welcome! You're about to unlock Claude Code's full potential." |
| Module 1 done | "Great foundation! Your project now has memory and custom commands." |
| Module 2 done | "Skills created! Claude now knows your team's patterns." |
| Module 3 done | "Extensions configured! Automation is working for you." |
| Module 4 done | "One module left! You're almost a Claude Code master." |
| All done | "Congratulations! You've completed the course!" |

---

## Session Information Section

If sessions have been recorded, add:

```
╠═══════════════════════════════════════════════════════════════╣
║  SESSION INFO                                                 ║
║  Current: [session-id]                                        ║
║  Module 1 sessions: [count]                                   ║
║  Exports: [count] available in ./exports/                     ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## Task Count Calculation

For each module:
```python
module_data = progress["modules"][module_key]
tasks = module_data["tasks"]
completed = sum(1 for v in tasks.values() if v is True)
total = len(tasks)
# Display as: "Tasks: 8/12"
```

---

## If No Progress Yet

If progress.json shows no student info:

```
╔═══════════════════════════════════════════════════════════════╗
║              CLAUDE CODE DEVELOPER COURSE                     ║
╠═══════════════════════════════════════════════════════════════╣
║                                                               ║
║  You haven't started the course yet!                          ║
║                                                               ║
║  To begin, type: /cc-course:start 1                           ║
║                                                               ║
║  This will:                                                   ║
║  • Set up your profile                                        ║
║  • Begin Module 1: Foundations & Commands                     ║
║  • Guide you through CLAUDE.md and your first command         ║
║                                                               ║
╚═══════════════════════════════════════════════════════════════╝
```

---

## Next Steps Logic

Determine next action based on state:

1. If no student info: "Start with /cc-course:start 1"
2. If current_module exists: "Continue with /cc-course:start [N]"
3. If module in_progress but paused: "Resume with /cc-course:start [N]"
4. If module complete, next unlocked: "Ready for /cc-course:start [N+1]"
5. If all complete: "You've graduated! Consider /cc-course:validate for final review"
