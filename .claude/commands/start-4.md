---
name: start-4
description: Start Module 4 - Agents. Learn subagents, parallel execution, and multi-agent orchestration.
---

# Module 4: Agents

You are starting the **Agents** module. Time to multiply your capabilities.

## Pre-flight Checks

1. Read `progress.json`
2. Verify Module 3 is completed (if not, redirect to `/start-3`)
3. Note the learner's repository for parallel work setup

## Module Objectives

By the end of this module, the learner will:
- ✅ Understand subagent architecture
- ✅ Use subagents for parallel tasks
- ✅ Set up git worktrees for true parallel execution
- ✅ Design effective multi-agent patterns

## Teaching Script

Read the detailed teaching content from:
`lesson-modules/4-agents/SCRIPT.md`

Follow each chapter in order:
1. **Chapter 1**: Understanding Subagents
2. **Chapter 2**: Launching Subagents
3. **Chapter 3**: Parallel Execution Patterns
4. **Chapter 4**: Git Worktrees
5. **Chapter 5**: Running Parallel Agents
6. **Chapter 6**: Merging Parallel Work
7. **Chapter 7**: Documenting Your Agent Pattern
8. **Chapter 8**: Commit Your Work

## Validation

Task keys for this module:
- `use_subagent`
- `create_worktrees`
- `run_parallel_agents`
- `merge_results`
- `document_pattern`
- `commit_updates`

## Completion

When all tasks are complete:

1. Update `progress.json`:
   - Set module status to "completed"
   - Unlock module 5-workflows

2. Celebrate!
   > "You've unlocked parallel processing power!
   > From now on, big tasks can be split across multiple agents.
   >
   > Final module: CI/CD integration. Type `/start-5`"

## Common Issues

**"Subagent didn't have my context"**
→ CLAUDE.md is shared, but conversation context isn't. Be explicit in delegation.

**"Worktrees have conflicts"**
→ Make sure tasks are truly independent. Overlapping files = conflicts.

**"It's slower than doing it myself"**
→ Parallelization has overhead. Best for larger, independent tasks.

**"How many agents can I run?"**
→ Limited by your machine and API rate limits. 2-3 is practical for most workflows.
