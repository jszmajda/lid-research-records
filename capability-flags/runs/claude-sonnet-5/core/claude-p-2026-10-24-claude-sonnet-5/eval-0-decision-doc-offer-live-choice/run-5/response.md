This is an HLD-level choice (Phase 1), so it stops here for review before Phase 2's three LLDs.

I updated `docs/high-level-design.md`:
- **Approach**: now states delivery is over a self-hosted WebSocket connection, with the change store holding replayable revisions and publishing reliably, delivery owning socket sessions (connection, reconnect, catch-up), and browsers carrying reconnect/catch-up logic.
- **Architecture** table: each of the three not-yet-written nodes (change store, delivery, browser sync) now states its WebSocket-specific responsibility instead of "depends on the approach."
- **Key Design Decisions**: added a row recording the choice and why polling and the hosted service were rejected.

This choice stays live for a cold reader — it trades real latency/ops/vendor-coupling criteria against each other, and three LLDs are about to be sized around it — so it clears the bar where I'd normally offer a full decision doc instead of just the table row. Do you want it recorded as a standalone decision doc at `docs/decisions/delivery-approach.md` (laying out the three options, criteria, and selection for a future cold reader), or is the HLD row above enough?

Once you confirm that, I'll move to Phase 2 for the three nodes (change store, delivery, browser sync).