# LID Coach — printfarm

## 1. Executive summary

**Posture:** Bootstrapping — the design arrow is real and clean; the implementation side is absent, and a few decisions need capturing.

**Scorecard**
- ✓ Linkage hygiene — prefixes, IDs, and `prefix:` frontmatter all line up; no collisions, no orphans
- ✗ Arrow completeness — the arrow stops at EARS: no tests, no code, but every spec claims `[x]`
- ⚠ Cascade & tenet coherence — the queue/registry seam and the "promise" tenet carry unrecorded trades
- ⚠ HLD discipline — clean of implementation detail, but several Full-mode sections are missing
- ✓ Mutation hygiene — no changelog residue, no obsolete markers, no `[inferred]` backlog
- ✓ Mode fit — Full mode on a two-node design is proportionate

**The design layer is in good shape; the fastest wins are making the spec status markers tell the truth and capturing the durability and priority decisions that currently live only as prose.**

## 2. Findings (14 total · 6 high · 6 medium · 2 low)

- **F1 (high):** all 8 specs are marked `[x]` (= "code and tests exist") in a repo with zero source files and zero tests · *coherence is adjacency* — each arrow level should agree with the next
- **F2 (high):** the arrow has no Tests and no Code phase; no doc anywhere states the project's implementation status, so a cold reader cannot tell "designed" from "shipped" · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code
- **F3 (high):** the HLD is missing Full-mode sections: Target Users, Key Design Decisions, Success Metrics, System Design (an `Architecture` stub stands in) · *HLD is architecture and rationale* — it carries the project's *why*
- **F4 (high):** the HLD promises "a small web UI" and QUEUE-005 depends on a "queue view", but no design node owns any UI — the tree doesn't cover a surface the HLD sells · *effective intent-tree alignment* — LLD behaviors with no node are unnamed intent
- **F5 (high):** the durability choice (queue held entirely in process memory; accepted-but-undispatched jobs vanish on restart) sits in prose with no Decisions row, and it works against the tenet "a submitted job is a promise" under the power blip the LLD itself names · *docs carry current intent* + *tenet cascade* — decide which tenet wins when they conflict
- **F6 (high):** ~7 LLD behaviors have no spec at all — staff/member priority classes and FIFO, the acceptance gate (target class has a registered printer), content-hash storage, base32 slug IDs and 90-day recycling, printer *registration*, the heartbeat interval/poll loop, job loss on restart · *effective intent-tree alignment* — no spec means no test and silent drift
- **F7 (medium):** two pollers over the same printers — the queue polls for each printer's current job at startup (QUEUE-004) while the registry derives state from heartbeats; no doc says who is authoritative for printer state · *intent attaches at the lowest node that dominates it*
- **F8 (medium):** the registry is internally ambiguous — the table has a `state` column yet "state is derived from heartbeats", and REG-003 says "stop heartbeats to it" while the architecture says the registry polls the printer · *semantic legibility as cheap linkage* — names should echo the design
- **F9 (medium):** tenet 2's "no silent reordering" is a triggered rule that duplicates QUEUE-005, and it leaves a hole — a job silently returning to the head of the queue after a dispatch failure (QUEUE-003) is never explained to the member · *tenets capture forward-looking preference* — a lean, not a spec
- **F10 (medium):** the HLD goal "fair access to the popular printer classes" has no mechanism anywhere, and the FIFO decision's accepted cost (one long job holds a class for hours) trades that goal with no record of which was given up · *tenet cascade*
- **F11 (medium):** cross-file concepts used without parenthetical scope — "the registry", "printer class", "queue view" · *scope disambiguation* — a spec found by grep must still be unambiguous
- **F12 (medium):** the two-class priority model (staff ahead of member) has no Decisions row; a cold reader would question it and want to reverse it · *docs carry current intent* — decisions live in the table, not in a one-line aside
- **F13 (medium):** the instruction file is minimal — `Consult the linked-intent-dev skill.` with no arrow-shape line, terminology, memory-vs-intent rule, or EARS/decision-docs navigation rows · *modes are declared, not inferred* — configuration lives in `/update-lid`
- **F14 (low):** the three tenets are unordered, yet tenet 1 and tenet 3 conflict under a power blip; ordering should say which wins · *tenets capture forward-looking preference* — order them so conflict resolves by position
- **F15 (low):** unstated details a cold reader trips on — how long uploaded G-code is retained after a print, and where decision docs are meant to live · *docs carry current intent, written to be read cold*

*(Also noted, not a finding: job-queue currently owns upload, ordering, and dispatch in one node — if ingest grows, it's a promotion candidate per *one LLD per intent component*, but at today's size it reads as one coherent thing.)*

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 2 design nodes, 2 spec files, 8 spec IDs (all unique, all prefix-matched to their leaf's `prefix:` frontmatter), 0 arrow segments (no `docs/arrows/` overlay present)
- Sampled: the entire repository (6 tracked files, 1 commit) — 0 source files, 0 test files, 0 `@spec` references
- Cross-checked: each HLD tenet and goal against each LLD mechanism; each LLD behavior against the spec set; each spec's ID prefix against its owning leaf

## 4. Out-of-scope note

Omitted — Full mode; the whole repository was in scope.

## 5. Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into — F1/F2 are quick marker-and-status fixes, F5/F12 are decisions to capture, and F7/F8 are the queue↔registry seam to settle before any code gets written.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*(Note: the coach is advisory by design, so I haven't changed any files. F13 and F2 are configuration-level and best applied with `/update-lid`; the structural items F6/F7 can be enumerated precisely with `/arrow-maintenance`.)*