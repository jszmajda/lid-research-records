I've updated `docs/high-level-design.md` to reflect the self-hosted WebSockets approach, the resulting responsibilities across `change-store`, `delivery`, and `browser-sync`, the vendor-independence tenet lean, and the entry in `## Key Design Decisions`.

Here is the updated HLD in full:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets.

When an edit commits, the change store assigns the next event revision and records it in replayable revision history so reliable publication to active socket sessions and reconnect catch-up read from the same authoritative log. The delivery service manages per-event WebSocket sessions and broadcasts committed revisions to subscribed browsers. Connected browsers apply live revisions in order; after a disconnect, browsers reconnect and catch up from their last known revision (or load a fresh board snapshot when outside the replay window), surfacing connectivity loss distinctly until synchronization is restored.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative event revisions, seven-day revision history, replay queries for catch-up, and reliable publication to the delivery tier.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket session lifecycle, event-scoped subscription authorization, and live revision broadcast.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the WebSocket subscription lifecycle, visible disconnect state, reconnect backoff, and revision catch-up.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Self-hosted and managed infrastructure are both permitted. Event updates contain stall IDs and operational statuses, not customer records.
- Prefer self-hosted operational ownership over recurring vendor coupling when delivering low-latency updates.

## Goals

- Show committed changes in connected browsers within 15 seconds under normal connectivity.
- Support 800 simultaneous browsers and opening-time bursts of 20 edits per second.
- Recover the latest board after a browser has been disconnected for up to 20 minutes.
- Retain seven days of event revisions for operational investigation.
- Achieve 99.5 percent availability during published event hours.

## Non-Goals

- Offline editing or resolving conflicting offline commands.
- Vendor payments, customer information, or public attendee access.
- Multi-region active-active operation for the pilot.

## Key Design Decisions

- **Commands over HTTPS, one authoritative board per event.** Editors submit commands to the server, which assigns each committed edit one event revision. Peer-to-peer or browser-side merging was rejected: the tenets require one authoritative revision regardless of delivery route, and offline editing is a non-goal.
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to browsers over self-hosted WebSocket sessions backed by replayable event revisions in the change store. Five-second HTTPS polling was rejected because repeated polling reads add lag and read load against the store, whereas sockets deliver fast updates directly. A hosted realtime service was rejected to avoid recurring vendor fees and provider coupling, accepting the operational work of managing socket capacity, session lifecycle, and reconnect catch-up in-house.
```

Before we move to Phase 2 for the three nodes (`change-store`, `delivery`, and `browser-sync`), please review the updated HLD:

1. **Decision recording**: Because this choice trades three credible options across multiple criteria (latency, operational burden, vendor cost/coupling) and shapes three downstream design nodes (`change-store`, `delivery`, `browser-sync`), a cold reader could plausibly re-litigate why we didn't use five-second polling (given the 15-second freshness goal) or a managed realtime service. Would you like to record this in a standalone decision doc at `docs/decisions/change-delivery-transport.md` linked from `## Key Design Decisions`, or keep the entry in `## Key Design Decisions` as written?
2. **Tenet check**: I added the tie-breaker *"Prefer self-hosted operational ownership over recurring vendor coupling when delivering low-latency updates"* under `## Tenets` alongside the existing infrastructure tenet. Would you like to keep that lean, adjust how it interacts with the existing *"Self-hosted and managed infrastructure are both permitted"* tenet, or omit it and keep the preference scoped only to this transport decision?
3. **HLD approval & next node**: Does the HLD look ready, and which of the three nodes (`change-store`, `delivery`, or `browser-sync`) would you like to draft first in Phase 2?