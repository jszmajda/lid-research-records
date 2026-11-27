---

## LID Coach Report — Visit Planner

**Posture:** Bootstrapping well — intent layer solid, configuration and rationale need small fixes.

---

### Scorecard

- ✗ Configuration — instruction file directive text absent (prevents standard LID detection)
- ✓ HLD discipline — clean architecture-and-rationale, no implementation detail bleeding in
- ✓ LLD granularity — two focused LLDs for two components, well-bounded
- ✓ Mutation hygiene — docs read as live intent; no residue, no change-narration
- ⚠ Arrow completeness — test and code phases not yet present; arrow halts at specs
- ⚠ Decision capture — three timing constants unexplained; short-notice tenet exception unrecorded

**The arrow's intent layer is solid — two focused LLDs with clean specs and a well-formed HLD; the fastest wins are reconciling the instruction-file directive text and recording the rationale behind the short-notice exception and its timing constants.**

---

### Findings (5 total · 1 high · 3 medium · 1 low)

- **F1 (high):** `CLAUDE.md` has the `## LID` block and mode marker but not the "linked-intent-dev" or "Linked-Intent Development" text the detection rules require — a project that begins with a grep for the directive won't recognize this as a LID project · *modes are declared, not inferred — the declared mode is the foundation everything else keys off of* · run `/update-lid` to reconcile

- **F2 (medium):** Test and code phases are not yet present — the arrow has HLD, LLDs, and specs but there are no test files and no `@spec` annotations anywhere · *canonical arrow shape — the missing phases are where spec-to-code drift enters and sits undetected; when tests arrive, consider writing them against the existing spec IDs before implementing*

- **F3 (medium):** The short-notice path (openings ≤36 hours away) opens a 20-minute checkout window during which any eligible signed-in account can claim an opening — meaning a patient who submitted interest this morning can beat one who submitted weeks ago, directly working against the "first asked, first served" tenet ("an earlier request is never passed by one made after it") · *tenet cascade — a mechanism that works against a tenet under a described operating condition, with no Decisions row or HLD note recording the exception or the reasoning behind it; this also makes it a decision-capture gap* · consider adding a Decisions row in `fulfillment-design.md` naming the tenet trade, or a note in the HLD that the open-window path is an intentional scoped exception to first-asked-first-served

- **F4 (medium):** Three specific constants — the 2-hour offer duration, the 36-hour threshold separating advance from short-notice openings, and the 20-minute scan delay — appear as bare numbers with no Decisions row or contextual note explaining where they come from or what they're trading against · *decision capture — docs carry current intent; a cold reader inheriting this system would want to understand whether these values are load-bearing (regulatory, clinical) or tunable, and right now there is no way to tell* · a brief row each in `fulfillment-design.md`'s Decisions table would close this

- **F5 (low):** The four tenets are listed in an unordered way; if "clinical fit precedes utilization" and "first asked, first served" ever pull in opposite directions (e.g., the earliest requester isn't the most clinically compatible), the ordering doesn't tell a future agent which tenet wins · *tenets capture forward-looking preference — ordered tenets function as a tie-breaker priority stack; worth adding an ordering comment or resequencing once the short-notice exception (F3) is resolved, since that clarifies how these tenets relate*

---

### What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/intake/intake-design.md`, `docs/intent/fulfillment/fulfillment-design.md`, `docs/intent/intake/intake-specs.md`, `docs/intent/fulfillment/fulfillment-specs.md`
- LLDs reviewed: 2 (intake, fulfillment)
- Spec files: 2 · total specs: 15 (INTAKE-001–007, FILL-001–008)
- Arrow overlay (`docs/arrows/`): absent
- Code and test files sampled: none found in the project tree
- `@spec` annotation coverage: 0 (no code or test files to annotate yet)

---

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for this project — capturing tenet exceptions, when to add non-goals or success metrics to the HLD, how to handle the test-first phase when introducing code to a docs-first project — I can help with those too.