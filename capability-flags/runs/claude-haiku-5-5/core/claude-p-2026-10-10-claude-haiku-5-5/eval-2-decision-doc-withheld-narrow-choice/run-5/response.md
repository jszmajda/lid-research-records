**Phase 1 (HLD check): 2Q is recorded as the previews eviction policy. Nothing is edited yet.**

I read the HLD, the previews and review-api design and spec docs, and the skill's references. Your "finish the preview design" doesn't authorize skipping the phase stops, so I'm stopping here and will run each phase in turn.

**What the HLD check found**

- **Architecture holds.** The review API still reaches previews only through the fixed HTTP interface (200/202/404). The FIFO queue of four render jobs and the 12 GiB limit are unchanged. 2Q lives entirely inside the worker.
- **Tenets and goals hold.** "Keep cache paths and replacement bookkeeping private to the preview worker" covers 2Q's queues. "Return a ready preview or a pending response through the same interface for every eviction policy" is satisfied.
- **Specs trace to the LLD.** PREVIEW-001 through PREVIEW-005 match the design sections, and REVIEW-003 matches the preview interface. I found no drift.
- **One stale HLD line.** The Architecture bullet says previews' "eviction policy remains open." That becomes false once 2Q is chosen.
  - **Recommendation:** drop the clause. The policy is private to the previews node, so the HLD only needs "private bounded cache."

**How to record the choice**

2Q affects only the previews node, so I won't offer a decision doc. I'll add one row to a Decisions & Alternatives table in `previews-design.md`. The row will name all three options and the rationale: scan resistance during long screenings, and comparison sheets stay protected. The accepted cost is two queues and a size split to tune.

**Decisions I need from you before Phase 2**

1. **Queue sizing.** Should the first-use queue start at a fixed share of the 12 GiB, such as 25%, with the reused queue taking the rest? I'd write the split and the ghost-list length as tunable starting values, not as spec.
2. **Ghost list.** Should a sheet count as "reused" only if it is requested again after eviction, tracked by key alone, or also if it is requested again while still in the first-use queue? The first option is classic 2Q. Ghost entries hold no JPEG bytes, so they don't count against the 12 GiB.
3. **HLD edit.** Should I drop the "eviction policy remains open" clause from the HLD, as recommended above?

Reply with answers to 1–3 and approval to draft the LLD (Phase 2). I've made no file changes.