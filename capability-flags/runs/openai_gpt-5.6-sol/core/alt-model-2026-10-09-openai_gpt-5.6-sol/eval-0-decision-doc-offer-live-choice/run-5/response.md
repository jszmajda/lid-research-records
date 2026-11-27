**Phase 1: HLD Update**
`docs/high-level-design.md` now reads:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed change an event revision and records enough revision history for replay. A self-hosted WebSocket service pushes committed changes to connected browsers with low latency.

Change storage, delivery, and browser recovery form one revision protocol. The change store supports reliable publication and replay from a known revision. Delivery owns WebSocket sessions and distributes committed revisions. Browsers reconnect with their last applied revision, catch up on missed changes, and make connectivity loss visible while their view may be stale.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, replay reads, and the reliable handoff of committed revisions for publication.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection capacity, and distribution of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns live subscription, reconnect, catch-up, and visible stale-connection behavior.

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
- **Self-hosted WebSockets for committed-change delivery.** The service operates persistent browser connections and reconnect recovery to provide fast updates without coupling the board to a hosted realtime provider. Five-second HTTPS polling was operationally simpler but added repeated reads and update lag; a hosted realtime service reduced connection operations but introduced recurring fees and provider-specific publication and subscription behavior. This choice accepts connection-capacity and reconnect complexity and requires replayable revisions plus reliable publication across the change store, delivery, and browser-sync components.
```

The existing Access LLD remains behaviorally compatible, but `docs/intent/access/access-design.md:10` still calls the delivery approach “still-open.” I did not cross that segment boundary without approval.

This architectural choice also qualifies for a full project-level decision document because future maintainers could reasonably reconsider polling or hosted realtime after the three nodes depend on WebSockets.

1. Do you approve this HLD update?
2. Should the decision remain as the HLD entry, or should I add `docs/decisions/realtime-delivery.md` with the full tradeoff?
3. May I update the stale sentence in the Access LLD when proceeding?