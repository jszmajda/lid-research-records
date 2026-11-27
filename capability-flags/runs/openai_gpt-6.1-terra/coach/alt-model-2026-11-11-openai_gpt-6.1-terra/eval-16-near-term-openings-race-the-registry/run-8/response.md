## LID coach report

**Posture:** Design intent is taking shape; the arrow needs completion and a fairness decision.

**Scorecard**
- ✓ Design structure — the HLD identifies two recognizable components, each with a design and specs.
- ✓ Rationale — both component designs record alternatives and accepted costs.
- ⚠ Configuration — Full mode is declared, but the LID directives are missing.
- ✗ Arrow completeness — specs have no corresponding tests or implementation in the repository.
- ⚠ Tenet cascade — short-notice checkout can bypass the stated request order.
- ⚠ Specification clarity — a few important matching and retry edges remain open.

The component boundaries and decision tables provide a useful foundation. The most valuable next step is to resolve how short-notice checkout should interact with first-asked, first-served.

### Findings

- **F1 (high):** `CLAUDE.md` lacks LID directives; consider `/update-lid` to reconcile them · *modes are declared, not inferred* — sessions need explicit workflow guidance.
- **F2 (high):** The specs are marked complete, but no tests, code, or `@spec` links are present; clarify their status and complete the arrow · *canonical arrow shape* — intent needs test and implementation links to be checked.
- **F3 (high):** `fulfillment-design.md` allows a later requester to claim a short-notice opening ahead of an earlier compatible requester, contrary to the HLD’s first-asked tenet · *tenet cascade* — downstream mechanisms should honor declared priorities or record an exception.
- **F4 (high):** Offer expiry rematches the earliest active entry, potentially repeatedly offering to the same nonresponding patient and delaying others · *LLDs close enough of the solution space* — specify how rematching makes progress.
- **F5 (medium):** The short-notice direct-checkout choice has no decision row explaining its tradeoff against request order · *docs carry current intent* — a cold reader needs the rationale for a consequential choice.
- **F6 (medium):** `FILL-004` says “a published opening,” while the design describes direct checkout for short-notice cancellations; clarify its scope · *scope disambiguation* — a spec found alone should not invite broader implementation.
- **F7 (medium):** Intake’s “exact retries” and `INTAKE-004`’s retry of any idempotency key leave key reuse with changed preferences unclear · *coherence is adjacency* — design and spec should guide the same behavior.

### What was audited

- Read `CLAUDE.md`, the HLD, both component designs, and both spec files in full.
- Inspected the complete repository file list and recent Git history: two designs, two spec files, and no code or test files were available to sample.
- **Defaults:** No interactive choice required a default; Full mode was explicitly declared. The review proceeded using the existing artifacts despite missing LID directives.

Want me to walk through the findings, focus on a priority, or discuss a specific item?

I can also help with broader questions about using LID on this project.