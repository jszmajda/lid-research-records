**LID Coach — Shelfwise**

*Dispatch note:* `CLAUDE.md` declares `Mode: Full` but carries no linked-intent-dev directive block. Because the project is clearly LID-shaped (HLD, two LLDs, two spec files), I ran the full review, which is the skill's default for this case, and listed the gap as F3.

## Executive summary

**Posture:** *Clean, well-reasoned design layer; the arrow stops at the specs, and one core mechanism leans against the first tenet.*

**Scorecard**
- ✓ Design-tree shape — one HLD, two right-sized LLDs, and spec prefixes (`HOLDALLOC`, `PICKUP`) that map one-to-one onto them
- ✓ Mutation hygiene — every doc reads as current intent; no changelog residue, obsolete markers, or "as discussed" leftovers
- ✓ EARS quality — 13 well-formed specs with stable, greppable, collision-free IDs
- ⚠ Decision capture — most rows name the rejected option and accepted cost (the *Expiry handling* row even names the goal it trades against), but the most questionable choice has no row
- ⚠ LLD sufficiency — a few edges are left open around hold state, cancellation, and the dialer channel
- ✗ Arrow completeness — no tests or code in the repository, yet every spec is marked `[x]`

**Headline:** The design docs are in good shape: tight, cold-readable, and honest about what each decision costs. The most valuable next step is to reconcile hold allocation's same-branch-first rule with the "Waiting is honored in sequence" tenet, then settle what the `[x]` markers are claiming.

## Findings (10 total · 3 high · 5 medium · 2 low)

- **F1 (high):** Same-branch-first allocation works against the "Waiting is honored in sequence" tenet. Whenever the scanning branch has anyone waiting, a later local hold receives the copy ahead of an older hold at another branch, and on a popular title this can repeat indefinitely (`hold-allocation-design.md:11`, `HOLDALLOC-003`). · *tenets capture forward-looking preference* — leaf designs should lean the way the HLD's tie-breakers say, or record the exception
- **F2 (high):** All 13 specs are marked `[x]`, but the repository has no tests, no code, and no `@spec` annotations, so the arrow can't be walked past the spec layer. · *canonical arrow shape* — HLD → LLDs → EARS → Tests → Code, with each phase present or its absence made explicit
- **F3 (high):** `CLAUDE.md` has the `## LID` mode block but no linked-intent-dev directives, so future sessions get the mode without the workflow; `/update-lid` reconciles this. · *modes are declared, not inferred* — the instruction file is the foundation every session reads
- **F4 (medium):** The same-branch-first choice has no Decisions & Alternatives row. Its only rationale is one prose sentence about the courier van, with no rejected alternative and no mention of the tenet it trades against. This is separate from F1: a cold reader would question this choice first and can't reconstruct what was given up. · *docs carry current intent, written to be read cold* — a live decision keeps its reasoning on the page
- **F5 (medium):** Nothing distinguishes a hold that is still waiting from one that already has a copy allocated or in transit. Read literally, `HOLDALLOC-003` and `HOLDALLOC-004` hand a second returned copy to the same "oldest open hold". · *LLDs close enough of the solution space* — two agents reading the design should land on compatible implementations
- **F6 (medium):** Hold cancellation has no spec. The design covers only cancel-while-in-transit; cancelling a waiting hold or one already on the holds shelf, and deleting its record as the "Hold history is not kept" tenet implies, appear nowhere in `HOLDALLOC` or `PICKUP`. · *effective intent-tree alignment* — behaviour without a spec is unnamed intent with nothing to test against
- **F7 (medium):** The automated-dialer channel has no failed-delivery definition. The design and `PICKUP-006` name only bounced email and undeliverable SMS, leaving an unanswered call, voicemail, or busy line open. · *LLDs close enough of the solution space* — open edges get filled in by whoever implements next
- **F8 (medium):** The pickup-notices LLD and specs disagree on when a lapsed hold closes. The design reads as closing at lapse (`pickup-notices-design.md:11`); `PICKUP-005` closes it when staff scan the copy off the shelf. Whether a patron who arrives between lapse and the morning pull can still check out is undecided. · *coherence is adjacency* — each level agrees with the one next to it
- **F9 (low):** The four tenets are unordered, though they can pull against each other and against the goals (sequence vs. courier efficiency, "hear once" vs. Goal 2). "Staff attention goes to exceptions" also reads closer to a value than a tie-breaker. · *tenets capture forward-looking preference* — ordered leans for decisions no spec anticipated
- **F10 (low):** The *Failed delivery* row rejects auto-fallback because "patrons chose their channel deliberately", yet the chosen remedy is a staff phone call, which is a different channel for email and SMS patrons. The row would be stronger if it said why a human call is acceptable where an automated one isn't. · *docs carry current intent, written to be read cold* — a row should answer the question it raises

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, and both spec files (6 files, the whole repository).
- Enumerated: 1 HLD, 2 LLDs, 2 spec files, 13 EARS specs (7 `HOLDALLOC`, 6 `PICKUP`), 7 Decisions rows.
- Code and tests: none in the repository; 0 `@spec` references, so linkage, tests-first, and semantic-legibility dimensions could not be sampled.
- Arrow overlay: `docs/arrows/` is absent, so no structural audit input.
- Passes: dimension review, cold-read of every doc, Decisions-table sweep, and each leaf mechanism against the four tenets and two goals.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.