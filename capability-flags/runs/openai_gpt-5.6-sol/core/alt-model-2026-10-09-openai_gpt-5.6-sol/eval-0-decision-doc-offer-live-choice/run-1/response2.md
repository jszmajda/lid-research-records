Added `docs/decisions/realtime-delivery.md` and linked it from `docs/high-level-design.md`.

The decision document records:

- The scale, freshness, and recovery context.
- Delivery control, latency, operational burden, and recurring cost as selection criteria.
- Full analysis of polling, self-hosted WebSockets, and hosted realtime.
- Why WebSockets win on the two major criteria.
- The accepted obligations for replay, reliable publication, connection capacity, reconnects, and browser catch-up.

`git diff --check` passes. No tests were run because this phase changes documentation only.

Please approve or revise these Phase 1 artifacts. Once approved, we can proceed to the change-store, delivery, and browser-sync nodes.