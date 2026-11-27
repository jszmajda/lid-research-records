Updated `docs/high-level-design.md` with the self-hosted WebSocket approach. The full HLD is below.

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Self-hosted WebSockets deliver committed changes to connected browsers for low-latency updates without a realtime provider dependency. Subsecond updates would be useful, but are not required; the normal-connectivity freshness target remains 15 seconds.

The change store supports replayable revisions and reliable publication of committed changes. Delivery manages WebSocket sessions and their capacity. Browsers reconnect and catch up after interruptions so their views recover to the authoritative board. The storage, delivery, and browser recovery designs must work together across these boundaries.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions and delivery to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns browser-side subscription, reconnect, and catch-up behavior.

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
- **Self-hosted WebSockets for committed changes.** Fast updates and freedom from realtime-provider coupling justify operating connection capacity and reconnect recovery. Five-second HTTPS polling offers simpler stateless operation but adds repeated reads and several seconds of lag. A hosted realtime service reduces connection operations but introduces recurring fees and provider coupling. Both can meet the 15-second freshness goal.

---

The access design still calls the delivery approach “open”; that is a downstream inconsistency to address with your approval. The three affected nodes have not yet been written, and the existing access specs remain unimplemented.

1. Do you approve this HLD and the subsequent cascade, beginning with the change-store node?
2. Should future infrastructure decisions generally favor provider independence over lower operational effort, or is that preference specific to realtime delivery? Are there other tie-breakers you want recorded as tenets?
3. Would you like a standalone decision document preserving the three options and their tradeoffs, or is the HLD decision entry sufficient?