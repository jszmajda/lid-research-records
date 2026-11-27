## Phase 1 — HLD updated to self-hosted WebSockets

**Coherence pre-flight (resumption check):** clean. `docs/intent/access/access-design.md` and specs `ACCESS-001`–`ACCESS-004` still trace to the stable HTTPS command boundary and the HLD; there is no code, no tests, no `@spec` annotations, no `docs/arrows/` overlay, and no `docs/decisions/` yet; the change-store / delivery / browser-sync nodes have no LLD or specs, so there is no drift to repair before this change. One phrase in the Access LLD ("the still-open change-delivery approach") will go stale after this edit — noted as a cross-segment cascade below, not auto-fixed.

Here is the revised `docs/high-level-design.md` in full for your review:

```
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over self-hosted WebSocket connections run by the board's own servers.

Each WebSocket session streams committed event revisions. The change store keeps revisions replayable and publishes committed revisions reliably so a reconnecting browser can catch up from the last revision it saw. Delivery owns session lifecycle, publication onto those sessions, and reconnect handling. Browser sync holds subscription state and runs reconnect and catch-up against the revision stream. Freshness follows connection health; subsecond updates are achievable but are not required.

Running the WebSocket tier is the project's own operational responsibility: connection capacity for up to 800 simultaneous browsers, reconnect storms around opening time, and reliable publication.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns replayable event revisions and reliable publication of committed revisions to the delivery tier.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions, publication of revisions onto those sessions, and connection and reconnect handling.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns subscription state and reconnect and catch-up against the revision stream.

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
- **Self-hosted WebSockets for delivering committed changes.** Committed revisions stream to browsers over WebSocket sessions run by the project's own servers, backed by replayable revisions, reliable publication, and browser reconnect and catch-up. Five-second HTTPS polling was rejected: it adds repeated reads and a few seconds of lag in return for simpler stateless operation. A hosted realtime service was rejected: recurring fees and provider coupling, despite the quickest route to low-latency updates with less connection operations. The choice trades connection-capacity and reconnect operations work for low-latency updates without dependence on a realtime vendor; low latency and vendor independence were weighed above minimizing operational burden.
```

## STOP — Phase 1 review

Per your "we'll do the three nodes after that," I've stopped at the HLD and have **not** started change-store, delivery, or browser-sync (Phases 2+). Before I go further, I need your ruling on these:

1. **Phase 1 approval.** Approve the revised HLD above, or give numbered feedback. I proceed to any later phase only on your explicit approval.

2. **Decision doc — offering once.** This choice stays live for a cold reader: three credible options weighed across latency, recurring cost, operational burden, and vendor coupling, and the three nodes will be sized around the result. LID has me offer once: should I record it as a full decision doc at `docs/decisions/realtime-delivery.md` (context, gated/weighted criteria, all three options, selection) linked from the new Key Design Decisions row, or keep just the row as drafted? I won't write the doc unless you accept.

3. **Tenet elicitation.** Your justification — "fast updates without tying the board to a realtime vendor, accepting the extra connection and reconnect operations work" — reads as a reusable lean. Want me to record it as a one-line tenet under `## Tenets` (e.g., low latency and vendor independence are worth added operational burden), or leave it only as decision rationale? Any other load-bearing tenets you'd like surfaced?

4. **Cross-segment cascade, held for confirmation.** Updating the HLD leaves `docs/intent/access/access-design.md` saying "the still-open change-delivery approach," which is now stale; the three unwritten nodes are also downstream of this decision. Both cross a segment boundary, so I've paused rather than auto-propagating. Should I cascade the Access cleanup now (folding the three-node work in when you direct it), or hold the whole cascade until you start the three nodes?