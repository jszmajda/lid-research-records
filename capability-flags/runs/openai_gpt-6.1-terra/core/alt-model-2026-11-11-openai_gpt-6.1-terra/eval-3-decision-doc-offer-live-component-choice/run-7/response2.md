I’ve written the tradeoff in [Concurrent Visit Edits](docs/intent/record-store/decisions/concurrent-visit-edits.md), including why field-aware merging remains attractive and what tablet-sync and review-export must accommodate. I’ve also recorded the selection in the record-store design.

One resolution choice is needed to finish the contract. Suppose one revision corrects a species identification and another adds an observation:

- **Select one submitted revision:** the coordinator chooses one complete visit as the outcome.
- **Allow a coordinator-authored revision:** the coordinator can select one or deliberately combine observations into a new complete visit.

Both approaches retain the original submissions. Which should resolution support?