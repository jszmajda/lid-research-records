Added `docs/decisions/realtime-change-delivery.md` and linked it from `docs/high-level-design.md`.

The decision record documents:

- The scale, freshness, recovery, and authority constraints.
- Low latency, provider independence, operational simplicity, and infrastructure efficiency as selection criteria.
- Full analysis of five-second polling, self-hosted WebSockets, and hosted realtime.
- Why self-hosted WebSockets win despite connection-capacity, reconnect-storm, deployment, and observability costs.
- The resulting obligations for change store, delivery, and browser sync.

`git diff --check` passes. No tests apply to this documentation-only phase.

Please approve the completed HLD phase. On approval, I’ll start the downstream designs in dependency order: change store, delivery, then browser sync.