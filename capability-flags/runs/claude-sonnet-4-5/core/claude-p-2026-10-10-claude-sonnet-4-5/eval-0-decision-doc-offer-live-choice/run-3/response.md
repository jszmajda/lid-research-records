Updated the HLD with the self-hosted WebSockets approach:

## Approach (updated)

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered via self-hosted WebSockets to achieve fast updates without tying the board to a realtime vendor. Browsers establish WebSocket connections to receive updates; the store maintains replayable revisions for reconnection recovery.

The delivery layer manages connection lifecycle and session state; the change store maintains a revision sequence suitable for replay; browsers implement reconnect logic with revision-based catch-up. This accepts the operational burden of connection management and reconnect handling to avoid recurring realtime service fees and provider coupling.

## Key Design Decisions (added)

- **Self-hosted WebSockets for change delivery.** Fast updates without recurring realtime vendor fees or provider coupling. Rejected alternatives: five-second HTTPS polling (simpler but slower, with repeated store reads), and hosted realtime services (fastest route but ongoing costs and vendor lock-in). This choice accepts connection lifecycle management, reconnect logic, and replayable revision storage to achieve low-latency updates while maintaining infrastructure independence.

---

Ready to proceed with the three nodes (change-store, delivery, browser-sync)?