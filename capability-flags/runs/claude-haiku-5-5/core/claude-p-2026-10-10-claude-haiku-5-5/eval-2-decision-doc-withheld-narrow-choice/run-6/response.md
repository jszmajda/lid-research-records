**Phase 1: HLD check (stopped for your review)**

Nothing has been edited yet. Your request to finish the design covers Phases 2 and 3 as well, and each phase has its own stop, so I've stopped here.

**What I checked**

- `docs/high-level-design.md` already assigns the 12 GiB private cache and the pending-job protocol to Previews. Its tenets fit 2Q: replacement bookkeeping stays private to the preview worker, and no other node reads it.
- 2Q does not change the architecture. The fixed 200/202/404 contract, the four-job render queue, and the disk budget all stay the same.

**Two cascades**

1. `high-level-design.md` line 14 says the Previews eviction policy "remains open," which will be stale once 2Q is recorded. I propose changing it to: "Its private cache uses 2Q eviction; see the previews design."
2. The 2Q decision touches only the Previews segment, so it belongs in `docs/intent/previews/previews-design.md`, not the HLD. That doc has no Decisions & Alternatives table yet. Phase 2 would add one, recording 2Q with LRU and frequency-with-aging as rejected alternatives and their reasons.

I'm not offering a separate decision doc. The choice affects only its own node, so a table row is enough.

**Forks to settle before the LLD is drafted**

A. **What "reused" means.** Classic 2Q promotes a sheet to the protected queue only when it's requested again after it has left the probation queue. A ghost list of evicted keys, which holds metadata but no image bytes, makes that check. A simpler variant promotes on any second request while the sheet is still in probation. The two behave differently when an editor reopens a sheet a few minutes into a long screening. I recommend classic 2Q.

B. **The size split.** The probation share and the ghost-list length need values. My starting point: probation at 25% of the 12 GiB budget (about 3,072 sheets at 2 MiB each), and a ghost list of about 3,072 keys (metadata only). These would be configuration constants, tuned later from pilot data. Please confirm or give different numbers.

C. **Queue eviction order.** I'm assuming plain LRU inside both queues, which is standard for 2Q. Tell me if you want something else.

**Your feedback**

1. Approve the `high-level-design.md` line-14 edit, or give different wording.
2. Choose the "reused" definition for fork A.
3. Confirm or change the size-split values for fork B.
4. Confirm the LRU assumption in C.

Once you approve, I'll move to Phase 2, which drafts the previews LLD with the Decisions row and an LLD-level edge probe, and stop for your review. Phase 3 (the EARS specs) follows after that stop.