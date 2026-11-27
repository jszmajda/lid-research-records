**Phase 2 complete — stopping for your review before EARS.**

**HLD sync** (one stale line): `docs/high-level-design.md` now reads "…a private 12 GiB cache with 2Q replacement" instead of "Its eviction policy remains open." Nothing else in the HLD changed — the goals already promised a policy-invariant interface, so the review-api segment needs no cascade.

**LLD revision** (`docs/intent/previews/previews-design.md`): the open-candidates paragraph is gone, replaced by an **Eviction: two queues (2Q)** section — completed renders are admitted to a FIFO **probation queue**; a hit while in probation promotes the sheet to the LRU **main queue**, where it stays until evicted; the 12 GiB budget is split between the queues at a tunable byte boundary, and an admission or promotion that would exceed its queue's share evicts from that queue's tail. Pending jobs hold no queue state until admission.

**Decision record:** the policy choice is recorded as a row in the LLD's new Decisions & Alternatives table (2Q vs. LRU vs. aged-frequency, with the rationale you gave — protecting comparison sheets through big screenings at the cost of extra bookkeeping). I didn't create a decision doc: the choice affects only this node — the HLD guarantees no other segment consumes eviction behavior — so per the workflow it stays a table row despite the length of the debate. Say the word if you want it promoted to a full doc anyway.

**Edge-case probe** (delegated to a fresh subagent, plus my additions). Please triage — which do I fix in the LLD now, which defer as open questions?

*Behavioral forks:*
1. When an evicted sheet is requested again, does it re-enter probation as a fresh entry, or is there a ghost list of recently evicted keys that sends re-admissions straight to main? This is the gap that most decides whether 2Q achieves your goal: a comparison sheet re-fetched after a long screening restarts in probation without one, and continued scanning can evict it again before its next hit.
2. Do requests that joined a pending deduplicated job count as the "second access" that promotes the sheet once it completes, or only hits after admission?
3. When a hit on a probation sheet races its tail eviction, does the hit rescue it or does eviction win?
4. Can eviction delete a JPEG while a 200 for it is in flight?

*Unstated invariants to pin:* 5. promotion moves the sheet's bytes out of the probation share; 6. a hit on a main-queue sheet refreshes its LRU recency.

*Edges:* 7. a sheet larger than its target queue's whole share; 8. after a worker restart, is queue state rebuilt from existing cache files (into which queue?) or started cold?

Once you've triaged, I'll fold in the fixes and proceed to Phase 3 (EARS — e.g., promotion, admission-to-probation, and split-boundary specs alongside the existing PREVIEW-001–005).