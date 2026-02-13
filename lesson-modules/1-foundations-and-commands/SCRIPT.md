# Seminar 1: Foundations & Commands

**Duration**: 120 minutes (90 min guided + 30 min hands-on)

**Seminar ID**: `1-foundations-and-commands`

---

## Before You Begin

**Complete the installation before starting this interactive seminar.**

📄 **[Download Installation Guide (PDF)](./installation-guide.pdf)** — Follow these steps offline:
1. Install Node.js 18+
2. Install Claude Code via npm
3. Authenticate with Anthropic
4. Verify with `/doctor`

Once Claude Code is installed and working, return here and run:
```bash
claude
/cc-course:start 1
```

---

## Learning Objectives

By the end of this seminar, participants will:
- Navigate basic CLI interactions confidently
- Create a CLAUDE.md file that captures their project's context
- Use slash commands fluently for common operations
- Create a custom slash command for their workflow

---

## Chapter Phase Map

Quick reference showing which interactive phases each chapter has:

| Chapter | PRESENT | CHECKPOINT | ACTION | VERIFY |
|---------|---------|------------|--------|--------|
| 1 — What is Claude Code? | yes | yes | — | — |
| 2 — Installation | yes | yes | — | — |
| 3 — CLI Basics | yes | yes | yes | yes |
| 4 — CLAUDE.md | yes | yes | yes | yes |
| 5 — Testing Setup | yes | yes | yes | yes |
| 6 — Slash Commands | yes | yes | yes | yes |
| 6b — Session Management | yes | — | yes | yes |
| 7 — Plan Mode | yes | yes | yes | yes |
| 8 — Custom Commands | yes | yes | yes | yes |
| 9 — Commit | yes | — | yes | yes |

---

## Chapter 1: What is Claude Code?

**Chapter ID**: `1.1-what-is-claude-code`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 1.1](./KNOWLEDGE.md#chapter-11-what-is-claude-code) for detailed explanations of agentic execution, terminal-native advantages, and external resources.

### Content

Claude Code is an agentic coding assistant that runs in your terminal. Unlike chat-based AI tools:

- **Terminal-native**: Works where you already work
- **Full codebase awareness**: Reads and understands your entire project
- **Agentic execution**: Can read files, write code, run commands
- **Memory persistence**: Remembers context across sessions via CLAUDE.md

**Mental model**: Think of Claude Code as a pair programmer who lives in your terminal and never forgets what you told them about your project.

### Key Differences from Other Tools

| Feature | Claude Code | Copilot/Cursor |
|---------|-------------|----------------|
| Interface | Terminal | IDE plugin |
| Scope | Full codebase | Current file/context |
| Execution | Can run commands | Suggestions only |
| Memory | CLAUDE.md persistence | Session only |

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand the key differences between Claude Code and other AI coding tools (like Copilot/Cursor)? The main points are: terminal-native, full codebase awareness, agentic execution, and memory persistence."
- **Options**: "Yes, I understand — let's continue" / "I have a question" / "I need more explanation"
- On questions: answer them, then re-ask
- On "need more explanation": elaborate on the agentic execution model and CLAUDE.md persistence, then re-ask

### Checklist

- [ ] Understand what "agentic" means in the context of coding assistants
- [ ] Know the key differences between Claude Code and Copilot/Cursor
- [ ] Understand the "pair programmer in terminal" mental model

---

## Chapter 2: Installation & Authentication

**Chapter ID**: `1.2-installation`

> ⚠️ **Prerequisite**: You should have already completed the [Installation Guide (PDF)](./installation-guide.pdf) before starting this interactive course.

If you haven't installed Claude Code yet, please complete the PDF guide first, then return here.

### Quick Verification

Confirm your installation is working:

```bash
claude --version    # Should show version number
claude /doctor      # Should show all checks passing
```

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Since you're already in a Claude Code session right now, your installation is working. Can you confirm that `/doctor` showed all checks passing when you set up?"
- **Options**: "Yes, all good" / "I had some issues" / "I haven't checked"
- On issues: help troubleshoot before proceeding
- On "haven't checked": note it but proceed since they're clearly running Claude Code

### Checklist

- [ ] Claude Code installed globally via npm
- [ ] `claude --version` returns a version number
- [ ] Successfully authenticated (first session works)
- [ ] `/doctor` shows all checks passing

---

## Chapter 3: Basic CLI Interactions

**Chapter ID**: `1.3-cli-basics`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 1.3](./KNOWLEDGE.md#chapter-13-cli-basics) for detailed execution modes, tool visibility, and CLI cheat sheets.

### Content

#### Starting a Session

| Command | Description |
|---------|-------------|
| `claude` | Interactive mode (recommended for learning) |
| `claude "prompt"` | One-shot mode (run and exit) |
| `claude -p "prompt"` | Print mode (output only, no interactive) |
| `claude -c` | Continue last conversation |

#### Inside a Session

- Type naturally - Claude understands context
- Use `/` to access slash commands
- Press `Ctrl+C` to cancel current operation
- Type `exit` or press `Ctrl+D` to end session

#### Reading Claude's Output

Claude shows what tools it's using:
- `Reading file...` - Examining your code
- `Writing file...` - Making changes (asks permission)
- `Running command...` - Executing shell commands (asks permission)

### Practice Exercise

1. Start interactive mode: `claude`
2. Ask: "What files are in the current directory?"
3. Ask: "What is the main purpose of this project?"
4. Exit the session

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand the three ways to run Claude Code? (`claude` for interactive, `claude \"prompt\"` for one-shot, `claude -p \"prompt\"` for print mode)"
- **Options**: "Yes, clear" / "Can you explain the difference again?"
- On "explain again": clarify that interactive is for back-and-forth, one-shot runs and exits, print mode outputs text only (useful for scripts/piping)

### Security: Creating .claudeignore

#### Why .claudeignore Matters

Claude Code can read any file in your project. A `.claudeignore` file tells Claude which files to **never read or reference**, protecting sensitive data like API keys, certificates, and credentials.

It works like `.gitignore` — pattern-based file exclusion — but specifically for Claude Code's file access.

#### Recommended .claudeignore Contents

```
# Secrets and credentials
.env
.env.*
*.pem
*.key
credentials.json
service-account*.json
**/secrets/**

# Package manager auth
.npmrc
.pypirc
```

#### .claudeignore vs .gitignore

| Feature | .claudeignore | .gitignore |
|---------|--------------|------------|
| **Scope** | Claude Code file access | Git tracking |
| **Purpose** | Prevent AI from reading sensitive files | Prevent committing files |
| **Location** | Project root | Project root |
| **Overlap** | Should include secrets even if in .gitignore | Doesn't affect Claude |

**Key insight**: Even if a file is in `.gitignore`, Claude can still read it unless it's also in `.claudeignore`. Always add secrets to both.

### Verification

```yaml
chapter: 1.3-claudeignore
type: automated
verification:
  checks:
    - file_exists: ".claudeignore"
      task_key: create_claudeignore
```

### Instructor: Action

Tell the student:
"Before we set up your project memory, let's secure your project first. Create a `.claudeignore` file in your repository root to protect sensitive files from being read by Claude Code.

Create the file at `.claudeignore` (in your project root) with at least these patterns:
```
.env
.env.*
*.pem
*.key
credentials.json
service-account*.json
**/secrets/**
.npmrc
.pypirc
```

You can add more patterns specific to your project (e.g., `*.pfx`, `docker-compose.override.yml`, local config files).

Create the file now and use the {cc-course:continue} Skill tool when done."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run this check in the student's repository:

1. **file_exists**: Use Glob to check `.claudeignore` exists in the repo root
2. **content_check**: Use Read to verify it contains at least `.env` and `*.key` patterns

**On failure**: Tell the student what's missing. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json task `create_claudeignore`.

### Checklist

- [ ] Can start an interactive Claude session
- [ ] Understand difference between `claude`, `claude "prompt"`, and `claude -p`
- [ ] Know how to exit a session (`exit` or Ctrl+D)
- [ ] Understand what Claude shows when using tools
- [ ] Created `.claudeignore` to protect sensitive files

---

## Chapter 4: CLAUDE.md - Your Project's Memory

**Chapter ID**: `1.4-claude-md`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 1.4](./KNOWLEDGE.md#chapter-14-claudemd--project-memory) for file referencing with `@path`, size optimization strategies, progressive disclosure patterns, and real-world CLAUDE.md examples.

### Content

#### Why CLAUDE.md Matters

Without CLAUDE.md:
```
You: "Where should I add a new component?"
Claude: "I don't have context about your project structure..."
```

With CLAUDE.md:
```
You: "Where should I add a new component?"
Claude: "Based on your project structure, new components go in src/components/..."
```

#### The `/init` Command

Run inside your project:
```bash
claude
/init
```

This auto-generates a CLAUDE.md based on your codebase.

#### CLAUDE.md Structure

```markdown
# Project: [Name]

## Overview
[2-3 sentences about what this project does]

## Tech Stack
- Language: [e.g., TypeScript, Python]
- Framework: [e.g., React, FastAPI]
- Testing: [e.g., Jest, pytest]
- Build: [e.g., Vite, Poetry]

## Architecture
[Brief description of codebase organization]

## Conventions
- [Naming conventions]
- [File organization rules]
- [Code style preferences]

## Common Commands
- Run tests: `[command]`
- Start dev: `[command]`
- Build: `[command]`

## Important Context
- [Domain-specific knowledge]
- [Key business logic locations]
- [Sensitive areas]
```

#### Role-Specific Additions

| Role | Add to CLAUDE.md |
|------|------------------|
| Frontend | Component patterns, styling approach, browser support |
| Backend | API patterns, database schemas, auth flow |
| QA | Test organization, fixtures, coverage requirements |
| DevOps | Infrastructure layout, environments, deployment |
| Data | Pipeline architecture, data models, sources |

### Verification

```yaml
chapter: 1.4-claude-md
type: automated
verification:
  checks:
    - file_exists: "CLAUDE.md"
      task_key: create_claude_md
    - file_contains: ["## Overview", "# Project"]
      task_key: add_project_overview
    - file_contains: ["Tech Stack", "Stack", "Technologies"]
      task_key: add_tech_stack
    - file_contains: ["Convention", "Standards", "Style"]
      task_key: add_conventions
    - file_quality:
        path: "CLAUDE.md"
        max_lines: 500
        warn_lines: 300
        max_chars: 40000
        required_sections:
          - "^#+ .*Overview|^# Project"
          - "^#+ .*(Tech Stack|Stack|Technologies)"
          - "^#+ .*(Convention|Standards|Code Style)"
          - "^#+ .*(Commands?)"
        suggest_references_if_lines: 200
        warn_patterns:
          - pattern: "TODO|FIXME"
            message: "Contains placeholder text - consider completing or removing"
          - pattern: "\\[.*\\]"
            message: "Contains placeholder brackets - fill in actual values"
      task_key: claude_md_quality
```

### CLAUDE.md Best Practices

Based on official Anthropic documentation:

| Guideline | Recommendation |
|-----------|----------------|
| **Length** | Keep under 500 lines (warn at 300) |
| **Size** | Max 40,000 characters |
| **Sections** | Overview, Tech Stack, Conventions, Commands |
| **References** | Use `@path/to/file` for long files to avoid bloat |
| **Placeholders** | Remove TODO/FIXME before committing |

If your CLAUDE.md exceeds 200 lines, consider:
- Moving detailed specs to separate files (reference with `@docs/api-spec.md`)
- Using `.claude/settings.json` for project-specific settings
- Creating skills in `.claude/skills/` for reusable instructions

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand why CLAUDE.md matters and what sections it should contain? (Overview, Tech Stack, Conventions, Commands)"
- **Options**: "Yes, I understand the purpose and structure" / "I have a question" / "Can you show an example?"
- On "show an example": walk through a concrete CLAUDE.md for their role/stack
- On questions: answer, then re-ask

### Instructor: Action

**DO NOT create or edit CLAUDE.md for the student** — guide them to do it themselves.

#### Step 1: Check if CLAUDE.md Already Exists

Use Glob to check if `CLAUDE.md` exists in the student's repository root.

#### If CLAUDE.md EXISTS:

1. **Read it** and evaluate against the best practices checklist (see KNOWLEDGE.md Chapter 1.4)
2. **Give specific feedback** on what's present and what's missing:
   - Does it have a project overview? Tech stack? Conventions? Commands?
   - Is it under 500 lines? Free of TODO/FIXME placeholders?
   - Does it use `@path` references for long sections?
   - Are file paths and commands accurate?
3. **Tell the student**: "You already have a CLAUDE.md — great! I've reviewed it and here's what I found: [specific feedback]. Please enhance it by [specific improvements needed]."

#### If CLAUDE.md DOES NOT EXIST:

1. **Tell the student** to run `/init` to auto-generate a CLAUDE.md
2. **After they run it**, review the generated file

#### Step 2: Enhance (both paths)

Tell the student to add or improve these sections:
- Project overview (2-3 sentences describing the project)
- Tech stack (language, framework, testing, build tools)
- Conventions (naming, file organization, code style)
- Common commands (test, build, dev server, lint)
- Remove any placeholder text (TODO, FIXME, unfilled `[brackets]`)

Say the appropriate message:
- **If exists**: "I've reviewed your CLAUDE.md and here are my suggestions: [feedback]. Enhance it with the improvements above. Use the {cc-course:continue} Skill tool when you're done."
- **If not exists**: "Run `/init` in your repository now. Review what it generates, then enhance it with your project's specifics. Use the {cc-course:continue} Skill tool when you're done."

**Wait for the student to use the {cc-course:continue} Skill tool before proceeding.**

### Instructor: Verify

Run ALL these checks in the student's repository before marking complete:

1. **file_exists**: Use Glob to check `CLAUDE.md` exists in the repo root
2. **file_contains**: Use Grep to check for Overview/Project section, Tech Stack section, and Conventions section
3. **file_quality**: Use Read to check:
   - File is under 500 lines (warn at 300)
   - No remaining `TODO`/`FIXME` placeholders
   - No unfilled `[bracket]` placeholders
   - Has at least 4 meaningful sections

**On failure**: Tell the student specifically what's missing (e.g., "Your CLAUDE.md is missing a Tech Stack section"). Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json tasks: `create_claude_md`, `add_project_overview`, `add_tech_stack`, `add_conventions`, `claude_md_quality`.

### Checklist

- [ ] Run `/init` in your repository
- [ ] Review and enhance the auto-generated CLAUDE.md
- [ ] Add project overview section
- [ ] Add tech stack section
- [ ] Add conventions section
- [ ] Add common commands section
- [ ] Check CLAUDE.md quality (line count, no placeholders)

---

## Chapter 5: Testing Your Setup

**Chapter ID**: `1.5-testing-setup`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 1.5](./KNOWLEDGE.md#chapter-15-testing-your-setup) for expected responses, debugging context loading issues, and using `/context` effectively.

### Content

#### Verification Questions

Ask Claude these questions to verify CLAUDE.md is working:

1. **"What is this project about?"**
   - Claude should describe your project accurately

2. **"What testing framework do we use?"**
   - Claude should reference your tech stack

3. **"Where would I add a new [component/endpoint/test]?"**
   - Claude should know your file structure

4. **"What are the naming conventions in this project?"**
   - Claude should reference your conventions

#### If Claude Doesn't Understand

Common fixes:
- Add more specific examples to CLAUDE.md
- Remove jargon and use concrete terms
- Include actual file paths, not just descriptions
- Add a "Key Files" section pointing to important code

### Verification

```yaml
chapter: 1.5-testing-setup
type: manual
verification:
  questions:
    - "Ask Claude about your project and verify accurate response"
    - "Confirm Claude knows your tech stack"
    - "Confirm Claude understands your file structure"
  task_key: test_claude_understanding
```

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Ready to test your CLAUDE.md by asking me questions about your project? This will show whether the file is working well."
- **Options**: "Yes, let's test it" / "I want to tweak my CLAUDE.md first"
- On "tweak first": let them make changes, wait for {cc-course:continue}

### Instructor: Action

Tell the student:
"Now ask me questions about YOUR project to verify CLAUDE.md is working. Try these:
1. 'What is this project about?'
2. 'What testing framework do we use?'
3. 'Where would I add a new [component/endpoint/test]?'
4. 'What are the naming conventions?'

Ask at least 2-3 of these. If my answers are wrong or vague, that means your CLAUDE.md needs improvement — go back and enhance it."

**Answer the student's questions based on what you can read from their CLAUDE.md.** If your answers are inaccurate, help them identify what to add to CLAUDE.md.

After a few rounds of Q&A, ask: "Are you satisfied with how well I understand your project? Use the {cc-course:continue} Skill tool when ready."

### Instructor: Verify

Use AskUserQuestion:
- **Question**: "Did Claude answer your project questions accurately based on your CLAUDE.md?"
- **Options**: "Yes, it worked well" / "I improved my CLAUDE.md and it's better now" / "Still needs work"
- On "still needs work": guide them to add more specific info, then re-verify
- On success: update progress.json task `test_claude_understanding`

### Checklist

- [ ] Asked Claude "What is this project about?" - got accurate answer
- [ ] Asked about testing framework - Claude knew it
- [ ] Asked where to add new code - Claude gave correct location
- [ ] Claude references information from CLAUDE.md

---

## Chapter 6: Essential Slash Commands

**Chapter ID**: `1.6-slash-commands`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 1.6](./KNOWLEDGE.md#chapter-16-essential-slash-commands) for `/clear` vs `/compact` detailed comparison, session management deep dive, and complete CLI flags reference.

### Content

#### Navigation & Help

| Command | Purpose |
|---------|---------|
| `/help` | Show all available commands |
| `/clear` | Reset conversation context |
| `/compact` | Compress context (when running low) |

#### Session Management

| Command | Purpose |
|---------|---------|
| `/model` | Switch models mid-session |
| `/config` | View/modify settings |

#### Development Commands

| Command | Purpose |
|---------|---------|
| `/init` | Initialize project (create CLAUDE.md) |
| `/doctor` | Diagnose installation issues |
| `/review` | Code review mode |

#### CLI Flags (Outside Session)

| Flag | Purpose |
|------|---------|
| `--print` / `-p` | Output and exit (for scripts) |
| `--continue` / `-c` | Resume last conversation |
| `--resume` / `-r` | Resume specific session |
| `--max-turns` | Limit agentic loops |
| `--model` | Specify model |

### Practice Exercise

Run these commands and observe the output:
1. `/help` - See all commands
2. `/doctor` - Check installation health
3. `/config` - View your settings

### Verification

```yaml
chapter: 1.6-slash-commands
type: manual
verification:
  questions:
    - "Run /help and identify 5 useful commands"
    - "Run /doctor and confirm no issues"
    - "Run /config to view your settings"
  task_key: explore_slash_commands
```

### Checklist

- [ ] Used `/help` to see available commands
- [ ] Used `/doctor` to verify installation
- [ ] Used `/config` to see current settings
- [ ] Know the difference between `/clear` and `/compact`

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand the main slash commands? (`/help`, `/doctor`, `/config`, `/clear`, `/compact`, `/model`)"
- **Options**: "Yes, I understand them" / "Can you explain the difference between /clear and /compact?"
- On "/clear vs /compact": explain that `/clear` resets the conversation completely while `/compact` compresses context to free up space without losing it entirely

### Instructor: Action

Tell the student:
"Now try these commands yourself in this session:
1. Run `/help` — scan through the available commands
2. Run `/doctor` — check that everything is healthy
3. Run `/config` — look at your current settings

Try them now and use the {cc-course:continue} Skill tool when you've explored them."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Try to verify using MCP session search:
1. Use `mcp__cclogviewer__search_logs` or `mcp__cclogviewer__get_session_timeline` to check if the student ran `/help`, `/doctor`, and `/config` in this session
2. **Fallback** (if MCP is unavailable or returns no results): Use AskUserQuestion to confirm: "Did you try /help, /doctor, and /config?"

On success: update progress.json task `explore_slash_commands`

---

### Session Management Commands

These commands help you manage your Claude Code sessions and context.

#### Session Information

| Command | Purpose |
|---------|---------|
| `/context` | Show files and context currently loaded |
| `/statusline` | Configure the status bar display |
| `/config` | View and modify Claude Code settings |

#### Understanding /context Output

The `/context` command shows you what's currently in Claude's "working memory." Here's what each component means:

| Component | What It Shows |
|-----------|--------------|
| **System prompt** | Base instructions Claude follows (always present) |
| **CLAUDE.md** | Your project memory file content |
| **Messages** | Conversation history (your prompts + Claude's responses) |
| **Tool results** | Output from file reads, command execution, etc. |
| **Context usage %** | How full the context window is |

#### Context Usage and Performance

Your context usage percentage directly affects Claude's performance:

| Usage | Status | Recommendation |
|-------|--------|----------------|
| 0–50% | Optimal | Full performance, plenty of room |
| 50–75% | Good | Working well, monitor if doing large tasks |
| 75–90% | Consider `/compact` | Performance may start degrading |
| 90%+ | Degraded | Use `/compact` or `/clear` immediately |

#### Autocompact

When context approaches the limit, Claude Code **automatically compresses** the conversation — this is called "autocompact." It:
- Summarizes earlier messages while preserving key information
- Keeps recent messages and tool results intact
- Preserves CLAUDE.md content and system instructions
- Happens transparently (you may notice a brief pause)

You can trigger this manually with `/compact` at any time.

#### /clear vs /compact — When to Use Each

| Scenario | Use `/compact` | Use `/clear` |
|----------|---------------|-------------|
| Running low on context | Yes — compresses but keeps essential info | Overkill — loses everything |
| Claude is confused or hallucinating | Sometimes helps | Yes — fresh start is better |
| Switching to a different task | Not ideal — old context may confuse | Yes — clean slate for new task |
| Long session, want to continue | Yes — preserves conversation summary | No — you'd lose all progress |
| Want to try a different approach | Maybe — depends on how much to keep | Yes — start fresh |

**Power workflow**: Save your plan to a file → `/clear` → load via `@plan.md` → fresh context with your plan preserved.

#### Configuring /statusline

The `/statusline` command configures what's displayed in Claude Code's status bar at the bottom of your terminal. This gives you at-a-glance session awareness.

**Recommended items to show:**
- **Context %** — know when you're running low
- **Model name** — confirm which model you're using
- **Git branch** — stay aware of your current branch
- **Project name** — useful when working across multiple projects

**How to configure:**
1. Run `/statusline` in a Claude Code session
2. Select which items to display
3. Settings persist across sessions

#### Session Continuation

| Command / Flag | Purpose |
|----------------|---------|
| `/export` | Export current conversation |
| `claude -c` | Resume last conversation (CLI flag) |
| `claude -r <id>` | Resume specific session by ID (CLI flag) |

#### Understanding Session IDs

Every Claude Code session has a unique ID. You can find it by:
- Looking at the output when starting a session
- Using `/config` to see session info
- Checking `~/.claude/projects/` directory

Session IDs allow you to:
- Resume a specific conversation days or weeks later
- Share session logs for debugging
- Export and analyze your work patterns

#### Practice Exercise

1. Run `/context` to see what files are loaded — note the usage percentage and components
2. Run `/statusline` to explore display options
3. Run `/config` to view your current settings
4. Note your current session ID for future reference
5. Exit Claude Code and resume with `claude -c`

### Verification

```yaml
chapter: 1.6-session-commands
type: manual
verification:
  questions:
    - "Run /context and describe what files are currently loaded"
    - "Exit Claude Code and resume with claude -c - did it work?"
    - "What is the difference between -c and -r flags?"
  task_key: test_session_commands
```

### Instructor: Action

Tell the student:
"Let's explore session management:

1. Run `/context` — look at the output carefully:
   - What's the context usage percentage?
   - Can you see your CLAUDE.md listed?
   - How many messages are in the conversation?
2. Run `/statusline` — configure your status bar to show context %, model name, and git branch
3. Run `/export` — export this conversation (useful for saving your learning progress)

Pay attention to the context usage % — this tells you how much room Claude has for more work.

Try them now and use the {cc-course:continue} Skill tool when done."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Try to verify using MCP session search:
1. Use `mcp__cclogviewer__search_logs` or `mcp__cclogviewer__get_session_timeline` to check if the student ran `/context` in this session
2. **Fallback**: Use AskUserQuestion to confirm: "Did you try `/context`? What was your context usage percentage?"

On success: update progress.json task `test_session_commands`

### Additional Checklist

- [ ] Used `/context` to see loaded files
- [ ] Explored `/statusline` options
- [ ] Successfully resumed a session with `-c` flag
- [ ] Understand session ID usage with `-r` flag

---

## Chapter 7: Plan Mode

**Chapter ID**: `1.7-plan-mode`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 1.7](./KNOWLEDGE.md#chapter-17-plan-mode) for plan output format, evaluating plan quality, good vs poor plan examples, and plan modification techniques.

### Content

#### What is Plan Mode?

Plan mode makes Claude explain its approach **before** executing. This is useful for:
- Complex refactoring tasks
- Tasks with multiple approaches
- When you want to review before changes happen

#### Entering Plan Mode

- **Keyboard**: Press `Shift+Tab` before sending
- **Explicit**: Add "Plan this first, don't execute" to your prompt

#### Plan Mode Workflow

1. Enter plan mode
2. Describe your task
3. Claude generates a plan (no execution)
4. You review and modify
5. Approve to execute, or refine the plan

#### When to Use Plan Mode

| Use Plan Mode | Skip Plan Mode |
|---------------|----------------|
| Refactoring across files | Simple file edits |
| Adding new features | Quick fixes |
| Architectural changes | Reading/exploring code |
| Unfamiliar codebases | Familiar, small changes |

### Practice Exercise

1. Enter plan mode (`Shift+Tab`)
2. Ask: "Plan how to add [a feature relevant to your project]"
3. Review the plan — ask Claude to modify or improve it (2-3 rounds)
4. Press `Escape` to exit plan mode **without executing**
5. Key takeaway: plan mode is for thinking — you control whether anything gets executed

### Verification

```yaml
chapter: 1.7-plan-mode
type: manual
verification:
  questions:
    - "Enter plan mode and request a plan for a feature"
    - "Review the generated plan without executing"
    - "Identify if Claude understood your codebase from the plan"
  task_key: use_plan_mode
```

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand when to use plan mode vs just asking Claude directly? (Plan mode is best for complex, multi-file changes where you want to review the approach first.)"
- **Options**: "Yes, I understand when to use it" / "Can you give examples?"
- On "give examples": walk through the table of when to use vs skip plan mode

### Instructor: Action

Tell the student:
"Let's try plan mode as a **thinking tool** — we'll generate a plan, iterate on it, and then exit **without executing**:

1. **Enter plan mode**: Press `Shift+Tab` (you'll see a plan mode indicator)
2. **Request a plan**: Ask Claude to plan a feature for your project — e.g., 'Plan how to add [something relevant to your codebase]'
3. **Iterate on the plan** (2-3 rounds): Give feedback like:
   - 'What about edge cases?'
   - 'Can you split step 3 into smaller parts?'
   - 'What if we used [alternative approach] instead?'
4. **Exit with Escape**: Press `Escape` to deactivate plan mode **WITHOUT accepting or executing the plan**

The key lesson: plan mode is for **thinking and exploring** approaches. You always control whether anything gets executed. Pressing Escape discards the plan safely.

Try it now. When you've gone through all 4 steps, use the {cc-course:continue} Skill tool."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Use AskUserQuestion:
- **Question**: "Did you complete all 4 steps? (1) Enter plan mode, (2) Generate a plan, (3) Iterate on it with feedback, (4) Exit with Escape without executing"
- **Options**: "Yes, I did all 4 steps" / "I generated a plan but didn't iterate" / "I need to try again"
- On "didn't iterate": encourage them to try again with 2-3 rounds of feedback, wait for {cc-course:continue}
- On "need to try again": wait for {cc-course:continue}, then re-verify
- On success: update progress.json task `use_plan_mode`

### Checklist

- [ ] Know how to enter plan mode (Shift+Tab)
- [ ] Generated at least one plan without executing
- [ ] Iterated on a plan (asked for modifications 2-3 times)
- [ ] Exited plan mode with Escape WITHOUT executing
- [ ] Understand when plan mode is appropriate

---

## Chapter 8: Creating Custom Commands

**Chapter ID**: `1.8-custom-commands`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 1.8](./KNOWLEDGE.md#chapter-18-custom-commands) for all frontmatter options, commands with parameters, Skills vs Commands decision tree, and testing commands.

### Content

#### What Are Custom Commands?

Custom commands are project-specific slash commands you define. They live in `.claude/commands/` and appear when you type `/`.

#### Command File Structure

Location: `.claude/commands/[command-name].md`

```markdown
---
name: command-name
description: What this command does (shown in /help)
---

# Command: [Name]

## Instructions

When this command is invoked:

1. [First step Claude should take]
2. [Second step]
3. [Third step]

## Context

[Any additional context or constraints]

## Output Format

[How Claude should present results]
```

#### Example: Create a "New Feature" Command

Create `.claude/commands/new-feature.md`:

```markdown
---
name: new-feature
description: Scaffold a new feature with tests and documentation
---

# Command: New Feature

## Instructions

When invoked with a feature name:

1. Create the main implementation file in the appropriate directory
2. Create a corresponding test file
3. Update any index/barrel files
4. Add a brief documentation entry

## Naming Convention

- Feature file: `src/features/[name].ts`
- Test file: `src/features/__tests__/[name].test.ts`

## After Creation

Show a summary of files created and next steps.
```

#### Using Your Command

```bash
claude
/new-feature user-profile
```

### Practice Exercise

1. Create the commands directory: `mkdir -p .claude/commands`
2. Create a simple command for a task you do often
3. Test it with Claude

**Command Ideas by Role**:

| Role | Command Idea |
|------|--------------|
| Frontend | `/new-component` - Create component with styles and tests |
| Backend | `/new-endpoint` - Create API endpoint with validation |
| QA | `/test-suite` - Generate test suite for a module |
| DevOps | `/new-service` - Scaffold service configuration |
| Data | `/new-pipeline` - Create data pipeline template |

### Verification

```yaml
chapter: 1.8-custom-commands
type: automated
verification:
  checks:
    - directory_exists: ".claude/commands"
      task_key: create_commands_directory
    - file_pattern: ".claude/commands/*.md"
      min_count: 1
      task_key: create_custom_command
    - file_contains_frontmatter: ["name:", "description:"]
      task_key: valid_command_format
```

### Instructor: Checkpoint

Ask the student using AskUserQuestion:
- **Question**: "Do you understand the structure of a custom command? (A markdown file in `.claude/commands/` with frontmatter containing `name` and `description`.)"
- **Options**: "Yes, I understand" / "Can you show the structure again?"
- On "show again": re-present the command file structure from the Content section

### Instructor: Action

> **NOTE**: Unlike other ACTION phases where the student must do the work manually, here the student **prompts Claude Code to create the command for them** — that's the core lesson. You (the instructor) ARE allowed to create files when the student asks you to.

Tell the student:
"Now it's time to create your own custom command — but here's the key: **you MUST use Claude Code to create it**. This is a fundamental practice: use Claude Code to build Claude Code configurations.

**Why?** Claude already knows the correct format, frontmatter, and conventions. Prompting Claude to create commands:
- Ensures proper structure (frontmatter, sections)
- Adapts to your project automatically
- Practices the prompting skill you'll use daily

**Your task:**
1. First, create the commands directory: `mkdir -p .claude/commands`
2. Then **prompt me** (Claude) to create a command for you. Here are role-specific prompt examples:

| Role | Example Prompt |
|------|---------------|
| Frontend | 'Create a `/new-component` command that scaffolds a React component with styles and tests in my project's structure' |
| Backend | 'Create a `/new-endpoint` command that generates an API endpoint with validation following my project patterns' |
| QA | 'Create a `/test-suite` command that generates a test suite for a given module' |
| DevOps | 'Create a `/new-service` command that scaffolds a service configuration' |
| Data | 'Create a `/new-pipeline` command that creates a data pipeline template' |

3. After I create it, **review the result**:
   - Does the frontmatter have `name` and `description`?
   - Do the instructions make sense for your project?
   - Would you tweak anything?
4. Test it by running your new command

Prompt me now to create your command. Use the {cc-course:continue} Skill tool when you've reviewed and tested it."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks in the student's repository:

1. **directory_exists**: Use Glob to check `.claude/commands/` directory exists
2. **file_pattern**: Use Glob for `.claude/commands/*.md` — at least 1 file must exist
3. **frontmatter_check**: Use Read to verify the command file has frontmatter with `name:` and `description:`

**On failure**: Tell the student specifically what's missing:
- No directory? → "Run `mkdir -p .claude/commands` first"
- No files? → "Create a markdown file in `.claude/commands/`"
- No frontmatter? → "Add `---` delimiters with `name:` and `description:` at the top"

Give the student a brief review of their command — what's good, what could be improved.

Wait for {cc-course:continue} after fixes, then re-verify.

**On success**: Update progress.json tasks: `create_commands_directory`, `create_custom_command`, `valid_command_format`

### Checklist

- [ ] Prompted Claude Code to create a custom command
- [ ] Created `.claude/commands/` directory
- [ ] Created at least one custom command file
- [ ] Reviewed the command: frontmatter, structure, instructions
- [ ] Tested the command with Claude

---

## Chapter 9: Commit Your Work

**Chapter ID**: `1.9-commit`

> 📚 **Deep Dive**: See [KNOWLEDGE.md — Chapter 1.9](./KNOWLEDGE.md#chapter-19-commit-your-work) for what to commit decisions, `.gitignore` recommendations, and commit message conventions.

### Content

#### What to Commit

After completing this seminar, you should have:

```
your-repo/
├── .claudeignore          # Security: sensitive file exclusions
├── CLAUDE.md              # Project memory file
└── .claude/
    └── commands/
        └── [your-command].md  # Custom command
```

#### Commit Commands

```bash
# Stage your files
git add .claudeignore CLAUDE.md .claude/

# Commit with descriptive message
git commit -m "Add Claude Code configuration

- Add CLAUDE.md with project context
- Add custom command for [your workflow]"
```

### Verification

```yaml
chapter: 1.9-commit
type: automated
verification:
  checks:
    - git_committed: "CLAUDE.md"
      task_key: commit_claude_md
    - git_committed: ".claude/commands"
      task_key: commit_commands
```

### Instructor: Action

Tell the student:
"Great work! Let's commit everything you've created in this seminar:

1. Stage your files:
   ```bash
   git add CLAUDE.md .claude/
   ```
2. Commit with a descriptive message:
   ```bash
   git commit -m \"Add Claude Code configuration

   - Add CLAUDE.md with project context
   - Add custom command for [your workflow]\"
   ```

Run these commands now and use the {cc-course:continue} Skill tool when done."

**Wait for the student to use the {cc-course:continue} Skill tool.**

### Instructor: Verify

Run these checks:
1. Use Bash (read-only) to run `git log --oneline -5` in the student's repository
2. Check that the latest commit includes CLAUDE.md and `.claude/commands`
3. Alternatively, run `git diff --cached --name-only` or `git show --name-only HEAD` to verify committed files

**On failure**: Tell the student what's not committed yet. Wait for {cc-course:continue}, then re-verify.

**On success**: Update progress.json tasks: `commit_claude_md`, `commit_commands`

### Checklist

- [ ] CLAUDE.md committed to git
- [ ] `.claude/commands/` committed to git
- [ ] Commit message is descriptive

---

## Seminar Summary

### What You Learned

1. **Claude Code Basics**: Installation, authentication, CLI usage
2. **Project Memory**: Creating and maintaining CLAUDE.md
3. **Commands**: Using slash commands effectively
4. **Plan Mode**: Thinking before executing
5. **Custom Commands**: Extending Claude for your workflow

### Files Created

| File | Purpose |
|------|---------|
| `.claudeignore` | Security: excludes sensitive files from Claude |
| `CLAUDE.md` | Project context and memory |
| `.claude/commands/*.md` | Custom slash commands |

### Next Seminar Preview

In **Seminar 2: Skills**, you'll learn to create reusable instruction files that teach Claude your team's specific patterns and procedures.

---

## Session Export (Post-Completion)

After completing this seminar, you can export your session logs for review or portfolio purposes.

### Export Workflow

When module validation passes, the course engine offers to:

1. **Export session logs** to `exports/seminar1-session-{uuid}.json`
2. **Export summary stats** to `exports/seminar1-summary-{uuid}.json`
3. **Generate HTML report** (optional) for visual review

### Export Commands (via MCP cclogviewer)

The course engine uses these MCP calls:

```
mcp__cclogviewer__get_session_logs(
  session_id="<your-session-id>",
  output_path="./exports/seminar1-session.json"
)

mcp__cclogviewer__get_session_summary(
  session_id="<your-session-id>",
  output_path="./exports/seminar1-summary.json"
)

mcp__cclogviewer__generate_html(
  session_id="<your-session-id>",
  output_path="./exports/seminar1-report.html",
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
seminar: 1-foundations-and-commands
# Note: Chapters 1-3 (installation, authentication, CLI basics) are covered
# in the offline Installation Guide PDF. Validation starts from Chapter 4.
tasks:
  create_claudeignore:
    chapter: 1.3
    type: automated
    check: "file_exists:.claudeignore"

  create_claude_md:
    chapter: 1.4
    type: automated
    check: "file_exists:CLAUDE.md"

  claude_md_quality:
    chapter: 1.4
    type: automated
    check: "file_quality:CLAUDE.md"

  add_project_overview:
    chapter: 1.4
    type: automated
    check: "file_contains:## Overview"

  add_tech_stack:
    chapter: 1.4
    type: automated
    check: "file_contains:Tech Stack"

  add_conventions:
    chapter: 1.4
    type: automated
    check: "file_contains:Convention"

  test_claude_understanding:
    chapter: 1.5
    type: manual
    check: "student_confirms"

  explore_slash_commands:
    chapter: 1.6
    type: manual
    check: "student_confirms"

  test_session_commands:
    chapter: 1.6
    type: manual
    check: "student_confirms"

  use_plan_mode:
    chapter: 1.7
    type: manual
    check: "student_confirms"

  create_custom_command:
    chapter: 1.8
    type: automated
    check: "glob:.claude/commands/*.md"

  commit_work:
    chapter: 1.9
    type: automated
    check: "git_log:CLAUDE.md"
```
