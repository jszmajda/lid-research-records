Updated `docs/high-level-design.md` for the self-hosted WebSockets approach. The change store, delivery, and browser-sync nodes remain untouched.

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets. Socket delivery provides fast updates without recurring realtime-service fees or provider coupling, in exchange for operating connection capacity and reconnect handling ourselves.

The change store provides replayable revisions and reliable publication of committed changes. Delivery manages socket sessions and publication to connected browsers. Browsers reconnect after connectivity failures and catch up from their last received revision. Delivery, change storage, and browser recovery must be designed together around those revision and recovery contracts.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable revision history, read indexes, and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions and publication to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns subscriptions, reconnect, and catch-up from the last received revision.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Prefer operating realtime connections ourselves over recurring realtime-vendor fees and provider coupling.

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
- **Self-hosted WebSockets for committed-change delivery.** Five-second HTTPS polling would keep delivery stateless but add repeated reads and several seconds of lag. A hosted realtime service would reduce connection operations but introduce recurring fees and provider coupling. Self-hosted sockets provide fast updates without a realtime vendor; the project accepts connection-capacity and reconnect operations, replayable revisions, reliable publication, and browser catch-up as downstream obligations.

---

Please review this HLD before we start the three nodes. Two related choices:

1. Is the Key Design Decisions entry sufficient, or would you like a standalone decision doc preserving the full delivery-option tradeoff?
2. The Access LLD still describes delivery as “still-open.” May I refresh that stale wording when we cascade, or leave Access untouched?