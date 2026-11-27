Phase 1 (HLD check/update) is done. Pre-flight: the only existing node is `access`, whose LLD/specs remain coherent and delivery-independent; the other three nodes don't exist yet, so nothing could be cascaded into them beyond the HLD itself.

Revised `docs/high-level-design.md`:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over self-hosted WebSocket connections: the delivery service holds one socket session per connected browser and pushes each committed event revision as it is published.

The delivery service is operated by the market, not a realtime vendor. We accept the connection capacity, reconnect, and publication-reliability work that ownership brings, and in exchange the board carries no per-connection vendor bill and no provider subscription model that constrains how the board behaves. Because changes are pushed as they are committed rather than polled, browsers see updates in well under the freshness target, and every browser reconnects to a session that can resume from the last revision the browser saw.

Delivery, change storage, and browser recovery are designed together around this approach: the change store retains replayable revisions and publishes each committed revision reliably, the delivery service owns socket sessions and their resumption points, and the browser side owns reconnection and catch-up.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, read indexes, and the reliable publication path that hands each committed revision to delivery exactly once and in revision order, so that a reconnecting browser can be brought forward from any earlier revision.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns socket sessions: accepting and authenticating browser connections, pushing published revisions to them, and answering a reconnecting browser's request for the revisions it missed.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser's socket lifecycle: connecting, tracking the last revision seen, reconnecting after a failure, and catching up on revisions missed while disconnected.

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
- **Self-hosted WebSocket delivery of committed revisions.** The market operates the socket service that pushes committed revisions to connected browsers. Five-second HTTPS polling was rejected because it trades freshness for a polling loop in every browser and repeated reads, and leaves updates lagging behind the committed change; a hosted realtime service was rejected because it puts the board's update path behind a vendor's subscription model and per-connection cost. The cost of the chosen approach is ours to carry: socket capacity for connected browsers, reconnection and catch-up in the browser, replayable revisions and reliable publication in the change store, and session management in delivery.
```

Four things need your call before I move on to the three nodes:

1. **Tenet lean.** The delivery decision turns on preferring self-hosted to hosted for the board's update path, but the tenet list still only says "Self-hosted and managed infrastructure are both permitted." Do you want it sharpened to a lean — e.g. *"Prefer self-hosted infrastructure for the update path; accept the operational work it brings over per-connection vendor cost and provider coupling."* — or left as-is, so the decision stays a local one rather than a project-wide lean?

2. **Decision doc.** A cold reader of the landed HLD could ask why not polling (simpler, stateless) or a hosted service (less connection ops). The tradeoffs were weighed against more than one criterion, so the choice may stay live. Want a full decision doc at `docs/decisions/self-hosted-websocket-delivery.md` alongside the Key Design Decisions row, or is the row enough?

3. **One stale line in a sibling segment.** `docs/intent/access/access-design.md:10` still says "Authorization for HTTPS edit commands is independent of the still-open change-delivery approach." Its substance is unaffected — only that phrase is now wrong. Since it's a cross-segment edit, I'm asking first: may I reword it to "independent of the change-delivery approach"?

4. **HLD completeness.** The HLD still lacks the template's Target Users, System Design, and Success Metrics sections. Filling them means inventing intent (metrics in particular), so I left them out of this revision — tell me if you want them drafted as part of this change or as a separate pass.