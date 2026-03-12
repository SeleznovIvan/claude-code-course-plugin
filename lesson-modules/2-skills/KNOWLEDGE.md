# Seminar 2: Skills — Knowledge Base

## How to Use This File

This file complements `SCRIPT.md` with:
- **Deep dive explanations** — detailed background on each topic
- **External resources** — curated links to official docs and community content
- **Links verified** as of February 2026

**Separation of concerns:**
- `SCRIPT.md` = Teaching flow, validations, checklists (instructor guide)
- `KNOWLEDGE.md` = Deep content, external links, conceptual foundations (knowledge base)

---

## Chapter 2.1: What Are Skills?

### Deep Dive

#### The Agent Skills Open Standard

Skills in Claude Code follow the [Agent Skills](https://agentskills.io) open standard — a cross-tool specification for reusable AI instructions designed to work across multiple agentic tools, not just Claude Code. This means skills you write today can potentially be portable to other AI tools that adopt the same standard.

The standard defines a common format (YAML frontmatter + markdown body in a `SKILL.md` file) that any tool can parse, discover, and execute. Anthropic both contributes to and consumes this standard, meaning skills in Claude Code are built on a foundation with a broader ecosystem trajectory.

#### The Three-Way Decision Tree: Skills vs CLAUDE.md vs Commands

One of the most common points of confusion is knowing which mechanism to use for a given instruction. Here is the complete decision framework:

```
What kind of instruction is this?

Is it project-wide context that applies to every interaction?
├── Yes → CLAUDE.md
│          (tech stack, architecture, always-loaded project memory)
│
└── No → Is it invoked by the user with a / prefix?
    ├── Yes → Command (.claude/commands/name.md)
    │          (explicit tasks: /review, /deploy, /new-component)
    │
    └── No → Is it reusable knowledge Claude should apply
               when the situation calls for it?
        ├── Yes → Skill (.claude/skills/name/SKILL.md)
        │          (coding standards, procedures, patterns)
        │
        └── No → Consider if it belongs in any of the above,
                  or if a one-time prompt is sufficient
```

**Decision heuristics:**
- If Claude needs to know it in *every* session without being asked → **CLAUDE.md**
- If a human triggers it explicitly with `/` → **Command**
- If Claude should detect the situation and apply it, or if it encodes a reusable procedure → **Skill**
- If it is a one-time instruction for this conversation → **inline prompt**

#### Cognitive Model: How Skill Descriptions Work

Understanding how Claude processes skills prevents common performance problems. The loading mechanism has two phases:

**Phase 1 — Discovery (always active):** Skill *descriptions* (the `description` field in frontmatter) are always present in Claude's context. This is roughly 2% of the total context window, equivalent to approximately 16,000 characters of description text across all skills. Claude uses these descriptions to determine when a skill is relevant.

**Phase 2 — Invocation (on demand):** The full skill content — everything in the SKILL.md body — is loaded only when Claude decides the skill is relevant or the user explicitly invokes it. This keeps the base context clean.

This two-phase model has practical implications:

| What you write | When it matters |
|----------------|-----------------|
| `description` frontmatter field | Always — this is how Claude decides to load the skill |
| Full SKILL.md body content | Only when the skill is invoked |
| Supporting files (reference.md, etc.) | Only when explicitly referenced in the body |

**Consequence**: A poorly written description means the skill will never trigger correctly, even if the body is perfect. The description is the most important line in your skill file.

#### Two Content Types: Reference vs Task

The official documentation distinguishes between two fundamental skill content types, and understanding this distinction shapes how you write and configure skills:

**Reference content** — Background knowledge that Claude uses as context:
- Coding standards and conventions
- Architecture patterns and decisions
- API specifications
- Style guides
- Domain terminology

Reference skills run inline (not in a subagent). Their content becomes part of Claude's active reasoning when relevant. They are typically set to `user-invocable: false` so Claude applies them automatically without requiring explicit invocation.

**Task content** — Step-by-step procedures that Claude executes:
- Deployment workflows
- Component creation procedures
- Review checklists
- Testing protocols
- Onboarding scripts

Task skills often use `disable-model-invocation: true` to ensure the procedure is only run when the user explicitly chooses — preventing Claude from auto-triggering a deployment when it infers the situation might call for one.

#### Skill Loading Priority Hierarchy

When the same skill name exists in multiple locations, the priority order determines which one wins:

```
1. Enterprise   (organization-wide, highest priority)
2. Personal     (~/.claude/skills/)
3. Project      (.claude/skills/)
4. Plugin       (plugins installed via plugin system)
```

This design enables several useful patterns:
- Enterprise overrides ensure compliance-critical skills can't be bypassed
- Personal skills let individuals customize without affecting team configuration
- Project skills are shared via git with the whole team
- Plugin skills provide third-party capability that project skills can override

#### Automatic Discovery in Monorepos

Claude Code discovers skills recursively from the nearest `.claude/skills/` directories, including parent directories. This means a monorepo can have skills at multiple levels:

```
monorepo/
├── .claude/skills/           # Applies to all packages
│   └── commit-style/
│       └── SKILL.md
├── packages/
│   ├── frontend/
│   │   └── .claude/skills/   # Applies only to frontend work
│   │       └── component/
│   │           └── SKILL.md
│   └── backend/
│       └── .claude/skills/   # Applies only to backend work
│           └── api-endpoint/
│               └── SKILL.md
```

This automatic discovery eliminates any need to register or configure skills — placing the file in the right directory is sufficient.

### External Resources

**Official Anthropic:**
- [Official Skills Documentation](https://code.claude.com/docs/en/skills) — Complete skills reference
- [Agent Skills Open Standard](https://agentskills.io) — Cross-tool skills standard
- [What are Skills?](https://support.claude.com/en/articles/12512176-what-are-skills) — Support article
- [Equipping Agents for the Real World](https://anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills) — Engineering blog post

**Community:**
- [Claude Skills and CLAUDE.md Guide](https://www.gend.co/blog/claude-skills-claude-md-guide) — Team-focused guide comparing both mechanisms
- [Awesome Claude Skills (GitHub)](https://github.com/travisvn/awesome-claude-skills) — Community skill collection

---

## Chapter 2.2: Skill File Structure

### Deep Dive

#### Complete Frontmatter Reference — All 10 Official Fields

Every skill file begins with YAML frontmatter enclosed in `---` delimiters. Here is the complete reference for all officially supported fields:

```yaml
---
name: my-skill                    # 1. Identifier used for invocation
description: |                    # 2. Shown in discovery; key for trigger matching
  What this skill does and when
  Claude should use it.
argument-hint: <target-file>      # 3. Hint text shown to user for arguments
disable-model-invocation: true    # 4. When true, only user can invoke via /
user-invocable: false             # 5. When false, Claude can use but user cannot /
allowed-tools:                    # 6. Restrict which tools this skill can use
  - Read
  - Grep
  - Glob
model: claude-opus-4-6            # 7. Specify model for this skill
context: fork                     # 8. "fork" for isolated subagent execution
agent: Explore                    # 9. Subagent type: Explore, Plan, general-purpose
hooks:                            # 10. Hook configuration for this skill
  - event: post-skill
    command: echo "done"
---
```

**Field-by-field guidance:**

| Field | Required | Default | Purpose |
|-------|----------|---------|---------|
| `name` | Yes | — | Becomes `/skill-name` for invocation |
| `description` | Yes | — | Used for trigger matching; always in context |
| `argument-hint` | No | — | Displays `<hint>` after the command in `/help` |
| `disable-model-invocation` | No | `false` | `true` = user-only, never auto-triggered |
| `user-invocable` | No | `true` | `false` = Claude-only, hidden from `/help` |
| `allowed-tools` | No | All | Allowlist of tools this skill may use |
| `model` | No | Current | Override model for this skill's execution |
| `context` | No | inline | `fork` runs skill in isolated subagent |
| `agent` | No | general-purpose | Subagent type when `context: fork` |
| `hooks` | No | — | Lifecycle hooks for skill events |

#### Directory Structure: Single File vs Multi-File Skills

A skill can be as simple as a single file or as complex as a full directory:

**Simple skill (single file):**
```
.claude/skills/
└── coding-standards.md    # Can be a flat .md file
```

**Standard skill (named directory):**
```
.claude/skills/
└── create-component/
    └── SKILL.md           # Primary skill file
```

**Complex skill (with supporting files):**
```
.claude/skills/
└── create-component/
    ├── SKILL.md           # Primary file; keep under 500 lines
    ├── reference.md       # Detailed specifications
    ├── examples.md        # Comprehensive examples
    └── templates/
        ├── component.tsx.tmpl
        └── test.tsx.tmpl
```

The named-directory pattern (`my-skill/SKILL.md`) is the recommended approach for anything beyond trivial skills because it:
- Groups the skill and all related files together
- Keeps the primary SKILL.md focused and under the 500-line guideline
- Allows supporting files to be loaded on demand

#### `$ARGUMENTS` Substitution Patterns

Skills receive user-provided arguments through template variables:

```markdown
# In your SKILL.md body

Create a new component named $ARGUMENTS.

# Or with positional access:
Component name: $1
Target directory: $2
Test framework: $ARGUMENTS[2]

# Session context:
Session ID for this run: ${CLAUDE_SESSION_ID}
```

| Variable | Meaning |
|----------|---------|
| `$ARGUMENTS` | Full argument string as provided |
| `$ARGUMENTS[N]` | Positional argument, 0-indexed (`$ARGUMENTS[0]` = first word) |
| `$N` | Shorthand for `$ARGUMENTS[N]` (e.g., `$1` = first argument) |
| `${CLAUDE_SESSION_ID}` | Current session ID, useful for logging or file naming |

**Example:** If the user runs `/create-component UserProfile src/components premium`, then:
- `$ARGUMENTS` = `"UserProfile src/components premium"`
- `$1` = `"UserProfile"`
- `$2` = `"src/components"`
- `$ARGUMENTS[2]` = `"premium"`

#### Dynamic Context Injection with Backtick Syntax

A powerful and underused feature: SKILL.md content can include shell command output using the `` !`command` `` syntax. The command runs when the skill loads, and its output is injected inline.

```markdown
---
name: smart-deploy
description: Deploy to the current environment
---

You are deploying from branch: !`git branch --show-current`
Current git status: !`git status --short`
Last commit: !`git log -1 --oneline`

Follow the deployment checklist for this branch.
```

Every time this skill loads, it pulls live data from the environment. This enables:
- Branch-aware instructions ("if on `main`, use production credentials")
- Environment-aware workflows (dev vs staging vs prod)
- File count or size checks before operations
- Dependency version validation

**Security note:** The shell command runs with the same permissions as Claude Code. Avoid injecting user-controlled data into shell commands executed this way.

#### Skill Quality Criteria

A high-quality skill satisfies all three criteria:

1. **Clear description (for trigger matching):** The description should include concrete keywords that match the situations where the skill should apply. Vague descriptions like "helps with code" will never trigger correctly.

2. **Specific instructions:** The body should contain instructions specific enough that Claude cannot interpret them differently from what you intend. Include examples of correct and incorrect behavior.

3. **Testable output:** You should be able to evaluate whether Claude followed the skill. If you cannot tell whether the skill was applied, the instructions are too vague.

### External Resources

**Official:**
- [Official Skills Documentation](https://code.claude.com/docs/en/skills) — Complete frontmatter reference
- [Creating Custom Skills](https://support.claude.com/en/articles/12512198-creating-custom-skills) — Support article
- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices)

**Guides:**
- [Anthropic Skills Guide PDF](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf) — 33-page comprehensive guide
- [Anthropic Skilljar Course](https://anthropic.skilljar.com/introduction-to-agent-skills) — Interactive skills course

---

## Chapter 2.3: Install skill-creator & The Codify Workflow

### Deep Dive

#### The Winning Strategy: Do First, Then Codify

The most effective approach to creating skills is not to design them from scratch in the abstract. Instead:

1. **Do the task by hand** — ask Claude to perform the work in a normal conversation
2. **Observe what worked** — note which steps, which files, which patterns produced good results
3. **In the same session, codify** — while Claude still has full context of what actually happened, use skill-creator to turn the successful approach into a proper SKILL.md

This strategy works because the current session has live memory of what actually succeeded. When you ask skill-creator to codify in the same session, it can reference the actual steps, actual file paths, and actual patterns that worked — not hypothetical ones.

**Why "same session" matters:**
- Claude's context includes all the tool calls, file reads, and decisions from the current session
- skill-creator can read that context and extract the essential steps
- Starting a new session loses this context; you would have to reconstruct the workflow from memory
- The resulting skill is grounded in real work, not speculation

#### Anthropic's Official skill-creator

Anthropic publishes an official skill-creator skill in the `anthropics/skills` GitHub repository. This is a comprehensive, professionally written skill that guides Claude through the process of creating, testing, and optimizing skills.

**Installation:**
1. Type `/plugins` in your Claude Code session
2. Navigate to the **Discover** tab
3. Search for `skill-creator` (from the `anthropics/skills` repository)
4. Install it from the UI

After installation, restart Claude Code with `claude -c` — plugins load at startup, not during a session.

**What skill-creator does:** When you invoke it (typically `/skill-creator` or by describing what you want to codify), it conducts an interview:

1. **Intent capture** — What task does this skill perform? When should it trigger?
2. **Interview** — What steps did you follow? What worked? What edge cases exist?
3. **SKILL.md authoring** — Generates a properly structured skill file with correct frontmatter
4. **Test cases** — Creates concrete test scenarios to verify the skill works
5. **Iteration** — Reviews the result with you and refines based on feedback

#### skill-creator's Writing Principles

The skill-creator applies several principles from Anthropic's engineering team:

**Theory of mind:** Skills are written assuming Claude will read them with good judgment. Instructions should describe *intent*, not just steps, so Claude can adapt when edge cases arise.

**Lean instructions:** Every line in a skill should earn its place. Redundant instructions, over-explanation, and excessive caveats dilute the signal. A 50-line skill that is specific and clear outperforms a 200-line skill that is verbose.

**Generalization:** Good skills handle a class of situations, not just one specific example. skill-creator asks probing questions to find the generalizable pattern behind your specific use case.

**Progressive disclosure:** Descriptions are always in context; full content loads on invocation; supporting files load only when referenced. skill-creator structures output to respect this hierarchy.

#### The Codify Workflow Step by Step

```
Session starts fresh
        ↓
Ask Claude to perform the task
(e.g., "Help me set up a new API endpoint")
        ↓
Claude works through it, you observe and guide
        ↓
Task succeeds — good output produced
        ↓
In the SAME session:
"Now, let's codify what we just did into a skill
 so I can repeat this easily. Use skill-creator."
        ↓
skill-creator interviews you about the workflow
        ↓
SKILL.md is created at .claude/skills/api-endpoint/SKILL.md
        ↓
You review and approve
        ↓
New session → test the skill → iterate if needed
```

### External Resources

**Official:**
- [Anthropic Skills Repository](https://github.com/anthropics/skills) — Official skills including skill-creator
- [skill-creator SKILL.md](https://github.com/anthropics/skills/blob/main/skills/skill-creator/SKILL.md) — 31.6KB comprehensive skill creation guide
- [Anthropic Skilljar Course](https://anthropic.skilljar.com/introduction-to-agent-skills) — Interactive course

**Workflow Resources:**
- [How Anthropic Teams Use Claude Code (PDF)](https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf) — Real-world skill usage at Anthropic
- [claude-code-showcase (GitHub)](https://github.com/ChrisWiles/claude-code-showcase) — Example skills from the community

---

## Chapter 2.4: Creating a Reference Skill

### Deep Dive

#### What Makes a Good Reference Skill

Reference skills encode background knowledge — standards, conventions, and patterns that Claude applies as context when working in a domain. Think of them as the institutional knowledge your senior developers carry in their heads, made explicit and available to Claude.

**Good reference skill characteristics:**
- Specific and actionable — not "write clean code" but "use `const` for all declarations, prefer named exports over default exports, always include JSDoc for public functions"
- Contains examples of correct AND incorrect patterns
- Covers the cases where reasonable developers might disagree — those are exactly where explicit standards add value
- Short enough to be read in full when loaded

**Reference skill content to avoid:**
- Generic best practices that any developer already knows
- Statements like "follow best practices" or "write readable code" (no signal)
- Duplicating what is already in CLAUDE.md (redundant, wastes context)
- Procedural steps (those belong in task/action skills)

#### Reference Skill vs CLAUDE.md: When to Use Each

Both CLAUDE.md and reference skills provide background knowledge, but they serve different purposes:

| Dimension | CLAUDE.md | Reference Skill |
|-----------|-----------|-----------------|
| Loading | Always, every session | On demand when relevant |
| Scope | Project-wide context | Domain-specific standards |
| Content type | Project identity, commands, tech stack | Coding standards, patterns, specs |
| Size guidance | 200-500 lines max | No fixed limit, but lean |
| Discovery | Automatic | Via description matching |

**Rule of thumb:** If Claude needs it in every single interaction, put it in CLAUDE.md. If Claude only needs it when doing a specific type of work (frontend component work, database migrations, API design), make it a reference skill.

#### Example: Good vs Bad Reference Skill

**Bad reference skill (too vague):**
```markdown
---
name: coding-style
description: Coding style guide for our project
---

Write clean, readable code. Follow best practices.
Use meaningful variable names. Write tests.
Keep functions small and focused.
```

This provides no actionable information Claude doesn't already have.

**Good reference skill (specific and actionable):**
```markdown
---
name: typescript-standards
description: TypeScript conventions for this project — component types,
  naming patterns, import ordering, and what to avoid
user-invocable: false
---

## TypeScript Conventions

### Naming
- Components: PascalCase (`UserProfile`, not `userProfile` or `user-profile`)
- Hooks: camelCase with `use` prefix (`useUserData`, not `getUserData`)
- Types/Interfaces: PascalCase with descriptive suffix (`UserProfileProps`, not `Props`)
- Constants: SCREAMING_SNAKE_CASE only for true constants (`MAX_RETRY_COUNT`)

### Imports (always in this order)
1. React and React-related
2. Third-party libraries (alphabetical)
3. Internal utilities
4. Internal components
5. Types (with `type` keyword: `import type { User } from './types'`)

### What NOT to do
- Never use `any` — use `unknown` and narrow
- Never default export components — use named exports
- Never inline object types for props — always define an interface

### Required for every component
- Props interface named `{ComponentName}Props`
- JSDoc comment on the component function
- Display name set if component is defined with `const`
```

The second skill gives Claude real constraints to work within. Claude will produce meaningfully different (and more consistent) output when this skill is loaded.

#### The `user-invocable: false` Pattern

Setting `user-invocable: false` creates a "background knowledge" skill — one that Claude applies automatically without the user ever needing to invoke it. This is the ideal configuration for reference skills because:

- Users should not need to remember to say "apply our TypeScript standards" on every coding task
- Claude detects the situation (writing TypeScript) via the description and loads the skill
- The standards are applied transparently

The tradeoff: the skill must have a precise description for auto-detection to work reliably.

### External Resources

- [Official Skills Documentation](https://code.claude.com/docs/en/skills) — Reference vs task content types
- [Awesome Claude Skills (GitHub)](https://github.com/travisvn/awesome-claude-skills) — Community reference skill examples
- [Claude Code Best Practices (GitHub)](https://github.com/awattar/claude-code-best-practices) — Real-world skill patterns

---

## Chapter 2.5: Creating an Action Skill

### Deep Dive

#### What Makes a Good Action Skill

Action (task) skills encode procedures — the steps Claude should follow to accomplish a specific, bounded task. Think of them as runbooks: clear enough that a capable developer following them produces a consistent, correct result every time.

**Good action skill characteristics:**
- Has a clear entry condition: what triggers this procedure?
- Has a clear exit condition: what does "done" look like?
- Steps are in the right order, each building on the last
- Includes verification steps — how does Claude check its own work?
- Handles the most common edge cases explicitly

**Action skill content to avoid:**
- Open-ended exploration (that is what reference skills and free conversation are for)
- Steps that require judgment calls not covered by the skill (either cover them or defer to the user)
- Steps so vague that Claude must invent the implementation ("do the thing" is not a step)

#### `disable-model-invocation: true` — When and Why

This field prevents Claude from auto-triggering the skill based on context matching. When set to `true`, the skill can only be invoked by the user explicitly using `/skill-name`.

**Use `disable-model-invocation: true` when:**
- The procedure is irreversible (deployments, database migrations, file deletions)
- The procedure is expensive (long-running processes, API calls with costs)
- The procedure should always be a conscious human decision (releases, security operations)
- You want to prevent false-positive triggering during planning or discussion

**Leave it as default (`false`) when:**
- The skill is a helpful enhancement Claude should apply automatically
- The procedure is safe to run and easy to verify
- Users would benefit from Claude applying it without being prompted

#### Template Variables for Parameterization

Action skills become reusable procedures through template variables:

```markdown
---
name: create-component
description: Create a new React component with tests and barrel export
argument-hint: <ComponentName> [directory]
---

Create a new React component following our project conventions.

## Parameters
- Component name: $1
- Target directory: $2 (default: src/components if not provided)

## Steps

1. Create directory `$2/$1/` (or `src/components/$1/` if $2 is empty)
2. Create `$2/$1/$1.tsx` — the main component file
3. Create `$2/$1/$1.test.tsx` — the test file
4. Create `$2/$1/index.ts` — the barrel export
5. Update parent index if it exists

## Verification
After creating files, confirm:
- Component renders without errors (check imports)
- Test file includes at least a smoke test
- Barrel export uses named export, not default
```

Usage: `/create-component UserProfile src/features/auth`

#### `context: fork` for Isolated Execution

When `context: fork` is set, the skill runs in a separate subagent rather than inline with the current conversation. This has important implications:

| Dimension | Inline (default) | Fork |
|-----------|-----------------|------|
| Context pollution | Skill content enters main context | Isolated; main context unaffected |
| Conversation state | Shared | Separate |
| Parallel execution | Sequential | Can run while user continues |
| Use case | Quick tasks, reference | Complex procedures, analysis |

Fork execution is ideal for action skills that perform extensive file reads, run long searches, or generate large intermediate output that you do not want in your main conversation thread.

#### Conditional Branching in Skills

Skills can use markdown structure to define conditional paths:

```markdown
## Environment Check

If the argument is `production`:
- Use production credentials from environment
- Enable dry-run mode first
- Require explicit confirmation before writing

If the argument is `staging`:
- Use staging credentials
- Skip dry-run
- Proceed directly

If no argument is provided:
- Default to staging behavior
- Notify user of the default assumption
```

Claude follows these conditions using its own judgment. The key is being explicit about the conditions and their consequences.

#### Skill Composition: Referencing Other Skills

A skill can explicitly reference another skill by name, creating a composition pattern:

```markdown
## Pre-deployment Checks

Before deploying, first run the `code-review` skill to verify:
- No console.log statements in changed files
- All new functions have JSDoc
- Test coverage for new code

Only proceed if the code-review skill passes all checks.
```

This keeps individual skills focused while allowing complex workflows to be assembled from smaller pieces.

### External Resources

- [Official Skills Documentation](https://code.claude.com/docs/en/skills) — Task content, invocation control
- [Subagents Documentation](https://code.claude.com/docs/en/sub-agents) — Fork execution model
- [Anthropic Skills Guide PDF](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf) — Step-by-step skill design

---

## Chapter 2.6: Testing & Iterating

### Deep Dive

#### The Fresh Session Requirement

Skills are discovered and loaded at session start. This is the single most important fact for testing skills:

**After creating or modifying a skill, you must start a new Claude session before testing it.**

There is no hot-reload mechanism. A skill modified in the current session will not take effect until the next session begins. This is a common source of confusion — developers edit SKILL.md, try to use the skill, and see old behavior because the session loaded the previous version at startup.

**Workflow implication:** Treat the edit-test cycle as:
1. Edit SKILL.md in your editor
2. Exit the current Claude session (`/exit` or Ctrl+D)
3. Start a new session (`claude` in the same directory)
4. Verify with `/context` that the skill appears
5. Test by invoking or triggering the skill
6. If changes needed, repeat from step 1

#### Using `/context` to Verify Skill Discovery

The `/context` command shows everything currently loaded in Claude's context window, including which skills have been discovered and what their descriptions are. Before testing a skill, always run `/context` to confirm:

- Your skill appears in the list
- The description shown matches what you intended
- The name is correct (typos in directory names are a common issue)

If your skill does not appear in `/context`, it has not been discovered. Common causes:
- The file is named incorrectly (must be `SKILL.md`, case-sensitive)
- The directory is not under `.claude/skills/`
- The frontmatter YAML has a syntax error
- The session was not restarted after creating the skill

#### Four-Point Evaluation Rubric

When testing a skill, evaluate it against four dimensions:

**1. Trigger accuracy**
- Does the skill activate when you expect it to?
- Does it *not* activate when you do not expect it to?
- Test both positive cases (should trigger) and negative cases (should not trigger)

**2. Instruction adherence**
- Does Claude follow the steps in the skill in order?
- Are any steps skipped or reordered?
- Does Claude add steps not in the skill (over-helpfulness)?

**3. Output quality**
- Does the result match your project's actual conventions?
- Is the output at the right level of detail?
- Would a senior developer on your team approve this output?

**4. Edge cases**
- Run the skill with unusual input: empty arguments, very long arguments, special characters
- Try it in edge-case contexts: empty directory, existing file at the target path, missing dependencies
- Document edge cases the skill handles and those it explicitly defers

#### Troubleshooting Common Issues

**Issue: Skill not triggering when expected**

Diagnosis:
1. Run `/context` — is the skill listed?
2. Check the description — does it contain keywords that match the situation?
3. Try invoking explicitly with `/skill-name` to test the body independently of triggering

Fixes:
- Strengthen description keywords (add synonyms, related terms)
- Make description more specific about the triggering situation
- Test description by asking: "Would this description help Claude recognize when to use this skill?"

**Issue: Skill triggering too broadly (over-triggering)**

Diagnosis:
- Skill activates in conversations where it is not relevant
- Claude applies the skill even during planning or discussion of the topic

Fixes:
- Add `disable-model-invocation: true` to require explicit invocation
- Narrow the description to be more specific about the exact trigger condition
- Add negative examples to the description: "Use this when creating new components, NOT when modifying existing ones"

**Issue: Description budget exhausted**

Diagnosis:
- You have many skills, and some are not loading
- `/context` shows some skills are not listed despite correct file placement

Fix:
- Total skill descriptions must stay within approximately 16,000 characters combined (~2% of context)
- Audit all descriptions: shorten verbose ones, remove skills that are no longer used
- Consolidate related skills into a single skill with branching logic

#### The Iteration Loop

```
Write SKILL.md
      ↓
New Claude session
      ↓
/context — verify skill appears
      ↓
Test (trigger or invoke)
      ↓
Evaluate against 4-point rubric
      ↓
Identify specific issue
      ↓
Edit SKILL.md (target the specific issue)
      ↓
New Claude session → retest
      ↓
Repeat until all 4 dimensions pass
      ↓
Commit skill to repository
```

Each iteration should target one specific issue. Changing multiple things at once makes it hard to know which change fixed the problem.

### External Resources

- [Official Skills Documentation](https://code.claude.com/docs/en/skills) — Troubleshooting section
- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices)

---

## Chapter 2.7: Advanced Patterns & Maintenance

### Deep Dive

#### Subagent Skills: `context: fork` + `agent` Type

When a skill runs in a forked subagent, the `agent` field determines what type of subagent is used. Each type has a different profile optimized for different work:

| Agent Type | Optimized For | Best Used When |
|------------|---------------|---------------|
| `Explore` | Codebase searches, reading, understanding | Analysis tasks, code review, dependency tracing |
| `Plan` | Design decisions, architecture, planning | System design, migration planning, refactoring strategy |
| `general-purpose` | Multi-step tasks, writing, implementing | Component creation, test writing, documentation |

**Example: Analysis skill using Explore agent**
```yaml
---
name: dependency-audit
description: Audit all dependencies of a file, tracing imports recursively
context: fork
agent: Explore
allowed-tools:
  - Read
  - Grep
  - Glob
---
```

The Explore agent specializes in navigating and understanding codebases efficiently. Pairing it with `allowed-tools` restricting to read-only tools creates a safe, focused analysis skill.

**Example: Architecture skill using Plan agent**
```yaml
---
name: design-api
description: Design the API contract for a new endpoint before implementation
context: fork
agent: Plan
disable-model-invocation: true
---
```

The Plan agent is oriented toward producing structured plans and design documents rather than directly executing changes.

#### Dynamic Context Injection: Practical Patterns

The `` !`command` `` syntax enables sophisticated environment-aware skills. Here are production-tested patterns:

**Git-aware deployment skill:**
```markdown
Current branch: !`git branch --show-current`
Changed files: !`git diff --name-only HEAD`
Commit count since last tag: !`git rev-list $(git describe --tags --abbrev=0)..HEAD --count`
```

**Environment detection:**
```markdown
Node version: !`node --version`
Package manager: !`ls package-lock.json yarn.lock pnpm-lock.yaml 2>/dev/null | head -1`
Test framework: !`cat package.json | python3 -c "import sys,json; d=json.load(sys.stdin); print(list(d.get('devDependencies',{}).keys()))" 2>/dev/null`
```

**Project structure snapshot:**
```markdown
Current directory structure:
!`find . -maxdepth 2 -not -path '*/node_modules/*' -not -path '*/.git/*' | sort`
```

#### Supporting Files Pattern for Large Skills

When skill content grows beyond 500 lines, split it using the supporting files pattern:

```
.claude/skills/
└── api-endpoint/
    ├── SKILL.md              # Entry point: frontmatter + overview + references
    ├── conventions.md        # Detailed API conventions (referenced in SKILL.md)
    ├── examples.md           # Complete examples of correct endpoints
    └── templates/
        ├── handler.ts.tmpl   # Handler template
        └── test.ts.tmpl      # Test template
```

In SKILL.md, reference supporting files explicitly:
```markdown
## Conventions
See the detailed conventions in @.claude/skills/api-endpoint/conventions.md

## Examples
Reference @.claude/skills/api-endpoint/examples.md for complete examples
```

Supporting files are loaded only when Claude reaches that reference — a form of on-demand progressive disclosure within a skill.

#### `allowed-tools` Restrictions for Security and Focus

The `allowed-tools` field restricts which tools a skill can invoke. This serves two purposes:

**Security:** Prevent a skill from taking actions outside its intended scope.
```yaml
allowed-tools:
  - Read
  - Grep
  - Glob
# This skill can only read — cannot write files, run commands, or make network requests
```

**Focus:** Help Claude stay on task by removing distracting tool options.
```yaml
allowed-tools:
  - Bash
  - Write
# Deployment skill: only runs commands and writes config files
```

Common `allowed-tools` combinations:

| Use Case | Tools |
|----------|-------|
| Read-only analysis | `Read`, `Grep`, `Glob` |
| Code generation | `Read`, `Write`, `Edit` |
| Automation script | `Bash`, `Write` |
| Full capability | (omit the field — all tools available) |

#### Team Sharing and Skill Lifecycle

**Where skills live determines who shares them:**

| Location | Who Has Access | Use For |
|----------|---------------|---------|
| `.claude/skills/` (project) | Everyone with the repo | Team standards, project procedures |
| `~/.claude/skills/` (personal) | Only you | Personal workflow customizations |
| Plugin | Anyone who installs the plugin | Reusable skills across multiple projects |

**Skill lifecycle stages:**
1. **Create** — codify a working workflow into SKILL.md
2. **Test** — verify with the 4-point rubric
3. **Iterate** — refine based on real usage
4. **Share** — commit to repo (project) or publish as plugin (external)
5. **Maintain** — update when the underlying workflow changes
6. **Retire** — delete skills that no longer apply; unused skills consume description budget

**Signs a skill needs updating:**
- It references file paths that have moved
- The procedure it encodes has changed
- Claude consistently deviates from it (the instructions may no longer match current Claude behavior)
- Team members report it producing incorrect output

#### Enterprise Deployment Considerations

In enterprise settings, skills can be deployed at the organization level, taking the highest priority in the hierarchy. Key considerations:

- Enterprise skills override project and personal skills with the same name
- Use this for compliance-critical standards (security practices, data handling)
- Communicate enterprise skills to teams so they understand what is pre-loaded
- Enterprise skills are typically managed by platform/DevOps teams, not individual developers

#### Generating Visual Output from Skills

Skills can instruct Claude to generate rich output beyond plain text:

```markdown
## Output Format

After completing the analysis, generate an HTML report at `reports/dependency-audit.html` that includes:
- A summary table of all dependencies
- Highlighted unused dependencies in red
- Circular dependency chains shown as a graph
- Recommendations section

Use inline CSS for styling; the report should be self-contained.
```

This pattern is useful for audit skills, report generation, and documentation workflows where a persistent artifact is more valuable than a conversation response.

### External Resources

**Official:**
- [Official Skills Documentation](https://code.claude.com/docs/en/skills) — Advanced features section
- [Subagents Documentation](https://code.claude.com/docs/en/sub-agents) — Fork execution model and agent types
- [Anthropic Skills Repository](https://github.com/anthropics/skills) — Official skill examples from Anthropic

**Community:**
- [Awesome Claude Code (GitHub)](https://github.com/hesreallyhim/awesome-claude-code) — Skills, hooks, commands, plugins
- [Awesome Claude Skills (GitHub)](https://github.com/travisvn/awesome-claude-skills) — Community skill collection
- [claude-code-showcase (GitHub)](https://github.com/ChrisWiles/claude-code-showcase) — Real-world advanced skill patterns

---

## Chapter 2.8: Commit Your Skills

### Deep Dive

#### What to Commit — The Decision Matrix

Not all skill-related files belong in your repository. Here is the complete decision matrix:

| File / Directory | Commit? | Reason |
|-----------------|---------|--------|
| `.claude/skills/` (project skills) | Yes | Shared team knowledge |
| `~/.claude/skills/` (personal skills) | No | Personal machine only; not in project |
| `.claude/skills/*.md` (flat skill files) | Yes | Same as directory skills |
| Supporting files in skills/ | Yes | Part of the skill |
| Templates in skills/ | Yes | Required for skill to function |

**Common mistake:** Adding `.claude/skills/` to `.gitignore` accidentally. This prevents skills from being shared with teammates. If you see `.claude/` in your `.gitignore`, verify that the skills subdirectory is not excluded.

#### .gitignore Recommendations for Claude Files

A correctly configured `.gitignore` shares skills and commands while protecting personal settings:

```gitignore
# Claude Code personal files — do NOT share
.claude/settings.local.json
.claude/memory/MEMORY.md

# Claude Code team files — SHOULD be shared (do not gitignore these)
# .claude/skills/        <-- intentionally NOT ignored
# .claude/commands/      <-- intentionally NOT ignored
# CLAUDE.md              <-- intentionally NOT ignored
```

#### Practice Skill Cleanup

If you created a practice skill during this module that is not genuinely useful for your project, clean it up before committing:

```bash
# Review what you have
ls .claude/skills/

# Remove practice-only skills
rm -rf .claude/skills/my-practice-skill/

# Verify only useful skills remain
```

Committing practice or experimental skills adds noise to the repository and consumes description budget for every teammate's session.

#### Crafting a Good Commit for Skills

When committing skills, the commit message should communicate what the skill does and why it was created:

```
feat(.claude): add TypeScript conventions reference skill

- Add .claude/skills/typescript-standards/ with naming, import order,
  and anti-pattern rules for our TypeScript codebase
- Set user-invocable: false so skill applies automatically
- Codified from session where we standardized component naming

This replaces the conventions section in CLAUDE.md which was growing
too long. Claude now loads these standards only when writing TypeScript.
```

Include `Co-authored-by: Claude <noreply@anthropic.com>` if Claude contributed substantially to the skill content.

#### The Plugin Distribution Path

If your skills prove valuable beyond your immediate team — for example, skills encoding patterns common to a framework or domain — consider packaging them as a Claude Code plugin:

1. Create a plugin repository with the standard plugin structure
2. Add your skills under `skills/` in the plugin
3. Define the plugin manifest in `.claude-plugin/plugin.json`
4. Publish to GitHub (or a private registry for enterprise)
5. Teams install with `/plugin marketplace add your-org/your-skills`

This is how the broader Claude Code skill ecosystem grows: individuals codify workflows, teams share via plugins, and the community benefits.

### External Resources

- [Conventional Commits](https://www.conventionalcommits.org/) — Commit message standard used throughout this course
- [Awesome Claude Code (GitHub)](https://github.com/hesreallyhim/awesome-claude-code) — Plugin distribution examples and patterns

---

## Additional Resources

### Complete Guides

- [Anthropic Skills Guide PDF](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf) — 33-page comprehensive guide covering all skill concepts
- [Anthropic Skilljar Course](https://anthropic.skilljar.com/introduction-to-agent-skills) — Interactive skills course from Anthropic

### Curated Collections

- [Awesome Claude Skills (GitHub)](https://github.com/travisvn/awesome-claude-skills) — Community-maintained collection of ready-to-use skills
- [Awesome Claude Code (GitHub)](https://github.com/hesreallyhim/awesome-claude-code) — Skills, hooks, commands, and plugins

### Official Channels

- [Claude Code GitHub Issues](https://github.com/anthropics/claude-code/issues) — Bug reports and feature requests
- [Claude Code Changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md) — Version history and new skill features
