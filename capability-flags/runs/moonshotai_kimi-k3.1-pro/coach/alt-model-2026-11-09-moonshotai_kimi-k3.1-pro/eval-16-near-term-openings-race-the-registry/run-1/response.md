# LID Coach

**Posture: Clear design skeleton; incomplete arrow and fulfillment drift.**

**Scorecard**
- ✓ **Design decomposition & mutation hygiene** — two cohesive components; concise, current-state documents without history residue
- ⚠ **Configuration** — Full mode is declared, but the LID workflow directive is missing
- ✗ **Arrow completeness** — both components stop at EARS; no tests or implementation exist
- ⚠ **LLD sufficiency** — matching, offer, actor, and expiry semantics leave consequential choices open
- ⚠ **Tenet cascade** — near-term checkout conflicts with the unconditional FIFO tenet
- ⚠ **Spec coherence & linkage** — IDs are unique, but some constraints and prefix mapping need tightening

The HLD → LLD → EARS foundation is clear, with useful decision tables and strong durability choices; the most valuable next step is an intent-hardening pass over fulfillment before tests and implementation begin.

**Findings (12 total · 6 high · 5 medium · 1 low)**
- **F1 (high):** `CLAUDE.md` declares Full mode but omits the `linked-intent-dev` workflow directive; reconcile it with `/update-lid` · *canonical arrow shape — changes need an explicit route through the LID phases*
- **F2 (high):** Both components stop at EARS, with no test or implementation phase despite checked spec markers · *canonical arrow shape — HLD → LLD → EARS → tests → code*
- **F3 (high):** Near-term checkout lets later requesters bypass earlier compatible entries without a recorded exception to “First asked, first served” (`high-level-design.md:10`, `fulfillment-design.md:9`) · *tenets capture forward-looking preference — leaf mechanisms should preserve HLD tie-breakers or explicitly record exceptions*
- **F4 (high):** “Compatible” and “eligible” lack a defined predicate covering service, site, time, accessibility, and current clinical constraints · *LLDs close enough of the solution space — readers should not have to invent core matching behavior*
- **F5 (high):** Offer durability, acceptance/decline, and concurrency with checkout and expiry remain unspecified, leaving “Commit before communicating” unestablished for offers · *LLDs close enough of the solution space — compatible implementations need a shared offer lifecycle*
- **F6 (high):** Expiry can immediately reselect the same oldest active entry, starving later entries and delaying refill; the decision row acknowledges only repeated offers · *coherence is adjacency — the fulfillment mechanism should support the HLD’s refill goal under expiry*
- **F7 (medium):** Staff-assisted creation, withdrawal, authorization, and checkout are not defined despite staff acting for callers in the HLD · *LLDs close enough of the solution space — actor and delegation behavior should not depend on guesses*
- **F8 (medium):** `INTAKE-004` broadens “exact retries” to every retried key without defining payload mismatch, account scope, or key-expiry behavior · *scope disambiguation — universal requirements need their payload and retention limits in the WHEN clause*
- **F9 (medium):** Fulfillment EARS drops adjacent-design constraints: `FILL-005` omits “active,” while `FILL-003` omits the post-commit visibility boundary · *coherence is adjacency — specs should preserve the LLD’s behavioral constraints*
- **F10 (medium):** The 36-hour cutoff, 20-minute scan delay, and two-hour offer duration have no reconstructable source, alternatives, or accepted costs · *docs carry current intent — live decisions need their reasoning captured where future readers can find it*
- **F11 (medium):** The HLD leaves calendar, identity, and clinical-rule ownership boundaries implicit, and has no explicit non-goals or success measures · *HLD is architecture and rationale — system boundaries and evaluation criteria belong at this level*
- **F12 (low):** `FILL-*` has no declared mapping to the `fulfillment` design leaf, unlike the directly aligned `INTAKE-*` prefix · *specs are grep-anchored linkage — leaf prefixes should resolve mechanically to design-tree nodes*

**What was audited**
- Read fully: all six project files—the instruction file, HLD, two LLDs, and two EARS files.
- Cold-read every LID document; swept all eight Decisions & Alternatives rows and all four tenets.
- Enumerated 15 unique, collision-free spec IDs across two intent components.
- Repository-wide inventory found zero source files, zero test files, and zero `@spec` references; end-to-end arrow sampling therefore could not proceed beyond EARS.
- No arrow overlay, `[inferred]` markers, obsolete specs, or history/changelog residue found. Tests-first chronology is not assessable from the single documentation-only commit.
- **Default taken:** full review anchored on the existing artifacts because the workflow directive is absent but LID-shaped documentation exists. No other defaults were needed.
- Advisory review only; no files changed.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project—multi-repo setups, where PRDs fit, mode transitions, or what to do when a segment grows too large—I can help with those too.