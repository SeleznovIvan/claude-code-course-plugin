# Seminar 2: Skills

**Duration**: 110 minutes (80 min guided + 30 min implementation)

**Seminar ID**: `2-skills`

---

## Before You Begin

**Prerequisites**: You must have completed Module 1 (Foundations & Commands). Specifically:
- CLAUDE.md exists in your repository
- You've created at least one custom command in `.claude/commands/`
- You understand slash commands, plan mode, and basic CLI usage

If you haven't completed Module 1, run `/cc-course:start 1` first.

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
- Understand what Skills are and how they differ from CLAUDE.md and Commands
- Know the complete SKILL.md frontmatter specification (all 10 fields)
- Install and use Anthropic's official skill-creator via the `/plugins` Discover tab
- Master the "do by hand first, then codify" workflow for creating high-quality skills
- Create reference skills (coding standards, conventions)
- Create action skills (step-by-step procedures)
- Test, iterate, and maintain skills effectively

---

## Chapter Phase Map

Quick reference showing which interactive phases each chapter has:

| Chapter | PRESENT | CHECKPOINT | ACTION | VERIFY |
|---------|---------|------------|--------|--------|
| 1 — What Are Skills? | yes | yes | — | — |
| 2 — Skill File Structure | yes | yes | — | — |
| 3 — Install skill-creator & The Codify Workflow | yes | yes | yes | yes |
| 4 — Creating a Reference Skill | yes | yes | yes | yes |
| 5 — Creating an Action Skill | yes | yes | yes | yes |
| 6 — Testing & Iterating | yes | yes | yes | yes |
| 7 — Advanced Patterns & Maintenance | yes | yes | — | — |
| 8 — Commit Your Skills | yes | — | yes | yes |

---

## Chapter Progress Map

Data for the table of contents and progress bar (see teaching.md).

| Step | Chapter Label | Short Title |
|------|---------------|-------------|
| 1 | Chapter 1 | What Are Skills? |
| 2 | Chapter 2 | Skill File Structure |
| 3 | Chapter 3 | skill-creator & Codify Workflow |
| 4 | Chapter 4 | Reference Skill |
| 5 | Chapter 5 | Action Skill |
| 6 | Chapter 6 | Testing & Iterating |
| 7 | Chapter 7 | Advanced Patterns |
| 8 | Chapter 8 | Commit Your Skills |

**Total steps**: 8 | **Module title**: Skills | **Module number**: 2

---

## Chapter 1: What Are Skills?

**Chapter ID**: `2.1-what-are-skills`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 2.1](./KNOWLEDGE.md#chapter-21-what-are-skills) for the Agent Skills open standard, the three-way decision tree (Skills vs CLAUDE.md vs Commands), context loading model, and external resources.

### Content

#### Skills vs CLAUDE.md vs Commands

| Feature | CLAUDE.md | Skills | Commands |
|---------|-----------|--------|----------|
| Purpose | Project context and memory | Reusable instructions | Explicit user-triggered tasks |
| Loading | Always loaded, every session | Descriptions always; full content on invocation | Loaded when user types `/name` |
| Scope | "What this project is" | "How to do things" | "Do this specific thing now" |
| Count | One per directory | Many per project | Many per project |
| Auto-detection | Always active | Claude matches by description | User must invoke with `/` |

#### Mental Model

Skills are like **runbooks or playbooks** for Claude. They teach Claude how to perform specific tasks the way your team does them.

**Without skills**:
```
You: "Create a new component"
Claude: *Creates component in generic way*
```

**With skills**:
```
You: "Create a new component"
Claude: *Follows your team's exact patterns, file structure, naming conventions*
```

#### Two Content Types

Skills fall into two categories:

1. **Reference Skills** (Reference Content): Provide context and standards
   - Coding standards, naming conventions
   - Architecture documentation
   - API specifications
   - **Run inline** — content becomes part of Claude's active context
   - Often set `user-invocable: false` (Claude auto-detects when to apply)

2. **Action Skills** (Task Content): Define step-by-step procedures
   - "How to create a new component"
   - "How to add an API endpoint"
   - "How to deploy a release"
   - Often set `disable-model-invocation: true` (user controls when to run)
   - Can use `$ARGUMENTS` for parameterization

#### Skill Loading Priority

When multiple skills exist across locations, priority order is:

1. **Enterprise** (highest) — managed by organization admins
2. **Personal** (`~/.claude/skills/`) — your machine only
3. **Project** (`.claude/skills/`) — committed to repository
4. **Plugin** — from installed plugins

Higher-priority skills override lower-priority ones with the same name.

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand the difference between Skills, CLAUDE.md, and Commands? The key points are: CLAUDE.md is always-loaded project context, Skills are reusable instructions loaded when relevant, and Commands are explicit `/`-triggered tasks."
- **Options**: "Yes, I understand — let's continue" / "I have a question" / "I need more explanation"
- On questions: answer them, then re-ask
- On "need more explanation": elaborate on the two content types (reference vs task) and the loading model, then re-ask

### Checklist

- [ ] Understand the difference between CLAUDE.md, Skills, and Commands
- [ ] Know what reference skills are (standards/conventions, inline)
- [ ] Know what action skills are (procedures, often user-invoked)
- [ ] Understand skill loading priority (enterprise > personal > project > plugin)
- [ ] Understand the "runbook" mental model

---

## Chapter 2: Skill File Structure

**Chapter ID**: `2.2-skill-structure`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 2.2](./KNOWLEDGE.md#chapter-22-skill-file-structure) for the complete 10-field frontmatter reference, `$ARGUMENTS` substitution details, dynamic context injection, and skill quality criteria.

### Content

#### Location

Skills live in: `.claude/skills/`

#### Directory Structure

```
.claude/skills/
├── coding-standards/           # Directory-based skill (recommended)
│   ├── SKILL.md                # Main skill file
│   ├── reference.md            # Supporting details
│   └── examples.md             # Extended examples
├── create-component/
│   └── SKILL.md
└── deploy-release/
    └── SKILL.md
```

**Rule**: Keep `SKILL.md` under 500 lines. Use supporting files for longer content.

#### Basic SKILL.md Template

```markdown
---
name: skill-name
description: Brief description — this is what Claude uses to decide when to apply the skill
---

# Skill: [Human-Readable Name]

## Description

[What this skill enables - 2-3 sentences]

## When to Use

[Trigger conditions - when should Claude apply this skill?]

## Instructions

[Step-by-step process or guidelines]

## Examples

[Concrete examples showing the skill in action]
```

#### Complete Frontmatter Reference

| Field | Required | Purpose | Example |
|-------|----------|---------|---------|
| `name` | Yes | Identifier for the skill | `coding-standards` |
| `description` | Yes | Trigger matching — Claude reads this to decide relevance | `Team coding standards and naming conventions` |
| `argument-hint` | No | Hint text shown for expected arguments | `<component-name>` |
| `disable-model-invocation` | No | When `true`, only user can invoke via `/` | `true` |
| `user-invocable` | No | When `false`, only Claude can use it (not shown in `/help`) | `false` |
| `allowed-tools` | No | Restrict which tools the skill can use | `[Read, Grep, Glob]` |
| `model` | No | Specify model for execution | `sonnet` |
| `context` | No | `fork` runs in isolated subagent | `fork` |
| `agent` | No | Subagent type (requires `context: fork`) | `Explore` |
| `hooks` | No | Hook configuration for the skill | (see docs) |

#### String Substitution

Skills support template variables:

| Variable | Resolves To | Example Usage |
|----------|-------------|---------------|
| `$ARGUMENTS` | Full argument string | `/skill-name arg1 arg2` → `arg1 arg2` |
| `$ARGUMENTS[0]` | First positional argument | `/skill-name foo bar` → `foo` |
| `$ARGUMENTS[1]` | Second positional argument | `/skill-name foo bar` → `bar` |
| `$0`, `$1` | Shorthand for `$ARGUMENTS[N]` | Same as above |
| `${CLAUDE_SESSION_ID}` | Current session ID | For logging/tracking |

#### Dynamic Context Injection

Skills can include output from shell commands using backtick-bang syntax:

```markdown
## Current State

The current git branch is: !`git branch --show-current`
The last 5 commits are:
!`git log --oneline -5`
```

This executes the commands at skill load time and injects the output into the skill content.

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand the SKILL.md structure? Key points: directory-based skills with frontmatter (`name` and `description` are required), content sections, and the 500-line limit with supporting files for overflow."
- **Options**: "Yes, clear" / "Can you show the frontmatter fields again?" / "What's the difference between `disable-model-invocation` and `user-invocable`?"
- On "show again": re-present the frontmatter table
- On "difference": explain that `disable-model-invocation: true` means user-only (shown in `/help`, must type `/name`), while `user-invocable: false` means Claude-only (NOT shown in `/help`, Claude auto-applies it)

### Checklist

- [ ] Know where skills are stored (`.claude/skills/`)
- [ ] Understand directory-based skill structure (SKILL.md + supporting files)
- [ ] Know what frontmatter fields are required (`name`, `description`)
- [ ] Understand the 500-line rule for SKILL.md
- [ ] Know about `$ARGUMENTS` substitution and dynamic context injection

---

## Chapter 3: Install skill-creator & The Codify Workflow

**Chapter ID**: `2.3-skill-creator-workflow`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 2.3](./KNOWLEDGE.md#chapter-23-install-skill-creator--the-codify-workflow) for the winning strategy explained in detail, skill-creator's writing principles, progressive disclosure, and external resources.

### Content

#### The "Winning Strategy" for Creating Skills

The most effective way to create high-quality skills is **NOT** to write SKILL.md files from scratch. Instead:

1. **Do the work by hand first** — Work with Claude interactively to complete a real task
2. **Stay in the same session** — The context of what worked is still live
3. **Ask Claude to summarize** what was done and what patterns emerged
4. **Use skill-creator to codify** the summary into a proper SKILL.md

**Why this works better than writing skills from scratch:**
- The skill is grounded in what *actually worked*, not imagined steps
- Anthropic's skill-creator applies best practices automatically (progressive disclosure, lean instructions, proper frontmatter)
- The current session has full context — file paths, conventions, edge cases
- You get proper structure without memorizing the format

#### What is skill-creator?

Anthropic's official `skill-creator` is a comprehensive skill from the [`anthropics/skills`](https://github.com/anthropics/skills) repository. It guides Claude through:

1. **Intent capture** — Understanding what the skill should do
2. **Interview** — Asking clarifying questions about scope and behavior
3. **SKILL.md authoring** — Writing the skill with proper frontmatter and structure
4. **Test cases** — Optionally generating test scenarios
5. **Iteration** — Refining based on feedback

#### Installation

Install skill-creator via the plugin manager UI:

1. Type `/plugins` in your Claude Code session
2. Navigate to the **Discover** tab
3. Search for `skill-creator` (it's part of the `anthropics/skills` repository)
4. Install it from the UI

> ⚠️ **Important**: Plugins load at Claude startup. After installing, you must **restart Claude** with `claude -c` (to continue the session) for skill-creator to become available.

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand the 'winning strategy'? The key insight is: do the work by hand first, stay in the same session, then use skill-creator to codify it into a SKILL.md. This produces better skills because they're grounded in real work."
- **Options**: "Yes, makes sense — let's install skill-creator" / "Why can't I just write SKILL.md directly?" / "I need more explanation"
- On "why not directly": explain that writing from scratch often produces vague or incorrect skills because you're imagining steps rather than documenting what actually worked. The codify workflow captures real file paths, real conventions, and real edge cases from a live session.
- On "need more explanation": walk through a concrete example of the workflow, then re-ask

### Instructor: Action (Part A — Install)

Tell the student:
"Let's install Anthropic's official skill-creator. Follow these steps:

1. Type `/plugins` to open the plugin manager
2. Navigate to the **Discover** tab
3. Search for `skill-creator` (it's part of the `anthropics/skills` repository)
4. Install it from the UI

Use the {cc-course:continue} Skill tool when you've completed the installation."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Action (Part B — Save & Restart)

> **IMPORTANT**: Before restarting, save progress to progress.json. Update:
> - `current_module`: `"2-skills"`
> - `current_task`: `"understand_codify_workflow"`
> - `create_skills_directory`: check if `.claude/skills/` now exists — if so, mark `true`
> - Do NOT mark `understand_codify_workflow` as complete yet

Tell the student:
"The plugin is installed, but plugins load at Claude startup. You need to restart Claude for skill-creator to become available.

**Steps:**
1. Type `exit` to leave Claude
2. Start Claude again with `claude -c` to continue this session
3. Run `/cc-course:continue` to resume the course right where we left off

Your progress is saved — the course will pick up at this exact point."

**The student exits and restarts. The course resumes via `/cc-course:continue`.**

### Instructor: Action (Part C — Verify & Practice)

After the student returns via `/cc-course:continue`:

1. **Verify skill-creator is installed**: Ask the student to check:
   - Type `/plugins` → go to the **Installed** tab — skill-creator should appear in the list
   - Or run `/context` — skill-creator should appear in the loaded context
   - If skill-creator appears → proceed
   - If not → troubleshoot: re-open `/plugins` → Discover, search and install again, then restart with `claude -c`

2. **Discover a practice task from session history**:

Before asking the student to pick a task, analyze their recent Claude Code sessions to find repeatable patterns worth codifying.

**Use cclogviewer MCP tools** (read `student.mcp_project_name` from progress.json for the `project` parameter):

```
# Get recent sessions
mcp__cclogviewer__list_sessions(project=<project_name>, days=30, limit=10)

# Get tool usage patterns
mcp__cclogviewer__get_tool_usage_stats(project=<project_name>, days=30)

# Search for repeated task patterns
mcp__cclogviewer__search_logs(project=<project_name>, query="create|add|setup|fix|update")

# Optionally get timeline for the most active sessions
mcp__cclogviewer__get_session_timeline(session_id=<id>, project=<project_name>)
```

**Analyze the results** for:
- Tasks that appear across multiple sessions (repeated workflows)
- Frequently used tool sequences (e.g., Read → Edit → Bash patterns)
- Common prompts or request types
- Recurring file types or directories being modified

**Present 3-5 discovered patterns** to the student via AskUserQuestion:

"Based on your recent Claude Code sessions, here are repeatable patterns I found that would make great practice skills:

1. **[Pattern Name]** — [Description]. Found in [N] sessions. [Why it would make a good skill].
2. **[Pattern Name]** — [Description]. Found in [N] sessions. [Why it would make a good skill].
3. **[Pattern Name]** — [Description]. Found in [N] sessions. [Why it would make a good skill].

Which one would you like to work with?"

- **Options**: The discovered patterns + "I have my own idea"
- If the student picks their own idea, proceed with that

**Fallback** — if cclogviewer MCP is unavailable, the project has no session history, or no meaningful patterns are found, fall back to role-based suggestions:

| Role | Micro-Task Ideas |
|------|-----------------|
| Frontend | Set up a new page route |
| Backend | Add a new database model |
| QA | Write a test for an edge case |
| DevOps | Add a new environment variable |
| Data | Create a data validation check |

3. **Practice the codify workflow**:

Tell the student:
"Now let's practice the 'winning strategy' with your chosen task.

**Step 1**: Do the task interactively with me right now. Just ask me to help you do it.

**Step 2**: After we finish, I'll use skill-creator to turn what we did into a reusable skill.

Let's get started — describe what you need and I'll help you do it."

**Guide the student through their chosen micro-task interactively.**

After the task is done, tell the student:
"Now let's codify this into a skill. I'll use skill-creator to turn what we just did into a proper SKILL.md.

Use the skill-creator skill to create a skill based on what we just did."

Or if the student prefers, they can prompt: "Use the skill-creator skill to create a [name] skill for my project based on the task we just completed."

This will create a `.claude/skills/[name]/SKILL.md` file with proper frontmatter, structure, and content derived from the real work.

Tell the student: "Use the {cc-course:continue} Skill tool when the practice skill has been created."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks in the student's repository:

1. **directory_exists**: Use Glob to check `.claude/skills/` directory exists
2. **file_pattern**: Use Glob for `.claude/skills/*/SKILL.md` — at least 1 file must exist
3. **content_check**: Use Read to verify the skill file has:
   - Frontmatter with `name:` and `description:`
   - Meaningful content (more than 10 lines)

**On failure**: Tell the student what's missing. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set tasks `create_skills_directory`, `understand_codify_workflow` to `true`, set `current_task` to `"write_reference_skill"`

### Verification

```yaml
chapter: 2.3-skill-creator-workflow
type: automated
verification:
  checks:
    - directory_exists: ".claude/skills"
      task_key: create_skills_directory
    - file_pattern: ".claude/skills/*/SKILL.md"
      min_count: 1
      task_key: understand_codify_workflow
```

### Checklist

- [ ] Understand the "winning strategy" (do by hand → codify)
- [ ] Installed skill-creator plugin via `/plugins` → Discover
- [ ] Restarted Claude and verified skill-creator is available
- [ ] Completed a micro-task interactively
- [ ] Used skill-creator to codify the task into a SKILL.md
- [ ] `.claude/skills/` directory exists with at least one skill

---

## Chapter 4: Creating a Reference Skill

**Chapter ID**: `2.4-reference-skill`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 2.4](./KNOWLEDGE.md#chapter-24-creating-a-reference-skill) for good vs bad reference skill comparisons, when to use reference skills vs CLAUDE.md, and the `user-invocable: false` pattern.

### Content

#### What is a Reference Skill?

Reference skills document **standards and conventions**. They don't describe procedures — they describe rules Claude should follow. When Claude detects a relevant task, it loads the reference skill's content as background knowledge.

**Key characteristics:**
- Provides context, not steps
- Often set `user-invocable: false` (Claude auto-applies, no `/` command needed)
- Content runs inline (not in a subagent)
- Good for: coding standards, naming conventions, API design rules, testing patterns

#### The Codify Workflow for Reference Skills

The "winning strategy" works especially well for reference skills:

1. **Have a conversation about your standards** — Discuss your team's coding conventions, naming patterns, etc. with Claude interactively
2. **Iterate until you're satisfied** — "Actually, we also use X convention" / "No, we prefer Y over Z"
3. **Codify**: "Use skill-creator to turn what we agreed on into a reference skill"

This is better than writing conventions from scratch because:
- The conversation surfaces edge cases you'd forget
- Claude asks clarifying questions during the discussion
- The resulting skill reflects what you *actually* agreed on, not what you thought you'd want

#### Role-Specific Reference Skills

| Role | Reference Skill Ideas |
|------|----------------------|
| Frontend | Component patterns, accessibility standards, styling conventions |
| Backend | API design guidelines, error handling patterns, database conventions |
| QA | Test naming conventions, assertion patterns, fixture standards |
| DevOps | Infrastructure naming, security policies, documentation requirements |
| Data | Schema conventions, data quality rules, pipeline standards |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand reference skills? They document standards and conventions (not procedures), often use `user-invocable: false` for auto-detection, and run inline in Claude's context."
- **Options**: "Yes, let's create one" / "What's the difference from putting conventions in CLAUDE.md?" / "I need an example"
- On "difference from CLAUDE.md": explain that CLAUDE.md conventions are always loaded and count against context every session; reference skills only load when Claude detects relevance, making them more context-efficient for domain-specific standards
- On "need an example": show a brief coding-standards reference skill example, then re-ask

### Instructor: Action

#### Discover conventions from session history

Before asking the student to discuss conventions, analyze their recent sessions to find standards and conventions they already apply.

**Use cclogviewer MCP tools** (read `student.mcp_project_name` from progress.json for the `project` parameter):

```
# Search for convention/standard-related patterns
mcp__cclogviewer__search_logs(project=<project_name>, query="convention|standard|naming|style|pattern|format")

# Get tool usage to see what file types and directories are commonly touched
mcp__cclogviewer__get_tool_usage_stats(project=<project_name>, days=30)

# Get recent sessions for context
mcp__cclogviewer__list_sessions(project=<project_name>, days=30, limit=10)
```

**Analyze the results** for:
- Coding style corrections or naming pattern enforcement in past sessions
- Recurring file structures or directory conventions
- Patterns the student applied consistently (e.g., always adding tests, always using specific naming)
- Conventions discussed or enforced in CLAUDE.md or code reviews

**Present 3-5 discovered convention areas** to the student via AskUserQuestion:

"Based on your recent Claude Code sessions, here are convention areas I found that would make great reference skills:

1. **[Convention Area]** — [Description]. I noticed [evidence from sessions]. [Why it would make a good reference skill].
2. **[Convention Area]** — [Description]. I noticed [evidence]. [Why it would be valuable].
3. **[Convention Area]** — [Description]. I noticed [evidence]. [Why this matters].

Which convention area would you like to codify into a reference skill?"

- **Options**: The discovered areas + "I have my own idea"
- If the student picks their own, proceed with that

**Fallback** — if cclogviewer MCP is unavailable or no meaningful conventions are found, ask the student directly about their team's standards (naming conventions, code style, project-specific patterns).

#### Create the reference skill

Tell the student:
"Now let's create a reference skill for your project using the codify workflow:

**Step 1**: Let's discuss your [chosen convention area]. Tell me about:
- What rules or patterns you follow
- Any exceptions or edge cases
- How you want Claude to apply these conventions

Just describe them naturally — we'll iterate together.

**Step 2**: Once we've agreed on the standards, I'll use skill-creator to codify them into a proper reference skill.

Start by telling me about this convention in detail."

**Guide the student through a discussion of their standards. Ask clarifying questions. Iterate.**

After the discussion, use skill-creator to create the reference skill:
"Use the skill-creator skill to create a reference skill called [appropriate-name] based on the standards we just discussed."

This should produce `.claude/skills/[name]/SKILL.md` with reference content.

Tell the student: "Review the generated skill — does it capture your standards accurately? Make any edits you want, then use the {cc-course:continue} Skill tool."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks:

1. **file_pattern**: Use Glob for `.claude/skills/*/SKILL.md` — should have at least 2 files now (practice + reference)
2. **content_check**: Use Read to find a skill file containing reference-type content — look for keywords: `Standards`, `Convention`, `Guidelines`, `Rules`, `Naming`
3. **frontmatter_check**: Verify the skill has `name:` and `description:` in frontmatter

**On failure**: Tell the student what's missing. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `write_reference_skill` to `true`, set `current_task` to `"write_action_skill"`

### Verification

```yaml
chapter: 2.4-reference-skill
type: automated
verification:
  checks:
    - file_pattern: ".claude/skills/*/SKILL.md"
      contains: ["Standards", "Convention", "Guidelines", "Rules", "Naming"]
      task_key: write_reference_skill
```

### Checklist

- [ ] Discussed coding standards/conventions with Claude interactively
- [ ] Used skill-creator to codify the discussion into a reference skill
- [ ] Skill has proper frontmatter (name, description)
- [ ] Skill documents clear standards/conventions
- [ ] Skill is specific to your project (not generic)

---

## Chapter 5: Creating an Action Skill

**Chapter ID**: `2.5-action-skill`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 2.5](./KNOWLEDGE.md#chapter-25-creating-an-action-skill) for `disable-model-invocation`, `$ARGUMENTS` details, `context: fork`, conditional branching, and skill composition.

### Content

#### What is an Action Skill?

Action skills describe **step-by-step procedures**. They teach Claude how to perform a specific task the way your team does it.

**Key characteristics:**
- Provides steps, not just context
- Often set `disable-model-invocation: true` (user controls when to invoke via `/`)
- Can use `$ARGUMENTS` for parameterization
- Can use `context: fork` for isolated execution
- Good for: scaffolding, deployment, code generation, onboarding tasks

#### Key Frontmatter for Action Skills

```yaml
---
name: create-component
description: Create a new component following team patterns
argument-hint: <component-name>
disable-model-invocation: true
---
```

- `disable-model-invocation: true` — Prevents Claude from auto-triggering the procedure. The student must type `/create-component` explicitly. This is important for procedures with side effects.
- `argument-hint: <component-name>` — Shows the user what arguments to provide.

#### The Codify Workflow for Action Skills

1. **Do the task by hand** — Ask Claude to help you perform the actual task (e.g., "Create a new component called UserProfile")
2. **Review what happened** — Note the files created, patterns followed, conventions applied
3. **Codify**: "Use skill-creator to codify what we just did into an action skill, so I can repeat this for any component name"

The key difference from reference skills: you're documenting a *procedure* (steps Claude took), not *standards* (rules Claude should follow).

#### Role-Specific Action Skills

| Role | Action Skill Ideas |
|------|-------------------|
| Frontend | Create page, Add route, Create form, Add animation |
| Backend | Create endpoint, Add migration, Create service, Add middleware |
| QA | Create test suite, Add E2E scenario, Create fixture, Add coverage |
| DevOps | Add service, Create Terraform module, Add monitoring, Create runbook |
| Data | Create pipeline, Add transformation, Create model, Add validation |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand action skills? They document procedures (not standards), often use `disable-model-invocation: true` so the user controls when to run them, and can use `$ARGUMENTS` for parameterization."
- **Options**: "Yes, let's create one" / "What's `disable-model-invocation` exactly?" / "When would I use `$ARGUMENTS`?"
- On "`disable-model-invocation`": explain that without it, Claude might auto-trigger the procedure whenever it thinks it's relevant (e.g., creating components unprompted). With it set to `true`, the user must explicitly type `/create-component` — giving them control over when procedures run.
- On "`$ARGUMENTS`": show that `/create-component UserProfile` passes "UserProfile" as `$ARGUMENTS`, so the skill can reference `$ARGUMENTS` or `$0` to use the component name throughout the instructions.

### Instructor: Action

#### Discover procedural patterns from session history

Before asking the student to pick a task, analyze their recent sessions to find multi-step procedures they repeat.

**Use cclogviewer MCP tools** (read `student.mcp_project_name` from progress.json for the `project` parameter):

```
# Search for procedural/creation patterns
mcp__cclogviewer__search_logs(project=<project_name>, query="create|scaffold|generate|deploy|migrate|setup")

# Get tool usage to find multi-step workflows
mcp__cclogviewer__get_tool_usage_stats(project=<project_name>, days=30)

# Get timelines for active sessions to spot repeated sequences
mcp__cclogviewer__list_sessions(project=<project_name>, days=30, limit=10)
# Then for the most active sessions:
mcp__cclogviewer__get_session_timeline(session_id=<id>, project=<project_name>)
```

**Analyze the results** for:
- Multi-step workflows that appear across sessions (e.g., create file → add boilerplate → register → add test)
- Tool chains that repeat (e.g., Write → Edit → Bash sequences)
- Sessions where multiple files were created/modified in a consistent sequence
- Tasks involving scaffolding, configuration, or setup steps

**Present 3-5 discovered procedures** to the student via AskUserQuestion:

"Based on your recent Claude Code sessions, here are multi-step workflows I found that would make great action skills:

1. **[Procedure Name]** — [Description]. Found in [N] sessions. [Why automating this as a skill saves time].
2. **[Procedure Name]** — [Description]. Found in [N] sessions. [Why this is a good candidate].
3. **[Procedure Name]** — [Description]. Found in [N] sessions. [What makes this repeatable].

Which procedure would you like to codify into an action skill?"

- **Options**: The discovered procedures + "I have my own idea"
- If the student picks their own, proceed with that

**Fallback** — if cclogviewer MCP is unavailable or no meaningful procedures are found, fall back to role-based suggestions:

| Role | Suggested Task |
|------|---------------|
| Frontend | Create a new component with styles and tests |
| Backend | Add a new API endpoint with validation |
| QA | Set up a new test suite for a module |
| DevOps | Add a new service configuration |
| Data | Create a new data pipeline stage |

#### Create the action skill

Tell the student:
"Now let's create an action skill using the codify workflow:

**Step 1**: Let's do the task — I'll help you perform [chosen procedure] right now, for real, in your project.

**Step 2**: After we finish, I'll codify it into a reusable action skill.

Let's get started — describe what you need and I'll help."

**Guide the student through their chosen task interactively. Do the actual work.**

After the task is done:
"Great — now let's turn that into a reusable action skill. Use skill-creator to codify what we just did."

Tell the student: "Review the generated action skill. Check that:
- It has `disable-model-invocation: true` (if it should be user-controlled)
- The steps match what we actually did
- It uses `$ARGUMENTS` where appropriate for parameterization

Make any edits, then use the {cc-course:continue} Skill tool."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks:

1. **file_pattern**: Use Glob for `.claude/skills/*/SKILL.md` — look for a skill with action-type content
2. **content_check**: Use Read to find a skill containing step-based keywords: `Steps`, `Step 1`, `Step 2`, `Procedure`, `Process`
3. **frontmatter_check**: Verify the skill has `name:` and `description:` in frontmatter

**On failure**: Tell the student what's missing. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `write_action_skill` to `true`, set `current_task` to `"test_skills"`

### Verification

```yaml
chapter: 2.5-action-skill
type: automated
verification:
  checks:
    - file_pattern: ".claude/skills/*/SKILL.md"
      contains: ["Steps", "Step 1", "Step 2", "Procedure"]
      task_key: write_action_skill
```

### Checklist

- [ ] Picked a multi-step task relevant to your project
- [ ] Completed the task interactively with Claude
- [ ] Used skill-creator to codify it into an action skill
- [ ] Skill has `disable-model-invocation: true` (if appropriate)
- [ ] Skill uses `$ARGUMENTS` for parameterization (if applicable)
- [ ] Skill has clear step-by-step instructions

---

## Chapter 6: Testing & Iterating

**Chapter ID**: `2.6-testing-skills`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 2.6](./KNOWLEDGE.md#chapter-26-testing--iterating) for the four-point evaluation rubric, troubleshooting guide, and the iteration loop.

### Content

#### The Fresh Session Requirement

> ⚠️ **Critical**: Skills are loaded at session start. After creating or modifying a skill, you **must start a new Claude session** to test it. Changes to SKILL.md files are NOT picked up in the current session.

#### How to Test Skills

1. **Start a fresh Claude session**:
   ```bash
   exit    # Leave current session
   claude  # Start fresh
   ```

2. **Verify skill loading** with `/context`:
   - Your skill descriptions should appear in the loaded context
   - If a skill doesn't appear, check the file location and frontmatter

3. **Request a task that should trigger your skill**:
   - For reference skills: ask about conventions → Claude should apply your standards
   - For action skills: invoke with `/skill-name` → Claude should follow your steps

4. **Evaluate using the four-point rubric**:

| Check | Pass | Fail |
|-------|------|------|
| **Trigger accuracy** | Skill activates when expected | Doesn't activate, or activates for wrong tasks |
| **Instruction adherence** | Follows steps in order | Steps skipped or reordered |
| **Output quality** | Matches your conventions | Generic code style, wrong paths |
| **Edge cases** | Handles variations gracefully | Breaks with different inputs |

#### Troubleshooting

| Problem | Diagnosis | Fix |
|---------|-----------|-----|
| Skill doesn't trigger | Check `/context` — is description loaded? | Improve `description` keywords; verify file location |
| Skill triggers too often | Description too broad | Narrow description; add `disable-model-invocation: true` |
| Skill budget exceeded | Too many skill descriptions | Total descriptions exceed ~2% of context; remove unused skills |
| Wrong content applied | Multiple skills with similar descriptions | Make descriptions more distinct |

#### Iterating on Skills

The iteration loop:
1. **Test** in a fresh session
2. **Identify** what didn't work (use the rubric)
3. **Edit** the SKILL.md (description, instructions, or examples)
4. **New session** to pick up changes
5. **Retest** — repeat until satisfied

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand the testing workflow? The critical points are: fresh session required, use `/context` to verify loading, evaluate with the four-point rubric, and iterate in a test-edit-retest loop."
- **Options**: "Yes, let's test my skills" / "Why do I need a fresh session?" / "What's the `/context` command?"
- On "why fresh session": skills are discovered at session start. If you edit a SKILL.md mid-session, Claude is still using the old version. You must restart to pick up changes.
- On "`/context`": it shows everything loaded in Claude's context — CLAUDE.md, skill descriptions, conversation history. Use it to confirm your skills are visible.

### Instructor: Action

Tell the student:
"Time to test your skills in a real session. Here's the plan:

1. **Exit this session** (type `exit`)
2. **Start a fresh Claude session** (`claude`)
3. **Test your reference skill**: Ask Claude about your coding conventions — does it apply your standards?
4. **Test your action skill**: Invoke it with `/skill-name` — does it follow your steps?
5. **Note any issues** — we'll iterate after testing
6. **Return to the course**: Run `/cc-course:continue`

> **Before you exit**: I'll save your progress now so the course resumes cleanly.

Use the {cc-course:continue} Skill tool when you've tested both skills and are ready to discuss the results."

> **IMPORTANT**: Before the student exits, save progress to progress.json:
> - `current_module`: `"2-skills"`
> - `current_task`: `"test_skills"`

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

After the student returns:

Ask using AskUserQuestion:
- **Question**: "How did testing go? Did your skills work as expected?"
- **Options**: "Both worked great" / "Reference skill needs work" / "Action skill needs work" / "Both need work"

For any skills that need work:
1. Ask what specific issues they encountered
2. Guide them to edit the SKILL.md based on the troubleshooting table
3. Have them test again in a fresh session
4. Repeat until satisfied

**On success** (student confirms skills work): Update progress.json: set task `test_skills` to `true`, set `current_task` to `"commit_skills"`

### Verification

```yaml
chapter: 2.6-testing-skills
type: manual
verification:
  questions:
    - "Test your reference skill by asking Claude about conventions"
    - "Test your action skill by invoking it with /skill-name"
    - "Verify Claude follows your skill's instructions"
  task_key: test_skills
```

### Checklist

- [ ] Tested reference skill in a fresh session
- [ ] Tested action skill in a fresh session
- [ ] Used `/context` to verify skill loading
- [ ] Evaluated using the four-point rubric
- [ ] Iterated on any skills that needed improvement
- [ ] Both skills work as expected

---

## Chapter 7: Advanced Patterns & Maintenance

**Chapter ID**: `2.7-advanced-patterns`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 2.7](./KNOWLEDGE.md#chapter-27-advanced-patterns--maintenance) for subagent skills, dynamic context injection, supporting files pattern, `allowed-tools` restrictions, skill lifecycle, enterprise deployment, and visual output generation.

### Content

#### Subagent Skills

Skills can run in isolated subagents using `context: fork`:

```yaml
---
name: codebase-analysis
description: Analyze codebase structure and patterns
context: fork
agent: Explore
---
```

This runs the skill in a separate context, protecting your main conversation from large outputs. Available agent types:
- `Explore` — Fast codebase search and analysis
- `Plan` — Architecture and design decisions
- `general-purpose` — Complex multi-step tasks

#### Dynamic Context Injection

Include real-time data in your skills:

```markdown
---
name: pr-review
description: Review current changes against team standards
---

## Current State

Branch: !`git branch --show-current`
Changed files:
!`git diff --name-only`

## Review Checklist
[...]
```

The shell commands execute when the skill loads, injecting live data into the instructions.

#### Supporting Files Pattern

For complex skills, split content across files:

```
.claude/skills/deploy-release/
├── SKILL.md              # Main instructions (< 500 lines)
├── checklist.md          # Pre-deployment checklist
├── rollback-procedures.md # What to do if deployment fails
└── environments.md       # Environment-specific configurations
```

Reference supporting files from SKILL.md — they're loaded only when referenced, not upfront.

#### `allowed-tools` Restrictions

Limit what a skill can do:

```yaml
---
name: code-audit
description: Read-only code analysis and suggestions
allowed-tools:
  - Read
  - Grep
  - Glob
---
```

This prevents the skill from writing files or running commands — useful for analysis-only skills.

#### Skill Maintenance

| Signal | Action |
|--------|--------|
| Skill hasn't triggered in weeks | Consider removing — unused skills waste description budget |
| Project conventions changed | Update the skill to match new patterns |
| Skill triggers for wrong tasks | Narrow the description keywords |
| Skill content is > 500 lines | Split into SKILL.md + supporting files |
| Team member says skill is wrong | Review and iterate — skills should reflect team consensus |

#### Team Sharing

- **Project skills** (`.claude/skills/`) — Committed to git, shared with the whole team
- **Personal skills** (`~/.claude/skills/`) — Only on your machine, not shared
- **Plugin distribution** — Package skills as a Claude Code plugin for wider sharing

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "These are advanced patterns you can use as you grow. Do you have questions about any of them? (subagent skills, dynamic context, supporting files, allowed-tools, team sharing)"
- **Options**: "No questions — let's move on to committing" / "Tell me more about [specific pattern]" / "I want to try one of these"
- On specific pattern: elaborate on the requested pattern with a concrete example
- On "want to try": guide them through implementing it, but this is optional — don't require it for module completion

### Checklist

- [ ] Understand subagent skills (`context: fork` + `agent`)
- [ ] Know about dynamic context injection (`` !`command` ``)
- [ ] Understand the supporting files pattern for large skills
- [ ] Know about `allowed-tools` for restricting skill capabilities
- [ ] Understand skill maintenance signals
- [ ] Know the difference between project and personal skills

---

## Chapter 8: Commit Your Skills

**Chapter ID**: `2.8-commit`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 2.8](./KNOWLEDGE.md#chapter-28-commit-your-skills) for what to commit decisions, `.gitignore` recommendations, practice skill cleanup, and plugin distribution.

### Content

#### Before Committing

Review your `.claude/skills/` directory:

```
.claude/skills/
├── [practice-skill]/      # From Chapter 3 — keep or delete?
│   └── SKILL.md
├── [reference-skill]/     # From Chapter 4 — keep
│   └── SKILL.md
└── [action-skill]/        # From Chapter 5 — keep
    └── SKILL.md
```

**Decision**: The practice skill from Chapter 3 was for learning. If it's useful, keep it. If not, delete it before committing — no need to clutter your repository with practice exercises.

#### What to Commit

```bash
# Stage your skills
git add .claude/skills/

# Commit with descriptive message
git commit -m "Add Claude Code skills

- Add [reference-skill] for coding standards/conventions
- Add [action-skill] for [task description]"
```

#### What NOT to Commit

- Personal skills in `~/.claude/skills/` — these are local to your machine
- Skills with hardcoded personal paths or tokens
- Practice/draft skills you don't intend to use

### Instructor: Action

Tell the student:
"Let's commit your skills to the repository.

1. **Review** your `.claude/skills/` directory — delete the practice skill from Chapter 3 if you don't want to keep it
2. **Stage** your skills:
   ```bash
   git add .claude/skills/
   ```
3. **Commit** with a descriptive message:
   ```bash
   git commit -m \"Add Claude Code skills

   - Add [your-reference-skill] reference skill
   - Add [your-action-skill] action skill\"
   ```

Run these commands now and use the {cc-course:continue} Skill tool when done."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks:

1. Use Bash (read-only) to run `git log --oneline -5` in the student's repository
2. Check that the latest commit includes `.claude/skills`
3. Alternatively, run `git show --name-only HEAD` to verify committed files

**On failure**: Tell the student what's not committed yet. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json: set task `commit_skills` to `true`, set `current_task` to `null`

### Verification

```yaml
chapter: 2.8-commit
type: automated
verification:
  checks:
    - git_committed: ".claude/skills"
      task_key: commit_skills
```

### Checklist

- [ ] Reviewed `.claude/skills/` directory
- [ ] Removed practice skill if not needed
- [ ] All useful skills committed to git
- [ ] Commit message describes what skills do

---

## Module Completion

### Instructor: Final Validation

After Chapter 8 is complete, tell the student:

"You've finished all the chapters! Let's validate your work and package it for submission.

**Step 1 — Validate**: Run the {cc-course:validate} Skill tool now. This checks that all required files exist, your skills meet quality standards, and your work is committed."

**Wait for the student to run validate.** If validation fails, help them fix issues and re-run.

**After validation passes**, tell the student:

"All checks passed!

**Step 2 — Submit**: Run the {cc-course:submit} Skill tool to package your work into a submission archive. This bundles your skills, progress data, and session logs for instructor review."

**Wait for the student to run submit.**

After submission completes or if the student declines, proceed to the Seminar Summary below. Note: validation is required to unlock the next module. Submission is optional but recommended.

---

## Seminar Summary

### What You Learned

1. **Skills Concept**: Reusable instructions vs project memory, two content types
2. **Skill Structure**: SKILL.md format, all 10 frontmatter fields, directory layout
3. **The Codify Workflow**: Do by hand first → stay in session → use skill-creator
4. **Reference Skills**: Documenting standards and conventions
5. **Action Skills**: Step-by-step procedures with parameterization
6. **Testing**: Fresh sessions, `/context` verification, four-point rubric
7. **Advanced Patterns**: Subagents, dynamic context, supporting files, team sharing

### Files Created

| File | Purpose |
|------|---------|
| `.claude/skills/[reference-skill]/SKILL.md` | Reference skill (coding standards) |
| `.claude/skills/[action-skill]/SKILL.md` | Action skill (procedure) |

### Next Seminar Preview

In **Seminar 3: Extensions**, you'll learn to create hooks for automation, configure MCP servers for external tools, and build more sophisticated integrations.

---

## Session Export (Post-Completion)

After completing this seminar, you can export your session logs for review or portfolio purposes.

### Export Workflow

When module validation passes, the course engine offers to:

1. **Export session logs** to `exports/seminar2-session-{uuid}.json`
2. **Export summary stats** to `exports/seminar2-summary-{uuid}.json`
3. **Generate HTML report** (optional) for visual review

### Export Commands (via MCP cclogviewer)

The course engine uses these MCP calls:

```
mcp__cclogviewer__get_session_logs(
  session_id="<your-session-id>",
  output_path="./exports/seminar2-session.json"
)

mcp__cclogviewer__get_session_summary(
  session_id="<your-session-id>",
  output_path="./exports/seminar2-summary.json"
)

mcp__cclogviewer__generate_html(
  session_id="<your-session-id>",
  output_path="./exports/seminar2-report.html",
  open_browser=true
)
```

### What's Captured

| Data | Description |
|------|-------------|
| Session ID | Unique identifier for your learning session |
| Duration | Time spent on the module |
| Tool usage | Read, Write, Bash, Glob calls |
| Tasks completed | Which verification steps passed |
| Errors | Any issues encountered |

---

## Validation Summary

```yaml
seminar: 2-skills
tasks:
  create_skills_directory:
    chapter: 2.3
    type: automated
    check: "directory_exists:.claude/skills"

  understand_codify_workflow:
    chapter: 2.3
    type: automated
    check: "file_pattern:.claude/skills/*/SKILL.md"
    note: "Student installs skill-creator, restarts, then creates a practice skill using it"

  write_reference_skill:
    chapter: 2.4
    type: automated
    check: "file_contains:Standards|Convention|Guidelines|Rules|Naming"

  write_action_skill:
    chapter: 2.5
    type: automated
    check: "file_contains:Steps|Step 1|Step 2|Procedure"

  test_skills:
    chapter: 2.6
    type: manual
    check: "student_confirms"

  commit_skills:
    chapter: 2.8
    type: automated
    check: "git_log:.claude/skills"
```
