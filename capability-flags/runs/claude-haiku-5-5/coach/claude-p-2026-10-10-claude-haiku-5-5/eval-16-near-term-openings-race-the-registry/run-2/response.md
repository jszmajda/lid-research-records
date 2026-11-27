### Visit Planner: LID coaching report

**Posture:** Healthy intent layer, with tenet drift and configuration to tighten.

**Scorecard**
- ✓ Intent tree: two components, unique `FILL-`/`INTAKE-` prefixes, and the 36-hour and 20-minute thresholds agree between design and specs
- ✓ Mutation hygiene: no change-narration, `[obsolete]` markers, or history sections
- ✓ Mode fit: Full mode matches a two-component project; the `## LID` block declares it
- ⚠ Configuration: `CLAUDE.md` declares the mode but has no linked-intent-dev directives
- ⚠ Tenet cascade: the "first asked, first served" tenet has a tension with the late-cancel checkout path
- ⚠ Arrow completeness: the arrow stops at specs; this repo has no tests or code

**Headline:** The spec layer is clean and well scoped: EARS form throughout, unique IDs, and no residue. The fastest wins are reconciling the LID directives with `/update-lid`, and deciding how the first-asked tenet should govern the window where checkout is open before the scan runs.

### Findings (14 total · 4 high · 5 medium · 5 low)

- **F1 (high):** `CLAUDE.md` has no linked-intent-dev directives, only the `## LID` mode block · *modes are declared, not inferred*. Run `/update-lid` to reconcile.
- **F2 (high):** On openings 36 hours or less away, any eligible account can check out during the 20-minute window before the scan (FILL-004), so a later request can take an opening an earlier entry is waiting for · *tenets capture forward-looking preference*: "an earlier request is never passed by one made after it" has no recorded exception.
- **F3 (high):** The HLD's "normalized view of clinic openings" (Approach, Goal 1) has no LLD or spec; the component list has only Intake and Fulfillment · *effective intent-tree alignment*.
- **F4 (high):** No tests, application code, or `@spec` annotations exist in this repo, so the arrow can't be walked past specs · *canonical arrow shape*. If code lives in another repo, point me to it and the arrow review extends.
- **F5 (medium):** The 36-hour split and the open-checkout window have no Decisions row; a cold reader will ask why 36 hours and why checkout opens before the scan · *docs carry current intent*, decision capture.
- **F6 (medium):** No spec defines a confirmation or a patient accepting or declining an offer, though Goal 3 and a tenet both name confirmations. It is also unstated whether a checkout claim can land during a two-hour offer · *LLDs close enough of the solution space*.
- **F7 (medium):** Two LLD behaviors have no spec: the two-hour offer duration and idempotency-key expiry ("Keys require expiry state") · *coherence is adjacency*.
- **F8 (medium):** The HLD says staff act for callers, and the intake decisions mention "staff must onboard callers" and "staff notes", but no spec covers staff-assisted entry; INTAKE-001 says only "authenticated account" · *effective intent-tree alignment*.
- **F9 (medium):** Terms a cold reader can't resolve: "registry" (is it the matcher?), "portal search," "eligible" and "compatible" (criteria never listed; HLD says "clinical compatibility"), and "36 hours away" (from when, and which time zone?) · *docs carry current intent, written to be read cold*: lost implicit context.
- **F10 (low):** All 15 specs carry `[x]` with no legend. With no code present, the checkmarks read as "implemented" · *docs carry current intent*.
- **F11 (low):** The HLD has Goals but no non-goals, target users, or success metrics. A non-goals line would help, e.g., whether anonymous entries are out, which the intake decisions imply · *HLD is architecture and rationale*.
- **F12 (low):** The four tenets are unordered. First-asked and clinical-fit are the likeliest pair to pull against each other (F2 is already one such case), and an order would say which wins · *tenets capture forward-looking preference*.
- **F13 (low):** Fulfillment covers two paths (matching for ordinary openings, and the late-cancel scan and checkout) with shared design. Consider whether the late path earns a leaf under a fulfillment sub-HLD; not urgent at this size · *one LLD per intent component, or split into a sub-HLD*.
- **F14 (low):** The design docs have no `prefix:` frontmatter, so FILL and INTAKE map to their files by convention only · *specs are grep-anchored linkage*. Add it if your LID version uses it.

### What was audited
- **Dispatch:** `CLAUDE.md` has a `## LID` block (Mode: Full) but no linked-intent-dev directive. LID-shaped artifacts are present, so this is a full review in the default Full mode.
- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, `docs/intent/intake/intake-design.md`, `docs/intent/fulfillment/fulfillment-design.md`, and both spec files.
- **Enumerated:** 2 LLDs, 2 spec files, 15 EARS specs (INTAKE-001–007, FILL-001–008), 8 Decisions rows.
- **Passes:** the Decisions-table sweep and the cold-read pass covered every doc.
- **Not present:** the arrow overlay (`docs/arrows/`), tests, code, and `@spec` annotations. Linkage hygiene, semantic legibility, and tests-first evidence could not be assessed.
- **Capability flags:** the core skill's flag table has no flagged rows, so no note applies.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.