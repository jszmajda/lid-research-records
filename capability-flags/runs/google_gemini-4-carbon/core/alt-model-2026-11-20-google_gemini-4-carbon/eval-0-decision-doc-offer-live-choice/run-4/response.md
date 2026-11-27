`docs/high-level-design.md` is updated for the self-hosted WebSockets approach. Here is the full updated HLD for Phase 1 review:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS, and the server commits each accepted edit at the next event revision. Browsers load a revisioned view of the board and receive committed updates over self-hosted WebSockets.

Change storage, delivery, and browser recovery work together around ordered event revisions. The change store records replayable revisions and publishes committed updates reliably; delivery manages WebSocket sessions and fans updates out to subscribed browsers; browsers handle reconnects and catch up from their last known revision so transient drops do not leave stale boards on screen.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative board state, replayable event revisions, seven-day retention, and reliable publication of committed revisions.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, subscription credentials, and live and catch-up revision delivery.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns browser socket subscriptions, reconnect and catch-up logic, and visible connectivity status.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to subscribed browsers over self-hosted WebSocket sessions, backed by replayable revisions and reliable publication in the change store and reconnect catch-up in the browser. Five-second HTTPS polling would meet the 15-second freshness goal with simpler stateless operation, but was rejected because it adds repeated read load and multi-second delivery lag; a hosted realtime service would offload connection management, but was rejected to avoid recurring vendor fees and provider coupling. MarketBoard accepts owning connection capacity and reconnect operations to deliver fast updates without tying the board to a realtime vendor.
```

Before we move to Phase 2 for `change-store`, `delivery`, and `browser-sync`, please confirm a few points on the HLD:

1. **Decision doc vs. Key Design Decisions entry**: Because all three options satisfy the 15-second freshness goal, no constraint ruled out polling or hosted realtime, and three downstream nodes are about to be sized around this choice, a cold reader could plausibly revisit why MarketBoard runs stateful WebSocket sessions and replay on a 15-second budget. Would you like me to capture this in a standalone decision doc at `docs/decisions/change-delivery.md` (linked from `## Key Design Decisions`), or keep the HLD entry above on its own?
2. **Tenet check**: `## Tenets` currently states only the permission boundary (*"Self-hosted and managed infrastructure are both permitted..."*). As `change-store` and `delivery` face infrastructure choices (e.g., cross-instance pub/sub and durable storage), should we add a one-line tie-breaker tenet—such as leaning toward **portable, self-operated components over vendor coupling**, or conversely **preferring managed backing services where they do not couple the browser protocol**—or keep that trade-off local to the delivery decision?
3. **Sibling cascade flag (`access`)**: `docs/intent/access/access-design.md` remains substantively unchanged (`ACCESS-*` specs are unaffected), though its prose still mentions *"the still-open change-delivery approach"* and *"will belong to the delivery node."* Should I clean up that wording in `access-design.md` when we step into Phase 2?
4. **HLD approval**: Does the updated HLD look good to approve, and which of the three nodes (`change-store`, `delivery`, `browser-sync`) would you like to draft first?