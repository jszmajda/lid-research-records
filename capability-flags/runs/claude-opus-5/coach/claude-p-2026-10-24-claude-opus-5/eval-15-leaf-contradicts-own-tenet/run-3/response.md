# LID Coach — Shelfwise

## Executive summary

**Posture:** Design layer is in good shape; the arrow stops at EARS, and one tenet is quietly contradicted.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only, no schemas or signatures bleeding upstream
- ✓ Spec quality — all 13 specs are well-formed EARS with explicit triggers and no obsolete residue
- ✓ Decision capture (pickup notices) — four rows that each name the rejected option and the accepted cost
- ⚠ Tenet cascade — branch-preference allocation leans against *"waiting is honored in sequence"* with no exception on record
- ✗ Arrow completeness — no tests and no code exist, yet every spec is marked `[x]`
- ⚠ Configuration — `CLAUDE.md` carries the `## LID` block but no LID directives

**Headline:** Two components, two leaf designs, two spec files that trace cleanly to the HLD's Components list — the arrow's design half is genuinely walkable, and `pickup-notices` is close to exemplary on decision capture. The highest-value next step is reconciling the tenet-versus-allocation conflict, because it is the one place where a future session reading the leaf would implement something the HLD says not to.

## Findings (10 total · 4 high · 5 medium · 1 low)

- **F1 (high):** `HOLDALLOC-003`/`-004` prefer a newer same-branch hold over an older county-wide one, which lengthens the earlier patron's wait — the HLD tenet *"nobody's wait is lengthened by a patron who asked after them"* says otherwise, and no row records the trade · *tenets capture forward-looking preference* + *coherence is adjacency* (each arrow level agrees with the one above it)
- **F2 (high):** the branch-preference rule — the largest design choice in `hold-allocation` — has no Decisions & Alternatives row; its rationale ("keeps most copies off the courier van") lives in body prose with no rejected option or accepted cost · *docs carry current intent, written to be read cold* (a cold reader would still question this one)
- **F3 (high):** all 13 specs are status-marked `[x]`, but the repo contains no tests and no code — the Tests and Code phases of the arrow are absent · *canonical arrow shape* (HLD → LLDs → EARS → Tests → Code)
- **F4 (high):** `CLAUDE.md` has the `## LID` mode marker and version but no LID directive block, so a fresh session gets the mode without the methodology · *modes are declared, not inferred* — run `/update-lid` to reconcile
- **F5 (medium):** four tenets presented as an unordered list, though *"waiting is honored in sequence"* and *"staff attention goes to exceptions"* (via courier cost) can collide — exactly the collision F1 resolves without a tie-breaker · *tenets capture forward-looking preference*
- **F6 (medium):** cancelling a hold while its copy sits on a holds shelf is unspecified — `HOLDALLOC-007` covers only the in-transit case, and neither design says whether the shelved copy reallocates · *LLDs close enough of the solution space* (two agents would implement this differently)
- **F7 (medium):** Goal 1 measures "4 business hours" but nothing defines business hours across six branches with likely different schedules · *docs carry current intent, written to be read cold*
- **F8 (medium):** `PICKUP-001`'s 7-**calendar**-day window and `PICKUP-002`'s "last pickup date" don't say what happens when the last day falls on a branch closure · *scope disambiguation* (the rule reads universal but the six branches aren't uniform)
- **F9 (medium):** `PICKUP-006` fires on "fails to deliver," but failure is only illustrated for email and SMS — what counts as a failed automated dialer call is left open · *LLDs close enough of the solution space*
- **F10 (low):** neither spec file declares `prefix:` frontmatter, so the leaf-path boundary (`HOLDALLOC`, `PICKUP`) is inferred from the ID string rather than stated; the prefixes also don't echo their component names (`PICKUP` vs. `pickup-notices`) · *specs are grep-anchored linkage*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both leaf designs and both spec files under `docs/intent/`
- Enumerated: 2 LLDs, 2 spec files, 13 specs, 7 Decisions & Alternatives rows, 4 tenets, 2 goals
- Arrow-path sampled: both segments end-to-end (HLD Components → leaf design → specs → tests → code); the tests and code legs terminate with nothing to read
- Linkage metric: 0 `@spec` annotations across 0 code and test files — the project is currently docs-only
- Cold-read pass: all 5 LID docs, read without conversation context
- Overlay: `docs/arrows/` absent, so no `index.yaml` audit; `/arrow-maintenance` is not available here
- Dispatch note (non-interactive run): `CLAUDE.md` has no LID directives but the project is clearly LID-shaped, so I took the skill's default — a full review anchored on the existing artifacts, in Full mode, with the missing directives surfaced as F4

## Offer to help

Want me to walk through any of these in detail, focus on a theme or priority tier, or work through specific items together? F1 and F2 are the same choice seen from two angles and are probably the most productive place to start.

If you have broader questions about using LID on Shelfwise — when to write the first tests, how to handle a decision that spans both components, what changes as the project grows past two leaves — I can help with those too.