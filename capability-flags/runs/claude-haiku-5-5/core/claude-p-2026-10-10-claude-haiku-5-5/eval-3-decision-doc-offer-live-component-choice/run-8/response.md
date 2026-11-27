**Phase 1 (HLD check) is done. I've stopped here for your review, as the workflow requires before the LLD and EARS work.**

**Choice recorded:** whole-visit revisions. Each edit names its starting revision, and concurrent edits become competing complete revisions for a coordinator to resolve. Original submissions are never discarded.

**HLD check:** The HLD doesn't need a structural change, because the concurrency mechanism belongs to record-store. I updated one cell in `docs/high-level-design.md`: the record-store state now reads "concurrency policy selected: whole-visit revisions (public contract pending)". Tablet-sync and review-export still wait for record-store's contract.

**Not yet changed:** `docs/intent/record-store/record-store-design.md` still says OPEN and still presents both options. I'll rewrite it in Phase 2 once you approve this stop.

**Decisions for you:**

1. **Decision doc or table row?** This choice clears the bar for a full decision doc: a cold reader would ask why the team didn't merge automatically, and tablet-sync and review-export are sized around the answer. I'd write `docs/intent/record-store/decisions/concurrency-policy.md`, with a Decisions row in the record-store design linking to it. Should I write the doc, or just the row?

2. **Tenet candidate.** Your reasoning suggests a lean the HLD doesn't yet state: *prefer a coordinator's review over automatic combination of scientifically related edits.* It is not a platitude, since a different project could reasonably choose merging, and it's a lean rather than a triggered action. Should it go under `## Tenets`? If so, how would you word it?

3. **Phase 2 scope.** Once you approve, I'd draft the record-store LLD with the whole-visit contract (submission envelope, current-state response, unresolved-work representation, resolution operation) and then propose EARS changes, with a stop after each. Is that the sequence you want?