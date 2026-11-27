The architectural tradeoff is now documented in `docs/decisions/realtime-delivery.md` and linked from `docs/high-level-design.md`.

The decision document records:

- The expected scale and recovery constraints.
- Major criteria: update latency, provider independence, and recovery correctness.
- Moderate criteria: operational burden and resource/cost efficiency.
- The strongest case and tradeoffs for five-second polling, self-hosted WebSockets, and hosted realtime.
- Why self-hosted WebSockets win despite connection-capacity, observability, deployment-interruption, and reconnect-storm responsibilities.
- The resulting obligations for the change store, delivery, and browser-sync nodes.
- The invariant that WebSockets are only a delivery path; revision replay remains the source of recovery correctness.

`git diff --check` passes.

Phase 1 still needs your approval before I draft the three nodes. Also, the existing Access LLD says the delivery approach is “still-open.” May I update that stale sentence as part of the HLD cascade, then proceed to the change-store, delivery, and browser-sync LLDs?