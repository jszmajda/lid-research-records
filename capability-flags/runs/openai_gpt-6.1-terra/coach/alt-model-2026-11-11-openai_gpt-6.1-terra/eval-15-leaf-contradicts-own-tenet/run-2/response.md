## LID coach report

**Posture: A clear design foundation; the arrow needs completion and reconciliation.**

**Scorecard**
- ✓ Component design — allocation and notices have distinct homes and explicit alternatives.
- ✓ Spec linkage — both components have readable, uniquely named specs.
- ✗ Arrow completeness — no tests or implementation are present.
- ⚠ Intent coherence — allocation and expiry contain consequential tensions.
- ⚠ Configuration — Full mode is declared, but LID directives are absent.

The component designs provide a useful starting point; the most valuable next step is to reconcile the allocation policy with the project’s waiting-sequence tenet before building downstream.

### Findings (9 total · 5 high · 4 medium)

- **F1 (high):** `CLAUDE.md` lacks LID directives; consider `/update-lid` so future sessions have the workflow as well as the mode · *modes are declared, not inferred* — configuration needs to be visible.
- **F2 (high):** Both spec files mark all requirements `[x]`, but the repository has no tests or code; this makes completion and tests-first status unclear · *canonical arrow shape* — intent needs test and implementation links.
- **F3 (high):** Local-branch priority in `hold-allocation-design.md:11` can give a later patron a copy ahead of an earlier patron, contrary to the HLD’s waiting-sequence tenet · *tenets capture forward-looking preference* — downstream choices should honor the declared lean.
- **F4 (medium):** The local-first choice has a courier rationale but no Decisions row acknowledging the fairness trade-off · *docs carry current intent* — a cold reader needs the accepted cost of a live choice.
- **F5 (high):** `pickup-notices-design.md:11` closes a hold when its window lapses, while `PICKUP-005` closes it only when staff scan the copy off the shelf; the timing affects record deletion · *coherence is adjacency* — neighboring levels should agree.
- **F6 (high):** Allocation leaves unclear how an allocated hold is excluded from further matching and how a copy becomes eligible for reallocation after expiry · *LLDs close enough of the solution space* — otherwise implementations must guess at state transitions.
- **F7 (medium):** `HOLDALLOC-004` also matches the no-holds case covered by `HOLDALLOC-005`, but asks for an oldest hold that does not exist · *scope disambiguation* — triggers need unambiguous boundaries.
- **F8 (medium):** Failed email or SMS delivery leads to a staff phone call, an exception to the HLD’s chosen-channel tenet that is not acknowledged as such · *tenets capture forward-looking preference* — explicit exceptions keep future choices coherent.
- **F9 (medium):** The HLD’s “hold history is not kept” tenet prescribes record deletion rather than a forward-looking tie-breaker; the four tenets also have no stated priority if they conflict · *tenets capture forward-looking preference* — clear leans guide choices not already specified.

### What was audited

- Read `CLAUDE.md`, the HLD, both component designs, and both spec files: 2 designs and 13 specs.
- Inspected the repository inventory and available Git history. No code, tests, `@spec` annotations, or arrow overlay were present; tests-first ordering could not be assessed.
- No non-interactive defaults were needed; the project explicitly declares Full mode.

Want me to walk through the findings, focus on a priority, or explore a specific item together? I can also help with broader questions about using LID on this project.