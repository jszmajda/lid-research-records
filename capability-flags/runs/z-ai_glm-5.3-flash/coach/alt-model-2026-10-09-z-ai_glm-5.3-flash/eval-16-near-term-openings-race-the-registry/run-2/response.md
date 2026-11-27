# LID Coach — Visit Planner

## 1. Executive summary

**Posture:** Bootstrapping — a clean design layer, with the arrow stopped at EARS.

**Scorecard**
- ✓ HLD discipline — architecture and rationale only; no implementation detail bleeding upstream
- ✓ LLD granularity — one LLD per intent component (intake, fulfillment), right-sized, no lumps
- ✓ Tenet quality — `## Tenets` present; all four are real tie-breakers with defensible opposites
- ✓ Linkage hygiene — 15 spec IDs, all unique, grep-anchored to their leaf LLDs (`INTAKE-*`, `FILL-*`)
- ⚠ Configuration — the instruction file declares a mode but carries no LID directive block
- ✗ Arrow completeness — Tests and Code phases don't exist yet; the arrow ends at specs

**Headline:** The design layer is genuinely well-shaped — HLD, tenets, two leaf LLDs with decision tables, and clean spec linkage — and the fastest wins are reconciling the instruction file and walking the arrow's remaining phases (tests, then code) for the intent you've already specified.

## 2. Findings inventory

**Findings (6 total · 3 high · 2 medium · 1 low)**

- **F1 (high):** `CLAUDE.md` has a `## LID` block with `Mode: Full` but no LID directives — the file never names linked-intent-dev or instructs future sessions to consult the workflow for code changes, so an agent landing here won't run the six-phase loop · *modes are declared, not inferred* — a mode nobody reads is a default; run `/update-lid` to reconcile
- **F2 (high):** Every phase below EARS is missing — no tests, no code anywhere in the repo, so all 15 behavioral specs are unverified intent · *canonical arrow shape* — a phase gap this total is fine while bootstrapping, but tests-before-code only pays off if the tests are actually the first consumer of the design
- **F3 (high):** The ≤36-hour path lets any eligible signed-in account claim an opening via checkout (FILL-004) *before* the matcher offers it by `enteredAt` — under that condition an earlier asker can be passed by a later claimer, which works directly against the HLD tenet **"First asked, first served,"** and no Decisions row records the exception or the tenet traded against · *tenet cascade* — name the trade in `fulfillment-design.md`'s Decisions table, or the next session may "fix" the checkout path to restore FIFO and break the fast-refill goal
- **F4 (medium):** The 36-hour threshold and 20-minute scan window are load-bearing constants appearing only in prose and specs; a cold reader holding the design tree would still ask *why these numbers* and find nothing · *decision capture* — one Decisions & Alternatives row each in `fulfillment-design.md` would close this
- **F5 (medium):** The intake Decisions table accepts "Keys require expiry state" as the cost of client idempotency keys, but no spec anywhere specifies key expiry behavior — the accepted cost is named, the obligation isn't · *LLDs close enough of the solution space* — either add an INTAKE spec for expiry or a row noting it's deferred
- **F6 (low):** Specs use `[x]` checkboxes with no legend anywhere; a cold reader can't tell whether the mark means written, implemented, or verified · *docs carry current intent, written to be read cold* — one line in the spec files (or the instruction file) fixes this

## 3. What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, and all four files under `docs/intent/` (2 LLDs, 2 spec files)
- Enumerated: 2 LLDs, 2 spec files, 15 specs (7 INTAKE, 8 FILL); all ID prefixes resolve to their leaf LLDs
- Cold-read pass performed over every LID doc; decisions-table sweep over all 8 rows
- No code or tests exist to sample; no `docs/arrows/` overlay is installed

## 4. Capability-flag note

No flags apply — the capability-flags register lists no flagged configurations.

## 5. Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---
*Defaults taken for this non-interactive run: reviewed in the project's declared Full mode (no scope section exists, and none is needed for Full); no sampling of code/tests was required since none exist; no files were edited — the coach's advisory posture leaves all fixes to you (F1 via `/update-lid`, structural enumeration via `/arrow-maintenance` when you install the overlay).*