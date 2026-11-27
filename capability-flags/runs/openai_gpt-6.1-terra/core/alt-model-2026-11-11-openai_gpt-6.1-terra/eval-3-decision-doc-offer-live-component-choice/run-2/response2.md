I wrote the decision in [`concurrent-visit-edits.md`](docs/intent/record-store/decisions/concurrent-visit-edits.md) and linked it from the record-store design. It records why field-aware merging remains attractive, why whole-visit revisions were chosen, and the downstream tablet and export implications.

One contract choice needs your input before I can finish the record-store design:

When a coordinator resolves competing revisions, should they be able to:

1. **Select one submitted revision only.** This keeps the outcome exactly as submitted, but incorporating a useful correction from another revision requires a further edit.
2. **Create an edited whole-visit resolution.** The coordinator can combine or correct observations after comparing submissions; the original revisions and the resolution remain traceable.

For example, if one worker corrected an observer’s name and another corrected a species identification, option 2 would let the coordinator retain both corrections during review. Which should the store support?