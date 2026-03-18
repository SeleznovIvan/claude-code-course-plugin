# Seminar 4: Agents — Knowledge Base

## How to Use This File

This file complements `SCRIPT.md` with:
- **Deep dive explanations** — detailed background on each topic
- **External resources** — curated links to official docs and community content
- **Links verified** as of March 2026

**Separation of concerns:**
- `SCRIPT.md` = Teaching flow, validations, checklists (instructor guide)
- `KNOWLEDGE.md` = Deep content, external links, conceptual foundations (knowledge base)

---

## Chapter 4.1: Understanding Agents and Subagents

### Deep Dive

#### What Subagents Actually Are

When Claude Code uses the Agent tool, it launches a **subprocess** — a separate Claude instance with its own context window, its own tool access, and its own reasoning loop. The parent agent delegates a task by passing a prompt, and the subagent works independently until it completes, returning a text summary of its results.

This is not a metaphor. A subagent is a distinct API call chain with its own token budget. The parent does not see the subagent's intermediate reasoning, tool calls, or file reads — it only receives the final result. This isolation is by design: it keeps each agent's context focused and prevents the parent's context window from being consumed by delegated work.

```
Parent Agent (Coordinator)
    │
    ├── prompt: "Implement user auth middleware"
    │   └── Subagent A [general-purpose]
    │       ├── Reads existing code
    │       ├── Writes middleware file
    │       ├── Writes tests
    │       └── Returns: "Created auth.ts and auth.test.ts with JWT validation"
    │
    ├── prompt: "Review the codebase for security issues"
    │   └── Subagent B [Explore]
    │       ├── Searches for hardcoded secrets
    │       ├── Checks input validation
    │       └── Returns: "Found 3 issues: ..."
    │
    └── Integrates results from A and B
```

#### Subagent Types Available in Claude Code

Claude Code provides several subagent types, each optimized for different kinds of work:

**`general-purpose` (default)**
- Full tool access: Read, Write, Edit, Bash, Glob, Grep, and all configured MCP tools
- Best for: Multi-step implementation tasks — writing code, running tests, making changes
- Trade-off: Most capable but also most expensive (full tool set means more potential actions)

**`Explore`**
- Read-only tools: Glob, Grep, Read
- Best for: Codebase exploration, search, analysis, dependency tracing
- Trade-off: Fast and cheap but cannot make changes — purely observational
- Typical use: "Find all usages of this API", "Trace the data flow from endpoint to database"

**`Plan`**
- Read-only tools: Glob, Grep, Read
- Best for: Architecture planning, migration strategies, refactoring proposals
- Trade-off: Produces plans and recommendations but cannot execute them
- Typical use: "Design the API contract for the new payment service", "Plan the migration from REST to GraphQL"

**Custom plugin agents**
- Plugins can define their own agent types with specific tool sets
- These agents inherit the plugin's tool restrictions and capabilities
- Example: A database plugin might define a `db-admin` agent with only database-related MCP tools

#### Context Isolation Model

Each subagent starts with a **fresh context window**. It does not inherit the parent's conversation history. What it does inherit:

| Inherited | Not Inherited |
|-----------|---------------|
| CLAUDE.md content | Parent's conversation history |
| Skill descriptions | Previous tool call results |
| MCP tool availability | Parent's reasoning or plans |
| Project-level settings | User messages from the session |

This means the parent must pass all necessary context through the `prompt` parameter. A common mistake is assuming the subagent "knows" what the parent was discussing — it does not. The prompt is the subagent's entire understanding of the task.

**Practical implication**: Write subagent prompts as if you are briefing a colleague who just joined the project. Include:
- What the task is
- Where relevant files are located
- What conventions to follow
- What the expected output should look like

#### Agent Tool Parameters

The Agent tool accepts the following parameters:

| Parameter | Required | Default | Description |
|-----------|----------|---------|-------------|
| `prompt` | Yes | — | The task description passed to the subagent |
| `subagent_type` | No | `general-purpose` | Which agent type to use (`Explore`, `Plan`, `general-purpose`) |
| `description` | No | — | Short 3-5 word summary shown in the UI while the agent runs |
| `run_in_background` | No | `false` | Launch async; parent continues working and gets notified on completion |
| `isolation` | No | — | Set to `"worktree"` to run in an isolated git worktree copy |
| `model` | No | Current model | Override the model (e.g., `sonnet`, `opus`, `haiku`) for cost/speed trade-offs |
| `resume` | No | — | Continue a previous agent by its ID |

#### Foreground vs Background Agents

**Foreground agents** (`run_in_background: false`, the default):
- The parent blocks until the subagent completes
- Use when: The parent needs the subagent's result before it can proceed
- Example: "Explore the codebase to find all API endpoints" — parent needs the list before planning implementation

**Background agents** (`run_in_background: true`):
- The parent continues working immediately
- The parent is notified when the background agent completes
- Use when: The task is independent and the parent has other work to do
- Example: "Write documentation for the auth module" — parent can implement the next feature while docs are being written

**Decision framework:**
```
Does the parent need this result before it can continue?
├── Yes → Foreground (blocking)
└── No → Is the task independent of what the parent is doing?
    ├── Yes → Background (async)
    └── No → Foreground (blocking) — dependency means you need to wait
```

#### When to Use Subagents vs Single Session

Not every task benefits from subagents. Use this decision framework:

| Factor | Single Session | Subagents |
|--------|---------------|-----------|
| Task complexity | Simple, linear, < 5 steps | Complex, multi-faceted, many steps |
| Task independence | Steps depend on each other | Steps can run in parallel |
| Context needs | All steps need shared context | Steps need focused, isolated context |
| File scope | Few files, same area | Many files, different areas |
| Time sensitivity | Quick task, no parallelism needed | Large task, parallelism saves time |
| Review needs | Self-contained work | Benefit from separate write + review |

**Rule of thumb**: If the task naturally decomposes into parts that a team of humans would divide among themselves, subagents are a good fit.

#### Token Economics

Subagents use separate context windows, which has cost implications:

- **Single large context**: One session accumulates all file reads, tool calls, and reasoning. Works well until the context fills up, at which point compaction loses information.
- **Multiple small contexts**: Each subagent has focused context — only the files and reasoning relevant to its specific subtask. More efficient for complex tasks because no single context becomes overloaded.

The trade-off: subagents have overhead (each needs its own initial context loading — CLAUDE.md, skill descriptions). For tasks that take fewer than 3-4 tool calls, a subagent is more expensive than just doing it inline. For tasks that require 10+ tool calls across different parts of the codebase, subagents are more efficient.

### External Resources

- **[Claude Code Sub-agents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)** — Official subagent documentation covering architecture and configuration
- **[Claude Code Agent SDK](https://docs.anthropic.com/en/docs/agents/claude-code-sdk)** — SDK reference for programmatic agent orchestration
- **[Best Practices for Claude Code](https://docs.anthropic.com/en/docs/claude-code/best-practices)** — Official guidance on effective Claude Code usage

---

## Chapter 4.2: Using Subagents

### Deep Dive

#### How Claude Auto-Delegates

Claude Code may spawn subagents automatically when it detects that a task has independent subtasks. You will see messages like:

```
Launching subagent for: writing unit tests...
Launching subagent for: exploring the codebase...
```

Auto-delegation typically happens when:
- The task explicitly mentions parallel or independent parts
- Claude recognizes the task would benefit from focused context (e.g., a large codebase search)
- The task involves both implementation and review/testing
- The conversation is getting long and a fresh context would be more efficient

You do not need to do anything special to enable auto-delegation — Claude decides based on the task structure and its assessment of whether delegation would improve the outcome.

#### Explicit Delegation Prompts

You can directly instruct Claude to use subagents. Effective prompt patterns:

**Direct subagent request:**
```
Use a subagent to search the codebase for all files that import the UserService class.
```

**Parallel delegation:**
```
In parallel:
1. Have one agent implement the login endpoint in src/auth/login.ts
2. Have another agent write tests for the login endpoint in tests/auth/login.test.ts
```

**Typed agent request:**
```
Launch an Explore agent to find all database queries that don't use parameterized inputs.
```

**Background delegation:**
```
Start a background agent to update the API documentation while we continue
working on the implementation.
```

**Multi-agent with specific instructions:**
```
I need three agents working in parallel:
1. Agent A: Implement the /users endpoint (create, read, update, delete)
2. Agent B: Write comprehensive tests for the /users endpoint
3. Agent C: Update the OpenAPI spec to include the new endpoint

Each agent should follow our existing patterns in src/api/ for consistency.
```

#### Skills with `context: fork`

The `context: fork` frontmatter field in a SKILL.md file runs the skill in an isolated subagent automatically. This is the declarative equivalent of launching a subagent — the skill invocation triggers the fork.

```yaml
---
name: codebase-audit
description: Perform a security audit across the entire codebase
context: fork
agent: Explore
allowed-tools:
  - Read
  - Grep
  - Glob
---

## Security Audit Procedure

1. Search for hardcoded credentials (API keys, passwords, tokens)
2. Check for SQL injection vulnerabilities
3. Verify input validation on all API endpoints
4. Report findings in a structured format
```

When a user invokes `/codebase-audit`, Claude automatically:
1. Spawns a new Explore subagent
2. Passes the skill body as the subagent's instructions
3. Returns the subagent's findings to the parent session

Combine `context: fork` with `agent` type for specialized execution:

| Combination | Use Case |
|-------------|----------|
| `context: fork` + `agent: Explore` | Read-only analysis, search, audit |
| `context: fork` + `agent: Plan` | Architecture planning, migration design |
| `context: fork` + `agent: general-purpose` | Full implementation in isolation |

#### Subagent Result Handling

The parent receives a **text summary** from the subagent — not structured data, not the subagent's full conversation, not its tool call history. The parent must interpret this summary and decide what to do with it.

This means:
- The subagent should be instructed to produce clear, actionable output
- If you need structured data, tell the subagent to format its response (e.g., "Return a JSON array of findings")
- The parent can ask follow-up questions by launching another subagent or resuming the same one with the `resume` parameter

#### Common Pitfalls

**Over-delegation**: Spawning subagents for trivial tasks wastes tokens. If a task takes 1-2 tool calls (e.g., "read this file and tell me what it does"), just do it inline. Subagent overhead (context loading, result summarization) is not worth it for simple tasks.

**Under-specifying the prompt**: Vague prompts produce poor subagent results. Compare:

| Vague Prompt | Specific Prompt |
|-------------|-----------------|
| "Write tests" | "Write unit tests for src/auth/login.ts covering: successful login, invalid credentials, expired tokens, and rate limiting. Use Jest with our existing test patterns from tests/auth/." |
| "Review the code" | "Review src/api/users.ts for: input validation, error handling, SQL injection risks, and consistency with our API patterns in src/api/orders.ts." |

**Not checking results**: Always verify subagent output before proceeding. A subagent may have misunderstood the task, made incorrect assumptions, or produced code that does not compile. Treat subagent output the same way you would treat a pull request from a colleague — review before merging.

**Context starvation**: Not providing enough context in the prompt. The subagent does not know what the parent was discussing. Include file paths, conventions, and expected output format explicitly.

#### Best Practices for Delegation Prompts

1. **Be specific about scope**: Name exact files, directories, and functions
2. **Provide context**: Explain why the task matters and how it fits into the larger picture
3. **Define output format**: Tell the subagent what its response should look like
4. **Reference conventions**: Point to existing patterns the subagent should follow
5. **Set boundaries**: Specify what the subagent should NOT do (e.g., "do not modify existing tests")

### External Resources

- **[Claude Code Sub-agents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)** — Official documentation on launching and configuring subagents
- **[Agent Skills Specification](https://agentskills.io)** — The `context: fork` field is part of the Agent Skills standard
- **[Best Practices for Claude Code](https://docs.anthropic.com/en/docs/claude-code/best-practices)** — Guidance on effective delegation and prompt writing

---

## Chapter 4.3: Parallel Execution Patterns

### Deep Dive

#### Pattern 1: Divide and Conquer

Split a large task into independent subtasks, execute them in parallel, and merge the results. This is the most common multi-agent pattern.

**When to use**: The task has clearly separable components that do not depend on each other during implementation. Each component can be developed and tested independently.

**Structure:**
```
Coordinator (Parent Agent)
    │
    ├── Task decomposition: identify independent subtasks
    │
    ├── Subagent A: Frontend component
    │   └── Works in: src/components/
    │
    ├── Subagent B: Backend API endpoint
    │   └── Works in: src/api/
    │
    ├── Subagent C: Database migration
    │   └── Works in: migrations/
    │
    └── Integration: verify all parts work together
```

**Example prompt for coordinator:**
```
I need to add a user profile feature. Please divide this into parallel subtasks:

1. Subagent 1: Create the UserProfile React component in src/components/UserProfile/
   - Include UserProfile.tsx, UserProfile.test.tsx, UserProfile.module.css
   - Follow existing component patterns in src/components/Dashboard/

2. Subagent 2: Create the /api/profile endpoint in src/api/
   - GET /api/profile/:id and PUT /api/profile/:id
   - Follow existing patterns in src/api/users.ts

3. Subagent 3: Create the database migration for the profiles table
   - Add profiles table with: id, user_id, bio, avatar_url, created_at, updated_at
   - Follow existing migration patterns in migrations/

After all complete, integrate the frontend to call the API endpoint.
```

**Key success factors:**
- Each subtask must be genuinely independent — no subagent waiting on another's output
- File scope must not overlap — different subagents should not modify the same files
- Integration happens after all subagents complete

#### Pattern 2: Specialist Agents

Different agents handle different aspects of the same task, each bringing specialized "expertise" through their tool access and instructions.

**When to use**: The task requires different skill sets or tool access. One agent writes code, another writes tests, another handles documentation.

**Structure:**
```
Coordinator
    │
    ├── Code Agent [general-purpose]
    │   └── Tools: Write, Edit, Bash
    │   └── Task: Implement the feature
    │
    ├── Test Agent [general-purpose]
    │   └── Tools: Write, Bash
    │   └── Task: Write comprehensive tests
    │
    ├── Security Agent [Explore]
    │   └── Tools: Read, Grep, Glob
    │   └── Task: Review for vulnerabilities
    │
    └── Doc Agent [general-purpose]
        └── Tools: Write, Read
        └── Task: Update documentation
```

**Key success factors:**
- Each specialist has a clearly defined role and scope
- Specialists receive the same context about the overall goal
- The coordinator aggregates and reconciles specialist outputs

#### Pattern 3: Writer + Reviewer

One agent creates work, another critiques it. This mimics the pull request review process and consistently produces higher-quality output than single-agent work.

**When to use**: Quality-critical code, complex refactoring, security-sensitive changes, or any situation where a second perspective adds value.

**Structure:**
```
Round 1:
├── Writer Agent: Produces initial implementation
└── Reviewer Agent: Critiques, suggests improvements

Round 2:
├── Writer Agent: Implements reviewer feedback
└── Reviewer Agent: Approves or requests more changes

(Repeat until approved)
```

**Example reviewer prompt:**
```
Review the following code changes for:
1. Correctness: Does the logic handle all edge cases?
2. Security: Are inputs validated? Any injection risks?
3. Performance: Any unnecessary loops, N+1 queries, or memory leaks?
4. Consistency: Does it follow our existing patterns?
5. Testing: Are the tests comprehensive? Any missing cases?

Provide specific, actionable feedback with file paths and line references.
If the code is acceptable, respond with "APPROVED" and a brief summary of strengths.
```

**Key success factors:**
- The reviewer must have access to read the writer's output (same repo or worktree)
- Review criteria should be explicit and specific
- Set a maximum number of rounds to prevent infinite loops (typically 2-3)

#### Pattern 4: Fan-out / Fan-in

One coordinator spawns many workers for batch operations, then collects and aggregates their results. This is ideal for tasks that apply the same operation across many targets.

**When to use**: Batch operations across many files, audit tasks, large-scale refactoring, or any task where the same operation applies to N items.

**Structure:**
```
Coordinator
    │
    ├── Fan-out: Spawn N workers
    │   ├── Worker 1: Audit file-1.ts
    │   ├── Worker 2: Audit file-2.ts
    │   ├── Worker 3: Audit file-3.ts
    │   │   ...
    │   └── Worker N: Audit file-N.ts
    │
    └── Fan-in: Aggregate all findings
        └── Produce consolidated report
```

**Example use cases:**
- Audit 20 API endpoints for consistent error handling
- Check 50 React components for accessibility compliance
- Validate all database queries for parameterized inputs
- Update import paths across 30 files after a module rename

**Key success factors:**
- Each worker task must be identical in structure (same operation, different target)
- Workers must be truly independent — no shared state
- The coordinator must have a clear aggregation strategy

#### Pattern 5: Pipeline

Sequential agents where each builds on the previous agent's output. Unlike other patterns, pipeline stages run one after another, not in parallel.

**When to use**: Multi-stage transformations where each stage requires the previous stage's output. The value comes from specialized context at each stage, not from parallelism.

**Structure:**
```
Stage 1: Design Agent [Plan]
    └── Output: Architecture document, API contracts
         │
Stage 2: Implementation Agent [general-purpose]
    └── Input: Architecture from Stage 1
    └── Output: Working code
         │
Stage 3: Test Agent [general-purpose]
    └── Input: Code from Stage 2
    └── Output: Test suite
         │
Stage 4: Documentation Agent [general-purpose]
    └── Input: Code + tests from Stages 2-3
    └── Output: API documentation, README updates
```

**Key success factors:**
- Each stage produces a clear, well-defined artifact that the next stage consumes
- Stage boundaries should align with natural task boundaries
- The coordinator manages the handoff between stages

#### Pattern Selection Decision Tree

```
What kind of task is this?

Is it a batch operation on many similar items?
├── Yes → Fan-out / Fan-in (Pattern 4)
│
└── No → Are the subtasks independent?
    ├── Yes → Do they require different expertise?
    │   ├── Yes → Specialist Agents (Pattern 2)
    │   └── No → Divide and Conquer (Pattern 1)
    │
    └── No → Does each step build on the previous?
        ├── Yes → Pipeline (Pattern 5)
        └── No → Does quality require a second perspective?
            ├── Yes → Writer + Reviewer (Pattern 3)
            └── No → Consider single session (no pattern needed)
```

#### Anti-Patterns: What NOT to Do

**Subagent for a single file read**: Do not spawn a subagent to read one file. The overhead exceeds the benefit.

**Overlapping file scope**: Two subagents modifying the same file guarantees merge conflicts. Always assign non-overlapping file scopes.

**Chain of dependent subagents without pipeline structure**: If each subagent depends on the previous, use the Pipeline pattern explicitly rather than ad-hoc delegation.

**Subagent inception**: Subagents spawning their own subagents. While technically possible, it creates deep nesting that is hard to monitor and debug. Keep the hierarchy flat — one coordinator, multiple workers.

**No result verification**: Trusting subagent output blindly. Always have the coordinator (or a reviewer agent) validate the results.

### External Resources

- **[Claude Code Sub-agents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)** — Official patterns and examples for multi-agent execution
- **[Claude Code Best Practices](https://docs.anthropic.com/en/docs/claude-code/best-practices)** — Guidance on task decomposition and parallel execution

---

## Chapter 4.4: Git Worktrees for Parallel Work

### Deep Dive

#### Git Worktree Fundamentals

A git worktree creates an **additional working directory** linked to the same repository. All worktrees share the same `.git` directory (the object database, refs, and configuration), but each has its own working tree, index (staging area), and HEAD.

```
/my-project/                    # Main worktree
├── .git/                       # THE repository (shared)
├── src/
└── ...

/my-project-feature-auth/       # Linked worktree
├── .git → file pointing to main .git  # NOT a copy — a pointer
├── src/
└── ...

/my-project-feature-profile/    # Another linked worktree
├── .git → file pointing to main .git
├── src/
└── ...
```

**Key insight**: Because worktrees share the object database, creating a new worktree is nearly instant — no `git clone` needed. The only cost is checking out the files.

#### Worktree Commands Reference

**Creating worktrees:**
```bash
# Create worktree for an existing branch
git worktree add ../my-project-feature-auth feature-auth

# Create a new branch AND worktree in one command
git worktree add -b feature-auth ../my-project-feature-auth

# Create worktree from a specific commit
git worktree add ../my-project-hotfix abc1234

# Create worktree based on a remote branch
git worktree add ../my-project-upstream-fix origin/fix-branch
```

**Listing worktrees:**
```bash
git worktree list
# Output:
# /path/to/my-project                abc1234 [main]
# /path/to/my-project-feature-auth   def5678 [feature-auth]
# /path/to/my-project-feature-profile ghi9012 [feature-profile]

# Verbose output with more details
git worktree list --porcelain
```

**Removing worktrees:**
```bash
# Remove a worktree (must be clean — no uncommitted changes)
git worktree remove ../my-project-feature-auth

# Force remove (even with uncommitted changes — use with caution)
git worktree remove --force ../my-project-feature-auth

# Clean up stale worktree references (after manual directory deletion)
git worktree prune
```

**Locking worktrees:**
```bash
# Prevent a worktree from being removed (e.g., it's on a network drive)
git worktree lock ../my-project-feature-auth

# Unlock when safe to remove
git worktree unlock ../my-project-feature-auth

# Lock with a reason
git worktree lock --reason "Long-running agent, do not remove" ../my-project-feature-auth
```

#### Worktree + Claude Code Integration

Each worktree is a fully independent working directory, which means Claude Code treats each one as a separate project context:

| Aspect | Shared Across Worktrees | Independent Per Worktree |
|--------|------------------------|--------------------------|
| Git objects (commits, blobs) | Yes | — |
| CLAUDE.md | Yes (it is in the repo) | — |
| `.claude/skills/` | Yes (in the repo) | — |
| `.claude/settings.json` | Yes (in the repo) | — |
| Working tree files | — | Yes (each has its own copy) |
| Git index (staging area) | — | Yes |
| HEAD (current commit) | — | Yes |
| Claude session context | — | Yes (each session is independent) |

**Practical consequence**: You can run separate Claude sessions in different worktrees simultaneously. Each session has its own file state, can make independent changes, and will not interfere with the other sessions.

#### The `isolation: "worktree"` Agent Parameter

When used in the Agent tool, this parameter automates worktree management:

1. Creates a temporary worktree with a new branch
2. Runs the subagent in that worktree
3. If the subagent made changes: returns the worktree path and branch name
4. If the subagent made no changes: cleans up the worktree automatically

```
Agent tool call:
  prompt: "Implement the user profile API endpoint"
  isolation: "worktree"
  subagent_type: "general-purpose"

Claude automatically:
  1. git worktree add ../project-agent-profile -b agent/profile
  2. Runs subagent in ../project-agent-profile/
  3. Subagent makes changes and commits
  4. Returns: "Changes on branch agent/profile in ../project-agent-profile"
```

This eliminates the manual worktree setup. You can launch multiple isolated agents and each gets its own worktree automatically.

#### Worktree Naming Conventions

Consistent naming makes worktrees easy to identify and manage:

| Convention | Example | Use Case |
|-----------|---------|----------|
| `project-feature-name` | `../myapp-feature-auth` | Feature development |
| `project-agent-task` | `../myapp-agent-tests` | Agent-spawned worktree |
| `project-hotfix-desc` | `../myapp-hotfix-login` | Urgent fixes |
| `project-experiment-desc` | `../myapp-experiment-graphql` | Exploratory work |

**Recommendation**: Always place worktrees as siblings of the main project directory (using `../`), not inside it. This avoids confusing the main project's file watchers and build tools.

#### Limitations and Constraints

**One branch per worktree**: You cannot have two worktrees checked out to the same branch. If you try, git will refuse. If you need a second copy of the same branch, create a new branch from it.

**Uncommitted changes block removal**: `git worktree remove` requires a clean working tree. Either commit, stash, or use `--force` (which discards changes permanently).

**Submodules**: If your project uses git submodules, each worktree needs its own submodule checkout. Run `git submodule update --init` in each new worktree.

**Large repositories**: While worktree creation is fast (shared objects), checking out files in a very large repository still takes time and disk space proportional to the working tree size.

**Build artifacts**: Each worktree has its own `node_modules/`, `target/`, `build/`, etc. You will need to run `npm install` or equivalent in each worktree. This is a feature (isolated build environments) but requires awareness.

#### Performance Considerations

- **Creation cost**: Near-instant (just checking out files — no network, no object copying)
- **Disk cost**: Only the working tree files are duplicated, not the git objects
- **Token cost**: Each Claude session in a worktree uses its own context window and API tokens
- **CPU cost**: If running tests or builds in multiple worktrees simultaneously, they compete for system resources

### External Resources

- **[Git Worktree Documentation](https://git-scm.com/docs/git-worktree)** — Official git reference for worktree commands
- **[Git Worktree Tutorial](https://www.gitkraken.com/learn/git/git-worktree)** — Visual guide to git worktrees
- **[Claude Code Sub-agents: Worktree Isolation](https://docs.anthropic.com/en/docs/claude-code/sub-agents)** — Official docs on the `isolation: "worktree"` parameter

---

## Chapter 4.5: Running Parallel Agents

### Deep Dive

#### Three Ways to Run Parallel Agents in Claude Code

**Method 1: Multiple Terminals + Worktrees (Manual)**

The most straightforward approach. Open multiple terminal windows, each pointing to a different worktree, and run Claude in each:

```bash
# Terminal 1
cd ../my-project-feature-auth
claude -p "Implement JWT authentication middleware following patterns in src/middleware/"

# Terminal 2
cd ../my-project-feature-profile
claude -p "Implement user profile CRUD endpoints following patterns in src/api/"

# Terminal 3
cd ../my-project-feature-notifications
claude -p "Implement notification system with email and in-app channels"
```

Pros: Full visibility, each terminal shows progress, easy to monitor
Cons: Manual setup, requires multiple terminal windows, manual cleanup

**Method 2: Background Agents via Agent Tool**

Use the `run_in_background: true` parameter to launch agents that run asynchronously while the parent continues working:

```
Parent prompt: "I need to implement auth, profile, and notifications in parallel."

Claude spawns:
- Background Agent 1: "Implement auth middleware" (run_in_background: true)
- Background Agent 2: "Implement profile endpoints" (run_in_background: true)
- Parent continues: Plans the integration layer

Notifications appear:
- "Background agent 1 completed: Created auth middleware with JWT validation"
- "Background agent 2 completed: Created profile CRUD endpoints"
```

Pros: Managed within a single Claude session, automatic notifications
Cons: Less visibility into individual agent progress, all agents share the same working directory unless combined with worktree isolation

**Method 3: Worktree-Isolated Agents**

Combine `run_in_background: true` with `isolation: "worktree"` for fully independent parallel execution:

```
Parent launches:
- Agent 1: isolation: "worktree", run_in_background: true
  → Creates ../project-agent-auth, works independently
- Agent 2: isolation: "worktree", run_in_background: true
  → Creates ../project-agent-profile, works independently

Parent continues coordinating while both agents work in isolated worktrees.
```

Pros: True isolation, no file conflicts, automatic worktree management
Cons: Highest token cost, requires merge step afterward

#### Headless Mode (`claude -p`)

Headless mode runs Claude non-interactively — a single prompt in, work done, exit. This is the foundation for parallel agent execution in multiple terminals:

```bash
# Basic headless execution
claude -p "Implement the login endpoint with tests"

# With JSON output (machine-readable results)
claude -p "List all API endpoints in this project" --output-format json

# With tool restrictions
claude -p "Write tests for auth.ts" --allowedTools Write,Edit,Bash,Read,Grep,Glob

# With a specific model (cost/speed trade-off)
claude -p "Generate API documentation" --model sonnet
```

**Running multiple headless sessions simultaneously:**
```bash
# Launch all three in parallel (& backgrounds the process in the shell)
cd ../project-feature-a && claude -p "Implement feature A" &
cd ../project-feature-b && claude -p "Implement feature B" &
cd ../project-feature-c && claude -p "Implement feature C" &

# Wait for all to complete
wait
echo "All agents completed"
```

**Headless mode flags reference:**

| Flag | Description |
|------|-------------|
| `-p "prompt"` | Non-interactive mode with a single prompt |
| `--output-format json` | Machine-readable JSON output |
| `--output-format stream-json` | Streaming JSON (each event as a line) |
| `--allowedTools Tool1,Tool2` | Restrict available tools |
| `--model name` | Override the model |
| `--max-turns N` | Limit the number of agentic turns |
| `--resume session-id` | Resume a previous session |
| `--verbose` | Show detailed execution logs |

#### Monitoring Parallel Agents

**Background agents** (launched via Agent tool with `run_in_background: true`):
- The parent session receives a notification when each background agent completes
- The notification includes the agent's result summary
- No polling needed — notifications are automatic

**Multiple terminals**:
- Watch each terminal's output directly
- Each Claude session logs its progress in real time
- Use terminal multiplexers (tmux, screen) to manage many terminals efficiently

**Process monitoring:**
```bash
# See all running Claude processes
ps aux | grep "claude"

# Monitor resource usage across all agents
top -p $(pgrep -d, -f "claude")
```

#### Resource Considerations

Each parallel agent is an independent API session:
- **Tokens**: Running 5 agents = 5x the token usage. Budget accordingly.
- **Rate limits**: Multiple simultaneous sessions count against your API rate limits.
- **System resources**: Each agent process uses CPU and memory. On resource-constrained machines, limit concurrency.
- **Disk I/O**: Multiple agents reading/writing files simultaneously can create I/O contention, especially on HDDs (less of an issue on SSDs).

**Cost optimization tips:**
- Use `--model sonnet` for simpler tasks (cheaper, faster)
- Use `--model opus` only for complex tasks that need deep reasoning
- Set `--max-turns` to prevent runaway agent loops
- Use `--allowedTools` to restrict tools and reduce unnecessary actions

#### Task Independence Checklist

Before parallelizing tasks, verify they will not conflict:

- [ ] **File scope**: No two agents modify the same files
- [ ] **Shared resources**: No two agents access the same external service simultaneously (e.g., same database, same API endpoint with rate limits)
- [ ] **Build dependencies**: No agent produces a build artifact that another agent needs
- [ ] **Import/export**: No agent creates a module that another agent imports
- [ ] **Configuration**: No agent modifies shared configuration files (package.json, tsconfig.json)
- [ ] **Test isolation**: Each agent's tests can run independently

If any item fails, either restructure the tasks to eliminate the dependency or switch to a Pipeline pattern (sequential) for the dependent parts.

### External Resources

- **[Claude Code CLI Usage](https://docs.anthropic.com/en/docs/claude-code/cli-usage)** — Official CLI reference including headless mode flags
- **[Claude Code SDK](https://docs.anthropic.com/en/docs/agents/claude-code-sdk)** — Programmatic orchestration of multiple Claude sessions
- **[Claude Code Sub-agents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)** — Background execution and worktree isolation

---

## Chapter 4.6: Merging Parallel Work

### Deep Dive

#### Pre-Merge Review Workflow

Before merging any agent-produced branch, follow this systematic review process:

**Step 1: Review changes on each branch**
```bash
# See what changed on feature-auth relative to main
git diff main...feature-auth

# See only file names (high-level overview)
git diff main...feature-auth --name-only

# See statistics (lines added/removed per file)
git diff main...feature-auth --stat
```

**Step 2: Check for overlapping modifications**
```bash
# List files modified on feature-auth
git diff main...feature-auth --name-only > /tmp/files-auth.txt

# List files modified on feature-profile
git diff main...feature-profile --name-only > /tmp/files-profile.txt

# Find common files (potential conflicts)
comm -12 <(sort /tmp/files-auth.txt) <(sort /tmp/files-profile.txt)
```

If there are common files, review those files on both branches to understand the nature of the overlap before attempting a merge.

**Step 3: Run tests on each branch independently**
```bash
# Test feature-auth
cd ../my-project-feature-auth
npm test    # or your test command

# Test feature-profile
cd ../my-project-feature-profile
npm test
```

**Step 4: Verify build on each branch**
```bash
cd ../my-project-feature-auth
npm run build   # or your build command

cd ../my-project-feature-profile
npm run build
```

#### Merge Strategies for Agent Work

**Fast-forward merge** (cleanest history, no merge commit):
```bash
git checkout main
git merge --ff-only feature-auth
```
Use when: The branch has commits on top of main with no divergence. Produces linear history.

**Three-way merge** (most common, creates merge commit):
```bash
git checkout main
git merge feature-auth
# If conflicts: resolve, then git add + git commit
git merge feature-profile
```
Use when: Branches have diverged from main. The merge commit documents that parallel work was integrated.

**Rebase then fast-forward** (linear history, rewritten commits):
```bash
git checkout feature-auth
git rebase main
git checkout main
git merge --ff-only feature-auth
```
Use when: You want linear history and are comfortable rewriting branch commits. Do not rebase branches that others have based work on.

**Squash merge** (collapse branch into single commit):
```bash
git checkout main
git merge --squash feature-auth
git commit -m "feat: add JWT authentication middleware"
```
Use when: The branch has many small/messy commits (common with agent work) and you want a clean single commit on main.

#### Conflict Resolution Patterns

**Common agent conflicts:**

| Conflict Type | Cause | Resolution Strategy |
|--------------|-------|-------------------|
| Import statements | Two agents add imports to the same file | Combine both imports, remove duplicates, sort |
| Shared constants | Two agents add constants to the same file | Merge both sets of constants |
| Package.json dependencies | Two agents install different packages | Merge both dependency lists, resolve version conflicts |
| Configuration files | Two agents modify tsconfig, eslint, etc. | Combine settings, test that both features work |
| Test fixtures | Two agents create overlapping test data | Unify fixture files, ensure no naming collisions |
| Index/barrel files | Two agents add exports to index.ts | Combine all exports |

**Using Claude to resolve conflicts:**
```
Look at the merge conflicts in the following files and suggest the best resolution.
Both branches are implementing independent features — auth and user profiles.
Combine changes from both where possible, preferring correctness over either branch.

Conflicted files:
- src/index.ts (both added new route registrations)
- package.json (both added new dependencies)
- src/types/index.ts (both added new type exports)
```

#### Post-Merge Verification

After merging all branches, verify the integrated result:

```bash
# 1. Run the full test suite
npm test

# 2. Run the build
npm run build

# 3. Run linting
npm run lint

# 4. If you have integration tests
npm run test:integration

# 5. Manual smoke test — start the application and verify key flows
npm start
```

If tests fail after merge, the issue is likely an integration problem — two features that work independently but interact poorly when combined. Common causes:
- Conflicting middleware order
- Duplicate route paths
- Incompatible type definitions
- Missing shared dependencies

#### Cleanup Workflow

After successful merge and verification:

```bash
# 1. Remove worktrees (must be done before deleting branches)
git worktree remove ../my-project-feature-auth
git worktree remove ../my-project-feature-profile

# 2. Delete merged branches
git branch -d feature-auth
git branch -d feature-profile

# 3. Clean up any stale worktree references
git worktree prune

# 4. Verify clean state
git worktree list    # Should show only the main worktree
git branch           # Should show only main (and any other long-lived branches)
```

**Important**: Remove worktrees before deleting branches. If you delete the branch first, `git worktree remove` may behave unexpectedly.

#### Rollback Strategy

If the merged result fails tests or introduces bugs:

```bash
# Option 1: Undo the last merge (if not yet pushed)
git reset --hard HEAD~1

# Option 2: Revert the merge commit (if already pushed)
git revert -m 1 <merge-commit-hash>

# Option 3: Revert to a known good state
git reset --hard <known-good-commit>

# After rollback: investigate what went wrong
git diff <merge-commit> HEAD    # See what the merge changed
```

Always prefer `git revert` over `git reset --hard` if the merge has been pushed to a shared branch — revert creates a new commit, preserving history, while reset rewrites history.

### External Resources

- **[Git Merge Documentation](https://git-scm.com/docs/git-merge)** — Official reference for merge strategies and options
- **[Git Worktree Documentation](https://git-scm.com/docs/git-worktree)** — Worktree removal and cleanup commands
- **[Atlassian Git Merge Tutorial](https://www.atlassian.com/git/tutorials/using-branches/git-merge)** — Visual guide to merge strategies

---

## Chapter 4.7: Documenting Agent Patterns

### Deep Dive

#### Why Document Agent Patterns

Agent patterns are **institutional knowledge**. Without documentation, each team member rediscovers the same patterns through trial and error. Documentation serves three audiences:

1. **Claude itself** — Patterns documented in CLAUDE.md become part of Claude's project context. When a team member describes a task, Claude can suggest the appropriate pattern.
2. **Team members** — New developers learn what agent workflows are available and when to use them.
3. **Future you** — Six months from now, you will not remember the exact worktree naming convention or the merge order that avoids conflicts.

#### Documentation Structure for Agent Patterns

Each documented pattern should include these sections:

```markdown
### Pattern: [Name]

**Use when**: [Trigger conditions — when should someone reach for this pattern?]

**Do NOT use when**: [Anti-trigger conditions — when is this pattern a bad fit?]

**Setup**:
1. [Step-by-step setup instructions]
2. [Include exact commands]
3. [Note any prerequisites]

**Agents**:
| Agent | Type | Worktree | Task |
|-------|------|----------|------|
| Coordinator | Parent session | Main | Orchestrates and integrates |
| Agent A | general-purpose | ../project-feature-a | [Specific task] |
| Agent B | Explore | ../project-review | [Specific task] |

**Prompts**:
```
[Exact prompts that work well for this pattern]
```

**Merge/Integration**:
1. [Order of operations for merging]
2. [Known conflict points]
3. [Post-merge verification steps]

**Cleanup**:
1. [Worktree removal commands]
2. [Branch cleanup]
3. [Any other cleanup]

**Estimated time**: [How long this pattern typically takes]
**Estimated cost**: [Rough token usage — e.g., "3x single-session cost"]
```

#### Where to Document

| Location | Audience | Purpose |
|----------|----------|---------|
| CLAUDE.md | Claude Code | Claude references this when suggesting patterns to users |
| `.claude/skills/` | Claude Code + humans | Executable patterns that Claude can invoke |
| Team wiki/docs | Humans | Detailed guides with screenshots, troubleshooting |
| README.md | Humans | High-level overview of available workflows |

**CLAUDE.md is the most important location** because it directly influences Claude's behavior. When you document a pattern in CLAUDE.md, Claude will:
- Suggest the pattern when a matching task is described
- Follow the documented setup steps
- Use the documented naming conventions
- Apply the documented merge strategy

#### Pattern Evolution

Agent patterns improve through iteration. Track what works and what does not:

**Iteration cycle:**
```
1. Design initial pattern
2. Try it on a real task
3. Note friction points:
   - Where did conflicts occur?
   - Which prompts produced poor results?
   - What was the merge order that worked?
4. Update documentation with learnings
5. Try the refined pattern on the next task
6. Repeat
```

**Version your patterns**: Include a "Last updated" date and a brief changelog in complex patterns. This signals to team members whether the pattern is current.

#### Sharing Patterns via Skills

For frequently used patterns, encode them as skills that automate the setup:

```yaml
---
name: parallel-feature
description: Set up parallel feature development with worktrees and agents
argument-hint: <feature-1-name> <feature-2-name>
disable-model-invocation: true
---

## Parallel Feature Development

Set up two worktrees for parallel feature development.

### Steps

1. Create branches: `feature-{arg1}` and `feature-{arg2}`
2. Create worktrees: `../project-feature-{arg1}` and `../project-feature-{arg2}`
3. Launch Claude in each worktree with the feature task
4. Monitor progress
5. When both complete: review, merge, cleanup

### Setup Commands

Run these commands to set up the worktrees:

```bash
git checkout -b feature-$ARG1 && git checkout main
git checkout -b feature-$ARG2 && git checkout main
git worktree add ../$(basename $(pwd))-feature-$ARG1 feature-$ARG1
git worktree add ../$(basename $(pwd))-feature-$ARG2 feature-$ARG2
```

### After Completion

Merge both branches and clean up:

```bash
git merge feature-$ARG1
git merge feature-$ARG2
git worktree remove ../$(basename $(pwd))-feature-$ARG1
git worktree remove ../$(basename $(pwd))-feature-$ARG2
git branch -d feature-$ARG1 feature-$ARG2
```
```

This turns a multi-step manual process into a single `/parallel-feature auth profile` invocation.

#### Role-Specific Pattern Examples

Different roles benefit from different pattern configurations:

**Frontend teams:**
```markdown
### Pattern: Component Development
- Agent A: Implement component (TSX + CSS modules)
- Agent B: Write Storybook stories
- Agent C: Write unit tests with Testing Library
```

**Backend teams:**
```markdown
### Pattern: API Endpoint Development
- Agent A: Implement handler + middleware
- Agent B: Write integration tests
- Agent C: Update OpenAPI specification
```

**QA teams:**
```markdown
### Pattern: Test Coverage Expansion
- Agent A: Write unit tests for module X
- Agent B: Write integration tests for module X
- Agent C: Write E2E tests for the user flow
```

**DevOps teams:**
```markdown
### Pattern: Infrastructure Update
- Agent A: Update Terraform configuration
- Agent B: Update Dockerfile and compose files
- Agent C: Update CI/CD pipeline configuration
```

### External Resources

- **[Claude Code CLAUDE.md Reference](https://docs.anthropic.com/en/docs/claude-code/memory)** — How CLAUDE.md influences Claude's behavior
- **[Agent Skills Specification](https://agentskills.io)** — Standard for creating reusable skills
- **[Best Practices for Claude Code](https://docs.anthropic.com/en/docs/claude-code/best-practices)** — Official guidance on project configuration

---

## Chapter 4.8: Commit Your Work

### Deep Dive

#### What to Commit

After completing the agents module, your repository should contain:

| File | Contains | Commit? |
|------|----------|---------|
| `CLAUDE.md` | Multi-agent patterns section | Yes |
| Merged feature branches | Code from parallel agent work | Yes (already merged) |
| `.claude/skills/parallel-feature/` | Automation skill (if created) | Yes |

#### What to Clean Up First

Before committing, ensure a clean state:

```bash
# 1. Verify no stale worktrees
git worktree list
# Should show only the main worktree

# 2. Verify no leftover branches
git branch
# Should show only main and any intentional long-lived branches

# 3. Clean up any stale worktree references
git worktree prune

# 4. Check for untracked files from agent work
git status
# Review any untracked files — commit useful ones, remove artifacts
```

#### Commit Message Conventions for Agent-Generated Work

When committing work that was produced by multi-agent workflows, the commit message should communicate the process:

```
feat: add user authentication and profile features

Implemented using parallel agent development pattern:
- Agent 1 (feature-auth): JWT authentication middleware
- Agent 2 (feature-profile): User profile CRUD endpoints
- Merged sequentially (auth first, then profile)
- No conflicts — agents worked on non-overlapping file scopes

Includes: middleware, API endpoints, tests, and database migrations.
```

For the CLAUDE.md documentation commit:
```
docs(CLAUDE.md): document multi-agent development patterns

- Add parallel feature development pattern with worktree setup
- Add implementation + review pattern for quality-critical work
- Include cleanup instructions and naming conventions
- Document merge order that avoids conflicts
```

#### Team Communication

When introducing agent patterns to a team:

1. **Share the documented patterns** in a team meeting or Slack message
2. **Demonstrate one pattern** on a real task so the team sees it in action
3. **Collect feedback** after team members try the patterns
4. **Iterate** on the documentation based on real-world usage
5. **Establish conventions** for when each pattern should be used

Patterns work best when the team agrees on conventions upfront — naming, merge order, review expectations — rather than each person improvising.

### External Resources

- **[Conventional Commits](https://www.conventionalcommits.org/)** — Commit message standard used throughout this course
- **[Claude Code Settings Reference](https://docs.anthropic.com/en/docs/claude-code/settings)** — Settings file locations and gitignore guidance

---

## Additional Resources

### Official Documentation

- **[Claude Code Sub-agents](https://docs.anthropic.com/en/docs/claude-code/sub-agents)** — Complete subagent reference with architecture, types, and configuration
- **[Claude Code CLI Usage](https://docs.anthropic.com/en/docs/claude-code/cli-usage)** — CLI reference including headless mode for parallel execution
- **[Claude Code SDK](https://docs.anthropic.com/en/docs/agents/claude-code-sdk)** — Programmatic SDK for orchestrating agents
- **[Claude Code Best Practices](https://docs.anthropic.com/en/docs/claude-code/best-practices)** — Official guidance on effective Claude Code usage

### Git References

- **[Git Worktree Documentation](https://git-scm.com/docs/git-worktree)** — Official git worktree reference
- **[Git Merge Documentation](https://git-scm.com/docs/git-merge)** — Merge strategies and conflict resolution
- **[Pro Git Book — Worktrees](https://git-scm.com/book/en/v2)** — Comprehensive git reference

### Community Resources

- **[Awesome Claude Code (GitHub)](https://github.com/hesreallyhim/awesome-claude-code)** — Community collection of Claude Code patterns, hooks, skills, and plugins
- **[Claude Code GitHub Issues](https://github.com/anthropics/claude-code/issues)** — Bug reports and feature requests
- **[Claude Code Changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)** — Version history and new features
