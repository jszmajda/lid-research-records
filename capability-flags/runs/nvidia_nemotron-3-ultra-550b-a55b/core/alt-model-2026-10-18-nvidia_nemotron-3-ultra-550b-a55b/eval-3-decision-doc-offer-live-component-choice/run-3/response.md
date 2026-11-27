**Phase 1 — HLD Check complete.** Updated HLD to record the whole-visit revisions decision:

```markdown
The concurrency mechanism belongs to record-store, not this HLD. The selected approach is whole-visit revisions: each submitted visit edit names its starting revision; concurrent edits produce competing complete revisions for coordinator resolution. Tablet-sync and review-export depend on this contract: tablet-sync tracks base revision IDs and displays pending competing revisions; review-export needs a revision comparison workflow and excludes unresolved visits from the Friday CSV export.
```

**STOP for user review.** Approve to proceed to Phase 2 (LLD update)?