# LID Coach — Visit Planner

**Posture:** Bootstrapping — arrow in place, docs healthy.

**Scorecard**
- ✓ LLD sufficiency — both leaf designs close the solution space (concrete timings, statuses, transaction boundaries)
- ✓ Mutation hygiene — docs carry current intent only; no history residue anywhere
- ✓ Tenet quality — four real tie-breakers with defensible opposites, not platitudes
- ✓ Linkage — 15 spec IDs, unique, grep-friendly, each tracing cleanly to its leaf design
- ⚠ Arrow completeness — the arrow currently stops at EARS: no tests or code exist yet
- ⚠ Configuration — the instruction file has a `## LID` block but no LID directive block

**Headline:** The design layer is genuinely well-written — HLD, two leaf LLDs, and 15 specs are coherent, current, and cold-readable. The fastest wins are adding the directive block to `CLAUDE.md` and starting the tests-first phase for the existing specs.

## Findings (4 total · 2 high · 1 medium · 1 low)

- **F1 (high):** `CLAUDE.md` has the `## LID` mode marker but no LID directive block telling sessions to consult `docs/` and walk the arrow — sessions must infer the workflow from file presence. Run `/update-lid` to reconcile. · *modes are declared, not inferred — the declared mode is only half visible*
- **F2 (high):** Arrow terminates at EARS — 15 behavioral specs have no tests and no code. That is normal for a project that hasn't started implementation, but the arrow's guarantees begin only when tests preload the specs; start tests-first before writing any code. · *tests before code — tests preload the use of the target system*
- **F3 (medium):** The ≤36-hour publish-and-claim path (FILL-003/004) lets any eligible signed-in account claim an opening *before* the queued matcher runs — this trades against your own tenet *first asked, first served*. The choice looks deliberate, but no Decisions & Alternatives row in `fulfillment-design.md` records it. Consider adding a row naming the tenet traded and why fast claim wins at short notice. · *tenet cascade — leaf mechanisms lean the way HLD tenets say, or record the exception*
- **F4 (low):** The Tenets list is unordered while *first asked, first served* and *clinical fit precedes utilization* can pull the same decision in opposite directions. Consider ordering them by precedence so a cold session knows which wins when they conflict. · *tenets capture forward-looking preference*

## What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both leaf design files, both spec files (the project's entire 6-file doc tree; 26 files total in the repo)
- Enumerated: 2 leaf LLDs, 2 spec files, 15 specs (7 INTAKE, 8 FILL), 8 Decisions & Alternatives rows, 4 tenets
- Cold-read pass: all 6 LID documents read as a first-time reader
- Decisions-table sweep: all 8 rows revisited with their parent docs in hand
- No code or test files exist, so code-side sampling (`@spec` placement, semantic legibility) had nothing to sample

## Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together — for example drafting the F3 decisions row? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project — where PRDs fit, mode transitions, what to do when a segment grows too large — I can help with those too.

---

*Defaults taken in this non-interactive run: dispatched as a full review per the marker's declared Full mode even though the directive block is missing (that gap is finding F1 rather than a stop); advisory posture — no files were edited; report rendered inline and not persisted to disk.*