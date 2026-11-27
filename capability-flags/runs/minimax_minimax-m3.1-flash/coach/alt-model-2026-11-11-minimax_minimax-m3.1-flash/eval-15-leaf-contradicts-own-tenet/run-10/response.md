# Shelfwise — LID Coaching Report

**Posture:** Clean design layer, with configuration and linkage drift.

**Scorecard**
- ✓ Spec discipline — 13 specs, every one properly triggered EARS; unique, greppable IDs
- ✓ Mutation hygiene — no obsolete markers, changelog residue, or `[inferred]`; every doc reads cold
- ✓ Decision capture — 7 decision rows, each with alternatives and an accepted cost
- ⚠ Configuration — `## LID` block is present, but the directives block that starts the workflow is not
- ⚠ Tenet coherence — two of the four tenets are contradicted by the design they govern
- ⚠ Segment integrity — every spec is marked implemented, and a few design behaviors have no spec at all

**Headline:** The design spine is genuinely good — 13 crisp EARS specs, no residue, well-captured decisions — and the fastest wins are reconciling the configuration, correcting the spec status markers, and settling the sequence tenet against branch-first allocation.

---

**Findings (13 total · 4 high · 6 medium · 3 low)**

- **F1 (high):** the instruction file declares its mode but no LID directives block — `CLAUDE.md:6-8` has `## LID` (Mode: Full, Version: 1.4.0) and nothing else; no `linked-intent-dev` / "Linked-Intent Development" reference anywhere, so an agent landing here has no way to know the arrow exists · *modes are declared, not inferred — the mode you declared gates a workflow nothing tells anyone to run* → `/update-lid`
- **F2 (high):** the tenet "Waiting is honored in sequence" is contradicted by the segment it governs — `docs/high-level-design.md:13` says no one's wait is lengthened by a later patron, but `hold-allocation-design.md:11` allocates branch-first (scanning-branch holds beat an older county-wide hold), and `HOLDALLOC-003/004` codify it · *tenets capture forward-looking preference — a tie-breaker the design ignores stops guiding anything and becomes decoration* · no Decisions row names the tenet traded against, so the exception is invisible
- **F3 (high):** all 13 specs carry the `[x]` marker (implemented) but the repo contains no code and no tests — `git ls-files` shows only `CLAUDE.md` and four docs · *tests before code — the marker asserts code and tests exist; an agent grepping a spec will believe the behavior is realized and never write the test* → consider `[ ]` until code lands
- **F4 (high):** three design behaviors have no spec anywhere — hold cancellation (`hold-allocation-design.md:13` assumes a cancel path), the in-transit copy state (`HOLDALLOC-007` names it, nothing defines or enters it), and channel selection at signup (`pickup-notices-design.md:5`, which `PICKUP-002` depends on) · *effective intent-tree alignment — LLD behaviors with no specs are unnamed intent that drifts silently because there's nothing to test against*
- **F5 (medium):** LLD prose and its own EARS disagree on when a lapsed hold closes — `pickup-notices-design.md:11` says the hold closes and the copy re-runs allocation at lapse, while `PICKUP-004/005` put both at the moment staff scan the copy off the shelf · *coherence is adjacency — the seam where LLD and specs disagree is exactly where a reader fills in the gap, and here the two readings produce different hold-lifetime behavior*
- **F6 (medium):** neither LLD carries `parent:`/`prefix:` frontmatter — `HOLDALLOC-*` and `PICKUP-*` resolve to their leaves by eye, not by declaration · *effective intent-tree alignment — the leaf's prefix frontmatter is the authoritative bridge from an ID to its design doc*
- **F7 (medium):** the branch-first allocation rule — the most consequential choice in `hold-allocation` — has no row in Decisions & Alternatives (`hold-allocation-design.md:19-23` covers granularity, trigger, and cap only) · *decision capture — a cold reader would still question this choice and cannot reconstruct what was given up*
- **F8 (medium):** the tenet "Routine steps are automated" is contradicted by the morning pull list — `pickup-notices-design.md:11` and `PICKUP-004` make a routine per-expiry staff task, and the Expiry handling row acknowledges the Goal 1 cost but never names the tenet traded against · *tenet cascade — when a mechanism works against a tenet and no row records the exception, the exception is lost*
- **F9 (medium):** two of four tenets are not tie-breakers — "Staff attention goes to exceptions. Routine steps are automated." states a rule whose opposite nobody would choose, and "Hold history is not kept" restates `PICKUP-003` rather than leaning toward future choices · *tenets capture forward-looking preference — a platitude narrows nothing while giving false confidence the space was constrained*; the tenets are also unordered, though sequence and staff-attention can conflict
- **F10 (medium):** delivery and operations components live only in `pickup-notices-design.md` — the automated dialer (`:5`), the daily exceptions list (`:13`), the morning pull list (`:11`) — and never appear in the HLD's system view (`high-level-design.md:23-26`) · *intent attaches at the lowest node that dominates it — a mechanism that spans the component and the operating staff belongs in the shared parent's view*
- **F11 (low):** the HLD has no Non-Goals or Target Users section · *HLD is architecture and rationale — without a stated boundary, "no" is harder to say to surface growth*
- **F12 (low):** the states `allocated` and `in-transit` are used in the spec files (`HOLDALLOC-006`, `HOLDALLOC-007`) but defined only in LLD prose · *scope disambiguation — a spec found by grep out of context should carry enough context to be implemented plausibly*
- **F13 (low):** no arrow overlay is installed (`docs/arrows/` absent), so there's no index for structural audits · *coherence is adjacency* → `/arrow-maintenance` once code and tests exist

---

**What was audited**
- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files — all 6 tracked files, in full
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 13 specs (7 `HOLDALLOC-*`, 6 `PICKUP-*`), 7 decision rows, 0 decision docs, 0 `[inferred]` markers, 0 obsolete markers
- Code and tests: none present in the repository (0 source files, 0 test files, 0 `@spec` annotations) — there was nothing to sample for annotation placement or test-first evidence; git history is a single commit, so tests-before-code ordering could not be assessed
- Not present to audit: `docs/arrows/` overlay, `docs/decisions/`, `docs/lid/workflow.md`, any implementation
- Configuration signals: `## LID` mode marker present and well-formed (Full); `- Version: 1.4.0` matches the installed `linked-intent-dev` plugin version, so no version walk is owed; `## LID Scope` correctly absent in Full mode

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---

*Defaults taken (non-interactive run):* the skill's advisory posture was kept — the report is inline only and **no project files were changed**; configuration reconciliation (F1) is pointed at `/update-lid` and structural enumeration at `/arrow-maintenance` rather than applied; Full mode was taken as the review scope (it is also the declared mode), so no out-of-scope section appears; and the report was not persisted to disk.