I've updated `docs/high-level-design.md` for the self-hosted WebSockets approach (Phase 1). Here is the updated HLD in full for review before we move to Phase 2:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS, and browsers display a revisioned view of the board updated over self-hosted WebSockets.

Change storage, session delivery, and browser recovery coordinate around ordered event revisions. Each accepted edit commits a new event revision in the change store and is reliably published to the delivery service, which manages WebSocket sessions and streams committed revisions to subscribed browsers. Browsers track their current revision, surface connection loss, and reconnect to catch up on missed revisions after interruptions.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Authorizes HTTPS edit commands and snapshot reads against current server-side event assignments.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Persists authoritative event revisions, retains seven-day history, serves snapshot and replay reads, and reliably publishes committed edits for delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Manages self-hosted WebSocket sessions, subscription credentials, and live delivery of committed revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Maintains the browser's WebSocket subscription, tracks local event revisions, surfaces degraded connectivity, and runs reconnect and catch-up recovery.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to subscribed browsers over server-managed WebSocket sessions, backed by replayable revisions in the change store, reliable internal publication, and reconnect catch-up in the browser. Five-second HTTPS polling and a hosted realtime service were also considered, as all three meet the 15-second freshness goal: polling keeps delivery stateless via cursor queries but adds multi-second lag and repeated read traffic across up to 800 simultaneous browsers, while a hosted realtime service offloads socket capacity management at the cost of recurring vendor fees, provider coupling in delivery and browser clients, and external publication reconciliation. Self-hosted WebSockets delivers low-latency updates without tying the board to a realtime vendor, accepting operational ownership of connection capacity, session lifecycle, and reconnect recovery.
```

Before we move into Phase 2 for the child nodes, a few items to confirm at this Phase 1 stop:

1. **Decision doc vs. Key Design Decisions entry:** Because all three options satisfy the 15-second freshness goal, trade across latency, operational ownership, and vendor coupling/cost, and size `change-store`, `delivery`, and `browser-sync`, a cold reader could plausibly revisit this choice. Would you like me to capture it in a standalone decision doc at `docs/decisions/change-delivery.md` (linked from `## Key Design Decisions`), or is the `## Key Design Decisions` entry above sufficient?
2. **Tenet check before designing the three nodes:**
   - *Vendor coupling vs. operational toil:* Tenet 4 currently states *"Self-hosted and managed infrastructure are both permitted."* Was accepting extra ops work to avoid vendor lock-in specific to realtime delivery, or would you like a project-wide tie-breaker leaning toward **portable, vendor-independent runtime components over managed provider lock-in** (vs. **preferring managed services wherever they don't own client protocol**)?
   - *Recovery simplicity vs. field bandwidth:* As we design replay and catch-up across spotty market connections, should unforeseen trade-offs lean toward **simple state convergence (e.g., coarse snapshot fallback) over protocol complexity**, or **minimizing payload size on constrained mobile links over server/protocol simplicity**? (Let me know if any other tenets should be added or refined.)
3. **Sibling cascade note (`access`):** `docs/intent/access/access-design.md` still refers to *"the still-open change-delivery approach"* and notes that subscription credentials *"will belong to the delivery node."* Should I clean up that prose in `access-design.md` when we step into Phase 2, and would you like to walk the three new nodes in data-flow order (`change-store` → `delivery` → `browser-sync`)?

Does this HLD update look good to approve, or what would you adjust?