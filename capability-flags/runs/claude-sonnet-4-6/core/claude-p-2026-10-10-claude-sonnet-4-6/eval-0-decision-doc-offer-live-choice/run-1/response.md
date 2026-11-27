Here is the updated HLD for review.

---

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit one event revision; browsers display the current revisioned view of the board.

Committed changes are delivered to browsers over self-hosted WebSockets. This achieves low-latency delivery without coupling the board to a realtime vendor. The change store maintains replayable event revisions and a reliable publication outbox so the delivery layer can fan changes out to open sessions. The delivery component owns WebSocket session lifecycle and publication. Browsers maintain a persistent connection and carry reconnect and catch-up logic for resuming after a disconnect.

## Architecture

- **Access:** `docs/intent/access/access-design.md`. Written below the stable HTTPS command boundary.
- **Change store:** `docs/intent/change-store/change-store-design.md`. Not written yet. Holds replayable event revisions and a reliable publication outbox; the delivery layer reads from the outbox to fan changes out to open sessions.
- **Delivery:** `docs/intent/delivery/delivery-design.md`. Not written yet. Manages WebSocket sessions, reads from the publication outbox, and owns the reconnect protocol including the catch-up handshake.
- **Browser sync:** `docs/intent/browser-sync/browser-sync-design.md`. Not written yet. Maintains the WebSocket connection, handles reconnect and catch-up on resume, and makes connectivity failures visible to the user.

## Tenets

*(unchanged)*

## Goals

*(unchanged)*

## Non-Goals

*(unchanged)*

## Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** *(unchanged)*

- **Self-hosted WebSockets for delivery.** The board delivers committed changes to browsers over server-managed WebSocket connections. HTTPS polling was rejected because it introduces up to five seconds of lag and adds repeated read load at scale. A hosted realtime service was rejected to avoid vendor coupling and recurring third-party fees. Self-hosted WebSockets achieves low-latency delivery under the 15-second freshness goal with no vendor dependency, at the cost of owning connection capacity and reconnect operations.

---

**Decision doc offer:** This delivery choice clears the bar — three credible options, multiple criteria, and all three unwritten nodes will be sized around it. A cold reader would question why self-hosted WebSockets over polling or a hosted service. I can write a full `docs/decisions/delivery-approach.md` with the options and selection analysis. Otherwise I can leave the Decisions row in the HLD as-is. Want the doc?

Once you've approved the HLD, we can move on to the three nodes (change store, delivery, browser sync) one at a time.