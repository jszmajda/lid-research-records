I've made one small change to the HLD for you to review. Nothing else is touched yet, and I'm stopping at the Phase 1 boundary.

**Coherence pre-flight:** the record-store design and specs are coherent with the HLD and with each other. REC-004 already holds for either policy, so it needs no change.

**What changed in `docs/high-level-design.md`**
- The record-store row's state now reads "Drafted; whole-visit revisions selected, contract pending".
- The paragraph under the architecture table, which said both downstream designs must wait on an unresolved choice, now states the selected policy:
  - Each submitted visit stays intact, and competing revisions go to a coordinator.
  - Tablet-sync keeps base revision IDs and shows pending competing revisions.
  - Review-export provides a revision comparison workflow and holds unresolved visits out of the CSV.
- The mechanism and its rationale stay in record-store, so the HLD only points to it. I added no tenet, since the existing ones already cover this.

**For you to decide**
1. **Approve the HLD edit**, or send numbered feedback. On approval I move to Phase 2, where I'll turn the Open Design Choice in the record-store LLD into the selected design. That covers the submission envelope with a base revision ID, the current-state response, the unresolved-work representation, and the resolution operation. It also includes the edge-case probe.
2. **Decision doc or table row?** This choice will probably stay live for a cold reader. Two credible options trade review workload against merge-rule burden and scientific-intent safety, and two other nodes will be sized around it. I can write a standalone doc at `docs/intent/record-store/decisions/` laying out context, criteria, options and verdict, with a Decisions & Alternatives row linking to it. The alternative is only the row. Which do you want? Your stated rationale (a bigger review queue beats merge rules that can combine related edits unnoticed) goes in either way.
3. **Site-catalog cascade (a different segment).** `site-catalog-design.md` still says tablet-sync reconciliation "remains pending that choice". That sentence is stale now but is outside the record-store segment, so I haven't touched it. Should I update it after the record-store LLD lands?

One tradeoff to confirm: with about 6,000 visits a season and two coordinators, the tenet "workflows two coordinators can operate" now leans on how the review queue is organised. I'll address that in the LLD (for example, how unresolved revisions are listed and how a resolution closes them) unless you want it handled differently.