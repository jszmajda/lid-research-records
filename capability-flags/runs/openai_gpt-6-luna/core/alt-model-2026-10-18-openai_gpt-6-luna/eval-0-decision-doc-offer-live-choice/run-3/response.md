Updated `docs/high-level-design.md` to select self-hosted WebSockets, record the accepted connection and reconnect work, and set the responsibilities for the change store, delivery service, and browser sync. `git diff --check` passes. I’ve left the three node designs untouched pending your review of this HLD phase.

## Updated HLD

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit an event revision. Browsers receive low-latency notifications over self-hosted WebSocket connections and use revisions to recover changes after disconnects. The change store retains replayable revisions and supports reliable publication; the delivery service manages socket sessions and connection recovery. This avoids a realtime vendor dependency while accepting the connection-capacity and reconnect operations of self-hosted delivery.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Retains event revisions for replay and supports reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Owns self-hosted WebSocket sessions and delivery of revisioned change notifications.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Subscribes to change notifications and reconnects and catches up from the last applied event revision.

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
- **Self-hosted WebSockets for change delivery.** Five-second HTTPS polling and a hosted realtime service were considered. WebSockets provide low-latency updates without recurring realtime-service fees or provider coupling; the project accepts the additional connection-capacity, session-management, and reconnect work. The change store must make revisions replayable and publication reliable so delivery can serve connected browsers and support catch-up.

One adjacent reference needs a cascade: `docs/intent/access/access-design.md` still describes the delivery choice as open. Should that reference be updated when we continue with the three nodes, or do you want Access left unchanged? Also, would you like the WebSockets choice expanded into a standalone decision doc, or is the HLD decision entry sufficient?