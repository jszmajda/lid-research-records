**Phase 1 — HLD updated** (`docs/high-level-design.md`). Problem, Tenets, Goals, and Non-Goals are unchanged. Revised sections in full:

---

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server commits each edit as one event revision; browsers render a revisioned view of the board. Browsers fetch snapshots over HTTPS and then hold a self-hosted WebSocket connection on which each committed revision is pushed as it happens. Subsecond updates would be useful, but are not required.

This project operates the realtime path itself rather than buying it from a provider. The change store keeps a replayable revision log and publishes commits reliably, the delivery component owns WebSocket sessions and connection capacity, and each browser reconnects and catches up from the revision log after a disconnect. Operating connection capacity and reconnect handling is the price paid for fast updates without recurring realtime fees or provider coupling.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Replayable revision history, read indexes, and reliable publication of commits to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. WebSocket sessions, connection capacity, and pushing committed revisions to subscribed browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Subscription over the socket, reconnect, and catch-up from the revision log after a gap.

## Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** Editors submit commands to the server, which assigns each committed edit one event revision. Peer-to-peer or browser-side merging was rejected: the tenets require one authoritative revision regardless of delivery route, and offline editing is a non-goal.
- **Self-hosted WebSockets for change delivery.** Committed revisions reach connected browsers over WebSocket connections this project runs. Five-second HTTPS polling was rejected: it meets the freshness target with the simplest stateless operation, but at the cost of repeated reads and a few seconds of lag. A hosted realtime service was rejected: the quickest route to low-latency updates with less connection operations, but at the cost of recurring fees and provider coupling. Self-hosted sockets were chosen accepting the work of owning connection capacity and reconnect problems.

---

Two questions before I proceed:

1. **Decision doc:** this choice was traded across three options and multiple criteria, and the three upcoming nodes are sized around it — it clears the bar for a full decision doc. Want me to write `docs/decisions/realtime-change-delivery.md` and link it from the Key Design Decisions entry, or keep just that entry as the record?
2. **Sibling segment (Access):** `access-design.md` still says authorization is independent of the "still-open change-delivery approach" — that phrase is now stale. Cross-segment cascade, so I'm asking rather than editing: shall I make that one-phrase fix?

Once you've reviewed the HLD and answered these, we'll walk the three nodes (change store, delivery, browser sync).