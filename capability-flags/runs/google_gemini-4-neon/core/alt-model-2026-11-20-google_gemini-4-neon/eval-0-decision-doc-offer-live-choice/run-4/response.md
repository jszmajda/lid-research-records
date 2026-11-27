Updated `docs/high-level-design.md` to record self-hosted WebSockets as the change-delivery approach, align the architecture summaries for `change-store`, `delivery`, and `browser-sync`, and add the choice to **Key Design Decisions**:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets.

Change storage, delivery, and browser sync are designed together around this model: the change store persists replayable event revisions and reliably publishes committed changes; the delivery service manages WebSocket sessions, connection capacity, and fan-out; and browsers handle subscription, reconnect, and revision catch-up after disconnects.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative event revisions, replayable revision history, and reliable publication of committed changes.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, connection capacity, subscription authorization, and live fan-out.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscriptions, disconnect visibility, reconnect handling, and revision catch-up.

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
- **Self-hosted WebSockets for change delivery.** Connected browsers receive committed edits over self-hosted WebSockets backed by replayable event revisions and reliable publication. Five-second HTTPS polling (simpler stateless operation, cursor queries, request/response delivery, browser polling loop) was rejected because it adds repeated read load and multi-second lag; a hosted realtime service (faster path to low-latency delivery with less connection-ops burden, publication reconciliation, and provider subscription model) was rejected to avoid recurring realtime vendor fees and provider coupling. Self-hosted WebSockets deliver fast updates without vendor lock-in, accepting the operational responsibility for connection capacity, session management, and reconnect/catch-up logic.
```

**Before we move to Phase 2:**

1. **Decision doc offer:** Because all three delivery options satisfy the 15-second freshness goal and the tenets, trade off across multiple criteria (latency, vendor cost/coupling, and connection-ops burden), and size three upcoming design nodes (`change-store`, `delivery`, `browser-sync`), a cold reader could re-litigate this choice later. Would you like to record it as a full project-level decision doc at `docs/decisions/change-delivery.md` (linked from the HLD's Key Design Decisions entry), or keep just the Key Design Decisions entry above?
2. **HLD review & cascade:** Does the updated HLD look right to approve? Note also that `docs/intent/access/access-design.md` still mentions the "still-open change-delivery approach" — I left it untouched during Phase 1 and can clean that up when we cascade into the LLDs. Once approved, let me know which of the three nodes (`change-store`, `delivery`, `browser-sync`) you want to draft first.