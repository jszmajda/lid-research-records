Phase 1 (HLD) is updated to record the self-hosted WebSockets choice. Full updated HLD:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers hold self-hosted WebSocket sessions that stream the revisioned board. Committed changes publish to connected browsers over those sessions, and a browser that reconnects catches up by replaying the revisions it missed.

Change storage, delivery, and browser recovery are designed together around this choice: the change store keeps replayable revisions and a reliable publication path, delivery owns socket sessions and reconnection, and browser sync owns reconnect and catch-up. Subsecond updates would be useful, but are not required.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Replayable revision history and a publication path that hands committed changes to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions: accepting connections, publishing committed revisions, and managing reconnect capacity.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns subscription over the socket session, reconnect, and catch-up of missed revisions.

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
- **Self-hosted WebSockets for change delivery.** Browsers hold WebSocket connections to servers this project operates; committed revisions publish over those sessions. Alternatives considered: five-second HTTPS polling — simplest stateless operation, but repeated reads, a few seconds of lag, cursor queries in the store, and a polling loop in every browser; a hosted realtime service — quickest route to low-latency updates with fewer connection operations, but recurring fees and provider coupling. Chosen to get fast updates without tying the board to a realtime vendor; the connection and reconnection operations are accepted operating work.
```

Two decisions for you at this stop:

1. **Decision doc?** This choice traded three credible options against multiple criteria, and the three nodes you want next get sized around it — so it qualifies for a full decision doc (`docs/decisions/self-hosted-websockets.md`) laying out options, criteria, and selection for a cold reader. The alternative is the HLD Key Design Decisions row above, which is already recorded. Full decision doc, or keep just the row?
2. **Cascade flag (cross-segment):** `docs/intent/access/access-design.md` says authorization is "independent of the still-open change-delivery approach" — now stale. The access specs themselves don't reference delivery. May I fix that one line when we touch the three nodes, or leave access untouched?

Give numbered feedback on the HLD (or approve it) and answer the two questions; then we'll start the three nodes — change store, delivery, browser sync — as LLD drafts.