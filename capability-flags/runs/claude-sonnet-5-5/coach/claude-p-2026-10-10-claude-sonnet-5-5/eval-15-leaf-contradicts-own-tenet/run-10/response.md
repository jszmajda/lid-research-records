## LID Coach report: Shelfwise

### Executive summary

**Posture:** Healthy, with two intent gaps worth closing.

**Scorecard**
- ✓ Design tree: the HLD, two component LLDs and two spec files line up cleanly, and each component's EARS prefix matches its LLD.
- ✓ Docs read cold: the HLD and both LLDs are written in the present tense, with no changelog residue and no `[obsolete]` specs.
- ✓ Decision capture in `pickup-notices`: the expiry row names Goal 1 and the cost accepted.
- ✓ Spec quality: the specs are consistently EARS-shaped, the IDs are unique, and their scopes are explicit.
- ⚠ Tenet cascade: one allocation mechanism works against the first tenet.
- ⚠ Configuration: the instruction file has the mode marker but no LID directives.
- ⚠ Downstream arrow: no tests or code in the repo cite the specs.

**Headline:** The design layer is compact and unusually well reasoned, and the tenets, goals and Decisions tables show real thought. The most valuable next step is to look at how hold allocation treats "waiting is honored in sequence" and record the answer.

### Findings (6 total · 3 high · 2 medium · 1 low)

- **F1 (high):** Allocation prefers a scanning-branch hold over the older county-wide hold (`HOLDALLOC-003/004`), which can lengthen an earlier patron's wait for a later patron's benefit · *tenet cascade (design nodes should lean the way the HLD's tenets say), against the tenet "Waiting is honored in sequence"*
  - Under the described conditions, patron A places a hold Monday with pickup at Branch X. Patron B places one Tuesday with pickup at Branch Y. A copy is returned at Y, and B receives it ahead of A.
- **F2 (high):** The local-first allocation choice has no Decisions & Alternatives row. Its reasoning (keeping copies off the daily courier van) sits only in design prose, and the tenet it trades against is not named · *docs carry current intent, written to be read cold (decisions a cold reader would question belong in the table with the cost accepted)*
- **F3 (high):** `CLAUDE.md` carries the `## LID` mode and version bullets but no LID directive block (no reference to linked-intent-dev), so a fresh session isn't told how to work the arrow · *modes are declared, not inferred*. Run `/update-lid` to reconcile.
- **F4 (medium):** The hold lifecycle isn't pinned down. Nothing says whether a hold with an `allocated` copy still counts as "open" for `HOLDALLOC-004`. Nothing covers a hold cancelled while its copy sits allocated or already on a holds shelf · *LLDs close enough of the solution space (two agents should land on compatible implementations)*
- **F5 (medium):** All 13 specs are marked `[x]`, but the repo has no tests or code carrying `@spec` annotations, so the arrow can't be walked below the specs · *tests carry `@spec` annotations; tests before code*
- **F6 (low):** The tenet "Hold history is not kept" reads as a data-retention rule more than a lean-one-way tie-breaker. `PICKUP-003/005` already enforce it · *tenets capture forward-looking preference (a tenet is a tie-breaker, not a triggered rule)*

### What was audited

- Read fully: `CLAUDE.md`, `docs/high-level-design.md`, both LLDs, both spec files.
- Enumerated: 2 LLDs, 2 spec files, 13 specs (7 `HOLDALLOC`, 6 `PICKUP`).
- Searched for code, tests and `@spec` references: none found.
- Not present: `docs/arrows/` overlay (so no `/arrow-maintenance` audit applies yet).
- Ran a cold-read pass over every LID doc and a sweep of all 7 Decisions & Alternatives rows.

### Offer to help

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into, and F1 and F2 are worth taking together.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.