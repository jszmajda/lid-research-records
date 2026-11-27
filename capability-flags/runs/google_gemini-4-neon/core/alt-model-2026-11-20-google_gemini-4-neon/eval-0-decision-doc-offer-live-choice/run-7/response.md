Updated `docs/high-level-design.md` for Phase 1 (`## Approach`, `## Architecture`, and `## Key Design Decisions`).

### Updated `docs/high-level-design.md`

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server commits each change with a single event revision and delivers committed changes to connected browsers over self-hosted WebSockets.

Delivery, change storage, and browser recovery are designed together around this model. The change store persists replayable event revisions and ensures reliable publication of committed changes; delivery manages WebSocket sessions and pushes updates; browsers maintain a revisioned view of the board with reconnect and catch-up logic to recover missed revisions after disconnection.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative event revisions, replayable revision history, and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, event subscriptions, and live update fan-out.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket connection lifecycle, reconnect handling, catch-up from missed revisions, and visible connectivity status.

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
- **Self-hosted WebSockets for change delivery.** Committed changes are pushed to browsers over self-hosted WebSockets rather than five-second HTTPS polling or a hosted realtime service. Five-second polling offers simpler stateless operation, but adds repeated reads and several seconds of lag; a hosted realtime service reduces connection-management operations, but introduces recurring vendor fees and provider coupling. Self-hosted WebSockets deliver fast updates without tying the board to a realtime vendor, accepting the operational work of managing connection capacity, replayable publication, and browser reconnect/catch-up.
```

### Questions before moving to Phase 2

1. **Decision doc vs. HLD entry:** All three delivery options meet the 15-second freshness goal and the tenets permit both self-hosted and managed infrastructure, so a future cold reader could plausibly re-litigate this choice — and `change-store`, `delivery`, and `browser-sync` are all about to be sized around it. Would you like me to record this as a standalone project-level decision doc at `docs/decisions/change-delivery.md` (linked from `## Key Design Decisions`), or is the `Key Design Decisions` entry in the HLD sufficient?
2. **Tenet check:** Is leaning toward avoiding vendor coupling/fees at the cost of extra self-hosted operational work specific to change delivery, or should it be added as a project-level tie-breaker under `## Tenets`?
3. **Cross-segment note (`access`):** `docs/intent/access/access-design.md` still refers to "the still-open change-delivery approach." Should I update that wording to stay coherent with the HLD, or leave `access` untouched for now?

Please review the HLD update and let me know your preferences on the items above before we proceed to the three nodes (`change-store`, `delivery`, `browser-sync`).