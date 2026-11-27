I recorded the decision in [`concurrent-visit-edits.md`](docs/intent/record-store/decisions/concurrent-visit-edits.md) and linked it from the record-store design. It covers why field-aware merging remains attractive, the scientific and maintenance tradeoffs, and the obligations for tablet sync and review/export.

One record-store contract choice remains before the design can be completed:

If one worker corrects an observer’s name and another adds a species, should the coordinator be able to:

1. **Select one submitted revision only**, leaving the other correction for a later edit; or
2. **Create a reviewed revision combining corrections**, while retaining the original submissions and recording their contribution?

Which resolution should the store support?