# Review System

Shared review logic for the `/cc-course:review` skill. This system is **generic** — it derives all quality criteria dynamically from the module's SCRIPT.md rather than hardcoding per-module rules. This makes it reusable for any learning platform that follows the same structure.

---

## Phase 1: Dynamic Rubric Extraction

Before evaluating any student work, build the rubric by reading the module's teaching script.

### Read the Module SCRIPT.md

```
lesson-modules/{module-key}/SCRIPT.md
```

Extract the following:

### 1. Learning Objectives

Found near the top of each SCRIPT.md, typically under a "Learning Objectives" or "By the end of this module" heading. These are numbered or bulleted items describing what the student should be able to do.

**Store these as the Understanding benchmark** — each objective will be checked against the student's artifacts.

### 2. Verification Blocks

YAML blocks embedded throughout SCRIPT.md that define automated checks. Look for patterns like:

```yaml
verification:
  type: file_exists | file_contains | file_quality | directory_exists | file_pattern | git_committed | command | manual
  path: "relative/path/to/artifact"
  contains: ["required", "strings"]
  min_count: N
  task_key: "maps_to_progress_json_key"
```

**Store these as the Completeness checklist** — each verification block defines a required artifact and its minimum criteria.

### 3. Checklists

Task completion lists after each chapter/subtheme. Each item has a `task_key` that maps to `progress.json`. These tell you which tasks the student should have completed and in what order.

### 4. Quality Context

The teaching narrative itself describes what "good" work looks like. Pay attention to:
- Phrases like "should reference your actual project", "adapt to your tech stack"
- Explicit good vs. bad examples in the script
- Warnings about common mistakes
- Phrases like "don't just copy", "make it specific"

**Use this narrative context as the Quality evaluation lens** — Claude reads the teaching goals and applies them when assessing artifacts.

---

## Phase 2: Artifact Analysis

Read every file in the submission's `student-work/` directory. For each artifact:

### Completeness Check
- Is this artifact present? (Cross-reference against verification blocks extracted in Phase 1)
- Is it non-empty?
- Does it meet minimum size/count requirements from the verification blocks?

### Quality Assessment

Evaluate each artifact against the SCRIPT.md's teaching expectations. **Do not use hardcoded rules.** Instead, assess:

1. **Substance** — Is the content substantive or placeholder?
   - Look for: TODO/FIXME markers, lorem ipsum, "[your X here]" placeholders
   - Check: reasonable content length relative to the task complexity

2. **Specificity** — Is the content specific to the student's project?
   - Cross-reference `manifest.student.role` and `manifest.student.repository`
   - Check: does the artifact reference real project paths, frameworks, tools?
   - Flag: generic content that could apply to any project

3. **Structure** — Does the artifact follow the patterns taught in SCRIPT.md?
   - Check: required sections, frontmatter fields, directory structure
   - These come from the verification blocks' `contains` and `file_quality` criteria

4. **Correctness** — Is the content technically valid?
   - For YAML/JSON files: valid syntax
   - For shell scripts: proper shebang, error handling
   - For markdown: proper formatting, valid links

5. **Relevance** — Does the artifact solve a real problem for the student?
   - A custom command should address an actual workflow need
   - A skill should be useful for the student's tech stack
   - A hook should target their actual development tools

### Understanding Evidence

For each learning objective extracted in Phase 1, look for evidence in the artifacts:
- Does the artifact demonstrate the objective was understood?
- Is the work adapted (not verbatim from course examples)?
- Can you trace the learning path from SCRIPT.md teaching → student implementation?

Negative signals:
- Artifacts contain text verbatim from the SCRIPT.md examples
- Content contradicts manifest metadata (e.g., artifact says "React" but student role is "backend/Python")
- Work is structurally correct but semantically empty

---

## Phase 3: Session Analysis via cclogviewer MCP

Analyze how the student worked, not just what they produced. Use the cclogviewer MCP tools.

### Getting Session IDs

Extract from the submission's `progress/progress.json`:

```
progress.modules["{module-key}"].sessions[].session_id
```

And the MCP project identifier from:
```
progress.student.mcp_project_name  (preferred)
— or —
progress.student.repository        (fallback)
```

### MCP Calls Per Session

For each session ID, call these MCP tools:

#### Session Summary
```
mcp__cclogviewer__get_session_summary(session_id, project)
```
Returns: duration, message count, token usage, overall statistics.

#### Session Statistics
```
mcp__cclogviewer__get_session_stats(session_id, project)
```
Returns: detailed tool usage breakdown — which tools were used, how often, success/failure rates.

#### Session Errors
```
mcp__cclogviewer__get_session_errors(session_id, project)
```
Returns: error count, error types, error messages. Helps assess experimentation vs. struggle.

#### Session Timeline
```
mcp__cclogviewer__get_session_timeline(session_id, project)
```
Returns: chronological list of actions. Reveals pacing and time distribution across tasks.

#### Tool Usage Stats (aggregate)
```
mcp__cclogviewer__get_tool_usage_stats(project)
```
Returns: aggregate tool usage patterns across all sessions for this project.

#### Hint/Struggle Search
```
mcp__cclogviewer__search_logs(query="hint", project)
```
Search for hint-related interactions to gauge how much help the student needed.

### Process Heuristics

From the MCP data, assess:

1. **Duration** — Is the total time reasonable for the module?
   - Compare against expected module duration from SCRIPT.md (if stated)
   - Flag if suspiciously fast (< 25% of expected time)
   - Flag if extremely long (> 300% of expected time without proportional output)

2. **Iteration** — Did the student refine their work?
   - Multiple Write/Edit tool calls to the same file paths = good (revision)
   - Single write per artifact = minimal iteration
   - Check timeline for back-and-forth patterns

3. **Tool Diversity** — Did the student explore Claude Code's capabilities?
   - Using Read, Grep, Glob, Bash, Edit, Write = engaged
   - Using only basic tools = limited exploration

4. **Error Recovery** — How did the student handle mistakes?
   - Errors followed by different approaches = experimentation (positive)
   - Same error repeated = stuck without adapting (negative)
   - Zero errors = possibly too cautious or pre-scripted

5. **Engagement Pattern** — Was the student actively learning?
   - Steady pace with natural pauses = genuine engagement
   - Burst of activity then long gaps = distracted
   - Very uniform timing = possibly automated/scripted

### Fallback: Raw Session Files

If cclogviewer MCP is unavailable, read session files from the zip:
- `sessions/{id}-summary.json` → parse for duration, message count
- `sessions/{id}-logs.json` → scan for tool usage patterns, errors
- `sessions/{id}.jsonl` → raw transcript, last resort

If no session data exists at all, mark Process dimension as **N/A** and exclude it from the weighted average (redistribute its 15% weight proportionally across the other 4 dimensions).

---

## Phase 3.5: Claude Code Usage Analysis & Flag Detection

After analyzing session data via MCP, assess how the student used Claude Code and flag any critical issues. This phase produces **flags** that appear in the feedback report.

### Flag Severity Levels

- **`CRITICAL`** — Strong fraud signal or fundamental misuse. Requires instructor attention.
- **`WARNING`** — Concerning pattern worth investigating. May have innocent explanation.
- **`INFO`** — Minor observation worth noting for the student's improvement.

### 1. False Usage / Fraud Detection

Use MCP data to identify submissions that may not represent genuine learning:

| Signal | Detection Method | Severity |
|--------|-----------------|----------|
| **Speed fraud** | `get_session_summary` → total duration < 5 minutes for any module | `CRITICAL` |
| **Pre-scripted work** | `get_session_summary` → < 5 user messages but complete artifacts with 100+ lines | `CRITICAL` |
| **No tool trace** | `get_tool_usage_stats` → zero Write/Edit calls but artifacts exist in submission | `CRITICAL` |
| **Verbatim copying** | Artifact content matches SCRIPT.md examples word-for-word | `CRITICAL` |
| **Rushed completion** | `get_session_summary` → duration < 25% of module's expected time | `WARNING` |
| **Zero iteration** | `get_tool_usage_stats` → zero Edit calls, only Write calls for artifacts | `WARNING` |
| **Minimal interaction** | `get_session_summary` → < 5 user messages but many tool calls | `WARNING` |
| **Zero errors** | `get_session_errors` → 0 errors on tasks that normally produce errors | `WARNING` |
| **Session gaps** | `get_session_timeline` → gaps > 30 minutes between actions | `INFO` |
| **Limited tools** | `get_tool_usage_stats` → only 1-2 tool types used across session | `INFO` |

### 2. Prompting Anti-Pattern Detection

Analyze session logs for signs of poor Claude Code usage:

**Delegation without learning**
- `search_logs(query="just do it")` or `search_logs(query="do it for me")` or `search_logs(query="do everything")`
- Very few user messages relative to assistant messages (student not engaging)
- Severity: `WARNING`

**No verification of output**
- `get_session_timeline` → Write/Edit calls never followed by Read or Bash (student doesn't check results)
- No test execution after code generation
- Severity: `INFO`

**Error ignorance**
- `get_session_errors` + `get_session_timeline` → errors occur but next action is unrelated (student ignores errors)
- Same error appears 3+ times without a different approach
- Severity: `WARNING`

**No plan mode usage**
- `search_logs(query="plan")` → no results for modules where plan mode was taught (Module 1+)
- `get_tool_usage_stats` → no plan-related tool calls in complex tasks
- Severity: `INFO`

**Hint dependency**
- `search_logs(query="hint")` → excessive hint requests (> 5 per module)
- Hints requested without attempting tasks first (hint call immediately after task presentation in timeline)
- Severity: `INFO`

**Prompt recycling**
- `search_logs` → same generic prompt text appears multiple times without adaptation
- Severity: `INFO`

### 3. Learning Effectiveness Issues

Patterns that suggest the student isn't learning effectively:

**No exploration**
- `get_tool_usage_stats` → no Read, Grep, or Glob calls (student never explored the codebase)
- Only Bash and Write used throughout
- Severity: `INFO`

**No iteration**
- `get_tool_usage_stats` → artifacts written exactly once (Write) with no subsequent Edit calls
- Timeline shows linear progression with no back-and-forth
- Severity: `WARNING`

**Checkpoint rushing**
- `get_session_timeline` → manual/conceptual tasks (checkpoints) completed in < 30 seconds each
- Student confirms understanding without actual engagement
- Severity: `WARNING`

### Flags Output Section

Add this section to the feedback report between **Process** and **Initiative**:

```
── Flags ────────────────────────────────────────

 [CRITICAL] {description}
            Evidence: {specific MCP data that triggered this flag}

 [WARNING]  {description}
            Evidence: {specific MCP data}

 [INFO]     {description}
            Suggestion: {what the student should do differently}

 {Or: "No flags detected."}
```

Every flag MUST include:
1. The severity level
2. A clear, specific description of what was detected
3. The evidence (which MCP tool returned what data)
4. For INFO flags: a constructive suggestion

---

## Phase 4: Scoring

### 5 Dimensions (1–5 each)

| Dimension | Weight | Source |
|-----------|--------|--------|
| **Completeness** | 20% | Artifacts present vs verification blocks |
| **Quality** | 30% | Artifact analysis against SCRIPT.md expectations |
| **Understanding** | 20% | Learning objectives evidence in artifacts |
| **Process** | 15% | Session analysis via MCP |
| **Initiative** | 15% | Extra work beyond minimum requirements |

### Scoring Scale Per Dimension

**5 — Excellent**: Exceeds all expectations. Work is thorough, specific, and demonstrates mastery.

**4 — Good**: Meets all expectations with minor gaps. Work is solid and project-specific.

**3 — Satisfactory**: Meets minimum requirements. Some generic areas or missing depth.

**2 — Needs Improvement**: Multiple gaps. Work is mostly boilerplate or superficial.

**1 — Incomplete**: Critical artifacts missing or placeholder-only content.

### Overall Grade Calculation

```
weighted_score = (completeness × 0.20) + (quality × 0.30) + (understanding × 0.20) + (process × 0.15) + (initiative × 0.15)
```

If Process is N/A (no session data):
```
weighted_score = (completeness × 0.235) + (quality × 0.353) + (understanding × 0.235) + (initiative × 0.176)
```

### Grade Map

| Score Range | Grade |
|-------------|-------|
| 4.5 – 5.0 | Excellent |
| 3.5 – 4.4 | Good |
| 2.5 – 3.4 | Satisfactory |
| 1.5 – 2.4 | Needs Improvement |
| 1.0 – 1.4 | Incomplete |

---

## Phase 5: Feedback Generation

### Report Format

Output the following structured report. Be specific — cite actual content from the student's artifacts as evidence. Do not be vague.

```
══════════════════════════════════════════════════
 REVIEW: Module {N} — {Module Title}
 Student: {name} ({role}) | Submitted: {date}
══════════════════════════════════════════════════

 OVERALL: {Grade} ({weighted_score}/5.0)

── Completeness ({score}/5) ─────────────────────

 For each artifact required by verification blocks:
 [PRESENT] {artifact name} ({metadata: lines, chars, count})
 [MISSING] {artifact name} — {what was expected}

 Commentary:
 {Explain what's complete and what's missing.
  Reference specific verification criteria from SCRIPT.md.}

── Quality ({score}/5) ──────────────────────────

 For each artifact present, provide specific analysis:

 {Artifact Name}:
   Substance: {Is content substantive or placeholder?} [{GOOD|WEAK|POOR}]
   Specificity: {Is content project-specific?} [{GOOD|WEAK|POOR}]
   Structure: {Does it follow taught patterns?} [{GOOD|WEAK|POOR}]
   Issues: {List specific problems found}

 {Repeat for each artifact}

── Understanding ({score}/5) ────────────────────

 Learning objectives from SCRIPT.md:
 For each objective:
   [{MET|PARTIAL|NOT MET}] {objective text}
   Evidence: {quote or reference from student's artifacts}

 Positive signals:
   - {specific example showing genuine comprehension}

 Concerns:
   - {specific example of copied or generic content}

── Process ({score}/5) ──────────────────────────

 Sessions: {count} | Duration: {total} min | Messages: {total} | Errors: {count}

 Iteration: {Did they revise? How many edits per artifact?}
 Pace: {Steady / Rushed / Thorough — with evidence}
 Tool usage: {Diverse / Limited — list key tools used}
 Error recovery: {How did they handle mistakes?}
 Engagement: {Active learning or mechanical completion?}

 [If N/A: "No session data available — this dimension is excluded from scoring."]

── Flags ────────────────────────────────────────

 {For each detected flag from Phase 3.5:}
 [{CRITICAL|WARNING|INFO}] {description}
   Evidence: {MCP tool and data that triggered this flag}
   {For INFO: Suggestion: {constructive advice}}

 {Or: "No flags detected."}

── Initiative ({score}/5) ───────────────────────

 Minimum required (from verification blocks): {count/description}
 Actually submitted: {count/description}

 {List any extra work: additional artifacts, optional sections,
  creative solutions, deeper implementations}

 {Or note: "Met minimum requirements only. No extra work observed."}

══════════════════════════════════════════════════
 FEEDBACK
══════════════════════════════════════════════════

 What you did well:
 1. {Specific positive with evidence from artifacts}
 2. {Specific positive with evidence from artifacts}
 3. {Specific positive (if applicable)}

 What to improve:
 1. {Specific, actionable improvement with example of what "better" looks like}
 2. {Specific, actionable improvement with example}
 3. {Specific, actionable improvement with example}

 Advice for next module:
   {Based on this review, what should the student focus on
    in the next module? Reference specific weaknesses to address
    and strengths to build on.}

══════════════════════════════════════════════════
```

### Feedback Principles

1. **Be specific** — Never say "good job" without citing what was good. Never say "needs improvement" without saying exactly what and how.

2. **Be critical** — This is an assessment, not encouragement. Point out genuine weaknesses. Students learn from honest feedback, not praise.

3. **Be actionable** — Every criticism must come with a concrete suggestion for improvement. Don't just say "CLAUDE.md is too generic" — say "Your CLAUDE.md lists 'JavaScript' as tech stack but doesn't mention which framework, package manager, or testing tools you use. Add specific versions and tools."

4. **Use evidence** — Quote or reference specific lines from the student's artifacts. Don't make abstract claims.

5. **Acknowledge effort** — If session data shows genuine iteration and experimentation, acknowledge it even if the final artifacts aren't perfect.

6. **Grade honestly** — A "Satisfactory" (3/5) is not a failure. Most students doing minimum required work should land here. Reserve 4-5 for genuinely good work. Don't inflate grades.

### Machine-Readable Summary Line

After the full report, output a single summary line for batch aggregation:

```
REVIEW_RESULT|{student_name}|{module_number}|{grade}|{weighted_score}|{flags_summary}
```

- `flags_summary` is a comma-separated list of flag keywords (e.g., `RUSHED,NO_ITERATION`) or empty if no flags
- Examples:
  ```
  REVIEW_RESULT|Jane Doe|1|Good|3.8|
  REVIEW_RESULT|John Smith|1|Satisfactory|2.9|RUSHED
  REVIEW_RESULT|Anonymous|1|Incomplete|1.2|FRAUD,NO_ITERATION
  ```

---

## Phase 6: Report Persistence

Each reviewer agent is responsible for writing its own reports directly to disk. The orchestrating skill passes an `OUTPUT DIRECTORY` (`STUDENT_DIR`) to each agent — the agent creates the folder and writes all files there.

### File Output Structure

Each agent writes to its dedicated directory:

```
{submissions_dir}/reviews/{zip-basename-without-ext}/
├── instructor-report.md     ← Full review: all dimensions, flags, MCP evidence (teacher only)
├── instructor-report.pdf    ← PDF conversion
├── student-feedback.md      ← Constructive student-facing version (no fraud flags)
└── student-feedback.pdf     ← PDF conversion
```

### Agent Responsibilities

The agent must (in order):
1. `mkdir -p {STUDENT_DIR}`
2. Write `instructor-report.md` using the Write tool (full review with all evidence)
3. Write `student-feedback.md` using the Write tool (filtered student-facing version)
4. Generate PDFs via Bash if pandoc+weasyprint are available:
   ```bash
   pandoc "{STUDENT_DIR}/instructor-report.md" -o "{STUDENT_DIR}/instructor-report.pdf" --pdf-engine=weasyprint
   pandoc "{STUDENT_DIR}/student-feedback.md" -o "{STUDENT_DIR}/student-feedback.pdf" --pdf-engine=weasyprint
   ```
5. If pandoc/weasyprint unavailable, skip PDFs silently — .md files are the minimum deliverable
6. Output the `REVIEW_RESULT|...` summary line as the last line of its output

### Batch Summary File

In batch mode, after all agents complete, write `{submissions_dir}/reviews/batch-summary.md`:

```markdown
# Batch Review Summary

**Date**: {current date}
**Submissions reviewed**: {N}

## Results

| Student | Module | Grade | Score | Flags |
|---------|--------|-------|-------|-------|
| {name}  | {N}    | {grade} | {score}/5.0 | {flags} |
| ...     | ...    | ...   | ...   | ...   |

## Distribution

| Grade | Count |
|-------|-------|
| Excellent | {N} |
| Good | {N} |
| Satisfactory | {N} |
| Needs Improvement | {N} |
| Incomplete | {N} |

## Flagged Submissions

{List submissions with CRITICAL or WARNING flags for instructor attention}
```

### Student Feedback Content Rules

The student-facing report must NEVER contain:
- Fraud/suspicion language: "CRITICAL", "WARNING", "fraud", "suspicious", "cheating", "pre-scripted"
- Raw MCP tool names, session IDs, or tool usage statistics
- References to session logs, timeline data, or error counts
- Anything implying the student is being monitored for dishonesty
- Weight percentages for dimensions (just show scores)

INFO-level observations should be reframed constructively:
- Instead of: "Limited tool diversity (only Bash and Write used)"
- Write: "Try exploring Claude Code's Read and Grep tools to understand existing code before writing — it helps produce better, more integrated solutions."

---

## Edge Cases

### No Session Data
- Mark Process as "N/A"
- Redistribute weight: Completeness 23.5%, Quality 35.3%, Understanding 23.5%, Initiative 17.6%
- Add note: "Session data was not available for this submission. The Process dimension is excluded from scoring."

### Partial Submission
- Score Completeness proportionally (e.g., 2 of 4 artifacts = 2-3/5)
- Still evaluate quality of what IS present
- Note in feedback what was missing and why it matters

### Missing SCRIPT.md
- Cannot build dynamic rubric — report error (handled in SKILL.md)
- This should not happen in normal operation

### Cross-Module Artifacts
- Later modules build on earlier ones (e.g., Module 3 includes updated CLAUDE.md from Module 1)
- Evaluate cumulative quality — if CLAUDE.md was weak in Module 1 and still weak in Module 3, note it
- But focus scoring on the new artifacts specific to this module

### Very Short Sessions
- If total session time is under 10 minutes for any module, flag as suspicious
- May indicate pre-prepared work pasted in, or student did work outside Claude Code
- Don't automatically penalize — note the observation and let the instructor interpret

### Manifest Reports Validation Failed
- If `manifest.validation.passed` is `false`, note this prominently
- The student submitted without passing validation — review should reflect this in Completeness score
- Check which specific tasks failed: `manifest.validation.tasks`
