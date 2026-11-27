Phase 1 — HLD check. Selecting the concurrency policy doesn't change the project's architecture (the node set and their responsibilities are unchanged), but the HLD carried the open choice in two places, so it gets a small revision:

```diff
- | record-store | ... | Drafted; concurrency choice open |
+ | record-store | ... | Drafted; revision contract pending |

- The concurrency mechanism belongs to record-store, not this HLD. Tablet-sync and
- review-export depend on that node's unresolved choice: it determines submission
- metadata, the shape of review work, and which record states can enter an export.
- Those two designs must wait for its contract.
+ The concurrency mechanism belongs to record-store, not this HLD. That node reconciles
+ concurrent edits as whole-visit revisions: a submission names the revision it started
+ from, and edits from the same starting revision become competing revisions a
+ coordinator resolves. Tablet-sync and review-export take their submission metadata,
+ their review surfaces, and their export eligibility rules from record-store's contract
+ rather than defining concurrency semantics of their own.
```

Tenets, Goals, Non-Goals, and the other three node rows are unchanged. I'll move the record-store row to `Drafted` once the contract sections land in Phase 2. Nothing in the HLD now says a choice is pending.

**One question before I draft the LLD.** The decision is owned by record-store, not the HLD — its substance is how that node defines a current record, and the effect on tablet-sync and review-export is a cascade obligation, not shared ownership. So it records at `docs/intent/record-store/`, either as a row in the Decisions & Alternatives table or as a full decision doc at `docs/intent/record-store/decisions/concurrent-visit-edits.md`.

I think this one is worth the full doc, and it's the only one I'll offer on this node. A coordinator or engineer reading the landed design in a year will hit a review queue holding visits whose only conflict is two workers fixing the same observer-name typo, and the obvious reaction is "why aren't we auto-merging the disjoint fields?" That's a live reversal temptation, and the reason it was rejected — merge rules can silently combine a species re-identification with its stale cover estimate — isn't recoverable from the code or from a one-line row. The doc would lay out both options against the criteria that actually separated them (review volume, implementation burden, scientific-relationship safety, submission size), so a future reader can re-run the judgment if, say, the review queue proves unworkable at 6,000 records a season.

A Decisions row is the cheaper alternative and it's a reasonable call — it just records *that* merging was rejected, not enough to re-decide from.

Decision doc, or table row?