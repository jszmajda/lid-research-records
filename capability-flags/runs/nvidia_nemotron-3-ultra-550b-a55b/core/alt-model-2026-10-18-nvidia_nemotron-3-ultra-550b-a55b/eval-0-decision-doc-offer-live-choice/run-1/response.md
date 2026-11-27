Updated the HLD with the self-hosted WebSockets decision. Here's the revised **Approach** and **Key Design Decisions** sections:

---

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered via **self-hosted WebSockets** for low-latency updates without a realtime vendor bill. This choice accepts the operational burden of connection capacity and reconnect management.

Delivery, change storage, and browser recovery are designed together around this approach. The change store provides replayable revisions and reliable publication. Delivery manages WebSocket sessions and replays. Browser sync handles reconnect and catch-up logic.

---

## Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** Editors submit commands to the server, which assigns each committed edit one event revision. Peer-to-peer or browser-side merging was rejected: the tenets require one authoritative revision regardless of delivery route, and offline editing is a non-goal.

- **Self-hosted WebSockets for change delivery.** Chosen over five-second HTTPS polling and hosted realtime services. Accepts connection management and reconnect complexity to avoid recurring vendor fees and provider coupling. The change store must support replayable revisions; delivery owns session lifecycle and replay; browser sync implements reconnect with catch-up.

---

**STOP for review.** 

Proceed to Phase 2: draft the three leaf LLDs — `change-store`, `delivery`, `browser-sync` — each with its own EARS specs?