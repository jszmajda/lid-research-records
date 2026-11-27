Recorded **whole-visit revisions** and drafted the contracts in [record-store-design.md](docs/intent/record-store/record-store-design.md): complete snapshots, base revision IDs, immutable history, competing-revision review, and no usable current snapshot while a visit is unresolved.

One choice is needed before I can finish the resolution contract:

**What may a coordinator do?**
1. **Select an existing revision only.** Simpler review; corrections combining observations require a further complete submission.
2. **Select or explicitly author a complete replacement snapshot.** More review/provenance work, but coordinators can reconcile observations directly without automated merging.

The design probe also found gaps to settle: delayed edits based on previously rejected revisions, retry-key scope and validation ordering, consistent retrieval during writes, and resolution retries after a lost response. Should I draft these mechanisms for your review now, or defer any explicitly?

Two documentation questions:
- This trade-off will shape both downstream designs. Would you like a standalone decision document explaining it, or is the Decisions & Alternatives row sufficient?
- May I refresh the HLD’s stale “concurrency choice open” wording?

The design remains at the LLD review stop, with these questions recorded in the file. `git diff --check` passes.