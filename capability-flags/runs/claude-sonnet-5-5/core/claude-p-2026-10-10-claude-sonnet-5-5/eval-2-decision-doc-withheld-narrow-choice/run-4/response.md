I've finished Phase 1 (HLD check) and stopped for your review before touching the preview LLD.

**What changed in `docs/high-level-design.md`**

The Previews bullet under Architecture said the eviction policy "remains open." It now reads:

> Owns rendering, pending jobs, and a private 12 GiB cache that uses 2Q eviction, so one-off sheets from long sequential screenings do not displace sheets editors revisit while comparing clips.

**Phase 1 check**

- **Architecture:** 2Q fits inside the existing architecture. The preview API, render queue, 12 GiB budget, and the review-API boundary are all unchanged, and the review-api node is not affected.
- **Tenets and goals:** The choice is consistent with them. 2Q's queues are replacement bookkeeping, which the tenets already keep private to the preview worker.
- **Decision record:** Your choice only affects the previews node, so I'm not proposing a standalone decision doc. The 2Q rationale and the LRU and frequency-with-aging alternatives will go in the previews LLD's Decisions & Alternatives table in Phase 2.
- **Candidate tenet (optional):** *"When replacement trade-offs conflict, favor keeping sheets editors repeatedly compare over adapting quickly to project switches."* Its opposite (LRU-style recency) is a reasonable choice for another project. It would guide future cache decisions that no spec anticipates. Do you want it under `## Tenets`, or should I leave the tenet list as is?

**Questions for you**

1. Do you approve the HLD edit?
2. Should I add the candidate tenet above?
3. Phase 2 will need a 2Q queue-size split, such as the share of the 12 GiB budget given to first-use entries versus reused entries. Do you have a starting split in mind, or should I sketch 2–3 options with their consequences?

On your approval I'll move to Phase 2 and update the previews LLD.