I've updated the HLD's Approach, Architecture, and Key Design Decisions sections to commit to self-hosted WebSockets. Here's the final diff summary for you to review:

- **Approach**: commits to self-hosted WebSocket delivery; describes the change store keeping replayable revisions and publishing reliably, delivery owning session lifecycle/reconnect handling, and browsers running catch-up logic.
- **Architecture**: the Change store, Delivery, and Browser sync node descriptions now name their WebSocket-specific responsibilities instead of listing all three options.
- **Key Design Decisions**: added a row recording the choice and why HTTPS polling and the hosted service were rejected.

This decision trades real criteria (latency, cost, ops burden) across three not-yet-written nodes, which meets the bar for a full decision doc rather than just the table row I added. Want me to write one (`docs/decisions/realtime-delivery-approach.md`) laying out the three options and selection criteria, or is the HLD row enough?