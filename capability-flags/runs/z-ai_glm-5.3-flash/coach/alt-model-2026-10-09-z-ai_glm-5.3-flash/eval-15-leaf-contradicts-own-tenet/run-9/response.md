# LID Coach — Shelfwise

**Posture line:** Solid bootstrapped foundation, docs clean and nearly residue-free.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no implementation detail has crept upstream
- ✓ Mutation hygiene — no change-narration, no `[obsolete]` markers, no history residue anywhere
- ✓ LLD granularity — two clean leaf LLDs, one per intent component, well-matched to HLD components
- ✓ Decision capture — Decisions & Alternatives rows are terse but self-sufficient; the expiry-vs-Goal-1 tension is recorded where a cold reader would ask
- ⚠ Configuration — the instruction file declares a mode but carries no linked-intent-dev directives
- ⚠ Arrow completeness — the arrow stops at EARS; no tests or code exist yet

**Headline sentence:** The design layer is genuinely well-built — clean HLD, well-scoped LLDs, disciplined spec format — and the highest-value steps are reconciling the instruction file and establishing the tests-first habit the moment implementation begins.

**Findings (4 total · 2 high · 0 medium · 2 low)**

- **F1 (high):** `CLAUDE.md` has a `## LID` block with `- Mode: Full` but no linked-intent-dev directive block — agents working here won't be pointed at the LID workflow · *modes are declared, not inferred* (declaration exists; the directives that make agents follow it don't). Run `/update-lid` to reconcile.
- **F2 (high):** Arrow phases Tests → Code are absent — no source files exist anywhere in the repo. That's fine for a design-stage project, but when implementation starts, establish tests-first (preload the API's use before code exists) so the arrow completes in canonical order rather than drifting into code-first · *tests before code*, *canonical arrow shape*.
- **F3 (low):** HOLDALLOC-002 hardcodes "15 open holds" while the Decisions table treats 15 as a chosen value — consider phrasing as "the configured hold cap" so a future cap change doesn't require spec mutation · *mutation, not accumulation*, *specs are grep-anchored linkage*.
- **F4 (low):** The HLD has Goals but no explicit Non-goals section — the privacy tenet ("hold history is not kept") is doing non-goal work; consider naming it as both so future sessions don't silently add retention features · *HLD is architecture and rationale*.

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`hold-allocation`, `pickup-notices`), both spec files
- Enumerated: 2 LLDs, 2 spec files, 13 EARS specs (7 + 6), 7 Decisions rows
- Sampled: full file inventory of the repo (7 files total — no code or test files exist to sample)
- Cross-checks: spec ID uniqueness, spec↔design traceability, cold-read pass over all five docs, decisions-table sweep

A note on cross-segment behavior: PICKUP-005 and HOLDALLOC-007 both re-run allocation for a copy. The allocation semantics correctly live in the `hold-allocation` leaf while `pickup-notices` only triggers them — that's intent attaching at the right node, worth preserving as the code layer grows.

No out-of-scope section: this is a Full-mode review, so everything was in scope.

---

Want me to walk through any finding in detail, focus on a theme or priority, or work through specific items together? You can pick a specific finding to dig into.

If you have broader questions about using LID for your project — where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

*Defaults taken this run: anchored the review in Full mode per the declared marker; skipped a capability-flag note (the flags reference lists no applicable configuration); applied the advisory no-edits posture throughout.*