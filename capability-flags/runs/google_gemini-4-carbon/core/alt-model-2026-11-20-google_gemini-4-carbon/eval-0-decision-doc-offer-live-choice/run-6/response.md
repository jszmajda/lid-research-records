I have updated `docs/high-level-design.md` for **Phase 1 (HLD)** to settle on self-hosted WebSockets, written as current intent with the rejected alternatives recorded under `Key Design Decisions`.

### Updated `docs/high-level-design.md`

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS, and each committed edit receives a single authoritative event revision. Browsers display a revisioned view of the board and receive committed updates over self-hosted WebSockets.

Change storage, socket delivery, and browser recovery cooperate around event revisions: the change store persists replayable revisions and reliably publishes committed updates; delivery manages WebSocket sessions and streams updates to subscribed browsers; and browsers maintain live socket subscriptions, surface connectivity loss, and catch up from missed revisions after reconnecting.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Authorizes HTTPS commands against current server-side event assignments.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative board state, seven-day replayable revision history, and reliable publication of committed revisions.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription credentials, and live delivery of committed revisions to browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscription lifecycle, visible connectivity status, reconnect, and revision catch-up.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions reach subscribed browsers over self-hosted WebSocket sessions backed by replayable store revisions and browser reconnect/catch-up logic, delivering fast push updates without coupling the board to a realtime vendor or recurring provider fees, at the cost of operating connection capacity and reconnect recovery. Five-second HTTPS polling was rejected despite simpler stateless operation and meeting the 15-second freshness bound because it adds multi-second lag and repeated read load across up to 800 browsers; a hosted realtime service was rejected despite offloading socket operations because it introduces recurring vendor fees, provider coupling, and external publication reconciliation.
```

---

### Items for Phase 1 Review

1. **Decision doc vs. HLD entry**: Because all three delivery options satisfy the 15-second freshness goal and infrastructure tenet while trading update latency, connection operations, and vendor cost/coupling—and `change-store`, `delivery`, and `browser-sync` will all be sized around this choice—a cold reader could reasonably re-litigate why MarketBoard runs stateful WebSockets instead of 5-second polling or a hosted service. Would you like me to record this as a standalone decision doc at `docs/decisions/change-delivery.md` (linked from `Key Design Decisions`), or keep the `Key Design Decisions` entry above on its own?
2. **Tenet check**: Your rationale leaned toward accepting operational work to avoid vendor coupling, whereas `## Tenets` currently states only that *"Self-hosted and managed infrastructure are both permitted."* Should we add a general tie-breaker tenet for upcoming choices in `change-store` and `delivery` (e.g., *Prefer portable, self-operated mechanisms over vendor-specific services when operational burden is manageable*), or keep that tradeoff specific to realtime delivery while remaining neutral toward managed backing stores (such as managed Postgres or Redis)?
3. **Cross-segment cascade (`access`)**: `docs/intent/access/access-design.md` still refers to *"the still-open change-delivery approach"* (and notes that subscription credentials *"will belong"* to delivery). No `ACCESS-*` behavior changes, so I paused at the segment boundary—should I clean up that stale wording in `access-design.md` once the HLD is approved?
4. **Approval & next node**: Does the updated HLD look good to approve, and when we move to Phase 2 for the three nodes, would you like to take them in dependency order (`change-store` → `delivery` → `browser-sync`)?