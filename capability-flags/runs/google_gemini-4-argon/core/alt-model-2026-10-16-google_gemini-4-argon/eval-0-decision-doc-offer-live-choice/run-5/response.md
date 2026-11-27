I have updated `docs/high-level-design.md` for Phase 1 to reflect the self-hosted WebSockets approach across `## Approach`, `## Architecture`, `## Tenets`, and `## Key Design Decisions`.

### Updated `docs/high-level-design.md`

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets.

Delivery, change storage, and browser recovery work together around this WebSocket pipeline: the change store records replayable event revisions and reliably publishes committed changes; the delivery service manages WebSocket sessions and streams revision updates to subscribed browsers; and browser sync maintains the connection, detects disconnects, and catches up from missed revisions on reconnect.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, replayable revision queries, and reliable publication of committed changes to delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket sessions, event subscriptions, and streaming committed revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscription lifecycle, disconnect detection, reconnect, and revision catch-up.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Prefer owning operational complexity in self-hosted infrastructure over coupling core workflows to third-party vendors.
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
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to browsers over self-hosted WebSocket sessions, accepting connection-capacity and reconnect/replay operational work in exchange for low-latency updates without recurring realtime-vendor fees or provider lock-in. Five-second HTTPS polling (simpler stateless operation and cursor queries, but higher repeated read load and multi-second lag) and a hosted realtime service (less connection ops, but recurring vendor cost, provider coupling, and external publication reconciliation) were considered.
```

---

### Questions for Phase 1 Review

1. **Decision doc vs. Key Design Decisions entry**: Because the delivery transport choice weighs three credible options against competing criteria (latency, operational burden, vendor coupling/recurring cost) and shapes the three downstream nodes (`change-store`, `delivery`, and `browser-sync`), would you like to record this in a standalone decision doc at `docs/decisions/change-delivery-approach.md` (linked from `## Key Design Decisions`), or keep the entry in `## Key Design Decisions` above as the sole record?
2. **Tenets**: Does the added tenet (*"Prefer owning operational complexity in self-hosted infrastructure over coupling core workflows to third-party vendors"*) capture your general lean alongside the existing infrastructure tenet, or would you prefer to adjust or omit it?
3. **Downstream note on `access`**: `docs/intent/access/access-design.md` currently notes in `## Context` that *"Authorization for HTTPS edit commands is independent of the still-open change-delivery approach."* Once you approve the HLD, should we also clean up that stale phrase in `access-design.md` before moving on to the three new LLDs?

Please let me know your feedback and whether you approve the HLD to proceed to Phase 2 (and which of `change-store`, `delivery`, or `browser-sync` you'd like to draft first).