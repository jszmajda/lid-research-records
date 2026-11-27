Added `docs/decisions/realtime-delivery.md` with the three options, their trade-offs, and why the project accepts self-hosting the connection and reconnect work. Linked it from the HLD. `git diff --check` passes.

Please review these Phase 1 artifacts and confirm they’re ready before I move on to the three design nodes.

### `docs/high-level-design.md`

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Deliver committed changes to browsers through self-hosted WebSockets for fast updates without a realtime vendor. The change store retains replayable event revisions and supports reliable publication; delivery manages WebSocket sessions; browsers reconnect and catch up from revisions after interruptions. The system owns connection capacity and reconnect reliability. Subsecond updates are useful, though the freshness goal does not require them.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable event revisions and the reliable publication path for committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket publication and connection sessions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns browser subscriptions, reconnection, and revision catch-up.

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
- **Self-hosted WebSockets for committed-change delivery.** Five-second HTTPS polling would reduce connection-management work but add repeated reads and update lag; hosted realtime would reduce connection operations but add recurring fees and provider coupling. Self-hosted WebSockets provide fast updates without a realtime vendor, with the trade-off that MarketBoard owns connection capacity and reconnect reliability. This choice requires replayable revisions and reliable publication in the change store, session management in delivery, and reconnect/catch-up behavior in browsers. See [the delivery decision](decisions/realtime-delivery.md) for the option analysis.

### `docs/decisions/realtime-delivery.md`

---
node: high-level-design
---

# Decision: Realtime Change Delivery

## Context

MarketBoard keeps one authoritative board per event and assigns a revision to each committed edit. Editors submit commands over HTTPS; delivery determines how connected browsers learn about committed revisions and recover after interruptions.

The system serves up to 800 simultaneous browsers, targets 99.5 percent availability during published event hours, and aims to show committed changes within 15 seconds under normal connectivity. Faster, subsecond updates are useful but are not required to meet the freshness goal. Browsers must recover the latest board after being disconnected for up to 20 minutes.

The delivery choice affects the work required of the change store, delivery service, and browser: cursor reads or publication, connection management, and reconnect/catch-up behavior. The project must balance update speed and independence from realtime vendors against the operational burden of running the delivery path.

## Decision Elements

- **Fast feedback — major.** Connected staff benefit from seeing committed status changes with little delay. The 15-second freshness goal is a bound, not a reason to avoid faster delivery.
- **Avoid realtime-vendor fees and coupling — major.** The delivery path should not require a realtime provider's recurring service or make board updates dependent on its subscription model.
- **Keep operational burden manageable — moderate.** Connection capacity and recovery work affect the team's ability to meet the 800-browser and event-hour availability goals. Lower operations burden is valuable, though not at the expense of the two priorities above.

These are local priorities for realtime delivery; no project-wide infrastructure tenet selects one delivery model.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically issue HTTPS requests for revisions after their last known cursor. This keeps delivery request/response-based and avoids long-lived connections, at the cost of repeated reads and delay until the next poll. The change store must support efficient cursor queries, and each browser must run and recover a polling loop.

- **Fast feedback — partial.** A five-second interval can satisfy the 15-second goal under normal connectivity, but changes wait for the next poll and request completion.
- **Avoid realtime-vendor fees and coupling — strong.** Delivery uses the existing HTTPS service and no realtime provider.
- **Keep operational burden manageable — strong.** The service does not own persistent browser sessions or socket reconnects, though it must handle repeated reads and cursor requests.

### Self-hosted WebSockets

Browsers maintain WebSocket sessions with MarketBoard's delivery service. The service publishes committed revisions to connected browsers; after interruption, browsers reconnect and catch up from revision history. The change store must retain replayable revisions and support reliable publication. MarketBoard operates connection capacity and reconnect reliability itself.

- **Fast feedback — strong.** Committed changes can be pushed without waiting for a polling interval.
- **Avoid realtime-vendor fees and coupling — strong.** The board's delivery path is self-hosted and does not depend on a realtime provider.
- **Keep operational burden manageable — weak.** MarketBoard owns connection capacity, session lifecycle, reliable publication, and reconnect/catch-up behavior across the service and browsers.

### Hosted realtime service

MarketBoard publishes changes to a realtime provider, which manages browser subscriptions and persistent connections. This reduces the connection operations owned by MarketBoard, but introduces provider credentials and a publication-reconciliation path, as well as recurring fees and dependence on the provider's service and subscription model.

- **Fast feedback — strong.** The provider distributes publications to subscribed browsers without a polling interval.
- **Avoid realtime-vendor fees and coupling — weak.** The design relies on a vendor service and its provider-specific subscription model.
- **Keep operational burden manageable — strong.** The provider manages browser connections, reducing MarketBoard's direct session and reconnect workload; MarketBoard still owns integration and publication reconciliation.

## Selection

Choose self-hosted WebSockets. They provide faster feedback than five-second polling without binding board delivery to a realtime vendor. The 15-second goal could be met by polling, but the project values faster updates enough to accept the additional operating work; avoiding realtime-provider fees and coupling also rules against hosted realtime for this use.

This choice makes connection capacity and reconnect reliability first-party operational responsibilities. It requires replayable event revisions and reliable publication in the change store, session management and WebSocket publication in delivery, and browser reconnection with revision catch-up. The component designs define the detailed publication, session, and recovery behavior while preserving this ownership split.