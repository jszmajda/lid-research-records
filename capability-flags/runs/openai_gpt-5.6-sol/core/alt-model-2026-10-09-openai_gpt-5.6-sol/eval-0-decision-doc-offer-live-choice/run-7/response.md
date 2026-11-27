**Phase 1: HLD Review**
Updated `docs/high-level-design.md`:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. The service delivers committed changes over self-hosted WebSocket connections so connected browsers receive updates with low latency without depending on a realtime service provider.

The change store retains replayable event revisions and reliably exposes committed changes for publication. Delivery owns WebSocket connection capacity, sessions, and update publication. Browsers reconnect with their last applied revision and catch up before resuming live updates. HTTPS remains the command path and the recovery path for obtaining a current board snapshot when retained revisions cannot bridge a gap.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable event revisions and reliable availability of committed changes for publication and catch-up.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection capacity, publication, and server-side disconnect handling.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns live subscription, reconnect, revision catch-up, and snapshot recovery behavior.

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
- **Self-hosted WebSockets for committed-change delivery.** The service operates persistent browser connections and reconnect recovery to provide fast updates without recurring realtime-provider fees or provider coupling. Five-second HTTPS polling was rejected because it adds repeated reads and avoidable update lag. A hosted realtime service was rejected because its lower connection-operations burden does not outweigh its recurring cost and coupling for this board.
```

This choice remains sufficiently live that a future reader could reasonably re-litigate it, and the three downstream nodes will be designed around it. Please decide:

1. Do you approve this HLD update?
2. Should the WebSocket choice receive a full project-level decision document, or is the HLD decision entry sufficient?
3. `access-design.md` still calls delivery “still-open.” Should the next phase include that wording-only coherence cleanup alongside drafting the three affected nodes?