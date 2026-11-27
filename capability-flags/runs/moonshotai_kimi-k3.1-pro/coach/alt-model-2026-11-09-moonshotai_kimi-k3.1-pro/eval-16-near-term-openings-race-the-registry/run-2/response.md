## LID Coach Report

**Design-stage arrow; implementation linkage absent.**

**Scorecard**
- ✓ **Design foundations** — concise HLD, focused LLDs, unique spec IDs, and useful alternatives tables
- ✗ **Arrow completeness** — all 15 specs are marked complete, but no tests or implementation exist
- ⚠ **Tenet cascade** — near-term public claiming conflicts with strict request-order fairness
- ⚠ **LLD sufficiency** — eligibility, compatibility, and retry semantics remain open to interpretation
- ⚠ **Configuration** — the instruction file lacks the recognized LID directive

The project has a clear architectural spine and readable, current-tense design documents; the most valuable next step is to reconcile the near-term fulfillment mechanism with the FIFO tenet before implementation begins.

**Findings (8 total · 3 high · 4 medium · 1 low)**
- **F1 (high):** `CLAUDE.md` declares Full mode but never names `linked-intent-dev`; run `/update-lid` to reconcile the directive · *modes are declared, not inferred* — configuration should explicitly identify the methodology
- **F2 (high):** All specs carry `[x]`, yet the repository has neither tests nor code, leaving the completed arrow unwalkable below EARS · *canonical arrow shape* — specs should lead to tests and then implementation
- **F3 (high):** `FILL-003`/`FILL-004` let any eligible signed-in account claim a near-term opening before the delayed registry scan, contradicting “an earlier request is never passed by one made after it” · *tenet cascade* — leaf mechanisms should honor the HLD’s stated preferences or record an explicit exception
- **F4 (medium):** The consequential 36-hour threshold, 20-minute open-claim window, and public-search choice have no Decisions & Alternatives row explaining the fairness trade-off · *decision capture* — future readers cannot reconstruct what was given up or why
- **F5 (medium):** “Compatible,” “eligible,” and “current service and patient constraints” are not defined closely enough for independent implementations to agree · *LLDs close enough of the solution space* — load-bearing matching rules should not depend on implicit context
- **F6 (medium):** `INTAKE-004` does not scope idempotency keys by account or payload, while the LLD’s “exact retries” leaves exactness undefined · *scope disambiguation* — a grep-found spec should not invite cross-account or changed-payload replay ambiguity
- **F7 (medium):** The two-hour offer duration, immediate publication after commit, and the LLD’s event requirement for every transition lack corresponding behavioral specs · *effective intent-tree alignment* — named design behavior needs a spec anchor to remain testable
- **F8 (low):** The HLD would be more useful cold with explicit non-goals and measurable success criteria · *HLD is architecture and rationale* — boundaries and outcomes help future changes preserve architectural intent

**What was audited**
- Read fully: `CLAUDE.md`, the HLD, both LLDs, and both spec files, including a cold-read and Decisions & Alternatives sweep
- Enumerated: 2 intent components, 15 EARS specs, and 0 `@spec` references
- Repository sample: all 6 project files; no code, tests, or `docs/arrows/` overlay exists
- Default applied: **Full review**, consistent with the explicitly declared Full mode; no files were changed

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project—multi-repo setups, where PRDs fit, mode transitions, or what to do when a segment grows too large—I can help with those too.