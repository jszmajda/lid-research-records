Phase 1 HLD update is complete.

**docs/high-level-design.md** now records self-hosted WebSockets as the delivery approach:

*Approach*
> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Delivery uses self-hosted WebSockets for fast updates without a realtime vendor.
>
> The change store provides replayable revisions and reliable publication; delivery owns WebSocket sessions, connection capacity, and reconnect handling; browsers implement reconnect and catch-up logic to recover missed updates. Subsecond updates are a benefit; the required freshness target is 15 seconds under normal connectivity.

*Architecture*
- Change store: Not written yet. Revision history, read indexes, and a publication outbox for WebSocket delivery.
- Delivery: Not written yet. Owns WebSocket sessions, reliable publication, and reconnect handling.
- Browser sync: Not written yet. Its subscription, reconnect, and catch-up logic for WebSocket delivery.

*Key Design Decisions*
- **Self-hosted WebSockets for delivery.** Chosen over five-second HTTPS polling and a hosted realtime service to avoid vendor coupling and recurring fees. The store must support replayable revisions and reliable publication; delivery manages sessions and reconnects; browsers handle reconnect and catch-up. Connection capacity and reconnect operations are accepted as the cost of fast updates.

Coherence pre-flight: HLD is now consistent with the selected approach; LLDs for change-store, delivery, and browser-sync are not yet written, so no downstream drift to reconcile.

STOP for your review. Please confirm the HLD reflects your intent for the self-hosted WebSockets approach, or provide numbered feedback. On explicit approval I will proceed to Phase 2 LLD check/draft for the three nodes: change-store, delivery, and browser-sync.