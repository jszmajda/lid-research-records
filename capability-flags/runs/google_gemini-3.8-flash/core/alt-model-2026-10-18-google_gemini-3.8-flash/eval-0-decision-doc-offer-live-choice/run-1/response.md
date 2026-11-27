I have updated `docs/high-level-design.md` with the self-hosted WebSockets approach, reflecting the downstream implications across the change store, delivery, and browser sync components, and recorded the choice under Key Design Decisions.

Here is the revised High-Level Design:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit a strictly increasing event revision. Committed changes are delivered to staff browsers via self-hosted WebSockets.

The server manages live WebSocket sessions per market event and broadcasts committed revisions directly to connected clients. To support reconnecting browsers and late joiners, the change store maintains ordered, replayable event revisions. Browsers track the latest revision seen, reconnecting with catch-up replay queries when connections drop, and falling back to a full board snapshot if the client has fallen behind available replay history.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Manages session identities, role verification, and server-side authorization for HTTPS edit commands.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns committed revision persistence, replayable revision logs, and snapshot generation.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket connections, session lifecycle, and real-time broadcast of revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns client WebSocket connection management, reconnect/backoff logic, and gap recovery via replay or snapshot.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to connected staff browsers via server-managed WebSockets rather than periodic polling or a hosted realtime service. Polling was rejected due to repeated read load and latency lag; a hosted realtime service was rejected to avoid recurring vendor fees and provider lock-in. Self-hosted WebSockets trade off taking on server connection capacity and reconnection/replay management to deliver fast, low-latency updates independently.
```

Does this HLD update meet your intent, and would you also like to record this choice as a full decision doc in `docs/decisions/` before we proceed to Phase 2 for the three nodes?