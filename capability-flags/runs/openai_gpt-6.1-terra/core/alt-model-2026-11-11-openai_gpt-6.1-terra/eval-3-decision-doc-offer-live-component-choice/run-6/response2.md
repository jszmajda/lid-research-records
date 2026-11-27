I wrote the concurrency decision in [`concurrent-visit-edits.md`](docs/intent/record-store/decisions/concurrent-visit-edits.md) and linked it from the record-store design. It explains why field-aware merging remains attractive, why whole-visit revisions were chosen, and what tablet sync and review/export must accommodate.

One contract choice remains open. If edits A and B both start from revision R0 and A arrives first, what should retrieval show while they await review?

1. **R0**, the last uncontested state, alongside A and B.
2. **A provisionally**, alongside the conflict.
3. **No current state** until resolution, with R0, A, and B available for review.

All three retain the submissions and exclude the unresolved visit from export. Which should the store use?