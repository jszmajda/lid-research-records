Here is the updated HLD for your review.

---

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit one event revision and pushes it to connected browsers over self-hosted WebSockets. Subsecond delivery to connected browsers is the expected outcome, though 15 seconds is the hard target.

The change store keeps a replayable revision log and a publication outbox so the delivery layer can push each committed edit and backfill reconnecting browsers. The delivery layer manages WebSocket sessions and subscription state per event. Browsers maintain the connection, reconnect on drop, and request a revision catch-up to close any gap.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, cursor-indexed reads, and the publication outbox that feeds WebSocket delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Manages WebSocket sessions, subscribes browsers to their event, pushes committed edits, and backfills reconnecting browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Manages the WebSocket connection lifecycle, reconnect with exponential backoff, and revision catch-up after a gap.

## Tenets

*(unchanged)*

## Goals

*(unchanged)*

## Non-Goals

*(unchanged)*

## Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** *(unchanged)*

- **Self-hosted WebSockets for change delivery.** Committed edits are pushed to browsers over server-managed WebSocket sessions. Five-second HTTPS polling was rejected because per-request overhead and polling lag become disruptive at opening-time burst rates (20 edits per second reaching 800 browsers). A hosted realtime service was rejected to avoid recurring vendor fees and provider coupling. Self-hosted WebSockets deliver sub-second push without a realtime vendor, at the cost of owning connection capacity, session state, and reconnect logic.

---

**Decision doc offer.** This choice stays live for a cold reader — three credible options weighed against multiple criteria, with three design segments being sized around the result. It clears the bar for a full decision doc at `docs/decisions/delivery-mechanism.md`. Would you like one, or is the KDD row sufficient?

Once you approve this HLD update (and let me know on the decision doc), I'll move on to the three LLD nodes.