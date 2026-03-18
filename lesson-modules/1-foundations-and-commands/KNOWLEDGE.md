# Seminar 1: Foundations & Commands — Knowledge Base

## How to Use This File

This file complements `SCRIPT.md` with:
- **Deep dive explanations** — detailed background on each topic
- **External resources** — curated links to official docs and community content
- **Links verified** as of February 2026

**Separation of concerns:**
- `SCRIPT.md` = Teaching flow, validations, checklists (instructor guide)
- `KNOWLEDGE.md` = Deep content, external links, conceptual foundations (knowledge base)

---

## Chapter 1.1: What is Claude Code?

### Deep Dive

#### What "Agentic" Really Means

An **agentic** coding assistant can take autonomous actions to complete tasks, not just provide suggestions. This includes:

- **Reading files** — scanning your entire codebase to understand context
- **Writing files** — making code changes directly (with permission)
- **Running commands** — executing shell commands like tests, builds, git operations
- **Making decisions** — choosing which tools to use and in what order
- **Iterating** — running tests, seeing failures, and fixing them autonomously

Traditional AI coding tools (like Copilot) are **reactive** — they suggest code as you type. Agentic tools are **proactive** — you describe the goal, and they work toward it.

#### Terminal-Native Advantages

Running in the terminal provides several benefits:

1. **Full filesystem access** — Claude can read any file, not just open tabs
2. **Shell integration** — can run any command your terminal can run
3. **No IDE lock-in** — works with any editor, any project
4. **Automation-ready** — can be scripted, piped, and integrated into workflows
5. **Resource efficiency** — no heavy IDE overhead

#### Memory Persistence via CLAUDE.md

Unlike session-based AI tools, Claude Code maintains project memory through:

- **CLAUDE.md** — project-specific context loaded every session
- **Hierarchical loading** — parent directories' CLAUDE.md files are inherited
- **Session continuation** — `-c` flag resumes previous conversations

### External Resources

**Official Documentation:**
- [Claude Code Overview](https://code.claude.com/docs/en/overview) — Main documentation entry point
- [GitHub: anthropics/claude-code](https://github.com/anthropics/claude-code) — Official repository

**Comparisons & Context:**
- [Claude Code vs Cursor vs GitHub Copilot (2026)](https://javascript.plainenglish.io/github-copilot-vs-cursor-vs-claude-i-tested-all-ai-coding-tools-for-30-days-the-results-will-c66a9f56db05) — 30-day comparison test
- [AI Coding Assistants in 2026 (Medium)](https://medium.com/@saad.minhas.codes/ai-coding-assistants-in-2026-github-copilot-vs-cursor-vs-claude-which-one-actually-saves-you-4283c117bf6b) — Time savings analysis
- [Which AI Coding Tool Wins in 2026?](https://www.thepromptbuddy.com/prompts/claude-code-vs-cursor-vs-github-copilot-vs-amazon-q-which-ai-coding-tool-wins-in-2026) — Full comparison including Amazon Q

**Use Case Guide:**
- [How Anthropic Teams Use Claude Code (PDF)](https://www-cdn.anthropic.com/58284b19e702b49db9302d5b6f135ad8871e7658.pdf) — Official use cases from Anthropic

---

## Chapter 1.2: Installation & Authentication

### Deep Dive

#### Node.js Requirements

Claude Code requires Node.js 18+ for modern JavaScript features and performance. Check your version:

```bash
node --version  # Should be v18.x or higher
```

If you need to upgrade, consider using a version manager like `nvm` or `fnm` for easier Node.js management.

#### Authentication Methods

Claude Code supports two authentication approaches:

1. **OAuth (Recommended)** — Browser-based login tied to your Claude subscription
   - Automatic token refresh
   - No API key management
   - Works with Pro, Max, Teams, and Enterprise plans

2. **API Key** — Direct Anthropic API authentication
   - Set `ANTHROPIC_API_KEY` environment variable
   - Usage billed separately from subscription
   - Useful for CI/CD and automation

#### Common Installation Issues

| Issue | Solution |
|-------|----------|
| Permission errors | Don't use `sudo npm install -g` — use a Node version manager instead |
| Command not found | Ensure npm bin is in your PATH |
| Authentication fails | Check if browser pop-up is blocked |
| Version mismatch | Run `npm update -g @anthropic-ai/claude-code` |

### External Resources

**Package & Installation:**
- [@anthropic-ai/claude-code on npm](https://www.npmjs.com/package/@anthropic-ai/claude-code) — Official npm package
- [Claude Code Setup Guide](https://code.claude.com/docs/en/setup) — Official installation docs
- [Node.js Downloads](https://nodejs.org/) — Get the latest Node.js

**API & Authentication:**
- [Anthropic Console](https://console.anthropic.com/) — API key management
- [Claude Pricing](https://www.anthropic.com/pricing) — Subscription and API pricing

---

## Chapter 1.3: CLI Basics

### Deep Dive

#### Execution Modes Explained

| Mode | Command | When to Use |
|------|---------|-------------|
| **Interactive** | `claude` | Learning, exploration, multi-step tasks |
| **One-shot** | `claude "prompt"` | Quick questions, simple tasks |
| **Print** | `claude -p "prompt"` | Scripting, piping output, automation |
| **Continue** | `claude -c` | Resume previous conversation |

**Interactive mode** maintains a REPL-like experience where you have a conversation. Best for exploratory work.

**One-shot mode** runs a single prompt and exits. Claude still has full tool access.

**Print mode** (`-p`) outputs only Claude's response text — no interactive elements. Perfect for:
```bash
claude -p "Explain this error" | less
claude -p "Generate a function that..." > output.txt
```

#### Tool Visibility

When Claude uses tools, you'll see indicators:
- `Reading file...` — Examining your code
- `Writing file...` — Making changes (prompts for permission)
- `Running command...` — Executing shell commands (prompts for permission)
- `Searching...` — Using glob or grep to find files

#### Exit Methods

- Type `exit` — Graceful exit with session save
- `Ctrl+D` — EOF signal, equivalent to `exit`
- `Ctrl+C` — Cancel current operation (once)
- `Ctrl+C` twice — Hard exit

#### Security: Protecting Sensitive Files

Claude Code has full filesystem access within your project. Protecting sensitive files requires a layered approach using the official mechanisms documented at [code.claude.com/docs/en/permissions](https://code.claude.com/docs/en/permissions).

**Layer 1: `permissions.deny` in `.claude/settings.json`** (Primary)

The official way to block Claude from reading sensitive files. Uses [gitignore pattern syntax](https://code.claude.com/docs/en/permissions#read-and-edit):

```json
{
  "permissions": {
    "deny": [
      "Read(./.env)",
      "Read(./.env.*)",
      "Read(./secrets/**)",
      "Read(./*.pem)",
      "Read(./*.key)",
      "Read(./credentials.json)"
    ]
  }
}
```

**Pattern types:**
| Pattern | Meaning | Example |
|---------|---------|---------|
| `Read(./.env)` | Relative to current directory | `.env` in project root |
| `Read(./secrets/**)` | Recursive glob | Everything under `secrets/` |
| `Read(~/.ssh/*)` | Home directory path | SSH keys |
| `Read(//.env)` | Absolute path (double slash prefix) | Filesystem root |

**Important caveat**: Read deny rules block Claude's built-in Read tool but do NOT prevent `cat .env` via Bash. For full protection, also use the sandbox.

**Layer 2: Sandbox** (OS-level enforcement)

Enable with `/sandbox` to get filesystem and network isolation that also blocks Bash subprocesses from accessing denied files. This is the strongest protection layer.

**Layer 3: PreToolUse hooks** (Automated enforcement, covered in Module 3)

Hooks can intercept tool calls before execution, validate the target file, and block with exit code 2 if it matches a sensitive pattern. The stderr message feeds back to Claude explaining why the read was blocked.

**Security layers comparison:**
| Layer | Blocks Read tool | Blocks Bash `cat` | Setup |
|-------|-----------------|-------------------|-------|
| `permissions.deny` | Yes | No | `.claude/settings.json` |
| Sandbox | Yes | Yes | `/sandbox` command |
| PreToolUse hook | Yes | No | Hook config in settings |

**Best practices:**
- Always configure `permissions.deny` for `.env*`, `*.pem`, `*.key` patterns
- Enable sandbox for full protection in sensitive environments
- Add `.env*` to `.gitignore` as well (defense-in-depth)
- Use `${API_KEY}` interpolation in MCP configs instead of hardcoded values
- Commit `.env.example` (no real values) as a template for teammates

### External Resources

**Official Docs:**
- [Interactive Mode](https://code.claude.com/docs/en/interactive-mode) — Full interactive mode reference
- [Common Workflows](https://code.claude.com/docs/en/common-workflows) — Usage patterns

**Cheat Sheets:**
- [Claude Code CLI Cheatsheet (Shipyard)](https://shipyard.build/blog/claude-code-cheat-sheet/) — Commands and config
- [Claude Code Cheat Sheet (GitHub)](https://github.com/Njengah/claude-code-cheat-sheet) — Tips and workflows
- [Developer Cheatsheet (AwesomeClaude)](https://awesomeclaude.ai/code-cheatsheet) — Commands, config, workflows

---

## Chapter 1.4: CLAUDE.md — Project Memory

### Deep Dive

#### Why Each Section Matters

| Section | Purpose | Without It |
|---------|---------|------------|
| **Overview** | Establishes project context | Claude treats it as generic code |
| **Tech Stack** | Informs library/tool choices | May suggest wrong frameworks |
| **Architecture** | Guides file placement | Creates files in wrong locations |
| **Conventions** | Enforces coding style | Inconsistent code style |
| **Commands** | Enables running builds/tests | Can't verify its own changes |

#### File Referencing with `@path/to/file`

For large context, reference external files instead of inlining:

```markdown
## API Documentation
See @docs/api-spec.md for detailed endpoint documentation.

## Database Schema
Reference @prisma/schema.prisma for current data models.
```

This keeps CLAUDE.md concise while giving Claude access to detailed docs on demand.

#### Size Optimization Strategies

**Problem**: CLAUDE.md over 300 lines loses effectiveness.

**Solutions**:
1. **Move specs to separate files** — Use `@path` references
2. **Remove obvious context** — If Claude already knows it, don't repeat it
3. **Use hooks for enforcement** — Don't document rules Claude should verify
4. **Create skills for procedures** — Move step-by-step instructions to `.claude/skills/`
5. **Delete placeholders** — Remove TODO/FIXME before committing

#### Progressive Disclosure Pattern

Instead of one massive CLAUDE.md, use hierarchy:

```
project/
├── CLAUDE.md                 # Project-wide context
├── src/
│   └── CLAUDE.md             # Source code conventions
├── tests/
│   └── CLAUDE.md             # Testing guidelines
└── docs/
    └── CLAUDE.md             # Documentation rules
```

Claude loads child CLAUDE.md files when working in those directories.

#### CLAUDE.md Best Practices Checklist

Use this checklist when reviewing an existing CLAUDE.md or evaluating a newly created one:

**Structure (required sections):**
- [ ] Project overview — 2-3 sentences describing what the project does
- [ ] Tech stack — language, framework, testing, build tools
- [ ] Conventions — naming, file organization, code style
- [ ] Common commands — test, build, dev server, lint
- [ ] Key files — important entry points, configuration files

**Quality indicators:**
- [ ] Under 500 lines (warn at 300)
- [ ] Under 40,000 characters
- [ ] No TODO/FIXME placeholders remaining
- [ ] No unfilled `[bracket]` placeholders
- [ ] Uses `@path/to/file` references for detailed specs (if > 200 lines)

**Effectiveness:**
- [ ] Contains specific instructions, not generic advice
- [ ] References actual file paths in the project
- [ ] Includes "what NOT to do" rules where relevant
- [ ] Commands are correct and runnable
- [ ] Tech stack matches actual dependencies (check package.json, requirements.txt, etc.)

**Advanced (optional but recommended):**
- [ ] Hierarchical CLAUDE.md files in subdirectories for large projects
- [ ] Skills referenced for reusable procedures (`.claude/skills/`)
- [ ] Architecture section with directory structure explanation

### External Resources

**Official Guidance:**
- [Best Practices for Claude Code](https://code.claude.com/docs/en/best-practices) — Official recommendations
- [The Complete Guide to Building Skills for Claude (PDF)](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf?hsLang=en) — Anthropic's skills guide

**Community Best Practices:**
- [Writing a Good CLAUDE.md (HumanLayer)](https://www.humanlayer.dev/blog/writing-a-good-claude-md) — Practical tips
- [Claude Skills and CLAUDE.md Guide (2026)](https://www.gend.co/blog/claude-skills-claude-md-guide) — Team-focused guide
- [Claude Code Best Practices (GitHub)](https://github.com/awattar/claude-code-best-practices) — Examples and patterns

**Real-World Examples:**
- [claude-code-showcase (GitHub)](https://github.com/ChrisWiles/claude-code-showcase) — Comprehensive example with hooks, skills, agents
- [claude-md-examples (GitHub)](https://github.com/ArthurClune/claude-md-examples) — Sample CLAUDE.md files
- [CLAUDE.md Templates (Wiki)](https://github.com/ruvnet/claude-flow/wiki/CLAUDE-MD-Templates) — Templates for different project types
- [Awesome Claude Code (GitHub)](https://github.com/hesreallyhim/awesome-claude-code) — Curated list of skills, hooks, commands

---

## Chapter 1.5: Testing Your Setup

### Deep Dive

#### Expected Claude Responses

When properly configured, Claude should:

1. **Know your project's purpose** without needing to scan files
2. **Reference your tech stack** when suggesting solutions
3. **Follow your conventions** when generating code
4. **Know command patterns** like how to run tests

#### Debugging Context Loading Issues

**Symptom**: Claude doesn't know project context

**Diagnostic Steps**:
1. Run `/context` to see what's loaded
2. Check CLAUDE.md exists in project root
3. Verify CLAUDE.md has required sections
4. Look for syntax errors in CLAUDE.md (especially YAML-like sections)

**Common Fixes**:
- Add more specific examples (not just descriptions)
- Include actual file paths
- Remove jargon and use concrete terms
- Add a "Key Files" section pointing to important code

#### Using `/context` Effectively

The `/context` command shows:
- Files currently in Claude's context
- Memory from CLAUDE.md
- Recent conversation context

Use it to verify Claude has the information it needs before asking complex questions.

### External Resources

**Troubleshooting:**
- [Claude Code Doctor Command](https://code.claude.com/docs/en/slash-commands#doctor) — Diagnose installation issues
- [Claude Code Troubleshooting (ClaudeLog)](https://claudelog.com/faqs/) — Common issues and fixes

---

## Chapter 1.6: Essential Slash Commands

### Deep Dive

#### `/clear` vs `/compact` — Detailed Difference

| Command | What It Does | When to Use |
|---------|--------------|-------------|
| `/clear` | Resets conversation completely | Starting fresh, context is wrong |
| `/compact` | Summarizes and compresses context | Running low on context, want to continue |

**`/compact`** is intelligent compression — it keeps essential information while reducing token usage. Use when you get warnings about context limits.

**`/clear`** is a hard reset — nothing from the current conversation persists. Use when Claude is confused or you want a fresh start.

#### Session Management Deep Dive

**Finding Your Session ID:**
```bash
# In a Claude session
/config  # Shows session info

# Or check the directory
ls ~/.claude/projects/
```

**Session ID Uses:**
- Resume specific sessions: `claude -r <session-id>`
- Share logs for debugging
- Export for analysis

#### Context Management Deep Dive

Understanding context is crucial for effective Claude Code usage. The context window is Claude's "working memory" — everything it can reference at once.

**What counts toward context:**
- System prompt (base instructions)
- CLAUDE.md file content
- All conversation messages (your prompts + Claude's responses)
- Tool results (file reads, command output, search results)
- Skill/command content when invoked

**Performance by context usage:**

| Usage Range | Performance Impact | What To Do |
|-------------|-------------------|------------|
| 0–50% | Full quality, fast responses | Keep working normally |
| 50–75% | Good quality, slightly slower | Monitor, start planning compaction |
| 75–90% | Noticeable quality drop | Run `/compact` to free space |
| 90–100% | Degraded, may miss details | Run `/compact` or `/clear` immediately |

**Autocompact behavior:**
- Triggers automatically when context approaches the limit
- Summarizes earlier conversation while preserving recent messages
- CLAUDE.md and system instructions are always preserved
- You may notice a brief pause when it runs
- Manual `/compact` gives you control over when compression happens

**Practical context workflows:**

1. **Long task**: Work → check `/context` → `/compact` when over 75% → continue
2. **Fresh start with plan**: Write plan to file → `/clear` → reference `@plan.md` → work in clean context
3. **Multiple attempts**: If approach isn't working → `/clear` → try different angle with full context available

#### /statusline Best Practices

The status line provides persistent, at-a-glance information while you work. Configuring it well reduces the need to run `/context` or `/config` repeatedly.

**Recommended configuration:**
- **Context usage %** — the most important metric; tells you when to compact
- **Model name** — confirms you're on the right model (Sonnet vs Opus)
- **Git branch** — prevents accidental commits to wrong branches
- **Project name** — helps when switching between projects

**When it's especially useful:**
- Long coding sessions where context fills up
- Working across multiple projects in different terminals
- Pair programming or screen sharing (others can see your session state)

#### CLI Flags Reference

| Flag | Long Form | Purpose |
|------|-----------|---------|
| `-p` | `--prompt` | Run non-interactively with a prompt |
| `-c` | `--continue` | Resume last session |
| `-r` | `--resume` | Resume specific session by ID |
| `--max-turns N` | — | Limit agentic iterations |
| `--model NAME` | — | Use specific model |
| `--no-permissions` | — | Disable permission prompts (careful!) |
| `--add-dir PATH` | — | Add additional working directories |

### External Resources

**Official References:**
- [CLI Reference](https://code.claude.com/docs/en/cli-reference) — Full command reference
- [Skills Documentation](https://code.claude.com/docs/en/skills) — Create custom slash commands
- [SDK Slash Commands](https://code.claude.com/docs/en/sdk/sdk-slash-commands) — For SDK users

**Command Collections:**
- [Production-Ready Commands (GitHub)](https://github.com/wshobson/commands) — Community slash commands
- [Awesome Claude Code (GitHub)](https://github.com/hesreallyhim/awesome-claude-code) — Curated skills and commands
- [Slash Commands Reference (Learnia)](https://www.learn-prompting.fr/en/blog/claude-code-slash-commands-reference) — Complete 2026 reference

---

## Chapter 1.7: Plan Mode

### Deep Dive

#### Plan Output Format

When in plan mode, Claude produces structured plans:

```markdown
## Plan: [Task Name]

### Understanding
[Claude's interpretation of the task]

### Approach
1. [Step 1]
2. [Step 2]
...

### Files to Modify
- `path/to/file.ts` — [what changes]
- `path/to/test.ts` — [new test file]

### Risks & Considerations
- [Potential issues]
- [Edge cases]
```

#### How to Evaluate Plan Quality

Good plans should:
- ✅ Reference actual files in your codebase
- ✅ Follow your project's conventions
- ✅ Include testing/verification steps
- ✅ Identify potential risks

Red flags:
- ❌ Generic patterns not matching your stack
- ❌ Missing test considerations
- ❌ Unclear about file locations
- ❌ Ignoring existing code patterns

#### Examples: Good vs Poor Plans

**Good Plan:**
> "I'll add the login feature to `src/auth/login.tsx`, following your existing pattern in `register.tsx`. I'll create a test in `__tests__/login.test.tsx` using your Jest + RTL setup."

**Poor Plan:**
> "I'll create a new Login component with standard React patterns and add appropriate tests."

The good plan shows Claude understands your specific codebase.

#### Plan Mode as a Thinking Tool

Plan mode is most powerful when used as a **deliberation tool** rather than an execution step:

**The iterate-and-discard pattern:**
1. Enter plan mode → request a plan
2. Iterate 2-3 times with feedback ("What about X?", "Can you split step 3?")
3. Press Escape to exit **without executing**
4. Save the plan to a file if it's good: copy the plan to `plan.md`
5. `/clear` to get fresh context
6. Reference `@plan.md` and execute with full context available

**Why this works:**
- Planning consumes context — a long planning session can eat 30-50% of your context window
- By saving the plan to a file and clearing, you get the best of both worlds: a well-thought-out plan AND full context for execution
- The iterate step catches edge cases and improves plan quality before any code is written

**Warning about context during planning:**
- Each iteration adds to context usage
- Long planning sessions (5+ rounds) can consume significant context
- If you see context above 60% after planning, consider the save → clear → reload pattern

#### Plan Modification Techniques

If the plan isn't right:
1. **Ask for alternatives**: "What other approaches could work?"
2. **Add constraints**: "I need this to work with X"
3. **Request detail**: "Explain step 3 more"
4. **Reject and redirect**: "Instead of X, let's do Y"

### External Resources

**Official Documentation:**
- [Common Workflows — Plan Mode](https://code.claude.com/docs/en/common-workflows) — Official guide
- [EnterPlanMode Tool (GitHub)](https://github.com/Piebald-AI/claude-code-system-prompts/blob/main/system-prompts/tool-description-enterplanmode.md) — Tool specification

**Guides & Tutorials:**
- [What Is Plan Mode? (Armin Ronacher)](https://lucumr.pocoo.org/2025/12/17/what-is-plan-mode/) — Deep explanation
- [Plan Mode on ClaudeLog](https://claudelog.com/mechanics/plan-mode/) — Mechanics explained
- [Mastering Plan Mode (Substack)](https://agiinprogress.substack.com/p/mastering-claude-code-plan-mode-the) — Advanced techniques
- [How to Use Plan Mode in VS Code (Medium)](https://medium.com/@automateandtweak/how-to-use-plan-mode-in-claude-code-vs-code-the-smart-way-to-code-with-ai-a93d1b437646) — IDE integration

**System Prompts Reference:**
- [Claude Code System Prompts (GitHub)](https://github.com/Piebald-AI/claude-code-system-prompts) — All prompts including Plan agent

---

## Chapter 1.8: Custom Commands

### Deep Dive

#### All Frontmatter Options

```yaml
---
name: command-name           # Required: becomes /command-name
description: What it does    # Required: shown in /help
allowed-tools:               # Optional: auto-approve these tools
  - Bash
  - Edit
  - Read
---
```

#### Commands with Parameters

Commands receive arguments after the command name:

```markdown
---
name: new-component
description: Create a new React component
---

Create a new React component with the name provided as the argument.
The component should:
1. Be placed in `src/components/{name}/`
2. Include `{name}.tsx`, `{name}.test.tsx`, and `index.ts`
3. Follow our existing component patterns
```

Usage: `/new-component UserProfile`

The argument "UserProfile" is passed to Claude as context.

#### Skills vs Commands Decision Tree

```
Should this be a Skill or Command?

Is it invoked with a slash command?
├── Yes → Could be either
│   └── Does it need parameters?
│       ├── Yes → Command
│       └── No → Does it encode reusable knowledge?
│           ├── Yes → Skill
│           └── No → Command
└── No → Should Claude detect when to use it?
    ├── Yes → Skill
    └── No → Probably neither
```

**Commands**: Explicit invocation, often with parameters, specific tasks
**Skills**: Reusable knowledge, can be auto-detected, encode patterns

#### Using Claude Code to Build Claude Code

A core practice: **always use Claude Code to create Claude Code configurations**. This applies to:

- **Commands** — Prompt Claude to create `.claude/commands/*.md` files
- **Skills** — Prompt Claude to create `.claude/skills/*.md` files
- **Hooks** — Prompt Claude to configure `.claude/hooks/` entries
- **CLAUDE.md** — Use `/init` or prompt Claude to enhance your CLAUDE.md
- **MCP configs** — Prompt Claude to set up `.mcp.json`

**Why this works better than manual creation:**
1. **Claude knows the format** — correct frontmatter, proper sections, valid syntax
2. **Adapts to your project** — Claude reads your codebase and tailors instructions accordingly
3. **Practices prompting** — the meta-skill of describing what you want Claude to build
4. **Catches mistakes** — Claude validates its own output against conventions

**Example workflow:**
```
You: "Create a /review command that reviews the current git diff,
     checks for our team's coding standards, and outputs a summary"

Claude: [reads your CLAUDE.md, understands your conventions,
        creates .claude/commands/review.md with proper frontmatter
        and project-specific instructions]

You: [review the result, test it, suggest tweaks]
```

#### Testing Custom Commands

1. Create the command file
2. Start a new Claude session (or restart current)
3. Type `/help` — your command should appear
4. Invoke with `/your-command-name`
5. Verify Claude follows the instructions

### External Resources

**Official Documentation:**
- [Slash Commands Docs](https://code.claude.com/docs/en/slash-commands) — Creating custom commands
- [Skills Guide (Anthropic PDF)](https://resources.anthropic.com/hubfs/The-Complete-Guide-to-Building-Skill-for-Claude.pdf?hsLang=en) — Complete skills reference

**Examples & Collections:**
- [Production-Ready Commands (GitHub)](https://github.com/wshobson/commands) — Real command examples
- [Awesome Claude Code (GitHub)](https://github.com/hesreallyhim/awesome-claude-code) — Community collection
- [Claude Code Everything Guide (GitHub)](https://github.com/wesammustafa/Claude-Code-Everything-You-Need-to-Know) — Comprehensive reference
- [Project Start Template (Gist)](https://gist.github.com/shamshirz/eb1dac86bc7238f228ed58d1fac5fba2) — Command template example

---

## Chapter 1.9: Commit Your Work

### Deep Dive

#### What to Commit — `.claude/` Decisions

**Always commit:**
- `CLAUDE.md` — Project context, shared with team
- `.claude/commands/` — Team-shared custom commands
- `.claude/skills/` — Team-shared skills

**Consider carefully:**
- `.claude/settings.json` — May contain personal preferences
- `.claude/memory/` — Usually personal, not shared

**Never commit:**
- API keys or secrets referenced in any file
- Personal configuration that conflicts with team settings

#### `.gitignore` Recommendations

```gitignore
# Claude Code personal files (optional)
.claude/settings.local.json
.claude/memory/

# Don't ignore these (they're meant to be shared)
# .claude/commands/
# .claude/skills/
# CLAUDE.md
```

#### Commit Message Conventions

Follow your project's conventions, but good Claude Code commits:

```
Add Claude Code configuration

- Add CLAUDE.md with project context and conventions
- Add custom /new-component command for React workflow
- Configure tech stack and common commands

Co-authored-by: Claude <noreply@anthropic.com>
```

Include `Co-authored-by` if Claude helped write the code.

### External Resources

**Git Best Practices:**
- [Conventional Commits](https://www.conventionalcommits.org/) — Commit message standard
- [Git Best Practices (GitHub)](https://github.com/trein/dev-best-practices/wiki/Git-Commit-Best-Practices) — General git guidance

---

## Keyboard Shortcuts Reference

Quick reference for Claude Code keyboard shortcuts:

| Shortcut | Action |
|----------|--------|
| `?` | Show all available shortcuts |
| `Shift+Tab` | Toggle plan mode |
| `Ctrl+C` | Cancel current operation |
| `Ctrl+C` (twice) | Hard exit |
| `Ctrl+D` | Exit session (EOF) |
| `Ctrl+A` | Move to start of line |
| `Ctrl+E` | Move to end of line |
| `Ctrl+W` | Delete previous word |
| `Ctrl+T` | Toggle task list view |
| `Escape` | Stop Claude |
| `Escape` (twice) | Show message history |
| `Option+F` / `Option+B` | Word forward/back (macOS) |

**Note**: macOS users need to configure Option as Meta in terminal settings for Alt shortcuts.

### External Resources

- [Interactive Mode — Keyboard Shortcuts](https://code.claude.com/docs/en/interactive-mode) — Official reference
- [Keybindings Guide (ClaudeFast)](https://claudefa.st/blog/tools/keybindings-guide) — Complete guide
- [Essential Shortcuts (Egghead)](https://egghead.io/the-essential-claude-code-shortcuts~dgsee) — Video tutorial
- [Terminal Setup (ClaudeLog)](https://claudelog.com/faqs/claude-code-terminal-setup/) — Shift+Enter configuration

---

## Additional Resources

### Complete Guides

- [Cooking with Claude Code — Complete Guide](https://www.siddharthbharath.com/claude-code-the-complete-guide/) — Comprehensive walkthrough
- [Claude Code for Beginners (2026)](https://codewithmukesh.com/blog/claude-code-for-beginners/) — Beginner-friendly tutorial
- [How I Use Claude Code (Builder.io)](https://www.builder.io/blog/claude-code) — Practical tips from power user

### Curated Collections

- [Awesome Claude Code (GitHub)](https://github.com/hesreallyhim/awesome-claude-code) — Skills, hooks, commands, plugins
- [ClaudeLog](https://claudelog.com/) — Docs, guides, tutorials, best practices

### Official Channels

- [Claude Code GitHub Issues](https://github.com/anthropics/claude-code/issues) — Bug reports and feature requests
- [Claude Code Changelog](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md) — Version history
- [Claude Code Release Notes](https://releasebot.io/updates/anthropic/claude-code) — Latest updates
