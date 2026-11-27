HLD updated to record the WebSocket choice. Here is the revised `docs/high-level-design.md` in full:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over self-hosted WebSocket connections: the server holds a socket per subscribed browser and pushes each newly committed revision on it. Board snapshots stay readable over HTTPS for the initial load of a browser.

### Delivery of committed changes

The delivery route shapes the three components below the HTTPS command boundary:

- **Change store** keeps committed revisions replayable in order, so a browser that missed changes can be brought forward, and publishes each committed revision reliably to the delivery layer.
- **Delivery** owns socket sessions: accepting and closing connections, authorizing subscriptions, carrying committed revisions to connected browsers, and bringing a reconnecting browser forward from the revision it last saw.
- **Browser sync** holds the socket open, reconnects when the connection drops, and resumes from its last known revision.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Revision history is replayable in order and each committed revision is published reliably to the delivery layer.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns socket sessions — accepting and closing connections, authorizing subscriptions, pushing committed revisions, and bringing reconnecting browsers forward.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser's socket subscription, reconnection, and resumption from the last known revision.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Self-hosted and managed infrastructure are both permitted. Event updates contain stall IDs and operational statuses, not customer records.

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
- **Committed changes reach browsers over self-hosted WebSocket connections.** The project operates the socket tier itself and pushes each committed revision to the sockets subscribed to that event, serving catch-up from the revision log when a browser reconnects. Five-second HTTPS polling and a hosted realtime service were the alternatives. Polling was rejected for its repeated reads and seconds of lag on every browser; a hosted realtime service was rejected for its recurring per-connection fees and the provider coupling it would introduce. Self-hosting costs the project the connection capacity, session management, and reconnect handling that a hosted service would have carried, and the project accepts that cost in exchange for fast updates and no dependency on a realtime vendor.
```

**Phase 1 stop — decisions I need from you:**

1. **HLD revision** — approve as written, or name what to change.
2. **Tenet elicitation** — is "keep the board off a realtime vendor" only this one decision, or a general project lean? The existing tenet says "Self-hosted and managed infrastructure are both permitted." If the vendor-free delivery choice is general, that tenet needs revising and a Non-Goal may be warranted (e.g. hosted realtime services as the delivery path). I did not assume either way.
3. **Decision doc** — this choice stays live for a cold reader (three viable options traded against latency, cost, ops burden, and coupling, and the three unwritten nodes get sized around it), so it may earn a full decision doc at `docs/decisions/delivery-approach.md` with a link from the HLD decision. Say the word and I'll write it; otherwise the Key Design Decisions row stands alone.
4. **Cross-segment cascade** — `docs/intent/access/access-design.md:10` still says authorization is "independent of the still-open change-delivery approach", which is now stale wording. It's a one-line edit in the access segment; per cross-segment discipline I'm not touching it without your go-ahead. Approve and I'll fix it.

The three nodes (change-store, delivery, browser-sync) come next, as you said.