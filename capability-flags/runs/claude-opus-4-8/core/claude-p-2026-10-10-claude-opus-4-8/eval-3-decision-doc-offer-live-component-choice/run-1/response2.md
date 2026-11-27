Done. The decision doc is written and linked.

## `docs/intent/record-store/decisions/concurrent-visit-edits.md`
- **Context** frames the problem from the domain (offline edits from a shared base, fields that can be scientifically related across field names) and notes the retain-everything invariant as background, not a differentiator.
- **Decision Elements** — five criteria that actually drive the choice, each tied to the tenet or non-goal it turns on: whole-visit preservation and coordinator-operability (both major), review workload and inspectability (moderate), submission size (minor). No hard gate, since neither option is eliminated by one.
- **Options in the Domain** — both given their strongest honest form. Field-aware merge is written as its advocate would (smaller queue, disjoint-field auto-combine, smaller submissions) with a per-criterion verdict, so the reason we'd *reconsider* it is on the page: it's **strong** on review workload, which is the lever to revisit if the queue proves unsustainable.
- **Selection** — whole-visit revisions, won on the two major criteria, accepting the review-workload cost explicitly. It spells out what the choice forecloses (no auto-combination; queue grows with concurrent-edit frequency) and the **downstream obligations** as cascades:
  - **tablet-sync**: track + send the base revision ID, store whole-visit payloads, tell the worker when their submission became a competing revision.
  - **review-export**: revision comparison screen, invoke resolution (records coordinator + contributing IDs + chosen revision), hold unresolved visits out of the CSV.

The LLD's Decisions row now points here instead of restating the rationale.

## Still open before Phase 3
We're still at the **Phase 2 stop** — the record-store LLD is drafted and the decision is recorded, but the 8 forks from my last message aren't resolved yet, and I need your calls (especially the leanings on #1 unresolved-visit fast-forward, #2 ancestry-vs-receipt-time and basing on a competitor, #3 readability while unresolved) before I cascade them into the REC EARS specs. Want to walk through those now, or review the LLD and decision doc first?