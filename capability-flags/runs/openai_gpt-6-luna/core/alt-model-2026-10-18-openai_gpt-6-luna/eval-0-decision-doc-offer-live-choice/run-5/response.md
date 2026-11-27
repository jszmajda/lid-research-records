Updated `docs/high-level-design.md` to select self-hosted WebSockets, record the tradeoffs, and establish the downstream responsibilities for the change store, delivery, and browser sync. The revised HLD reads as current intent without relying on our conversation.

## HLD for review

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit an event revision. Publish committed revisions to connected browsers over self-hosted WebSockets for low-latency updates without coupling the board to a realtime vendor. The change store retains replayable revisions and supports reliable publication. Delivery owns WebSocket connection management, while browsers reconnect and catch up from their last observed revision after interruptions. This approach accepts the operational work of managing connection capacity and recovery.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable event revisions and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions and delivery of published revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscription, reconnection, and catch-up from the last observed event revision.

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
- **Self-hosted WebSockets for live updates.** Five-second HTTPS polling would simplify stateless delivery but add repeated reads and up to several seconds of update lag. A hosted realtime service would reduce connection-management work and provide low-latency delivery, but introduce recurring fees and provider coupling. Self-hosted WebSockets provide low-latency updates without a realtime vendor dependency; the project accepts the added work of connection-capacity management, reliable publication, and reconnect/catch-up behavior. This choice requires replayable event revisions in the change store, session management in delivery, and recovery logic in browser sync.

Please review and explicitly approve or request changes before I proceed to the three downstream nodes.

Two follow-ups for your judgment:
1. This choice has credible alternatives with tradeoffs the downstream nodes will depend on. Do you want a project-level decision document for the full comparison, or is the HLD decision entry sufficient?
2. The existing Access design still describes the delivery approach as “still-open,” though it keeps delivery-specific subscription credentials outside Access. Should I update that sentence during the cascade? I left it untouched because it crosses into the ACCESS segment.

I treated vendor independence and lower update latency as rationale for this specific design choice, not as a new project-wide tenet. If you intend that preference to guide future infrastructure decisions too, please say so.