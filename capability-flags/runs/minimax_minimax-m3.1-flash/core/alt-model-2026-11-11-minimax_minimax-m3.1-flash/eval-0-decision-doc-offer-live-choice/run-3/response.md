I loaded the skill, ran the coherence pre-flight, and completed Phase 1 (HLD check) with the delivery approach you selected.

**Pre-flight result:** `docs/high-level-design.md`, `docs/intent/access/access-design.md`, and `docs/intent/access/access-specs.md` are mutually coherent. No code or tests exist yet, so there is no drift to repair, and the delivery choice contradicts no existing spec. The access node already scopes delivery-specific subscription credentials to the delivery node, so nothing cascades into it this session.

Here is the revised HLD in full:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over self-hosted WebSocket connections: the server holds one socket session per connected browser and pushes each newly committed event revision down it.

Delivery, change storage, and browser recovery are designed around that route. The change store keeps a replayable log of event revisions and publishes each committed revision reliably to the delivery layer. The delivery layer owns socket sessions — accepting them, keeping them alive, and expiring them — and answers a reconnecting browser's catch-up request from the stored revisions. Browsers track the last revision they applied, reconnect after a dropped connection, and replay everything committed since that revision, so a browser that was away converges on the same board as one that never disconnected.

The revision log is the record of what happened; delivery is the path by which it is announced. Keeping the durable record separate from the announcement means a delivery failure cannot lose a revision, and a browser that was away for up to twenty minutes can be brought back to the present by replay rather than by a full resync.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns the replayable revision log, the read indexes, and the reliable publication of each committed revision to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns socket sessions — accept, keep alive, expire — and the push of each published revision to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser's socket subscription, its reconnect behavior, and its catch-up after a dropped connection.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- **Own over rent, within reason.** When a capability can be self-hosted at an acceptable operational cost, we lean toward operating it ourselves rather than buying a managed service.
- Event updates contain stall IDs and operational statuses, not customer records.

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
- **Self-hosted WebSocket delivery.** Committed changes are pushed to browsers over self-hosted WebSocket connections. Five-second HTTPS polling would have kept delivery stateless and request/response, at the cost of repeated reads and a few seconds of lag on every change; the store would have needed cursor queries and browsers a polling loop. A hosted realtime service would have given the quickest route to low-latency updates with the least connection operations to run, at the cost of recurring fees and provider coupling; the store would have needed publication reconciliation and delivery a provider wrapper. Self-hosted sockets place connection capacity, replay, and reconnection work on this project, and that operational cost is accepted in exchange for fast updates with no realtime vendor dependency.
```

What changed: the delivery approach is no longer open; the three unwritten nodes now carry WebSocket-shaped responsibilities (replayable revisions and reliable publication in the store, session management in delivery, reconnect and catch-up in browser sync); the key decision and the rejected alternatives are recorded.

Three things need your call before I go further:

1. **The infra tenet.** I replaced "Self-hosted and managed infrastructure are both permitted" with "**Own over rent, within reason.** When a capability can be self-hosted at an acceptable operational cost, we lean toward operating it ourselves rather than buying a managed service." The old wording kept the choice open; the new one is a forward-looking tie-breaker that stays true after this decision. Do you want it sharpened as written, kept as the original neutral wording, or split into two tenets?

2. **Decision doc for this choice.** A cold reader will find WebSockets-over-polling non-obvious and may be tempted to reverse it, so this clears the bar for a full decision doc at `docs/decisions/delivery-approach.md` (criteria, options, selection). The Key Design Decisions bullet above is the alternative. Do you want the doc?

3. **Inspection for the three nodes.** Default is that you read each phase's output at its stop. For the change-store, delivery, and browser-sync nodes I can instead (or additionally) run a zero-context reader over the drafts, or a delegated inspector reviewing in your place. Which do you want?

One assumption I made without asking: sockets are TLS-wrapped (`wss://`) on the same origin policy as the command endpoint. Say if you want that stated differently.