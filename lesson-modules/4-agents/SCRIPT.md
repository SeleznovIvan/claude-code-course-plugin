# Seminar 4: Agents

**Duration**: 120 minutes (80 min guided + 40 min practice)

**Seminar ID**: `4-agents`

**Prerequisites**: Completed Seminars 1-3 (CLAUDE.md, skills, hooks, MCP configured)

---

## Learning Objectives

By the end of this seminar, participants will:
- Understand the subagent architecture and when to use it
- Launch and orchestrate parallel agent execution
- Use git worktrees for true parallel development
- Design effective agent delegation patterns

---

## Chapter 1: Understanding Subagents

**Chapter ID**: `4.1-understanding-subagents`

### Content

#### What is a Subagent?

A subagent is an **isolated Claude instance** that handles a specific subtask. Think of it as delegation:

```
Main Agent (Coordinator)
    ├── Subagent A (Implementation)
    ├── Subagent B (Testing)
    └── Subagent C (Documentation)
```

#### Why Use Subagents?

| Benefit | Description |
|---------|-------------|
| **Parallelism** | Multiple tasks happen simultaneously |
| **Isolation** | Each agent has focused context |
| **Specialization** | Agents can have different "expertise" |
| **Review** | One agent writes, another reviews |

#### Subagent vs. Single Session

| Aspect | Single Session | With Subagents |
|--------|----------------|----------------|
| Context | Shared, grows large | Isolated, focused |
| Execution | Sequential | Parallel |
| Token usage | One large context | Multiple smaller contexts |
| Best for | Simple, linear tasks | Complex, multi-part tasks |

### Verification

```yaml
chapter: 4.1-understanding-subagents
type: conceptual
verification: manual
question: "When would you use subagents instead of a single session?"
```

### Checklist

- [ ] Understand what subagents are
- [ ] Know the benefits of using subagents
- [ ] Can identify tasks that benefit from subagents

---

## Chapter 2: Launching Subagents

**Chapter ID**: `4.2-launching-subagents`

### Content

#### Implicit Subagents

Claude may spawn subagents automatically for complex tasks. You'll see:
```
Launching subagent for: writing tests...
```

#### Explicit Subagent Requests

You can explicitly request subagent delegation:

```
I need to implement a user authentication feature. Please:
1. Use a subagent to write the unit tests
2. While you implement the main authentication logic
3. Then integrate both results
```

#### Subagent Communication

Main agent can:
- Pass context to subagents
- Receive results from subagents
- Aggregate and merge work

Subagents:
- Have access to CLAUDE.md and skills
- Work independently on their task
- Return results to main agent

### Practice Exercise

1. Start Claude
2. Ask for a task with explicit subagent delegation:
   ```
   Create a new utility function for date formatting.
   Use a subagent to write comprehensive tests while you implement the function.
   ```
3. Observe how Claude delegates and coordinates

### Verification

```yaml
chapter: 4.2-launching-subagents
type: manual
verification:
  questions:
    - "Request a task with explicit subagent delegation"
    - "Observe Claude launching a subagent"
    - "See results from both main agent and subagent"
  task_key: use_subagent
```

### Checklist

- [ ] Requested task with explicit subagent delegation
- [ ] Observed Claude launching subagent
- [ ] Saw subagent complete its task
- [ ] Main agent integrated subagent results

---

## Chapter 3: Parallel Execution Patterns

**Chapter ID**: `4.3-parallel-patterns`

### Content

#### Pattern 1: Divide and Conquer

Split a large task into independent subtasks:

```
Task: Add user profile feature

Main Agent: Coordinates and integrates
├── Subagent A: Creates UI components
├── Subagent B: Creates API endpoints
└── Subagent C: Creates database models
```

#### Pattern 2: Specialist Agents

Different agents for different expertise:

```
Task: Code review and improvement

├── Code Agent: Implements feature
├── Test Agent: Writes tests
├── Security Agent: Reviews for vulnerabilities
└── Doc Agent: Updates documentation
```

#### Pattern 3: Writer + Reviewer

One agent creates, another critiques:

```
Task: Refactor authentication module

Round 1:
├── Writer Agent: Proposes refactoring
└── Reviewer Agent: Critiques and suggests improvements

Round 2:
├── Writer Agent: Implements feedback
└── Reviewer Agent: Approves or requests more changes
```

### Role-Specific Patterns

| Role | Recommended Pattern |
|------|-------------------|
| Frontend | Component + Tests + Storybook agents |
| Backend | Handler + Tests + API spec agents |
| QA | Unit + Integration + E2E agents |
| DevOps | Config + Dockerfile + K8s agents |
| Data | Ingestion + Validation + Documentation agents |

### Verification

```yaml
chapter: 4.3-parallel-patterns
type: conceptual
verification: manual
question: "Describe the three main parallel execution patterns"
```

### Checklist

- [ ] Understand divide-and-conquer pattern
- [ ] Understand specialist agents pattern
- [ ] Understand writer-reviewer pattern
- [ ] Identified which pattern fits your workflow

---

## Chapter 4: Git Worktrees

**Chapter ID**: `4.4-git-worktrees`

### Content

#### What Are Git Worktrees?

Git worktrees allow **multiple working directories for one repository**. Each worktree can be on a different branch.

```
/my-project/              # Main worktree (main branch)
/my-project-feature-a/    # Worktree for feature-a branch
/my-project-feature-b/    # Worktree for feature-b branch
```

#### Why Worktrees + Agents?

Without worktrees:
- Multiple Claude sessions would conflict on same files
- Can't truly work in parallel

With worktrees:
- Each agent has its own working directory
- True parallel file modifications
- No conflicts until merge time

#### Creating Worktrees

```bash
# Create branches first
git checkout -b feature-a
git checkout -b feature-b
git checkout main

# Create worktrees
git worktree add ../my-project-feature-a feature-a
git worktree add ../my-project-feature-b feature-b
```

#### Listing Worktrees

```bash
git worktree list
```

Output:
```
/path/to/my-project              abc1234 [main]
/path/to/my-project-feature-a    def5678 [feature-a]
/path/to/my-project-feature-b    ghi9012 [feature-b]
```

#### Removing Worktrees

```bash
git worktree remove ../my-project-feature-a
```

### Verification

```yaml
chapter: 4.4-git-worktrees
type: automated
verification:
  checks:
    - command: "git worktree list | wc -l"
      min_value: 2
      task_key: create_worktrees
```

### Checklist

- [ ] Understand what git worktrees are
- [ ] Created at least 2 worktrees
- [ ] Can list existing worktrees
- [ ] Know how to remove worktrees when done

---

## Chapter 5: Running Parallel Agents

**Chapter ID**: `4.5-parallel-agents`

### Content

#### Setup

1. Create two worktrees (from Chapter 4)
2. Open two terminal windows
3. Navigate each to a different worktree

#### Launch Parallel Sessions

**Terminal 1** (in `/my-project-feature-a`):
```bash
claude "Implement user authentication with tests"
```

**Terminal 2** (in `/my-project-feature-b`):
```bash
claude "Implement user profile with tests"
```

#### Monitoring Progress

- Watch both terminals
- Each agent works independently
- No file conflicts (different directories)

#### Best Practices

| Do | Don't |
|----|-------|
| Give clear, independent tasks | Give overlapping tasks |
| Let agents work autonomously | Interrupt frequently |
| Review before merging | Merge without review |
| Use descriptive branch names | Use generic names |

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

- [ ] Set up two worktrees
- [ ] Launched Claude in both simultaneously
- [ ] Both agents completed their tasks
- [ ] No file conflicts occurred

---

## Chapter 6: Merging Parallel Work

**Chapter ID**: `4.6-merging`

### Content

#### Review Before Merge

Before merging agent work:

1. **Review each branch**:
   ```bash
   git diff main...feature-a
   git diff main...feature-b
   ```

2. **Run tests on each branch**:
   ```bash
   cd ../my-project-feature-a
   npm test

   cd ../my-project-feature-b
   npm test
   ```

#### Merging Branches

```bash
# Return to main worktree
cd /path/to/my-project

# Merge first feature
git merge feature-a
# Resolve conflicts if any
# Run tests

# Merge second feature
git merge feature-b
# Resolve conflicts if any
# Run tests
```

#### Handling Merge Conflicts

If agents modified overlapping files:

1. Git will show conflicts
2. Review both changes
3. Choose the correct resolution
4. Test after resolving

#### Cleanup

After merging:
```bash
# Remove worktrees
git worktree remove ../my-project-feature-a
git worktree remove ../my-project-feature-b

# Delete branches if done
git branch -d feature-a
git branch -d feature-b
```

### Verification

```yaml
chapter: 4.6-merging
type: automated
verification:
  checks:
    - command: "git log --oneline | head -5"
      contains: "Merge"
      task_key: merge_results
```

### Checklist

- [ ] Reviewed changes on each branch
- [ ] Ran tests on each branch
- [ ] Merged both branches to main
- [ ] Resolved any conflicts
- [ ] Cleaned up worktrees

---

## Chapter 7: Documenting Your Agent Pattern

**Chapter ID**: `4.7-documenting`

### Content

#### Add Agent Pattern to CLAUDE.md

```markdown
## Multi-Agent Patterns for This Project

### Pattern: Parallel Feature Development

**Use when**: Implementing independent features simultaneously

**Setup**:
```bash
git worktree add ../[project]-feature-a feature-a
git worktree add ../[project]-feature-b feature-b
```

**Agents**:
1. Main worktree: Coordination and final integration
2. Feature-a worktree: First feature implementation
3. Feature-b worktree: Second feature implementation

**Workflow**:
1. Create branches and worktrees
2. Launch Claude in each worktree with independent task
3. Review completed work
4. Merge branches
5. Clean up worktrees

### Pattern: Implementation + Review

**Use when**: Want quality assurance on generated code

**Workflow**:
1. First agent implements feature
2. Second agent reviews and suggests improvements
3. First agent applies feedback
4. Repeat until approved
```

### Verification

```yaml
chapter: 4.7-documenting
type: automated
verification:
  checks:
    - file_contains: "CLAUDE.md"
      pattern: "Multi-Agent|Parallel|Worktree"
      task_key: document_pattern
```

### Checklist

- [ ] Added multi-agent patterns section to CLAUDE.md
- [ ] Documented at least one pattern with setup steps
- [ ] Included cleanup instructions

---

## Chapter 8: Commit Your Work

**Chapter ID**: `4.8-commit`

### Content

#### What to Commit

- Updated CLAUDE.md with agent patterns
- Any merged feature branches
- Cleanup of temporary branches

#### Commit Commands

```bash
git add CLAUDE.md
git commit -m "Document multi-agent patterns

- Add parallel feature development pattern
- Add implementation + review pattern
- Include worktree setup/cleanup instructions"
```

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

- [ ] Updated CLAUDE.md committed
- [ ] Feature branches merged
- [ ] Worktrees cleaned up
- [ ] Temporary branches deleted

---

## Seminar Summary

### What You Learned

1. **Subagents**: Isolated Claude instances for subtasks
2. **Parallel Patterns**: Divide-and-conquer, specialists, writer-reviewer
3. **Git Worktrees**: Multiple working directories for parallel work
4. **Orchestration**: Running and merging parallel agent work

### Key Commands

| Command | Purpose |
|---------|---------|
| `git worktree add <path> <branch>` | Create worktree |
| `git worktree list` | List worktrees |
| `git worktree remove <path>` | Remove worktree |
| `git merge <branch>` | Merge branch |

### Next Seminar Preview

In **Seminar 5: Workflows**, you'll learn to integrate Claude Code with GitHub Actions, create CI/CD pipelines, and build headless automation scripts.

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
    check: "git_worktree_list:>=2"

  run_parallel_agents:
    chapter: 4.5
    type: manual
    check: "student_confirms"

  merge_results:
    chapter: 4.6
    type: automated
    check: "git_log:Merge"

  document_pattern:
    chapter: 4.7
    type: automated
    check: "file_contains:CLAUDE.md:Multi-Agent|Parallel"

  commit_updates:
    chapter: 4.8
    type: automated
    check: "git_log:CLAUDE.md"
```
