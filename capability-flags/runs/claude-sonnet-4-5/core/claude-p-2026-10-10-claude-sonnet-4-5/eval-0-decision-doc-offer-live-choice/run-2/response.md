Updated HLD with the self-hosted WebSockets approach:

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to connected browsers via self-hosted WebSockets, providing subsecond update latency without coupling to a realtime vendor.

The change store maintains replayable revisions and publishes each committed edit to active connections. The delivery layer manages WebSocket sessions, handles reconnection scenarios, and ensures reliable publication. Browsers initiate WebSocket subscriptions on page load, apply streamed updates as they arrive, and catch up from missed revisions after reconnect.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Maintains replayable event revisions and publishes committed edits to the delivery layer's publication channel.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Manages WebSocket connection lifecycles, session tracking, and reliable streaming of committed edits to subscribed browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Initiates WebSocket subscriptions, applies streamed updates, and executes reconnect-with-catch-up recovery after connection loss.

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
- **Self-hosted WebSockets for change delivery.** Committed edits are streamed to browsers via self-hosted WebSocket connections rather than HTTPS polling or a hosted realtime service. Accepts connection management and reconnect complexity to achieve subsecond update latency without vendor coupling or recurring realtime-service fees. HTTPS polling was rejected for multi-second lag; hosted services were rejected to avoid provider lock-in for a core coordination path.

---

The HLD now reflects the WebSocket choice and its implications for the three nodes (change-store, delivery, browser-sync). Ready to proceed with the LLDs when you approve.