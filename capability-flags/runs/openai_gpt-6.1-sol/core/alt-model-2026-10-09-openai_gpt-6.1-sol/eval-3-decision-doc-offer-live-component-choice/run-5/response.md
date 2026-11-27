Updated [the record-store design](docs/intent/record-store/record-store-design.md) around **whole-visit revisions**, recording the scientific rationale and the accepted cost of more review work.

The draft now defines:
- Complete submitted visits with base revision IDs and retry keys.
- Immutable originals with author and receipt-time provenance.
- Straight-line updates becoming current; competing revisions creating unresolved review work.
- Unresolved visits having no export-eligible current revision.
- Version-checked coordinator resolutions so a decision cannot silently resolve newer submissions.

**One design choice needs your judgment before I finish the resolution contract:**

1. **Select an existing revision intact.** Simple provenance and a smaller review interface. If neither submission is correct, someone submits another complete correction.
2. **Select or author a complete reviewed revision.** A coordinator can correct two partly right submissions during review, with the resulting complete visit linked to its source submissions. This adds editing and validation responsibilities to review/export.

Both avoid automatic field merging. **Which should coordinators be able to do?**

The design probe also found gaps around corrections to competing revisions, resolution retries, contributing submission IDs, plot-reference corrections, permissions, and concurrent history/list reads. These are recorded under **Open Questions & Future Decisions** for your triage.

The existing REC specs remain compatible with the selected approach but do not yet cover its detailed contract; their update follows design approval. The HLD and site-catalog still contain “choice open” dependency wording, which needs your approval to cascade across those node boundaries.

This concurrency choice also merits offering a standalone decision document: future maintainers may revisit the review-workload versus scientific-integrity tradeoff, and two downstream designs will depend on it. **Would you like that document, or keep the rationale in the design’s Decisions & Alternatives table?**

`git diff --check` passed. Pausing here for design review.