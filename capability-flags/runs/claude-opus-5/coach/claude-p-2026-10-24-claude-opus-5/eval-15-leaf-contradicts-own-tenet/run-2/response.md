**LID Coach — Shelfwise**

## Executive summary

**Posture:** Clean, well-written design layer — the arrow stops at EARS, and the HLD's tenets aren't fully cascading into the leaves.

**Scorecard**
- ✓ Mutation hygiene — docs read as current intent; no changelog residue, no `[obsolete]` markers, no `[inferred]` backlog
- ✓ LLD granularity — two leaves matching the two HLD components, no overlap, no straining
- ✓ HLD discipline — architecture and rationale only; no schemas, signatures, or pseudocode
- ⚠ Configuration — the `## LID` block declares mode and version but the instruction file never names LID itself
- ✗ Arrow completeness — Tests and Code phases are absent while every spec is marked complete
- ⚠ Tenet cascade — allocation's branch-first rule and the no-history tenet both pull against stated tenets/goals

**Headline:** The design layer is genuinely good — specs are crisp EARS, IDs are stable and grep-friendly, and every Decisions row names an accepted cost, which is rarer than it should be. The highest-value next moves are reconciling the instruction file and closing the two places where a leaf mechanism quietly leans against an HLD tenet.

## Findings (12 total · 4 high · 6 medium · 2 low)

- **F1 (high):** `CLAUDE.md` carries a `## LID` block (Mode: Full, Version: 1.4.0) but no LID directive block — nothing in the instruction file names linked-intent-dev, so a fresh session gets the mode without the method · *modes are declared, not inferred* — the foundation should be visible, not assumed → `/update-lid`
- **F2 (high):** Allocation prefers a later hold at the scanning branch over an older county-wide hold (`hold-allocation-design.md:11`, `HOLDALLOC-003`/`-004`), which lengthens the earlier patron's wait — the thing tenet 1 ("Waiting is honored in sequence… nobody's wait is lengthened by a patron who asked after them") says not to do, with no row recording the exception · *tenets capture forward-looking preference* + *keep the arrow coherent*
- **F3 (high):** Every spec in both files is marked `[x]`, but the repo has no tests and no code — the Tests and Code phases of the arrow don't exist here · *canonical arrow shape*; also *tests before code* — if implementation is still ahead, the markers are reading as done before anything exercises them
- **F4 (high):** Goal 1 (median check-in→notification time) and Goal 2 (under 10% expiry) can't be computed once `PICKUP-003`/`-005` delete the closed hold's record, as tenet 4 ("Hold history is not kept") requires — two success metrics and the mechanism that erases their inputs sit in the same docs with no reconciliation · *tenets capture forward-looking preference*
- **F5 (medium):** The branch-locality-beats-seniority choice is the most consequential decision in `hold-allocation`, and the Decisions & Alternatives table doesn't hold it — the courier-van rationale lives in a half-sentence of body prose (`hold-allocation-design.md:11`) · *docs carry current intent* — a cold reader would question or try to reverse this one
- **F6 (medium):** `hold-allocation-design.md:13` turns on "when a hold is cancelled," and `HOLDALLOC-007` handles the in-transit case, but no spec anywhere defines hold cancellation itself · *effective intent-tree alignment* — named behavior with no spec is unnamed intent
- **F7 (medium):** `PICKUP-006` fires when a ready notice "fails to deliver," and the design names bounced email and undeliverable SMS — but the third channel is an automated dialer, where no-answer and busy are neither clearly a failure nor clearly a delivery · *scope disambiguation*
- **F8 (medium):** Neither spec file declares a `prefix:`, so `HOLDALLOC-*` → `hold-allocation` and `PICKUP-*` → `pickup-notices` resolve only by resemblance of names · *specs are grep-anchored linkage*
- **F9 (medium):** The design marks a copy `allocated` "until picked up or expired," but `PICKUP-003`/`-005` only close and delete the hold — nothing specifies releasing the copy's `allocated` state, which `HOLDALLOC-006` then blocks forever · *coherence is adjacency*
- **F10 (medium):** The four tenets are an unordered list even though they can conflict (F2 and F4 are exactly that), and tenet 4's second sentence — "A closed hold's record is deleted" — is a triggered rule already living in `PICKUP-003`, not a lean · *tenets capture forward-looking preference*
- **F11 (low):** The HLD has no target users or non-goals section; the "Components" list stands in for key design decisions · *HLD is architecture and rationale*
- **F12 (low):** `pickup-notices-design.md:9,13` state absences inline ("No reminder follows", "does not trigger a fallback channel") that the Decisions table already owns · *docs carry current intent* — the rejected-alternative belongs in the row, not as an aside in body prose

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`
- Enumerated: 1 HLD, 2 leaf LLDs, 2 spec files, 13 specs (7 `HOLDALLOC`, 6 `PICKUP`), 7 Decisions & Alternatives rows
- Arrow-path traced: both segments from HLD component → LLD → specs; the Tests and Code phases had nothing to trace (F3)
- Linkage metric: 0 `@spec` annotations found — no code or test files exist in the repository
- Cold-read pass: all five LID docs re-read without conversation context; sources F7 and F12
- No arrow-maintenance overlay (`docs/arrows/`) is installed, so structural enumeration (orphans, adjacent-level drift) wasn't available; findings above come from direct reads
- Dispatch note: the instruction file is LID-shaped (populated HLD, two LLDs, two spec files) but lacks the directive block, so I ran the full review anchored on the artifacts and surfaced the configuration gap as F1 — the skill's stated default. Nothing required a question; this was a non-interactive run.

---

Want me to walk through the findings in detail, focus on a theme or priority (the tenet-cascade pair in F2/F4 is where I'd start), or work through specific items together? You can also pick a single finding to dig into.

If you have broader questions about using LID on Shelfwise — where the Tests and Code phases should come in, how to record a decision that trades one tenet against another, or what to do when goals need data a tenet forbids keeping — I can help with those too.