# Seminar 4: Agents

**Duration**: 120 minutes (80 min guided + 40 min implementation)

**Seminar ID**: `4-agents`

---

## Before You Begin

**Prerequisites**: You must have completed Modules 1-3 (Foundations & Commands, Skills, Extensions). Specifically:
- CLAUDE.md exists in your repository
- You've created custom commands in `.claude/commands/`
- You've created skills in `.claude/skills/`
- You've configured hooks in `.claude/settings.json`
- You've configured at least one MCP server in `.mcp.json`
- You understand slash commands, plan mode, the codify workflow, and event-driven automation

If you haven't completed earlier modules, run `/cc-course:start 1`, `/cc-course:start 2`, or `/cc-course:start 3` first.

---

## How This Course Works

This is an interactive course — Claude guides you through each chapter step by step. Here are the commands you'll use:

| Command | When to Use |
|---------|-------------|
| `/cc-course:start N` | Begin a module (1-5) |
| `/cc-course:continue` | Signal you're done with the current step and ready to move on |
| `/cc-course:hint` | Get help when you're stuck on a task |
| `/cc-course:status` | Check your overall progress across all modules |
| `/cc-course:validate` | Verify your work at the end of a module |
| `/cc-course:submit` | Package your completed work for instructor review |

**The flow**: Claude presents a concept → checks your understanding → gives you a hands-on task → you do it → Claude verifies → repeat. Use `/cc-course:continue` to tell Claude you're ready for the next step.

---

## Learning Objectives

By the end of this seminar, participants will:
- Understand subagent architecture: types, context isolation, and when to delegate
- Use explicit delegation prompts to launch subagents for focused tasks
- Recognize and apply parallel execution patterns (Divide & Conquer, Specialist, Writer + Reviewer, Fan-out, Pipeline)
- Set up git worktrees for conflict-free parallel agent work
- Run multiple Claude instances simultaneously in separate worktrees
- Merge parallel work, resolve conflicts, and clean up worktrees
- Document multi-agent patterns in CLAUDE.md for team reuse

---

## Chapter Phase Map

Quick reference showing which interactive phases each chapter has:

| Chapter | PRESENT | CHECKPOINT | ACTION | VERIFY |
|---------|---------|------------|--------|--------|
| 1 — Understanding Agents | yes | yes | — | — |
| 2 — Using Subagents | yes | yes | yes | yes |
| 3 — Parallel Patterns | yes | yes | — | — |
| 4 — Git Worktrees | yes | yes | yes | yes |
| 5 — Running Parallel Agents | yes | yes | yes | yes |
| 6 — Merging Parallel Work | yes | yes | yes | yes |
| 7 — Documenting Patterns | yes | yes | yes | yes |
| 8 — Commit Your Work | yes | — | yes | yes |

---

## Chapter Progress Map

Data for the table of contents and progress bar (see teaching.md).

| Step | Chapter Label | Short Title |
|------|---------------|-------------|
| 1 | Chapter 1 | Understanding Agents |
| 2 | Chapter 2 | Using Subagents |
| 3 | Chapter 3 | Parallel Patterns |
| 4 | Chapter 4 | Git Worktrees |
| 5 | Chapter 5 | Running Parallel Agents |
| 6 | Chapter 6 | Merging Parallel Work |
| 7 | Chapter 7 | Documenting Patterns |
| 8 | Chapter 8 | Commit Your Work |

**Total steps**: 8 | **Module title**: Agents | **Module number**: 4

---

## Chapter 1: Understanding Agents & Subagents

**Chapter ID**: `4.1-understanding-subagents`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 4.1](./KNOWLEDGE.md#chapter-41-understanding-agents-and-subagents) for the full subagent architecture, context inheritance details, and advanced delegation strategies.

### Content

#### What Is a Subagent?

A subagent is an **isolated Claude instance** launched via the Agent tool to handle a specific subtask. Think of it as delegation — the main agent coordinates, and subagents do focused work independently:

```
Main Agent (Coordinator)
    ├── Subagent A (Implementation)
    ├── Subagent B (Testing)
    └── Subagent C (Documentation)
```

Each subagent starts with a **fresh context** — it does not see the parent conversation history. However, it inherits CLAUDE.md, skills, and MCP configuration, so it follows the same project rules.

#### Subagent Types

Claude Code provides several built-in subagent types, each optimized for a specific purpose:

| Subagent Type | Tool Access | Best For |
|---------------|-------------|----------|
| `general-purpose` | Full tool access (Read, Write, Edit, Bash, etc.) | Complex multi-step tasks, implementation work |
| `Explore` | Read-only (Glob, Grep, Read) | Fast codebase search, understanding code structure |
| `Plan` | Read-only | Architecture planning, design proposals |
| Custom plugin agents | Defined by plugin | Plugin-specific workflows |

#### Context Isolation

Understanding what subagents inherit and what they don't is critical:

| Inherits | Does NOT Inherit |
|----------|-----------------|
| CLAUDE.md instructions | Parent conversation history |
| Skills and commands | Variables or state from parent |
| MCP server configuration | Any in-memory context |
| Project-level settings | Files the parent has read |

This isolation is a feature, not a limitation. Each subagent gets a **focused context** for its task, avoiding the "growing context" problem of long single sessions.

#### Foreground vs Background Execution

| Mode | Behavior | When to Use |
|------|----------|-------------|
| **Foreground** | Blocks until subagent completes | When you need the result before continuing |
| **Background** | Runs async; notification when done | For long-running tasks you don't need immediately |

#### When to Use Subagents vs Single Session

| Scenario | Single Session | Subagents |
|----------|---------------|-----------|
| Simple linear task | Best | Overkill |
| Complex multi-part task | Context grows too large | Each agent has focused context |
| Independent parallel work | Sequential only | True parallelism |
| Code review | Bias from writing the code | Fresh eyes on the code |
| Codebase exploration | Works but slow | Explore agent is faster |
| Architecture planning | Grows context with research | Plan agent keeps it separate |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand what subagents are and when to use them? Key: isolated contexts, parallel execution, focused tasks. Can you name the subagent types and explain why context isolation is a feature?"
- **Options**: "Yes, I understand — let's continue" / "I have a question" / "I need more explanation"
- On questions: answer them, then re-ask
- On "need more explanation": elaborate on context isolation (subagents start fresh so they don't carry irrelevant context from a long conversation), give a concrete example (e.g., an Explore agent finds all API endpoints without being distracted by the parent's implementation work), then re-ask

### Checklist

- [ ] Understand what subagents are (isolated Claude instances for focused tasks)
- [ ] Know the subagent types (general-purpose, Explore, Plan, custom plugin agents)
- [ ] Understand context isolation (inherits CLAUDE.md/skills/MCP, NOT conversation history)
- [ ] Know the difference between foreground and background execution
- [ ] Can identify scenarios where subagents beat single-session work

---

## Chapter 2: Using Subagents

**Chapter ID**: `4.2-using-subagents`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 4.2](./KNOWLEDGE.md#chapter-42-using-subagents) for Agent tool parameters, skill fork context, delegation prompt patterns, and subagent result handling.

### Content

#### How Claude Auto-Delegates

Claude may spawn subagents automatically when it detects a task would benefit from delegation. You'll see output like:

```
Launching agent for: analyzing test coverage...
```

This happens when Claude recognizes that part of a task is independent or would benefit from focused context.

#### Explicit Delegation Prompts

You can explicitly ask Claude to use subagents. Be specific about what you want delegated and which agent type to use:

**Research and exploration:**
```
Use a subagent to research how error handling works in this codebase.
```

```
Launch an Explore agent to find all API endpoints and their authentication methods.
```

**Background work:**
```
In the background, have an agent analyze the test coverage for the auth module.
```

**Implementation delegation:**
```
Use a subagent to write comprehensive unit tests for the UserService class
while you refactor the service implementation.
```

#### Skills with `context: fork`

Skills can run in isolated subagent contexts by adding `context: fork` to the SKILL.md frontmatter:

```markdown
---
name: security-audit
context: fork
description: Run a security audit in an isolated context
---

Review the codebase for common security vulnerabilities...
```

When this skill is invoked, it runs in a fresh subagent context — useful for review tasks where you want unbiased analysis.

#### Agent Tool Parameters

The Agent tool accepts several parameters that control subagent behavior:

| Parameter | Description | Example |
|-----------|-------------|---------|
| `prompt` | The task description for the subagent | `"Find all database queries that lack input validation"` |
| `subagent_type` | Agent type to use | `"Explore"`, `"Plan"`, `"general-purpose"` |
| `description` | Human-readable description shown in output | `"Searching for SQL injection risks"` |
| `run_in_background` | Run asynchronously | `true` / `false` |
| `isolation` | Isolation level | `"context"`, `"worktree"` |
| `model` | Override the model used | `"claude-sonnet-4-20250514"` |
| `resume` | Resume a previous subagent | Agent ID string |

#### Best Practices for Delegation

| Do | Don't |
|----|-------|
| Be specific about what the subagent should do | Give vague instructions like "look at the code" |
| Choose the right agent type for the task | Use general-purpose for simple searches (use Explore) |
| Review subagent output before acting on it | Blindly trust subagent results |
| Use background mode for long-running tasks | Block on tasks you don't need immediately |
| Include success criteria in the prompt | Leave the subagent to decide what "done" means |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand how to use subagents? Key: ask Claude to delegate with specific prompts, choose the right agent type (Explore for search, Plan for architecture, general-purpose for implementation), and review output before acting on it."
- **Options**: "Yes, I understand — let's try it" / "I have a question" / "Can you show more delegation examples?"
- On questions: answer them, then re-ask
- On "more examples": provide 3-4 role-specific delegation prompts based on the student's role, then re-ask

### Instructor: Action

#### Discover delegation opportunities from session history

Before asking the student to try a subagent, analyze their recent Claude Code sessions to find tasks that would benefit from delegation.

**Use cclogviewer MCP tools** (read `student.mcp_project_name` from progress.json for the `project` parameter):

```
# Get recent sessions
mcp__cclogviewer__list_sessions(project=<project_name>, days=30, limit=10)

# Search for complex, multi-step, or analysis patterns
mcp__cclogviewer__search_logs(project=<project_name>, query="complex|multi-step|parallel|refactor|review|analyze|audit|coverage|search|find all")

# Get tool usage to identify heavy exploration sessions
mcp__cclogviewer__get_tool_usage_stats(project=<project_name>, days=30)
```

**Analyze the results** for:
- Sessions with many Read/Grep/Glob calls (would benefit from Explore agent)
- Multi-step tasks where context grew large
- Tasks that involved both research and implementation
- Code review or audit requests

**Present 2-3 discovered patterns** to the student via AskUserQuestion:

"Based on your recent Claude Code sessions, here are tasks I found that would benefit from subagent delegation:

1. **[Pattern Name]** — [Description]. Found in [N] sessions. [Why a subagent would help — e.g., 'An Explore agent could do this search in focused context'].
2. **[Pattern Name]** — [Description]. Found in [N] sessions. [Why delegation helps].
3. **[Pattern Name]** — [Description]. Found in [N] sessions. [What agent type fits].

Which one would you like to try with a subagent? Or try: 'Ask Claude to use an Explore agent to analyze your codebase structure' (works for any project)."

- **Options**: The discovered patterns + "I'll try the Explore agent on my codebase" + "I have my own idea"
- If the student picks their own, proceed with that

**Fallback** — if cclogviewer MCP is unavailable, the project has no session history, or no meaningful patterns are found, suggest:

"Let's try a guaranteed-to-work delegation exercise. Ask Claude:

'Use an Explore agent to analyze the structure of this codebase — find the main entry points, key modules, and how they connect.'

This works for any project and demonstrates how Explore agents do focused research."

#### Execute the delegation

Tell the student:
"Now try delegating to a subagent. You can either:

1. **Use your chosen task** from the patterns above
2. **Use the Explore agent exercise**: Ask Claude to use an Explore agent to analyze your codebase

Type your delegation prompt now. Observe how Claude launches the subagent, what output you see, and what results come back.

Use the {cc-course:continue} Skill tool when the subagent has completed its task and you've reviewed the results."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

After the student returns:

Ask using AskUserQuestion:
- **Question**: "Did the subagent complete its task? What was the result? Did you notice the isolated context — the subagent worked without seeing your conversation history?"
- **Options**: "It worked — I saw the subagent results" / "It ran but the results weren't what I expected" / "I couldn't get it to use a subagent" / "I have questions about what happened"

For issues:
1. If the subagent didn't produce useful results: discuss prompt specificity — more specific prompts lead to better delegation
2. If Claude didn't spawn a subagent: suggest more explicit prompts like "Launch an Explore agent to..." or "Use a subagent to..."
3. Help them try again if needed

**On success** (student confirms subagent worked): Update progress.json: set task `use_subagent` to `true`, set `current_task` to `"create_worktrees"`

### Verification

```yaml
chapter: 4.2-using-subagents
type: manual
verification:
  questions:
    - "Request a task with explicit subagent delegation"
    - "Observe Claude launching a subagent"
    - "Review the subagent results"
  task_key: use_subagent
```

### Checklist

- [ ] Requested a task with explicit subagent delegation
- [ ] Observed Claude launching a subagent (saw agent output)
- [ ] Reviewed the subagent's results
- [ ] Understand how to choose the right agent type for a task

---

## Chapter 3: Parallel Execution Patterns

**Chapter ID**: `4.3-parallel-patterns`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 4.3](./KNOWLEDGE.md#chapter-43-parallel-execution-patterns) for detailed pattern diagrams, real-world case studies, and pattern composition strategies.

### Content

#### The 5 Parallel Execution Patterns

These patterns describe how to structure multi-agent work. Understanding them helps you pick the right approach for any complex task.

#### Pattern 1: Divide and Conquer

Split a large task into independent subtasks, execute in parallel, merge results:

```
        ┌──────────────┐
        │  Coordinator  │
        └──────┬───────┘
       ┌───────┼───────┐
       ▼       ▼       ▼
   ┌───────┐┌───────┐┌───────┐
   │Agent A││Agent B││Agent C│
   │(UI)   ││(API)  ││(DB)   │
   └───┬───┘└───┬───┘└───┬───┘
       └───────┼───────┘
        ┌──────┴───────┐
        │    Merge     │
        └──────────────┘
```

**Best for**: Tasks with clearly independent parts that don't overlap.

#### Pattern 2: Specialist Agents

Different agents handle different aspects based on expertise:

```
        ┌──────────────┐
        │    Task       │
        └──────┬───────┘
       ┌───────┼───────┐
       ▼       ▼       ▼
   ┌───────┐┌───────┐┌───────┐
   │Code   ││Test   ││Docs   │
   │Expert ││Expert ││Expert │
   └───────┘└───────┘└───────┘
```

**Best for**: Tasks requiring multiple types of output (implementation + tests + docs).

#### Pattern 3: Writer + Reviewer

One agent creates, another critiques, iterate until quality target is met:

```
   Round 1:              Round 2:
   ┌────────┐            ┌────────┐
   │ Writer │──creates──▶│Reviewer│──feedback──┐
   └────────┘            └────────┘            │
       ▲                                       │
       └───────────applies feedback────────────┘
```

**Best for**: Quality-critical work where fresh eyes catch issues the author misses.

#### Pattern 4: Fan-out / Fan-in

One coordinator spawns many workers for the same type of task, then aggregates:

```
        ┌──────────────┐
        │  Coordinator  │
        └──────┬───────┘
    ┌────┬────┬┴───┬────┐
    ▼    ▼    ▼    ▼    ▼
  ┌──┐┌──┐┌──┐┌──┐┌──┐
  │M1││M2││M3││M4││M5│  (audit each module)
  └──┘└──┘└──┘└──┘└──┘
    └────┴────┴┬───┴────┘
        ┌──────┴───────┐
        │  Aggregate   │
        └──────────────┘
```

**Best for**: Applying the same analysis across many modules, files, or services.

#### Pattern 5: Pipeline

Sequential stages where each agent builds on the previous output:

```
  ┌─────────┐    ┌─────────┐    ┌─────────┐    ┌─────────┐
  │ Stage 1 │───▶│ Stage 2 │───▶│ Stage 3 │───▶│ Stage 4 │
  │ Design  │    │  Build  │    │  Test   │    │ Deploy  │
  └─────────┘    └─────────┘    └─────────┘    └─────────┘
```

**Best for**: Workflows with ordered dependencies where each stage needs the previous output.

#### Pattern Selection Guide

| Need | Pattern | Why |
|------|---------|-----|
| Independent parts of one feature | Divide & Conquer | No dependencies between parts |
| Implementation + tests + docs | Specialist | Different expertise for each output |
| High-quality critical code | Writer + Reviewer | Fresh perspective catches bugs |
| Same analysis on many targets | Fan-out / Fan-in | Parallelizable identical tasks |
| Sequential build process | Pipeline | Each stage depends on the previous |

#### Role-Specific Pattern Recommendations

| Role | Best Pattern | Example Use Case |
|------|-------------|------------------|
| Frontend | Divide & Conquer | Component + Tests + Storybook in parallel |
| Backend | Specialist | Handler + Tests + API spec, each by a focused agent |
| QA | Fan-out | Audit multiple modules simultaneously for test coverage |
| DevOps | Pipeline | Config generation → Deploy → Verify → Monitor |
| Data | Specialist | Ingestion logic + Validation rules + Documentation |
| Fullstack | Divide & Conquer | Frontend + Backend + Integration tests |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Can you describe the main parallel execution patterns? Key: Divide & Conquer (split independent work), Writer + Reviewer (create then critique with fresh eyes), Fan-out (one coordinator, many workers on same task type). Which pattern would best fit your typical work?"
- **Options**: "Yes, I can describe them — let's continue" / "I have a question about the patterns" / "Can you help me choose the right pattern for my work?"
- On questions: answer them, then re-ask
- On "help me choose": ask about their most common complex tasks, then map each to the best pattern using the Role-Specific table, then re-ask

### Checklist

- [ ] Understand the 5 parallel execution patterns (Divide & Conquer, Specialist, Writer + Reviewer, Fan-out, Pipeline)
- [ ] Know when to use each pattern
- [ ] Identified which pattern fits your typical workflow
- [ ] Understand how patterns map to your role

---

## Chapter 4: Git Worktrees for Parallel Work

**Chapter ID**: `4.4-git-worktrees`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 4.4](./KNOWLEDGE.md#chapter-44-git-worktrees-for-parallel-work) for the complete git worktree reference, advanced worktree management, and Claude Code worktree integration details.

### Content

#### What Are Git Worktrees?

Git worktrees allow **multiple working directories sharing one `.git` repository**. Each worktree can be on a different branch, with its own set of checked-out files:

```
/my-project/                  # Main worktree (main branch)
/my-project-feature-auth/     # Worktree for auth feature branch
/my-project-feature-search/   # Worktree for search feature branch
     │                             │                            │
     └─────────── All share one .git directory ────────────────┘
```

#### Why Worktrees + Agents?

Without worktrees, parallel agents would **conflict on the same files**:

| Without Worktrees | With Worktrees |
|-------------------|----------------|
| Multiple Claude sessions edit the same files | Each agent has its own working directory |
| Changes overwrite each other | Changes are isolated to separate branches |
| No true parallelism | True parallel file modifications |
| Conflicts happen during work | Conflicts are deferred to merge time |

#### Worktree Commands

**Create a worktree with a new branch:**
```bash
git worktree add -b feature-auth ../my-project-feature-auth main
```
This creates a new branch `feature-auth` based on `main` and checks it out in `../my-project-feature-auth`.

**Create a worktree for an existing branch:**
```bash
git worktree add ../my-project-feature-auth feature-auth
```

**List all worktrees:**
```bash
git worktree list
```
Output:
```
/path/to/my-project                    abc1234 [main]
/path/to/my-project-feature-auth       def5678 [feature-auth]
/path/to/my-project-feature-search     ghi9012 [feature-search]
```

**Remove a worktree:**
```bash
git worktree remove ../my-project-feature-auth
```

#### Claude Code Worktree Integration

The Agent tool supports automatic worktree management via the `isolation` parameter:

| Isolation Mode | Behavior |
|---------------|----------|
| `"context"` | Subagent runs in the same directory (default) |
| `"worktree"` | Subagent gets its own worktree automatically |

With `isolation: "worktree"`, Claude Code:
1. Creates a new worktree for the subagent
2. The subagent works in its own directory on its own branch
3. CLAUDE.md, skills, and MCP configuration are inherited
4. The worktree can be cleaned up after merging

#### Practical Setup

For the upcoming exercise, you'll create 2 worktrees for independent tasks. Think about two features or improvements in your project that could be worked on simultaneously:

**Good choices** (independent work):
- Adding a new utility function + writing tests for existing code
- Creating a new component + updating documentation
- Adding a CLI command + refactoring a module

**Bad choices** (overlapping work):
- Two features that modify the same files
- Refactoring that touches everything

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand git worktrees? Key: multiple working directories for one repo, each on a different branch, perfect for parallel agents because they avoid file conflicts. Do you have two independent tasks in mind for the exercise?"
- **Options**: "Yes, I understand and have two tasks in mind" / "I understand worktrees but need help picking tasks" / "I have a question about worktrees"
- On "help picking tasks": ask about their project, suggest two independent tasks appropriate for their role and codebase
- On questions: answer them, then re-ask

### Instructor: Action

Tell the student:
"Now let's create 2 worktrees for your independent tasks.

1. **Choose two independent tasks** from your project (or use the ones we discussed)
2. **Create the worktrees**:

```bash
# Create worktree for task A
git worktree add -b feature-task-a ../$(basename $(pwd))-task-a main

# Create worktree for task B
git worktree add -b feature-task-b ../$(basename $(pwd))-task-b main

# Verify both exist
git worktree list
```

Replace `feature-task-a` and `feature-task-b` with descriptive branch names for your chosen tasks.

3. **Verify**: Run `git worktree list` — you should see at least 3 entries (main + 2 worktrees)

Create your worktrees now. Use the {cc-course:continue} Skill tool when you've created both worktrees."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks in the student's repository:

1. **worktree_count**: Use Bash (read-only) to run `git worktree list | wc -l` — must be at least 3 (main + 2 feature worktrees)
2. **worktree_list**: Use Bash to run `git worktree list` and verify the output shows multiple branches

**On failure**: Tell the student what's missing. Common issues: worktree command syntax wrong, branch already exists (use a different name), directory already exists. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `create_worktrees` to `true`, set `current_task` to `"run_parallel_agents"`

### Verification

```yaml
chapter: 4.4-git-worktrees
type: automated
verification:
  checks:
    - command: "git worktree list | wc -l"
      min_value: 3
      task_key: create_worktrees
```

### Checklist

- [ ] Understand what git worktrees are (multiple working directories, one .git)
- [ ] Created at least 2 worktrees with descriptive branch names
- [ ] Verified worktrees with `git worktree list`
- [ ] Know how to remove worktrees when done
- [ ] Chosen two independent tasks for parallel work

---

## Chapter 5: Running Parallel Agents

**Chapter ID**: `4.5-parallel-agents`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 4.5](./KNOWLEDGE.md#chapter-45-running-parallel-agents) for headless mode options, allowed tools configuration, background agent management, and monitoring strategies.

### Content

#### Three Ways to Run Parallel Agents

| Method | How | Best For |
|--------|-----|----------|
| **Multiple terminals + headless mode** | `claude -p "task" --allowedTools Write,Edit,Bash` | Full control, independent tasks |
| **Background agents** | `run_in_background: true` in Agent tool | Tasks managed by a coordinator |
| **Worktree isolation** | `isolation: "worktree"` in Agent tool | Automatic worktree + branch management |

#### Headless Mode (`claude -p`)

Headless mode runs Claude non-interactively — it processes the prompt and exits when done. This is perfect for parallel work:

```bash
claude -p "Implement the authentication middleware with tests" --allowedTools Write,Edit,Bash,Read,Glob,Grep
```

Key flags:
| Flag | Purpose |
|------|---------|
| `-p "prompt"` | Run in headless (non-interactive) mode |
| `--allowedTools` | Restrict which tools the agent can use |
| `--output-format json` | Get structured JSON output |
| `--model` | Override the model |

#### Practical Exercise: Run Claude in Both Worktrees

Here's the workflow you'll follow:

**Terminal 1** (in your first worktree):
```bash
cd ../my-project-task-a
claude -p "Implement [task A description]. Create the necessary files and write tests."
```

**Terminal 2** (in your second worktree):
```bash
cd ../my-project-task-b
claude -p "Implement [task B description]. Create the necessary files and write tests."
```

Both agents work simultaneously, each in their own directory with their own branch. No conflicts possible.

#### Monitoring Parallel Work

- **Watch both terminals**: Each shows progress independently
- **Check output**: Each agent reports what files it created/modified
- **Time savings**: Two tasks complete in the time of one

#### Best Practices

| Do | Don't |
|----|-------|
| Give clear, complete task descriptions | Give vague prompts like "make it better" |
| Use `--allowedTools` to limit scope | Give agents unrestricted access to everything |
| Let agents work autonomously until done | Interrupt or add input mid-execution |
| Use descriptive branch names | Use generic names like `feature-1`, `feature-2` |
| Review all output before merging | Merge without reviewing agent work |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you know how to run parallel agents? Key: use separate worktrees so agents don't conflict, headless mode with `claude -p` for non-interactive execution, and you can monitor both terminals simultaneously."
- **Options**: "Yes, I'm ready to run parallel agents" / "I have a question" / "Can you clarify headless mode?"
- On questions: answer them, then re-ask
- On "clarify headless mode": explain that `claude -p "prompt"` runs Claude non-interactively — it processes the prompt, does the work, and exits. No user input needed during execution. Perfect for running in background terminals.

### Instructor: Action

> **IMPORTANT**: Before the student exits, save progress to progress.json. Update:
> - `current_module`: `"4-agents"`
> - `current_task`: `"run_parallel_agents"`

Tell the student:
"Time to run parallel agents. This requires exiting the current session to open multiple terminals.

**Before you exit**, I'll save your progress so the course resumes cleanly.

**Steps:**

1. **Exit this session** (type `exit`)
2. **Open 2 terminal windows** (or use tmux/split panes)
3. **Terminal 1** — navigate to your first worktree and run Claude:
   ```bash
   cd [path-to-worktree-a]
   claude -p \"[Your task A description]\"
   ```
4. **Terminal 2** — navigate to your second worktree and run Claude:
   ```bash
   cd [path-to-worktree-b]
   claude -p \"[Your task B description]\"
   ```
5. **Wait** for both agents to complete their tasks
6. **Return to the course**: Come back to your main project directory and run `/cc-course:continue`

> **Tip**: Write clear, specific prompts for each agent. Include what files to create, what tests to write, and what success looks like.

Use the {cc-course:continue} Skill tool when both agents have completed their tasks."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

After the student returns:

Ask using AskUserQuestion:
- **Question**: "Did both agents complete their tasks? What did each one produce? How did it feel running parallel agents — did you notice the time savings?"
- **Options**: "Both completed successfully" / "One completed but the other had issues" / "Neither worked as expected" / "I couldn't get the setup working"

For issues:
1. If agents failed: check the error messages, verify the worktree paths are correct, suggest more specific prompts
2. If only one worked: help debug the failing one, possibly try again with adjusted prompts
3. If setup failed: walk through the terminal setup again

**On success** (student confirms both agents completed): Update progress.json: set task `run_parallel_agents` to `true`, set `current_task` to `"merge_results"`

### Verification

```yaml
chapter: 4.5-parallel-agents
type: manual
verification:
  questions:
    - "Run Claude in two different worktrees simultaneously"
    - "Give each agent an independent task"
    - "Observe both completing their tasks"
  task_key: run_parallel_agents
```

### Checklist

- [ ] Opened two terminal windows
- [ ] Launched Claude in headless mode in both worktrees
- [ ] Both agents completed their tasks independently
- [ ] No file conflicts occurred (each agent in its own directory)
- [ ] Reviewed the output from both agents

---

## Chapter 6: Merging Parallel Work

**Chapter ID**: `4.6-merging`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 4.6](./KNOWLEDGE.md#chapter-46-merging-parallel-work) for merge strategies, conflict resolution techniques, and post-merge testing best practices.

### Content

#### Pre-Merge Review

Before merging any agent work, review what each branch contains:

**Review changes on each branch:**
```bash
# See what task-a changed
git diff main...feature-task-a

# See what task-b changed
git diff main...feature-task-b
```

**Run tests on each branch** (if applicable):
```bash
# Test task-a
cd ../my-project-task-a
npm test  # or your project's test command

# Test task-b
cd ../my-project-task-b
npm test
```

#### Merge Workflow

Follow this step-by-step process:

1. **Return to main worktree**:
   ```bash
   cd /path/to/my-project
   ```

2. **Merge first branch**:
   ```bash
   git merge feature-task-a
   ```

3. **Run tests** after first merge:
   ```bash
   npm test  # verify nothing broke
   ```

4. **Merge second branch**:
   ```bash
   git merge feature-task-b
   ```

5. **Resolve conflicts** if any (see below)

6. **Run full test suite** after both merges:
   ```bash
   npm test  # verify everything works together
   ```

#### Handling Merge Conflicts

If agents modified overlapping files (rare with good task selection, but possible):

1. Git marks conflicts in the affected files
2. Open the file and look for conflict markers (`<<<<<<<`, `=======`, `>>>>>>>`)
3. **Use Claude for help**: "Look at these merge conflicts and suggest the best resolution"
4. After resolving, stage and commit:
   ```bash
   git add <conflicted-files>
   git commit -m "Resolve merge conflicts between task-a and task-b"
   ```

#### Cleanup

After successfully merging both branches:

```bash
# Remove worktrees
git worktree remove ../my-project-task-a
git worktree remove ../my-project-task-b

# Delete feature branches (they're merged)
git branch -d feature-task-a
git branch -d feature-task-b
```

Verify cleanup:
```bash
git worktree list   # Should show only main worktree
git branch          # Feature branches should be gone
```

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you know the merge workflow? Key: review each branch with `git diff main...branch`, merge one at a time, run tests after each merge, resolve conflicts if any, then clean up worktrees and branches."
- **Options**: "Yes, let's merge" / "I have a question" / "What if there are conflicts?"
- On questions: answer them, then re-ask
- On "what if conflicts": explain the conflict resolution workflow — git marks conflicts, you (or Claude) resolve them, stage, and commit. Emphasize that good task selection minimizes conflicts.

### Instructor: Action

Tell the student:
"Let's merge your parallel work back to main.

1. **Review each branch**:
   ```bash
   git diff main...feature-task-a
   git diff main...feature-task-b
   ```

2. **Merge the first branch**:
   ```bash
   git merge feature-task-a
   ```

3. **Merge the second branch**:
   ```bash
   git merge feature-task-b
   ```

4. **If you get merge conflicts**: Use Claude to help resolve them — 'Look at these merge conflicts and suggest the best resolution'

5. **Clean up worktrees and branches**:
   ```bash
   git worktree remove ../[your-worktree-a]
   git worktree remove ../[your-worktree-b]
   git branch -d feature-task-a
   git branch -d feature-task-b
   ```

6. **Verify clean state**:
   ```bash
   git worktree list
   git branch
   ```

Use the {cc-course:continue} Skill tool when you've merged both branches and cleaned up."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks in the student's repository:

1. **merge_check**: Use Bash (read-only) to run `git log --oneline -10` — look for merge commits or the merged branch content
2. **worktree_cleanup**: Use Bash to run `git worktree list` — ideally only main worktree remains
3. **branch_cleanup**: Use Bash to run `git branch` — feature branches should be deleted

**On failure**: Tell the student what's not yet done. Help with:
- Merge conflicts: walk through resolution
- Worktree removal errors: check if there are uncommitted changes in the worktree
- Branch deletion errors: branch may not be fully merged (use `git branch -D` if they're sure)
Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `merge_results` to `true`, set `current_task` to `"document_pattern"`

### Verification

```yaml
chapter: 4.6-merging
type: automated
verification:
  checks:
    - command: "git log --oneline -10"
      contains: "Merge|merge|feature"
      task_key: merge_results
```

### Checklist

- [ ] Reviewed changes on each branch (`git diff main...branch`)
- [ ] Merged both branches to main
- [ ] Resolved any merge conflicts
- [ ] Ran tests after merging (if applicable)
- [ ] Removed worktrees (`git worktree remove`)
- [ ] Deleted feature branches (`git branch -d`)
- [ ] Verified clean state

---

## Chapter 7: Documenting Agent Patterns

**Chapter ID**: `4.7-documenting`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 4.7](./KNOWLEDGE.md#chapter-47-documenting-agent-patterns) for pattern documentation templates, team onboarding guides, and pattern library design.

### Content

#### Why Document Patterns?

You just completed a multi-agent workflow. Without documentation, team members (and your future self) won't know:
- What pattern you used and when to use it
- How to set up worktrees and branches
- What prompts to give each agent
- How to merge and clean up

Adding this to CLAUDE.md means Claude itself will follow these patterns when asked.

#### What to Document in CLAUDE.md

Your agent pattern documentation should include:

| Section | What to Write |
|---------|--------------|
| **Pattern name** | Descriptive name (e.g., "Parallel Feature Development") |
| **When to use** | Scenarios where this pattern applies |
| **Setup steps** | Branch creation, worktree commands |
| **Agent prompts** | Example prompts for each agent |
| **Merge workflow** | How to review, merge, resolve conflicts |
| **Cleanup steps** | Worktree removal, branch deletion |

#### Template for CLAUDE.md

```markdown
## Multi-Agent Patterns

### Pattern: Parallel Feature Development

**When to use**: Implementing 2+ independent features simultaneously.

**Setup**:
1. Create feature branches and worktrees:
   ```bash
   git worktree add -b feature-name ../project-feature-name main
   ```
2. Launch Claude in each worktree with specific task prompts

**Agent prompts**:
- Task A: "Implement [feature A] with tests. Files to create: [list]"
- Task B: "Implement [feature B] with tests. Files to create: [list]"

**Merge**:
1. Review: `git diff main...feature-name`
2. Merge one at a time: `git merge feature-name`
3. Run tests after each merge
4. Resolve conflicts if any

**Cleanup**:
```bash
git worktree remove ../project-feature-name
git branch -d feature-name
```
```

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand what to document? Key: pattern name, when to use it, setup steps (branches + worktrees), agent prompts, merge workflow, and cleanup steps — all in CLAUDE.md so Claude and your team can follow the pattern."
- **Options**: "Yes, I know what to document" / "I have a question" / "Can you show the template again?"
- On questions: answer them, then re-ask
- On "show template": re-present the CLAUDE.md template from the Content section, then re-ask

### Instructor: Action

#### Discover patterns worth documenting from session history

**Use cclogviewer MCP tools** (read `student.mcp_project_name` from progress.json for the `project` parameter):

```
# Search for multi-agent or parallel work patterns
mcp__cclogviewer__search_logs(project=<project_name>, query="worktree|parallel|agent|delegate|subagent|merge")

# Get recent sessions to see what workflows they've been doing
mcp__cclogviewer__list_sessions(project=<project_name>, days=7, limit=5)
```

**Analyze the results** for:
- The parallel workflow the student just completed
- Any other multi-agent patterns they've used
- Workflows that could benefit from the patterns taught in Chapter 3

**Fallback** — if cclogviewer is unavailable or no additional patterns are found, the student should document the pattern they just used (parallel worktree development).

#### Create the documentation

Tell the student:
"Now let's add a 'Multi-Agent Patterns' section to your CLAUDE.md. You should document:

1. **The pattern you just used** — Parallel Feature Development with worktrees
2. **Optionally** — any other pattern from Chapter 3 that fits your workflow (Writer + Reviewer, Fan-out, etc.)

Add a new section to your CLAUDE.md using the template from the lesson. Include:
- Pattern name and when to use it
- Setup steps (worktree creation commands)
- Agent prompt examples (based on what you actually used)
- Merge and cleanup steps

Use the {cc-course:continue} Skill tool when you've added the Multi-Agent Patterns section to your CLAUDE.md."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks in the student's repository:

1. **file_exists**: Use Glob to check `CLAUDE.md` exists
2. **content_check**: Use Read to verify CLAUDE.md contains agent pattern documentation. Check for keywords matching the regex: `Multi-Agent|Parallel|Worktree|Agent Pattern|parallel.*development|worktree.*pattern`

**On failure**: Tell the student what's missing — they need a section documenting at least one multi-agent pattern with setup, prompts, merge, and cleanup steps. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `document_pattern` to `true`, set `current_task` to `"commit_updates"`

### Verification

```yaml
chapter: 4.7-documenting
type: automated
verification:
  checks:
    - file_contains: "CLAUDE.md"
      pattern: "Multi-Agent|Parallel|Worktree|Agent Pattern"
      task_key: document_pattern
```

### Checklist

- [ ] Added "Multi-Agent Patterns" section to CLAUDE.md
- [ ] Documented at least one pattern with a descriptive name
- [ ] Included setup steps (branch + worktree creation)
- [ ] Included example agent prompts
- [ ] Included merge and cleanup instructions
- [ ] Pattern documentation is clear enough for a teammate to follow

---

## Chapter 8: Commit Your Work

**Chapter ID**: `4.8-commit`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 4.8](./KNOWLEDGE.md#chapter-48-commit-your-work) for commit message conventions, what to include in agent workflow commits, and branch hygiene tips.

### Content

#### What to Commit

The key artifact from this module is your updated CLAUDE.md with agent pattern documentation:

```
CLAUDE.md                      # Updated with Multi-Agent Patterns section
```

Plus any merged feature branch work from your parallel agents (already committed during merge).

#### What to Verify Before Committing

| Check | Command | Expected Result |
|-------|---------|-----------------|
| Worktrees cleaned up | `git worktree list` | Only main worktree |
| Feature branches deleted | `git branch` | No leftover feature branches |
| Working tree clean | `git status` | Only CLAUDE.md changes |

#### Commit Message Template

```bash
git add CLAUDE.md
git commit -m "Document multi-agent patterns in CLAUDE.md

- Add Parallel Feature Development pattern with worktree setup
- Include agent prompts, merge workflow, and cleanup steps
- Patterns are reusable by team and by Claude"
```

### Instructor: Action

Tell the student:
"Let's commit your updated CLAUDE.md.

1. **Verify clean state**:
   ```bash
   git worktree list    # Only main worktree
   git branch           # No leftover feature branches
   git status           # See what needs committing
   ```

2. **Stage and commit**:
   ```bash
   git add CLAUDE.md
   git commit -m \"Document multi-agent patterns in CLAUDE.md

   - Add Parallel Feature Development pattern
   - Include setup, prompts, merge, and cleanup steps\"
   ```

Run these commands now and use the {cc-course:continue} Skill tool when done."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks:

1. Use Bash (read-only) to run `git log --oneline -5` in the student's repository
2. Check that a recent commit includes CLAUDE.md changes
3. Alternatively, run `git show --name-only HEAD` to verify committed files

**On failure**: Tell the student what's not committed yet. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `commit_updates` to `true`, set `current_task` to `null`

### Verification

```yaml
chapter: 4.8-commit
type: automated
verification:
  checks:
    - git_committed: "CLAUDE.md"
      task_key: commit_updates
```

### Checklist

- [ ] Verified worktrees are cleaned up
- [ ] Verified feature branches are deleted
- [ ] Updated CLAUDE.md committed
- [ ] Commit message describes the agent patterns added

---

## Module Completion

### Instructor: Final Validation

After Chapter 8 is complete, tell the student:

"You've finished all the chapters! Let's validate your work and package it for submission.

**Step 1 — Validate**: Run the {cc-course:validate} Skill tool now. This checks that you've used subagents, created worktrees, run parallel agents, merged results, documented patterns, and committed your work."

**Wait for the student to run validate.** If validation fails, help them fix issues and re-run.

**After validation passes**, tell the student:

"All checks passed!

**Step 2 — Submit**: Run the {cc-course:submit} Skill tool to package your work into a submission archive. This bundles your CLAUDE.md updates, progress data, and session logs for instructor review."

**Wait for the student to run submit.**

After submission completes or if the student declines, proceed to the Seminar Summary below. Note: validation is required to unlock the next module. Submission is optional but recommended.

---

## Seminar Summary

### What You Learned

1. **Subagent Architecture**: Isolated Claude instances with fresh context, inheriting CLAUDE.md/skills/MCP but NOT conversation history
2. **Subagent Types**: general-purpose (full tools), Explore (read-only search), Plan (architecture), custom plugin agents
3. **Delegation**: Explicit prompts to launch subagents, choosing the right agent type, reviewing results
4. **Parallel Patterns**: Divide & Conquer, Specialist, Writer + Reviewer, Fan-out, Pipeline
5. **Git Worktrees**: Multiple working directories for conflict-free parallel work
6. **Headless Mode**: `claude -p "prompt"` for non-interactive parallel execution
7. **Merge Workflow**: Review branches, merge one at a time, resolve conflicts, clean up
8. **Pattern Documentation**: Capturing agent workflows in CLAUDE.md for team reuse

### Key Commands

| Command | Purpose |
|---------|---------|
| `git worktree add -b <branch> <path> main` | Create worktree with new branch |
| `git worktree list` | List all worktrees |
| `git worktree remove <path>` | Remove worktree |
| `claude -p "prompt"` | Run Claude in headless mode |
| `git diff main...branch` | Review branch changes |
| `git merge <branch>` | Merge branch to current |
| `git branch -d <branch>` | Delete merged branch |

### Next Seminar Preview

In **Seminar 5: Workflows**, you'll learn to integrate Claude Code with GitHub Actions, create CI/CD pipelines, and build headless automation scripts that run Claude as part of your development workflow.

---

## Session Export (Post-Completion)

After completing this seminar, you can export your session logs for review or portfolio purposes.

### Export Workflow

When module validation passes, the course engine offers to:

1. **Export session logs** to `exports/seminar4-session-{uuid}.json`
2. **Export summary stats** to `exports/seminar4-summary-{uuid}.json`
3. **Generate HTML report** (optional) for visual review

### Export Commands (via MCP cclogviewer)

The course engine uses these MCP calls:

```
mcp__cclogviewer__get_session_logs(
  session_id="<your-session-id>",
  output_path="./exports/seminar4-session.json"
)

mcp__cclogviewer__get_session_summary(
  session_id="<your-session-id>",
  output_path="./exports/seminar4-summary.json"
)

mcp__cclogviewer__generate_html(
  session_id="<your-session-id>",
  output_path="./exports/seminar4-report.html",
  open_browser=true
)
```

### What's Captured

| Data | Description |
|------|-------------|
| Session ID | Unique identifier for your learning session |
| Duration | Time spent on the module |
| Tool usage | Read, Write, Bash, Glob, Agent calls |
| Tasks completed | Which verification steps passed |
| Errors | Any issues encountered |

---

## Validation Summary

```yaml
seminar: 4-agents
tasks:
  use_subagent:
    chapter: 4.2
    type: manual
    check: "student_confirms"

  create_worktrees:
    chapter: 4.4
    type: automated
    check: "git_worktree_list:>=3"

  run_parallel_agents:
    chapter: 4.5
    type: manual
    check: "student_confirms"

  merge_results:
    chapter: 4.6
    type: automated
    check: "git_log:Merge|merge|feature"

  document_pattern:
    chapter: 4.7
    type: automated
    check: "file_contains:CLAUDE.md:Multi-Agent|Parallel|Worktree|Agent Pattern"

  commit_updates:
    chapter: 4.8
    type: automated
    check: "git_log:CLAUDE.md"
```
