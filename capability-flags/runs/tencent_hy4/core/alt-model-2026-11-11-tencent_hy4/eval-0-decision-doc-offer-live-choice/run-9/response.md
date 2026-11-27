Phase 1 (HLD) is done — I updated `docs/high-level-design.md` for the self-hosted WebSockets approach. Coherence pre-flight (new session): HLD ↔ `access` LLD ↔ ACCESS specs were mutually coherent going in (no code/tests yet; all four ACCESS specs are `[ ]` gaps — expected greenfield), so no drift to fix before editing. The three downstream nodes stay unwritten, per "we'll do the three nodes after that." Here is the full revised HLD for your review:

```
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit one event revision. Browsers display a revisioned view of the board and receive committed changes over self-hosted WebSocket connections, giving fast updates without coupling the board to a hosted realtime vendor. Subsecond updates are useful but not required; the freshness target is 15 seconds under normal connectivity.

Change storage, delivery, and browser recovery are designed together around this approach. The change store retains replayable revisions and a reliable publication path; the delivery component owns WebSocket sessions and pushes published revisions; browsers reconnect and catch up from the last revision they hold.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Will own replayable event revisions and a reliable publication path for socket delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Will own WebSocket session management and the push of published revisions.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Will own socket subscription, reconnect, and catch-up from the last held revision.

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
- **Change delivery over self-hosted WebSockets.** Committed edits reach browsers over self-hosted WebSocket connections, giving low-latency updates without a recurring realtime-vendor fee or provider coupling. The trade is owning connection capacity and reconnect/replay behavior. Alternatives: five-second HTTPS polling (simplest stateless operation, but repeated reads and seconds of lag; needs cursor queries and a browser polling loop) and a hosted realtime service (least connection operations, but recurring fees and provider coupling; needs publication reconciliation and provider credentials). We accept the extra connection and reconnect operations work in exchange for fast updates and no realtime-vendor dependency. This choice fixes the contracts for the change store (replayable revisions, reliable publication), delivery (session management), and browser sync (reconnect and catch-up).
```

I've written this as current intent (rejected alternatives moved into Key Design Decisions; no "still open" / "depending on the approach" narration). Before I proceed, four things are yours to call:

1. **Decision doc?** This choice clears the bar for a full decision doc — three credible options weighed against latency, operational burden, and vendor coupling, with change-store / delivery / browser-sync all about to be sized around it. I've recorded it as the Key Design Decisions row above (the default). Want me to expand it into `docs/decisions/change-delivery-approach.md` (context, criteria, options, selection) and link it from that row, or keep just the row? I won't write the doc unless you say so.

2. **A tenet to record?** Your selection implies a lean no current tenet captures. My read as a one-line tie-breaker: *"Prefer self-hosted operation over vendor coupling when it buys fast updates — accept the operational burden."* Its opposite (prefer managed services and minimum operations, accept vendor coupling) is a choice a different project could reasonably make, so it passes the defensible-opposite test. Should I add it under `## Tenets` as written, reword it, or leave the tenets as they are? Any other lean you want captured?

3. **Cross-segment cascade.** The `access` LLD has one now-stale context phrase — "independent of the still-open change-delivery approach" (`docs/intent/access/access-design.md:10`). Access is a different segment, so I haven't touched it. Want me to update that reference now, or fold it into the node work later?

4. **Approval.** Approve this Phase 1 output, or give numbered feedback. I'll hold here and won't start the three nodes (change-store, delivery, browser-sync) until you say go.