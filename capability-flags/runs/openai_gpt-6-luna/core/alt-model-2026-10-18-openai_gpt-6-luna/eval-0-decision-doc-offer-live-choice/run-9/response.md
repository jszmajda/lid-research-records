Updated `docs/high-level-design.md` for self-hosted WebSockets. `git diff --check` passes.

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit an event revision and pushes committed changes to connected browsers over self-hosted WebSockets. This favors low-latency updates without a realtime vendor, while making connection capacity, reliable publication, reconnection, and catch-up part of MarketBoard's operational responsibilities. Event revisions provide the history needed to recover after a browser disconnects.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative, replayable event revisions and the persistence support needed for reliable publication and client catch-up.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions and reliable publication of committed changes to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns browser subscriptions, reconnection, and catch-up from event revisions.

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
- **Self-hosted WebSockets for change delivery.** Five-second HTTPS polling was rejected because it adds repeated reads and update lag. A hosted realtime service was rejected to avoid recurring realtime fees and provider coupling. Self-hosted WebSockets provide low-latency push delivery without those dependencies, at the cost of operating connection capacity, reliable publication, and reconnect/catch-up behavior.

Please review this HLD. Does it capture your choice and the component responsibilities? Approve it or send numbered feedback.

Two decisions for your review:
1. Should avoiding realtime-vendor fees and coupling, even at added operational cost, be a project-wide tenet, or remain specific to this delivery decision?
2. Should the WebSockets choice stay as the HLD decision entry, or would you like a full decision document recording the trade-offs?

I’ll wait for your review before moving on to the three design nodes.