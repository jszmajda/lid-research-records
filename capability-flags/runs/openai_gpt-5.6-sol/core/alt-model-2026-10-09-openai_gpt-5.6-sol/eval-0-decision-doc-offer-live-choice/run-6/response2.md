Created `docs/decisions/change-delivery.md` and linked it from `docs/high-level-design.md`.

The decision document records:

- MarketBoard’s scale, freshness, and recovery context.
- Latency and infrastructure independence as major criteria.
- Operating burden and recovery clarity as moderate criteria.
- Full analysis of polling, self-hosted WebSockets, and hosted realtime delivery.
- Why self-hosted WebSockets win despite the accepted connection and reconnect workload.
- The resulting obligations for change storage, delivery, and browser sync.

`git diff --check` passes. No tests apply to this documentation-only phase.

Please review and approve this HLD phase. If approved, I’ll begin Phase 2 with the change-store node, followed separately by delivery and browser sync. I’ll also remove the stale “still-open” wording from the Access node if you approve that cleanup.