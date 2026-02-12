# Seminar 2: Skills

**Duration**: 90 minutes (60 min guided + 30 min implementation)

**Seminar ID**: `2-skills`

**Prerequisites**: Completed Seminar 1 (CLAUDE.md exists, basic commands understood)

---

## Learning Objectives

By the end of this seminar, participants will:
- Understand what Skills are and why they matter
- Distinguish between reference skills and action skills
- Create custom SKILL.md files for their project
- Load and use skills effectively in Claude Code sessions

---

## Chapter 1: What Are Skills?

**Chapter ID**: `2.1-what-are-skills`

### Content

#### Skills vs. CLAUDE.md

| CLAUDE.md | Skills |
|-----------|--------|
| Project context and memory | Reusable instructions |
| "What this project is" | "How to do things" |
| Always loaded | Loaded when relevant |
| One file per project | Many files per project |

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

#### Skill Types

1. **Reference Skills**: Provide context and standards
   - Coding standards
   - Architecture documentation
   - API specifications

2. **Action Skills**: Define step-by-step procedures
   - "How to create a new component"
   - "How to add an API endpoint"
   - "How to write tests"

### Verification

```yaml
chapter: 2.1-what-are-skills
type: conceptual
verification: manual
question: "Can you explain the difference between CLAUDE.md and Skills?"
```

### Checklist

- [ ] Understand the difference between CLAUDE.md and Skills
- [ ] Know what reference skills are
- [ ] Know what action skills are
- [ ] Understand the "runbook" mental model

---

## Chapter 2: Skill File Structure

**Chapter ID**: `2.2-skill-structure`

### Content

#### Location

Skills live in: `.claude/skills/`

#### Directory Structure Options

```
.claude/skills/
├── coding-standards.md      # Single file skill
├── create-component/        # Directory-based skill
│   └── SKILL.md
└── api-patterns/
    └── SKILL.md
```

#### Basic SKILL.md Template

```markdown
---
name: skill-name
description: Brief description shown when skill is discovered
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

#### Frontmatter Fields

| Field | Required | Purpose |
|-------|----------|---------|
| `name` | Yes | Identifier for the skill |
| `description` | Yes | Shown in skill discovery |
| `triggers` | No | Keywords that activate this skill |

### Verification

```yaml
chapter: 2.2-skill-structure
type: automated
verification:
  checks:
    - directory_exists: ".claude/skills"
      task_key: create_skills_directory
```

### Checklist

- [ ] Know where skills are stored (`.claude/skills/`)
- [ ] Understand the basic SKILL.md structure
- [ ] Know what frontmatter fields are required

---

## Chapter 3: Creating a Reference Skill

**Chapter ID**: `2.3-reference-skill`

### Content

#### What is a Reference Skill?

Reference skills document **standards and conventions**. They don't describe procedures - they describe rules Claude should follow.

#### Example: Coding Standards Skill

Create `.claude/skills/coding-standards.md`:

```markdown
---
name: coding-standards
description: Team coding standards and conventions
---

# Skill: Coding Standards

## Description

Enforces our team's coding standards and conventions when writing or reviewing code.

## When to Use

Apply these standards when:
- Writing new code
- Reviewing existing code
- Refactoring code
- Answering questions about code style

## Naming Conventions

### Files
- Components: `PascalCase.tsx` (e.g., `UserProfile.tsx`)
- Utilities: `camelCase.ts` (e.g., `formatDate.ts`)
- Tests: `*.test.ts` or `*.spec.ts`

### Variables
- Boolean: prefix with `is`, `has`, `should` (e.g., `isLoading`)
- Arrays: plural nouns (e.g., `users`, `items`)
- Functions: verb + noun (e.g., `fetchUser`, `calculateTotal`)

## Code Style

- Maximum line length: 100 characters
- Use explicit return types on functions
- Prefer `const` over `let`
- No magic numbers - use named constants

## Documentation

- Public functions require JSDoc comments
- Complex logic requires inline comments
- README required for new modules

## Examples

### Good
```typescript
const MAX_RETRY_COUNT = 3;

/** Fetches user data by ID */
async function fetchUser(userId: string): Promise<User> {
  // Implementation
}
```

### Bad
```typescript
async function fetch(id) {
  for (let i = 0; i < 3; i++) { // What is 3?
    // Implementation
  }
}
```
```

#### Role-Specific Reference Skills

| Role | Reference Skill Ideas |
|------|----------------------|
| Frontend | Component patterns, accessibility standards, styling conventions |
| Backend | API design guidelines, error handling patterns, database conventions |
| QA | Test naming conventions, assertion patterns, fixture standards |
| DevOps | Infrastructure naming, security policies, documentation requirements |
| Data | Schema conventions, data quality rules, pipeline standards |

### Verification

```yaml
chapter: 2.3-reference-skill
type: automated
verification:
  checks:
    - file_pattern: ".claude/skills/*.md"
      contains: ["Standards", "Convention", "Guidelines", "Rules"]
      task_key: write_reference_skill
```

### Checklist

- [ ] Created `.claude/skills/` directory
- [ ] Created at least one reference skill file
- [ ] Skill has proper frontmatter (name, description)
- [ ] Skill documents clear standards/conventions
- [ ] Skill includes examples of good vs. bad

---

## Chapter 4: Creating an Action Skill

**Chapter ID**: `2.4-action-skill`

### Content

#### What is an Action Skill?

Action skills describe **step-by-step procedures**. They teach Claude how to perform a specific task.

#### Example: Create Component Skill

Create `.claude/skills/create-component.md`:

```markdown
---
name: create-component
description: How to create a new React component following team patterns
---

# Skill: Create Component

## Description

Step-by-step process for creating a new React component in this codebase.

## When to Use

When asked to:
- Create a new component
- Add a new UI element
- Scaffold a component

## Prerequisites

Before creating a component, ensure:
- The component doesn't already exist (search first)
- The component name follows PascalCase convention
- You know which directory it belongs in

## Steps

### Step 1: Create the Component File

Location: `src/components/[ComponentName]/[ComponentName].tsx`

Template:
```tsx
import React from 'react';
import styles from './[ComponentName].module.css';

interface [ComponentName]Props {
  // Define props here
}

export function [ComponentName]({ ...props }: [ComponentName]Props) {
  return (
    <div className={styles.container}>
      {/* Component content */}
    </div>
  );
}
```

### Step 2: Create the Styles File

Location: `src/components/[ComponentName]/[ComponentName].module.css`

Template:
```css
.container {
  /* Base styles */
}
```

### Step 3: Create the Test File

Location: `src/components/[ComponentName]/[ComponentName].test.tsx`

Template:
```tsx
import { render, screen } from '@testing-library/react';
import { [ComponentName] } from './[ComponentName]';

describe('[ComponentName]', () => {
  it('renders without crashing', () => {
    render(<[ComponentName] />);
    // Add assertions
  });
});
```

### Step 4: Create the Index File

Location: `src/components/[ComponentName]/index.ts`

```ts
export { [ComponentName] } from './[ComponentName]';
```

### Step 5: Update Parent Index

Add to `src/components/index.ts`:
```ts
export * from './[ComponentName]';
```

## Verification

After creation, run:
```bash
npm run test -- --testPathPattern=[ComponentName]
```

## Example

Creating a `UserAvatar` component:
1. Create `src/components/UserAvatar/UserAvatar.tsx`
2. Create `src/components/UserAvatar/UserAvatar.module.css`
3. Create `src/components/UserAvatar/UserAvatar.test.tsx`
4. Create `src/components/UserAvatar/index.ts`
5. Update `src/components/index.ts`
```

#### Role-Specific Action Skills

| Role | Action Skill Ideas |
|------|-------------------|
| Frontend | Create page, Add route, Create form, Add animation |
| Backend | Create endpoint, Add migration, Create service, Add middleware |
| QA | Create test suite, Add E2E scenario, Create fixture, Add coverage |
| DevOps | Add service, Create Terraform module, Add monitoring, Create runbook |
| Data | Create pipeline, Add transformation, Create model, Add validation |

### Verification

```yaml
chapter: 2.4-action-skill
type: automated
verification:
  checks:
    - file_pattern: ".claude/skills/*.md"
      contains: ["Steps", "Step 1", "How to", "Create", "Process"]
      task_key: write_action_skill
```

### Checklist

- [ ] Created at least one action skill file
- [ ] Skill has clear step-by-step instructions
- [ ] Each step has specific file locations
- [ ] Skill includes code templates
- [ ] Skill has verification/testing step

---

## Chapter 5: Testing Your Skills

**Chapter ID**: `2.5-testing-skills`

### Content

#### How to Test Skills

1. **Start a fresh Claude session**:
   ```bash
   claude
   ```

2. **Request a task that should trigger your skill**:
   ```
   Create a new component called UserProfile
   ```

3. **Observe Claude's behavior**:
   - Does it follow your skill's steps?
   - Does it use the correct file locations?
   - Does it apply your conventions?

#### Evaluating Skill Effectiveness

| Check | Pass | Fail |
|-------|------|------|
| Follows step order | Steps executed in order | Steps skipped or reordered |
| Uses correct paths | Files in right locations | Wrong directory structure |
| Applies conventions | Matches your standards | Generic code style |
| Includes tests | Creates test file | No tests created |

#### Iterating on Skills

If Claude doesn't follow your skill correctly:

1. **Add more specificity**: Include exact file paths
2. **Add examples**: Show concrete before/after
3. **Clarify triggers**: Make "When to Use" more explicit
4. **Check conflicts**: Ensure skills don't contradict CLAUDE.md

### Verification

```yaml
chapter: 2.5-testing-skills
type: manual
verification:
  questions:
    - "Test your reference skill by asking Claude about conventions"
    - "Test your action skill by requesting a task it covers"
    - "Verify Claude follows your skill's instructions"
  task_key: test_skills
```

### Checklist

- [ ] Tested reference skill with a conventions question
- [ ] Tested action skill with a creation request
- [ ] Claude followed the skill's instructions
- [ ] Identified any improvements needed
- [ ] Updated skills based on testing

---

## Chapter 6: Advanced Skill Patterns

**Chapter ID**: `2.6-advanced-patterns`

### Content

#### Parameterized Skills

Skills can include placeholders that Claude fills in:

```markdown
## Template

Replace `[ENTITY]` with the actual entity name:
- File: `src/models/[ENTITY].ts`
- Test: `src/models/__tests__/[ENTITY].test.ts`
```

#### Conditional Instructions

Skills can include branching logic:

```markdown
## Steps

### If TypeScript project:
- Add types to `src/types/[name].ts`

### If JavaScript project:
- Add JSDoc comments for type hints
```

#### Skill Composition

Skills can reference other skills:

```markdown
## Related Skills

After completing this skill:
- Apply `coding-standards` skill for code review
- Apply `testing-conventions` skill for test file
```

#### Team Sharing

Skills can be shared across team:

```bash
# Add to repository
git add .claude/skills/
git commit -m "Add team skills for consistent development"
git push
```

### Checklist

- [ ] Understand parameterized skills
- [ ] Know how to add conditional logic
- [ ] Know how to reference other skills
- [ ] Committed skills to repository

---

## Chapter 7: Commit Your Skills

**Chapter ID**: `2.7-commit`

### Content

#### What to Commit

```
.claude/skills/
├── coding-standards.md     # Reference skill
└── create-[something].md   # Action skill
```

#### Commit Commands

```bash
git add .claude/skills/
git commit -m "Add Claude Code skills

- Add coding-standards reference skill
- Add create-[something] action skill"
```

### Verification

```yaml
chapter: 2.7-commit
type: automated
verification:
  checks:
    - git_committed: ".claude/skills"
      task_key: commit_skills
```

### Checklist

- [ ] All skills committed to git
- [ ] Commit message describes what skills do

---

## Seminar Summary

### What You Learned

1. **Skills Concept**: Reusable instructions vs. project memory
2. **Reference Skills**: Documenting standards and conventions
3. **Action Skills**: Step-by-step procedures
4. **Testing**: Verifying skills work correctly
5. **Advanced Patterns**: Parameterization, composition, sharing

### Files Created

| File | Purpose |
|------|---------|
| `.claude/skills/coding-standards.md` | Reference skill (example) |
| `.claude/skills/create-*.md` | Action skill |

### Next Seminar Preview

In **Seminar 3: Extensions**, you'll learn to create hooks for automation, configure MCP servers for external tools, and build more sophisticated custom commands.

---

## Validation Summary

```yaml
seminar: 2-skills
tasks:
  create_skills_directory:
    chapter: 2.2
    type: automated
    check: "directory_exists:.claude/skills"

  write_reference_skill:
    chapter: 2.3
    type: automated
    check: "file_contains:Standards|Convention|Guidelines"

  write_action_skill:
    chapter: 2.4
    type: automated
    check: "file_contains:Steps|Step 1|How to"

  test_skills:
    chapter: 2.5
    type: manual
    check: "student_confirms"

  commit_skills:
    chapter: 2.7
    type: automated
    check: "git_log:.claude/skills"
```
