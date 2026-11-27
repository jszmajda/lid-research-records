I’ve recorded the decision in [`concurrent-visit-edits.md`](docs/intent/record-store/decisions/concurrent-visit-edits.md) and updated the [record-store design](docs/intent/record-store/record-store-design.md).

The write-up explains why field-aware merging remains attractive: it could reduce the review queue and make more visits available for export. Whole-visit revisions instead preserve each submission’s scientific context without relying on rules to recognize related edits. Tablets will need base revision IDs and complete submissions; review/export will need revision comparison and must hold unresolved visits out of the CSV.

One choice is needed to finish the record-store contract:

1. **Select a submitted revision:** a coordinator chooses one complete competing revision. Further corrections require a new edit.
2. **Compose a resolution:** a coordinator may manually create a new complete revision using information from the competing submissions. This preserves more corrections in one review but needs a richer resolution and provenance contract.

Which should coordinator review support?