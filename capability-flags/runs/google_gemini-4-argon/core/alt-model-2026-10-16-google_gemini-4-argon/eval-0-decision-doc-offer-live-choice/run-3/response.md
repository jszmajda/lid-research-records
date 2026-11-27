I have updated `docs/high-level-design.md` for Phase 1 to commit to self-hosted WebSockets across Approach, Architecture, and Key Design Decisions:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are pushed to connected browsers over self-hosted WebSockets, with replayable event revisions in the change store and browser-side reconnect and catch-up logic to recover missed revisions after a disconnect.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Authorizes HTTPS commands and snapshot fetches against server-side event assignments.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative event revisions, replayable revision history, and reliable publication to the WebSocket delivery layer.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket session management, subscription admission, and pushing committed revisions to connected revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket subscriptions, connection health detection, reconnect, and revision catch-up.

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
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed over self-hosted WebSockets rather than five-second HTTPS polling or a hosted realtime service. This provides low-latency updates without recurring realtime vendor fees or provider coupling, accepting the operational burden of managing socket connections, replayable revision storage, and browser reconnect/catch-up logic.
```

Please review this Phase 1 HLD update:

1. **Decision doc vs. Key Design Decisions entry**: Because the delivery transport choice weighs three credible options across multiple criteria (latency, vendor coupling/cost, operational burden) and sizes the `change-store`, `delivery`, and `browser-sync` nodes beneath it, a future cold reader could re-litigate it. Would you like to record this in a standalone decision doc (`docs/decisions/change-delivery-transport.md` linked from Key Design Decisions), or keep the Key Design Decisions entry above?
2. **Tenet check**: In settling this choice, you leaned toward accepting self-hosted operational complexity over recurring vendor coupling/cost. Should we record a general project tenet for that (e.g., *Prefer self-hosted operation over recurring vendor coupling when operational load is bounded*), or keep that rationale scoped to this transport decision?
3. **Downstream note (`access`)**: `docs/intent/access/access-design.md` currently mentions "the still-open change-delivery approach" in its Context section. With your approval, we can clean up that stale phrasing when we proceed to Phase 2.

Once you approve the HLD (and let me know your preferences on 1–3), which of the three nodes (`change-store`, `delivery`, or `browser-sync`) would you like to draft first in Phase 2?