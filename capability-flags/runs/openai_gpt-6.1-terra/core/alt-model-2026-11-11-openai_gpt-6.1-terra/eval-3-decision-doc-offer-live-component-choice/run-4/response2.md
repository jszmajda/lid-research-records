I wrote the decision in [`concurrent-visit-edits.md`](docs/intent/record-store/decisions/concurrent-visit-edits.md) and linked it from the record-store design. It explains the trade-off, when field-aware merging might be worth reconsidering, and the implications for tablet sync and review/export.

One resolution detail needs your judgment before I can finish the record-store contract. Suppose two workers submit competing revisions: one corrects an observer’s name, and the other adds a species. Should a coordinator be able to:

1. **Choose one submitted revision only**, then arrange any further corrections separately; or
2. **Also create an edited whole-visit resolution**, deliberately combining or correcting information during review?

The second permits manual reconciliation without automatic merge rules, but requires the store to preserve the resolution and its provenance.