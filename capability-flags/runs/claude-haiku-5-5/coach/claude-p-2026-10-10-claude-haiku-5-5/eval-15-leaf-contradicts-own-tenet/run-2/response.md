## LID Coach Report: Shelfwise

**Posture: Solid design-stage arrow, with one tenet tension and a few cold-read gaps.**

The arrow is real and walkable for both components. The HLD has tenets and goals, each component has one LLD and a spec file, spec IDs are unique and namespaced, and the hold-allocation design records its choices in a table. The most valuable next step is the branch-first allocation rule. Either record it as a deliberate exception to the "waiting is honored in sequence" tenet, or change the rule to match the tenet.

### Scorecard
- ✓ **Linkage**: 13 specs with unique, namespaced IDs (HOLDALLOC-, PICKUP-), each traceable to one LLD
- ✓ **Granularity**: one LLD per HLD component, with no overlapping scope
- ⚠ **Tenets**: branch-first allocation pulls against "waiting is honored in sequence"
- ⚠ **Decision capture**: the branch-first rule has no Decisions row
- ⚠ **Cascade**: the expiry sequence reads two ways between the design and the specs
- ⚠ **Configuration**: the `## LID` block is in place, but the instruction file has no LID directive

### Findings (10 total · 3 high · 4 medium · 3 low)
- **F1 (high):** `CLAUDE.md` declares Mode: Full, but has no LID directive text, so future sessions aren't pointed at LID. Consider `/update-lid` to reconcile. · *modes are declared, not inferred*
- **F2 (high):** Branch-first allocation (HOLDALLOC-003/004) lets a later hold at the scanning branch beat an older hold from elsewhere, which pulls against "waiting is honored in sequence" · *tenets capture forward-looking preference* (tenet cascade)
- **F3 (high):** The expiry sequence reads two ways. The pickup design says the hold closes at lapse, but PICKUP-005 closes it only when staff scan the copy off the shelf. A cold reader can't tell which is intended. · *coherence is adjacency*; *docs carry current intent*
- **F4 (medium):** The branch-first rule has no Decisions row. The design prose gives the courier-van reason, but not the rejected county-wide-oldest alternative or the cost. · *docs carry current intent* (decision capture)
- **F5 (medium):** Goals 1 and 2 are measured from check-in and expiry timing, but closed-hold records are deleted (PICKUP-003/005) under "hold history is not kept." The HLD doesn't say where those metrics come from. Worth answering before the goals are tracked. · *tenets capture forward-looking preference*
- **F6 (medium):** Some LLD behaviors have no spec: cancelling a hold outside the in-transit case, choosing a contact channel at signup, and marking a copy `allocated`. Unspecified behavior is intent that can drift without anything to test against. · *specs are grep-anchored linkage*
- **F7 (medium):** The repo has no tests or code, so the arrow stops at the specs here. If the implementation lives in another repo, this is fine. If not, the Tests and Code phases are missing. · *canonical arrow shape*
- **F8 (low):** Every spec is marked `[x]`, but nothing defines what the marker means. Without code in the repo, a reader can't tell whether `[x]` means authored, implemented, or tested. · *docs carry current intent*
- **F9 (low):** The same events go by different names: "picked up" (design), "checks out" (PICKUP-003), "collected" (HLD). Expiry is "expire," "lapse," and "expiry." Consider settling on one term each. · *docs carry current intent*
- **F10 (low):** The tenets are unordered. "Waiting is honored in sequence" and "staff attention goes to exceptions" could collide, and the branch-first case shows the list gives no tie-break. · *tenets capture forward-looking preference*

### What was audited
- **Dispatch:** the project is LID-shaped (HLD and intent docs present) but has no LID directive, so the full review ran in the default Full mode, with F1 surfaced as the high-priority reconciliation item.
- **Read fully:** `CLAUDE.md`, `docs/high-level-design.md`, both LLDs (`hold-allocation`, `pickup-notices`), and both spec files.
- **Enumerated:** 2 LLDs, 2 spec files, 13 EARS specs (HOLDALLOC-001–007, PICKUP-001–006).
- **Arrow-path sampled:** none. There is no arrow overlay (`docs/arrows/` is absent), and no code or tests exist in this repo.
- **Linkage metric:** 0 `@spec` references, since there is no code to annotate.
- **Capability flags:** none are listed in the core skill's `capability-flags.md`, so no flag note applies.

Want me to walk through the findings in detail, focus on a theme or priority, or work through specific items together? You can also pick a specific finding to dig into.

If you have broader questions about using LID for your project (multi-repo setups, where PRDs fit, mode transitions, what to do when a segment grows too large), I can help with those too.