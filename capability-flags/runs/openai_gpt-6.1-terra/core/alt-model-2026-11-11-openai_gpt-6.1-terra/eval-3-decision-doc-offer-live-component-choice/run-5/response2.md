I wrote the decision up in `docs/intent/record-store/decisions/concurrent-visit-edits.md`, including why field-aware merging remains attractive and what tablet sync and review/export must accommodate. The record-store design links to it.

One choice is needed to complete the record-store contract:

Suppose one revision corrects an observer’s name and another adds a species. Should a coordinator be able to **create a new complete revision combining both corrections**, while retaining the originals? Or should they **choose one submitted revision intact**, leaving any further correction for a later edit?