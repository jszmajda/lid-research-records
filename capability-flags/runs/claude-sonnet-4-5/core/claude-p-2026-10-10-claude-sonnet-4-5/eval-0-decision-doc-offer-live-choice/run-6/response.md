Updated HLD with the WebSockets decision. The Approach section now commits to self-hosted WebSockets and describes the implications for the three dependent nodes. I've added an entry to Key Design Decisions recording the choice and why the other options were rejected.

This decision sizes three design nodes (change-store, delivery, browser-sync) around the WebSockets approach. I can record this as a standalone decision doc if you'd prefer the full options/criteria/fit-verdict treatment, though the row in Key Design Decisions may be sufficient for a choice this clear.

**HLD updated sections:**

## Approach
Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered via self-hosted WebSockets, providing fast updates without tying the board to a realtime vendor. This accepts the extra connection and reconnect operations work in exchange for low-latency delivery under direct operational control.

The change store maintains replayable revisions so reconnected browsers can catch up. Delivery manages WebSocket sessions, connection lifecycle, and publication of committed changes to active connections. Browser sync implements subscription, reconnect detection, and catch-up requests.

## Key Design Decisions
- **Self-hosted WebSockets for change delivery.** Fast updates without vendor coupling, accepting connection management and reconnect complexity. Five-second HTTPS polling was rejected as too slow for staff coordination needs; hosted realtime services were rejected to avoid recurring fees and provider lock-in during the pilot phase.

Ready to proceed to the three nodes (change-store, delivery, browser-sync) once you approve this HLD update.