---

## /lid-coach — Visit Planner

### Dispatch note

The instruction file (`CLAUDE.md`) has the `## LID` block and Mode marker but does not contain the formal directive strings `"linked-intent-dev"` or `"Linked-Intent Development"` that LID's detection rules require. The project is clearly LID-shaped — HLD, two LLDs, two spec files — so I'm proceeding with a full review and surfacing the configuration gap as a high-priority finding.

---

### Executive summary

**Posture: Clean design foundation; arrow stops at specs.**

**Scorecard**
- ⚠ Configuration — instruction file lacks the formal LID plugin directive; `/update-lid` will reconcile
- ✓ HLD discipline — tight architecture-and-rationale doc; no implementation detail bleeding in
- ✓ LLD granularity — two well-scoped components, appropriate split
- ✓ Mutation hygiene — all docs read as current intent; no residue, change-narration, or fossils
- ✗ Arrow completeness — tests and code phases are absent; the arrow ends at EARS specs
- ⚠ Decision capture — two key design parameters lack rationale; one tenet exception is undocumented

The design layer here is genuinely well-built: clean HLD tenets, well-scoped LLDs, consistent spec IDs, healthy Decisions tables. The fastest wins are extending the arrow into tests and code, and capturing a few pieces of implicit rationale before they drift out of reach.

---

### Findings inventory

**Findings (5 total · 2 high · 2 medium · 1 low)**

- **F1 (high):** `CLAUDE.md` uses a minimal `## LID` block but is missing the `"linked-intent-dev"` plugin directive that LID tooling greps for — *modes are declared, not inferred*; run `/update-lid` to add the directive and fully register the configuration.
- **F2 (high):** Tests and code phases are absent — the arrow exists as HLD → LLDs → EARS but stops there, with all specs marked `[x]` and no test or source files present — *canonical arrow shape*; intent-to-test linkage (`@spec` annotations) and behavioral verification can't begin until the next phase exists.
- **F3 (medium):** The 36-hour advance/same-day threshold and the 20-minute portal scan delay are load-bearing design parameters in `fulfillment-design.md` but have no Decisions row capturing why those numbers — *docs carry current intent, written to be read cold*; a cold reader would have no way to evaluate whether these values still fit if conditions change.
- **F4 (medium):** The same-day cancellation path (FILL-003/FILL-004) allows any eligible signed-in patient to claim during the 20-minute open window, regardless of `enteredAt` order — this is a deliberate exception to the "**First asked, first served**" tenet, but neither the fulfillment LLD nor a Decisions row names it as such — *tenet cascade* and *decision capture*; the exception is the right call for rapid same-day turnaround, but leaving it implicit means a future agent or reader can't tell whether this is intentional policy or an oversight.
- **F5 (low):** The four HLD tenets are unordered — *tenets capture forward-looking preference*; consider an explicit priority order in case a future decision sits at a cross-tenet edge (e.g., "Clinical fit precedes utilization" vs. "First asked, first served" for a borderline-eligible earliest entry).

---

### What was audited

- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/intake/intake-design.md`, `docs/intent/intake/intake-specs.md`, `docs/intent/fulfillment/fulfillment-design.md`, `docs/intent/fulfillment/fulfillment-specs.md`
- **Enumerated:** 2 LLDs, 2 spec files, 15 specs (INTAKE-001–007, FILL-001–008)
- **Arrow-path sampled:** Both segments end-to-end through the design layer (HLD → LLD → specs); no test or code layer present to sample
- **Code/test linkage:** 0 `@spec` references found — no source or test files in the repository

---

### Offer to help

Want me to walk through any of these findings in more detail, or work through a specific one together — say, drafting the Decisions rows for F3 or F4, or thinking through tenet ordering for F5?

If you have broader questions about using LID here — how to approach the tests-first phase from a docs-first starting point, how `@spec` annotation placement works, or how to think about the scope of these two LLDs as the project grows — I can help with those too.