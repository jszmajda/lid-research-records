Phase 1 (HLD) is done for the record-store choice. I'm stopping here for your review, as the workflow requires at each phase boundary. I read "finish the record-store design" as taking it through the LID phases (HLD, LLD, EARS, edge audit) with a stop after each. Tablet-sync and review-export come after that.

**What I changed in `docs/high-level-design.md`:**
- The record-store row now reads "Drafted; concurrency policy: whole-visit revisions" instead of "concurrency choice open".
- The paragraph on the concurrency mechanism now states the selected approach: each submission names its starting revision, and concurrent submissions stay as separate competing revisions until a coordinator resolves them.

I have not touched `docs/intent/record-store/`. The LLD still describes both options as open, so Phase 2 will rewrite it around the selected approach.

**Decisions for you:**
1. **Decision doc.** This choice will stay live for a cold reader, because tablet-sync and review-export are sized around it and the trade-off is real. Should I record it as `docs/intent/record-store/decisions/whole-visit-revisions.md`, with a Decisions & Alternatives row in the record-store LLD pointing to it? I'll write it only if you say yes.
2. **Tenet.** Your reasoning suggests a tenet for the HLD: "Keep each submitted visit intact rather than automatically merging fields that may be scientifically related." Should I add it under `## Tenets`?

Once you reply to those and approve the HLD edit, I'll move to Phase 2 and draft the record-store LLD.