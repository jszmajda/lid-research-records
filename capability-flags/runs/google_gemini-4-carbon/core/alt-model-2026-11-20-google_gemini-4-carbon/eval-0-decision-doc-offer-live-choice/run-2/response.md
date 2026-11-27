`docs/high-level-design.md` has been updated for Phase 1. Here is the full revised HLD for review before we move to Phase 2 (LLDs):

---

# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets.

Change storage, delivery, and browser recovery coordinate around event revisions. The change store persists board state with replayable event revisions and reliably publishes committed edits to delivery; delivery manages WebSocket sessions and streams committed revisions to subscribed browsers; browsers surface connection loss and reconnect with catch-up to recover missed revisions.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns board state, replayable event-revision history, and reliable publication of committed edits to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription credentials, and live push and catch-up delivery of committed revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns browser WebSocket lifecycle, visible connectivity state, reconnect, and catch-up to the latest event revision.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions stream to connected browsers over self-hosted WebSocket sessions, backed by replayable revisions and reliable publication in the change store and reconnect catch-up in the browser. Five-second HTTPS polling was rejected despite simpler stateless operation in favor of low-latency push without repeated polling reads across up to 800 browsers; a hosted realtime service was rejected despite lower connection-ops burden to avoid recurring vendor fees and provider coupling, accepting operational ownership of connection capacity and reconnect recovery.

---

### Review & Open Questions Before Phase 2

1. **Decision doc vs. `Key Design Decisions` entry:** Because the 15-second freshness target and managed-infrastructure tenet leave polling and hosted realtime genuinely viable to a cold reader—and `change-store`, `delivery`, and `browser-sync` will all be sized around this choice—would you like to record a standalone decision doc (`docs/decisions/change-delivery.md`, linked from `Key Design Decisions`), or keep the `Key Design Decisions` entry above as the sole record?
2. **Tenet check:** Does accepting extra operational work to avoid vendor coupling stay specific to realtime delivery (leaving managed backing services welcome where interfaces stay standard), or should `## Tenets` gain a general tie-breaker leaning toward operational ownership over proprietary vendor coupling across the stack (e.g., pub/sub and storage choices in the upcoming nodes)?
3. **Downstream `access` cascade note:** `docs/intent/access/access-design.md` still says *"Authorization for HTTPS edit commands is independent of the still-open change-delivery approach."* Once you approve the HLD, should we update that stale phrasing in `access-design.md` before drafting `change-store`, `delivery`, and `browser-sync`?