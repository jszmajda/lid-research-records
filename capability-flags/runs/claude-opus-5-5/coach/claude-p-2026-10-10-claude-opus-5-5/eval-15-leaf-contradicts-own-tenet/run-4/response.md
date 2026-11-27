# LID Coach — Shelfwise

## Executive summary

**Posture:** Well-formed design layer with one tenet conflict; the arrow stops at the specs.

**Scorecard**
- ✓ Design docs read cold — the HLD, both LLDs and both spec files stand on their own, with no history residue or chat-dependent phrasing
- ✓ Spec craft — 13 EARS specs with unique, stable, grep-friendly IDs, each prefix resolving to one LLD
- ✓ Decision capture, mostly — the Decisions tables name what was rejected and the cost accepted; one live decision has no row
- ⚠ Tenet cascade — one allocation mechanism leans against the first tenet with no recorded exception
- ⚠ Configuration — the mode marker is present, but the LID directive block is not
- ✗ Arrow completeness — no tests or code in the repository, yet every spec is checked `[x]`

**Headline:** The design tree is small, clear and well reasoned. The pickup-notices expiry row is a model of how to record a trade against a goal (it names Goal 1, the cost, and why it is accepted). The most valuable next step is to settle the branch-first allocation rule against "Waiting is honored in sequence", either by changing the mechanism or by recording the exception.

## Findings (9 total · 4 high · 4 medium · 1 low)

- **F1 (high):** Branch-first allocation works against the tenet "Waiting is honored in sequence". Under `hold-allocation-design.md` §Design and HOLDALLOC-003, a copy returned at a branch goes to the oldest hold *at that branch*, even when a patron at another branch asked earlier. That earlier patron's wait is lengthened by someone who asked after them, and no Decisions row records the exception. · *tenet cascade* — leaf designs should lean the way the HLD's tenets say, or record where they don't
- **F2 (high):** The branch-first choice itself has no Decisions row. The only reasoning is one prose clause ("keeps most copies off the courier van"), with no rejected alternative (strict county-wide order) and no accepted cost. · *decision capture* — a choice a cold reader would question needs what was given up and why on the page
- **F3 (high):** All 13 specs are marked `[x]`, but the repository holds no tests, no code and no `@spec` annotations. If the implementation lives elsewhere, the arrow isn't walkable from here; if it doesn't exist yet, the markers overstate. · *canonical arrow shape* — HLD → LLDs → EARS → tests → code, each phase present and linked
- **F4 (high):** `CLAUDE.md` has the `## LID` mode and version block but no linked-intent-dev directives, so future sessions get no workflow instructions. `/update-lid` reconciles this. · *modes are declared, not inferred* — the instruction file is where LID's foundation is made explicit
- **F5 (medium):** Hold cancellation has no spec. HOLDALLOC-007 presupposes it, but nothing says what cancelling does, including while the copy is on the holds shelf, or that the record is deleted. The "Hold history is not kept" tenet is therefore unspecified on that path. · *LLDs close enough of the solution space* — two agents reading the doc should land on compatible implementations
- **F6 (medium):** Arrival of an in-transit copy for a *live* hold is left open. Nothing says what the destination scan does or prints, or how it differs from an ordinary check-in event, given HOLDALLOC-006. The automated-dialer channel also has no failure definition (PICKUP-006 covers bounced email and undeliverable SMS only). · *LLDs close enough of the solution space*
- **F7 (medium):** The pickup-notices design and specs disagree on when a lapsed hold closes. The design reads as closing at window lapse; PICKUP-005 closes it, deletes the record and reallocates only when staff scan the copy off the shelf. · *coherence is adjacency* — each level of the arrow agrees with the one next to it
- **F8 (medium):** The four tenets are unordered, and they do collide: sequence against courier cost (F1), "hear once" against Goal 2. The courier-economy lean that drives F1 isn't a tenet at all. · *tenets capture forward-looking preference* — ordered tie-breakers for decisions no spec anticipated
- **F9 (low):** The HLD has no target users, non-goals or key design decisions sections. Non-goals would be the natural home for boundaries like "no reading history" and "no copy-level holds". · *HLD is architecture and rationale* — the HLD carries the project-level why

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both design docs and both spec files under `docs/intent/`.
- Enumerated: 2 LLDs, 2 spec files, 13 specs (HOLDALLOC-001–007, PICKUP-001–006), 7 Decisions rows.
- Code and tests: none in the repository, so there was nothing to sample and there are 0 `@spec` references.
- Arrow overlay: `docs/arrows/` is not installed, so no structural audit was available.
- Dispatch: the instruction file lacks LID directives but the project is LID-shaped, so I ran a full review in the declared Full mode. This was a non-interactive run and no user prompts were needed.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into — F1 and F2 are the pair I'd start with.

If you have broader questions about using LID for your project — multi-repo setups (relevant if the Shelfwise code lives elsewhere), where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.