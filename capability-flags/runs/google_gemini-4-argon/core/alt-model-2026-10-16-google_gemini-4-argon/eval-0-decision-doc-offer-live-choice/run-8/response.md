I have updated `docs/high-level-design.md` for **Phase 1 (HLD check)** to reflect the self-hosted WebSockets approach. Here is the updated HLD in full:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board and receive committed changes over self-hosted WebSockets.

Delivery, change storage, and browser recovery work together around the socket stream: the change store persists replayable event revisions and reliably publishes committed changes to the delivery tier; delivery manages WebSocket sessions and event fan-out; and browsers maintain the socket connection, detect disconnects, and catch up from their last applied revision (or fall back to a snapshot) on reconnect.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Authorizes HTTPS commands and snapshot reads against server-side event assignments.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns authoritative revision assignment, replayable revision history, snapshot reads, and reliable publication to the delivery tier.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns self-hosted WebSocket session management, subscription authorization, and revision fan-out to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns WebSocket connection lifecycle, visible disconnect state, and reconnect catch-up from the last known revision.

## Tenets

- A committed edit has one authoritative event revision regardless of its delivery route.
- Connectivity failures must be visible, not mistaken for an unchanged board.
- Commands use server-side authorization; browser state is not evidence of permission.
- Prefer owning operational runtime over coupling to external realtime vendors when the latency benefit justifies the operational work.
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
- **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to browsers over self-hosted WebSockets rather than five-second HTTPS polling or a hosted realtime service. Five-second polling was rejected despite simpler stateless operation because it adds repeated read load across 800 browsers and multi-second update lag. A hosted realtime service was rejected despite lower connection-management burden because it introduces recurring per-connection/message fees and couples the board's delivery contract and browser client to a third-party provider. Self-hosted WebSockets deliver low-latency updates without vendor lock-in or recurring realtime fees, accepting the operational work of managing socket capacity, session state, and reconnect replay across `change-store`, `delivery`, and `browser-sync`.
```

Before we move to Phase 2 for the three downstream nodes (`change-store`, `delivery`, and `browser-sync`), please review the updated HLD and let me know on these points:

1. **Decision doc vs. HLD entry**: Because the change-delivery choice weighs three credible options across latency, operational burden, recurring cost, and vendor coupling—and sizes `change-store`, `delivery`, and `browser-sync` around the outcome—a future cold reader could be tempted to re-litigate it (e.g., asking why we didn't just poll every 5s given the 15s freshness goal, or why we didn't use a managed service). Would you like me to record this as a standalone decision doc at `docs/decisions/change-delivery.md` (linked from Key Design Decisions), or keep it purely as the Key Design Decisions entry above?
2. **Tenet check**: Your rationale surfaces a cross-cutting lean—accepting operational runtime work over external vendor coupling and recurring fees when it buys capability/latency. I drafted that as a candidate tenet: *"Prefer owning operational runtime over coupling to external realtime vendors when the latency benefit justifies the operational work."* Does that match the tie-breaker you want governing downstream choices, or would you phrase/weight it differently? Also, `docs/intent/access/access-design.md` line 10 still refers to "the still-open change-delivery approach"; once you approve the HLD, should we update that cross-segment reference in `access-design.md` as well?
3. **HLD approval & first node**: Does the HLD look good to approve, and which of the three nodes (`change-store`, `delivery`, or `browser-sync`) would you like to draft first in Phase 2?