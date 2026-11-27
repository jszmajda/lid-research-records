# /lid-coach — printfarm

## Executive summary

**Posture:** *Healthy design layer, with a durability conflict and an arrow that stops at EARS.*

**Scorecard**
- ✓ Configuration & mode — directives and a `Full` mode marker are present, and Full fits a repo that is entirely LID docs
- ✓ Design layer — two clean leaf LLDs, disciplined Decisions tables, no history residue; every doc reads cold
- ✓ Linkage hygiene — 8 unique, grep-friendly, leaf-namespaced IDs (`QUEUE` / `REG`) backed by `prefix:` frontmatter
- ⚠ Arrow completeness — no test or code files, yet all 8 specs are marked `[x]`
- ⚠ Decision capture — the in-memory durability choice has no Decisions & Alternatives row
- ⚠ Tenets — a durability mechanism runs against two of the HLD's tenets/goals, and the tenets are unordered and can conflict

**Headline:** The top half of the arrow is genuinely well-built — clean LLDs, honest Decisions tables, tidy spec IDs — and the fastest wins are recording the durability trade-off and an honest status-marker sweep.

## Findings (6 total · 3 high · 2 medium · 1 low)

- **F1 (high):** No test or code files exist anywhere (the Tests and Code phases are absent), yet all 8 specs carry `[x]` — "Implemented: code and tests exist" · *canonical arrow shape* (phases run HLD → LLDs → EARS → Tests → Code) / *coherence is adjacency* (each level agrees with the one next to it)
- **F2 (high):** The in-memory queue drops accepted-but-undispatched jobs on restart and asks members to resubmit, and the Context itself names unattended OS updates and power blips — working against the "upload and walk away" tenet and the "morning pickup, no member present" goal · *tenet cascade* (design nodes lean the way the HLD's tenets and goals say)
- **F3 (high):** The durability choice (queue held in memory and lost on restart, while the registry persists to SQLite) is one a cold reader would question, yet it lives only in Architecture prose with no Decisions & Alternatives row naming the rejected alternative and the accepted cost · *docs carry current intent* (docs state present intent; git keeps history)
- **F4 (medium):** LLD behaviors with no EARS spec — job-queue's staff/member priority classes and FIFO, "accept only if the class has a registered printer", the restart-resubmit path; printer-registry's printer registration and 15 s heartbeat interval · *effective intent-tree alignment* (spec IDs trace to LLDs, which trace to HLD concepts; unnamed intent drifts silently)
- **F5 (medium):** `## Tenets` holds three tenets in an unordered list that can conflict ("upload and walk away" vs "the service stays small"), with the design quietly favoring one; a couple read as goals/values or recorded decisions rather than one-line leans · *tenets capture forward-looking preference* (one-line tie-breakers for choices no spec anticipates, ordered so the higher wins)
- **F6 (low):** QUEUE-001 adds "state the limit" to the 64 MB rejection, a user-facing behavior the LLD's size-limit decision doesn't mention — a small rung mismatch · *coherence is adjacency* (a spec says neither more nor less than its design node)

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both `-design.md` and both `-specs.md` files (6 project files), plus the four lid-coach references and LID's `ears-syntax.md` (confirming `[x]` = "Implemented: code and tests exist").
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 8 EARS specs (5 `QUEUE`, 3 `REG`), 5 Decisions rows, 3 tenets, 2 goals, 0 test files, 0 code files, 0 `@spec` annotations, 0 `[inferred]` markers, 0 obsolete/deferred markers.
- Sampling: judgment-based — at 2 LLDs, 0 annotated files and no `docs/arrows/index.yaml`, the sampling threshold wasn't met, so every LID doc was read end-to-end, including a cold-read pass and a Decisions-table sweep.
- No arrow-maintenance overlay present; a single-commit fixture, so no git history was available for change-narration.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.