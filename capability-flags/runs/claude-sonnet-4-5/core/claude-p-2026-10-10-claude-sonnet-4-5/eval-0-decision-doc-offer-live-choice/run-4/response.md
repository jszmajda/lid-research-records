Updated the HLD to commit to self-hosted WebSockets. Here's what changed:

**Approach section** (lines 7-12):
```markdown
Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to browsers via self-hosted WebSockets, enabling subsecond updates without vendor lock-in or recurring realtime service fees.

The change store maintains replayable revisions so reconnecting browsers can catch up from their last-seen revision. Delivery manages WebSocket sessions and publishes committed changes. Browser sync handles subscription, reconnection, and revision-based catch-up.
```

**Key Design Decisions** (new entry):
```markdown
- **Self-hosted WebSockets for change delivery.** Fast updates without vendor lock-in or recurring realtime service fees. HTTPS polling was rejected for slower update latency; hosted realtime services were rejected to avoid provider coupling and recurring costs. Accepts the operational work of connection management and reconnect handling.
```

The decision records your rationale: accepting the connection management and reconnect work to get fast updates without vendor dependency.

Ready to proceed with the three nodes (change-store, delivery, browser-sync)?