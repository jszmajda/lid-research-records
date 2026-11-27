I have updated `docs/high-level-design.md` for the self-hosted WebSockets approach. Here is the updated HLD in full:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets.

When an edit commits, the change store assigns an event revision and records the change in a replayable revision history for reliable publication. The delivery component manages WebSocket sessions and pushes committed revisions to subscribed browsers, while browsers maintain the socket connection and run reconnect and catch-up logic from their last known revision when connectivity drops.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Authorizes HTTPS commands and snapshot fetches against server-side event assignments.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative event revisions, seven-day replayable revision history, and reliable publication to the delivery component.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket session management, event subscription routing, and revision fan-out and replay to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser WebSocket lifecycle, visible connectivity status, and reconnect and catch-up from the last applied revision.

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
- **Self-hosted WebSockets for change delivery.** Committed event revisions are pushed to browsers over self-hosted WebSocket sessions, backed by replayable revisions in the change store and browser reconnect/catch-up logic. Five-second HTTPS polling (simpler stateless operation, but higher repeated read load and multi-second lag) and a hosted realtime service (lower connection-ops burden, but recurring vendor fees and provider coupling) were considered; self-hosted WebSockets were chosen to get low-latency updates without coupling the board to a realtime vendor, accepting connection capacity and reconnect operations work in exchange.
```

### Items for Review (Phase 1 Stop)

1. **Decision doc vs. Key Design Decisions entry**: Because the change-delivery choice weighs three credible options across multiple criteria (latency, vendor coupling, recurring cost, operational burden) and shapes the three downstream nodes (`change-store`, `delivery`, and `browser-sync`), a cold reader could plausibly re-litigate it. Would you like to record this in a standalone decision doc at `docs/decisions/change-delivery.md` (linked from Key Design Decisions), or keep it solely as the Key Design Decisions entry above?
2. **Tenet check**: You resolved this trade-off by accepting operational and connection-management work to get low-latency updates and avoid coupling the board to a paid third-party service. The current fourth tenet says *"Self-hosted and managed infrastructure are both permitted."* Should we add or refine a tenet capturing this lean for future architectural choices—for example, *"Prefer owning self-hosted runtime work over coupling core board delivery to third-party realtime services"*—or was this tradeoff specific to WebSocket delivery?
3. **Adjacent node (`access`)**: `docs/intent/access/access-design.md` line 10 currently contains the phrase *"independent of the still-open change-delivery approach."* Since that crosses into the `access` segment, would you like me to update that phrase so `access-design.md` also reads fresh, and which of the three nodes (`change-store`, `delivery`, `browser-sync`) should we draft first once you approve Phase 1?