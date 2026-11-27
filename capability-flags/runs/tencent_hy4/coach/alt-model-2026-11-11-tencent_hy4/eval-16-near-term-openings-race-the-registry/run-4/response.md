**LID Coach review — Visit Planner**

**1. Executive summary**

**Posture:** *Healthy, well-linked design layer — with a live tenet conflict and a configuration gap to tighten.*

**Scorecard**
- ✓ Linkage & granularity — clean `HLD → 2 LLDs → 2 spec files` tree, one LLD per component, unique zero-padded namespaced IDs
- ✓ Scope disambiguation — the `>36h` and `≤36h` paths are split inside the WHEN clauses rather than left universal
- ✓ HLD discipline — architecture and rationale only; no schemas, signatures, or pseudocode bleeding upstream
- ⚠ Tenet cascade — "First asked, first served" is set aside by the near-term public checkout window, with no exception recorded
- ⚠ Decision capture — the 36-hour split / fairness trade sits in design prose with no Decisions & Alternatives row
- ⚠ Configuration — the `## LID` block carries Mode/Version but no directive block

**Headline:** What's working is the arrow itself — one LLD per intent component, EARS-clean specs, disciplined scope, real tie-breaker tenets, and Decisions tables on both LLDs; the single most valuable next step is to record the near-term-checkout fairness trade as a Decisions row (which also settles the tenet conflict), then reconcile the instruction file with `/update-lid`.

**2. Findings (8 total · 3 high · 3 medium · 2 low)**
- **F1 (high):** `CLAUDE.md` has a `## LID` block with `- Mode: Full` and `- Version: 1.4.0` but no `linked-intent-dev` directive block — consider `/update-lid` to reconcile it · *modes are declared, not inferred* — the `## LID` block is the visible foundation the rest of LID keys off, so a half-present one leaves the directive set invisible
- **F2 (high):** for openings ≤36h away, FILL-003/FILL-004 let any eligible signed-in account check out during the 20-minute searchable window before the earliest interest entry is offered — the exact condition under which "First asked, first served" ("an earlier request is never passed by one made after it") is set aside, with no exception named · *tenet cascade* — leaf mechanisms should lean the way the HLD's tenets say, or record the trade they're making
- **F3 (high):** the 36-hour split, 20-minute scan, and public checkout window are a live choice a cold reader would question (it appears to trade fairness for refill speed), yet they survive only in `fulfillment-design.md` §Design prose with no Decisions & Alternatives row naming the rejected alternative or accepted cost · *docs carry current intent* — a decision a reader would still question needs its reasoning on the page, not just in the narrative
- **F4 (medium):** `intake-design.md` §Context ends with "without turning free-form notes into scheduling rules" — a rejected alternative parked as a defensive aside in body prose (a conversational fossil) when the Decisions table already holds the "Free-text matching" row; consider trimming the aside and leaving the row · *docs carry current intent, written to be read cold* — docs should stand on their own with no residue from the conversation that produced them
- **F5 (medium):** the HLD lists four tenets as an unordered list, with "First asked, first served" ahead of "Clinical fit precedes utilization" though the latter claims precedence, and the FIFO tenet's elaboration reads as a triggered *when X, do Y* rule — consider ordering them and restating the lean · *tenets capture forward-looking preference* — tenets are tie-breakers; order them when they can conflict, and keep them as leans rather than specs
- **F6 (medium):** all 15 specs are marked `[x]`, yet the repo carries no test or code files and no `@spec` citations anywhere — consider clarifying what `[x]` asserts and whether the Tests→Code phases are still ahead · *tests carry @spec annotations* — each test cites the spec it protects; without them the arrow can't be walked past EARS
- **F7 (low):** `fulfillment-design.md` §Design sets a "two-hour offer" but no spec pins that duration (FILL-002 covers expiry→rematch only) — consider a spec for it · *effective intent-tree alignment* — LLD behaviors with no spec are unnamed intent with nothing to test against
- **F8 (low):** INTAKE-006 says "create a newly timed entry" while the LLD says "creates a new one" — a cold reader can't tell whether `enteredAt` is re-derived; consider echoing the LLD's wording · *coherence is adjacency* — each level should agree with the one next to it

**3. What was audited**
- Read fully (6 files): `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/intake/intake-design.md`, `intake-specs.md`, `docs/intent/fulfillment/fulfillment-design.md`, `fulfillment-specs.md`. No `docs/arrows/index.yaml` (overlay absent), no code files, no test files, no `@spec` annotations anywhere in the repo — so tests-first history, test `@spec` linkage, and code entry-point placement could not be observed; the review is anchored on the doc layer.
- Enumerated: 2 LLDs, 2 spec files, 15 EARS specs (7 `INTAKE-*`, 8 `FILL-*`, all `[x]`), 2 Decisions & Alternatives tables (4 rows each), 4 HLD tenets, 3 goals, 2 components; 1 git commit (`309c8fc fixture`), so no commit-history evidence of tests leading code.
- Ran a cold-read pass across all 5 LID docs and a Decisions-table sweep against the HLD and both LLDs; sampled by judgment (small project), with 0 arrow paths available to sample end-to-end.
- **Non-interactive defaults taken:** proceeded with a **full review** — the dispatch's *default Full mode* for a LID-shaped project whose instruction file lacks directives, which also matches the declared `- Mode: Full` (no pause-for-repair default was needed, since the overlay is absent); sampled **by judgment** because `references/sampling.md`'s thresholds (more than 15 LLDs / 200 `@spec` files / an overlay) aren't met; rendered the report **inline** and **persisted nothing / edited no project file** — the skill's "render inline; do not persist unless asked" default plus its advisory no-edit posture. The two invitations below are left open for an interactive turn.

**4. Offer to help**

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.