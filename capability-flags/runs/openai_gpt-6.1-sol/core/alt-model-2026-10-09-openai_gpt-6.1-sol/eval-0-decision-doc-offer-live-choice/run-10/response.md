Updated `docs/high-level-design.md` to select **self-hosted WebSockets** and record the accepted operations tradeoff. Here are the revised sections for review.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Self-hosted WebSockets deliver committed changes to connected browsers, favoring fast updates without a realtime vendor dependency or recurring realtime service fees. The required freshness target remains 15 seconds under normal connectivity; subsecond delivery is desirable rather than a separate guarantee.

Change storage, delivery, and browser recovery form one revision-based path. The change store provides replayable event revisions and reliable publication of committed changes. Delivery operates WebSocket sessions and owns connection capacity and reconnect handling. Browser sync subscribes to event updates, reconnects after interruption, and catches up from its last applied revision. The project accepts the additional connection and recovery operations work required by self-hosting. Event updates contain stall IDs and operational statuses, not customer records.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, replay queries, and reliable publication of committed revisions.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection capacity, and server-side reconnect/catch-up coordination with the change store.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscription, browser reconnect, and catch-up from the last applied event revision.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Prefer fast, vendor-independent updates over minimizing connection and reconnect operations work.

## Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** Editors submit commands to the server, which assigns each committed edit one event revision. Peer-to-peer or browser-side merging was rejected: the tenets require one authoritative revision regardless of delivery route, and offline editing is a non-goal.
- **Self-hosted WebSockets for change delivery.** Fast updates and independence from a realtime vendor outweigh the additional connection-capacity and reconnect operations burden. Five-second HTTPS polling offers simpler stateless operation and meets the freshness target, but adds repeated reads and seconds of lag. A hosted realtime service reduces connection operations and accelerates delivery implementation, but introduces recurring fees and provider coupling. Self-hosted WebSockets require replayable revisions and reliable publication in the change store, session management in delivery, and reconnect/catch-up logic in browser sync.

---

The coherence check found one downstream wording mismatch: `docs/intent/access/access-design.md` still calls change delivery “still-open.” Its command-authorization design remains compatible with the selected approach. The three new nodes await their design reviews.

Before proceeding:

1. **Do you approve this HLD revision**, including the new tie-breaker tenet?
2. This choice has credible alternatives and shapes three nodes. Would you like a **standalone decision document** preserving the criteria and fuller tradeoffs, or is the HLD decision entry sufficient?
3. May I update the stale delivery-choice wording in the Access design when we begin the downstream work?