**Phase 1: HLD**
Updated `docs/high-level-design.md`:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS, and the server assigns each committed change a monotonically increasing event revision. Connected browsers receive committed changes over self-hosted WebSocket sessions for low-latency updates without coupling the board to a hosted realtime provider.

The change store retains replayable revisions. Delivery manages socket sessions and publishes committed revisions. Browsers track the latest applied revision, reconnect after interruptions, and catch up from that revision before resuming live updates. HTTPS remains available for commands and board snapshots; it is not the routine update channel.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history and the replay boundary required for publication and catch-up.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions and publication of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns subscription, revision tracking, reconnect, and catch-up behavior.

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
- **Committed changes over self-hosted WebSockets.** The service operates persistent browser connections and revision-based reconnect and catch-up so updates arrive quickly without a realtime vendor dependency. Five-second HTTPS polling was rejected because it adds repeated reads and avoidable update lag; a hosted realtime service was rejected because its lower connection-operations burden comes with recurring fees and provider coupling.
```

`git diff --check` passes. Two decisions are needed before proceeding:

1. Do you approve this HLD update?
2. Should the WebSocket choice receive a full project-level decision document, or is the HLD decision entry sufficient?

The existing access LLD also says the delivery approach is “still-open.” May I remove that stale cross-segment wording when we proceed to the change-store, delivery, and browser-sync nodes?