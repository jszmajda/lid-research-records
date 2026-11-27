Updated `docs/high-level-design.md` with the self-hosted WebSocket approach. Here is the complete HLD for review:

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets. Fast updates are desirable, while the freshness goal remains 15 seconds under normal connectivity.

The change store retains replayable event revisions and supports reliable publication of committed changes. Delivery manages WebSocket sessions and their capacity. Browsers reconnect and catch up after interruptions using the authoritative revisions. The service operators own connection capacity and recovery operations.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: planned at `docs/intent/change-store/change-store-design.md`, with specs at `docs/intent/change-store/change-store-specs.md`. Owns revision history and reliable publication of committed changes for delivery and replay.
- Delivery: planned at `docs/intent/delivery/delivery-design.md`, with specs at `docs/intent/delivery/delivery-specs.md`. Owns self-hosted WebSocket sessions and delivery of committed changes.
- Browser sync: planned at `docs/intent/browser-sync/browser-sync-design.md`, with specs at `docs/intent/browser-sync/browser-sync-specs.md`. Owns the browser's connection, reconnection, and catch-up behavior.

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
- **Self-hosted WebSockets for committed changes.** They provide fast updates without a realtime provider's recurring fees or coupling, at the cost of operating connections and reconnect recovery. Five-second HTTPS polling is simpler and stateless but adds repeated reads and seconds of lag. A hosted realtime service reduces connection operations but introduces recurring fees and provider coupling. All three can meet the 15-second freshness goal.

---

The access design still describes delivery as an open choice. It is a separate segment, so I’ve left it untouched pending your direction.

1. Do you approve the HLD, or would you like changes?
2. For future decisions, should the project generally favor faster updates over operational simplicity once the freshness target is met, or decide case by case? Likewise, should avoiding vendor coupling be a general preference or case-by-case? Are there other tenets you want recorded?
3. This delivery choice has substantial tradeoffs across the three planned nodes. Would you like a standalone decision document preserving those tradeoffs, or is the HLD decision entry sufficient?
4. May I later update the stale wording in the access design as a separate cascade?