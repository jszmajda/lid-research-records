## Phase 1: HLD Update

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. A self-hosted WebSocket service delivers committed changes to connected browsers without a realtime provider dependency.

Delivery, change storage, and browser recovery are designed together. The change store retains replayable event revisions; delivery publishes committed revisions to socket sessions and manages connection capacity; browsers reconnect and catch up from the revision they last applied. HTTPS remains the command boundary and recovery path when a socket is unavailable.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Revision history, read indexes, and any publication outbox depend on the delivery approach.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns polling responses, socket sessions, or hosted publication, depending on the approach.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Its subscription, reconnect, and catch-up behavior depend on the approach.

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
- **Self-hosted WebSockets for board-change delivery.** Connected browsers receive committed revisions over server-operated WebSocket sessions. Five-second HTTPS polling was rejected because its repeated reads and delivery delay work against prompt board updates; a hosted realtime service was rejected because the pilot does not require provider-operated connection infrastructure and should avoid provider coupling. This choice requires replayable revisions, reliable publication, socket connection capacity, and browser reconnect-and-catch-up behavior.
```

This remains a live, project-level architectural choice with credible alternatives. Would you like its reasoning recorded in a standalone decision document under `docs/decisions/`, or is the HLD decision entry sufficient?

Please also approve or revise this HLD update before I draft the three affected design nodes.