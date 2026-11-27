Updated `docs/high-level-design.md` with self-hosted WebSockets as the committed-change delivery approach. The HLD now assigns replayable revisions and reliable publication to the change store, session and connection-capacity management to delivery, and reconnect/catch-up to browser sync. It records the accepted operational costs and the reasons for choosing this approach over polling and a hosted service. The existing 15-second freshness goal remains.

**Phase 1 review — updated HLD**

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS, and the server assigns each committed change an event revision. A self-hosted WebSocket delivery service pushes committed changes to connected browsers for low-latency updates without a realtime-service vendor dependency. Event updates contain stall IDs and operational statuses, not customer records. Browsers reconnect and use the event's replayable revisions to catch up after interruptions.

The change store retains replayable revisions and supports reliable publication of committed changes to delivery. Delivery manages WebSocket sessions and connection capacity. Browser sync handles reconnect and revision catch-up. Self-hosting adds connection-capacity and reconnect operations; those costs are accepted in exchange for low-latency updates without recurring realtime-vendor fees or provider coupling. The project freshness goal remains delivery of committed changes within 15 seconds under normal connectivity.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative event revisions, replay history, and reliable publication of committed changes to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection capacity, and delivery of published revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser subscription lifecycle, reconnect behavior, and catch-up from replayable revisions.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Avoid recurring realtime-vendor costs and coupling even when self-hosting adds connection operations.

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
- **Self-hosted WebSockets for committed-change delivery.** Five-second HTTPS polling would use simpler stateless request/response delivery but add repeated reads and up to several seconds of update lag. A hosted realtime service would reduce connection-management work but add recurring fees and provider coupling. Self-hosted WebSockets provide low-latency push without that vendor dependency; the project accepts responsibility for connection capacity and reconnect behavior. This choice requires replayable revisions and reliable publication in the change store, session management in delivery, and reconnect/catch-up in browser sync.
```

The update reads coherently with the existing architecture and preserves the stated freshness and recovery goals. This is a project-level choice with credible alternatives and downstream nodes being shaped around it; a cold reader could reasonably revisit the trade-offs. Would you like a full decision document for it, or is the HLD decision entry sufficient?

Please review and approve the HLD direction. I’ll stop here before drafting the three nodes.