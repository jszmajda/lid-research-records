Phase 1 (HLD) is drafted. Coherence pre-flight was clean for the segment I touched: ACCESS-001–004 trace to the Access LLD, nothing cites a deleted ID, and there's no code/test layer yet to drift. I committed the approach to **self-hosted WebSockets** in `docs/high-level-design.md`. I have **not** written the three node LLDs (`change-store`, `delivery`, `browser-sync`) — those come after your approval, per "we'll do the three nodes after that."

Here is the updated HLD in full for your review:

```markdown
# MarketBoard High-Level Design

## Problem

Forty weekend markets currently relay stall closures, late arrivals, and power problems through group chats. About 120 coordinators maintain boards used by up to 800 simultaneous staff browsers. A busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; each committed edit receives one event revision. Browsers display a revisioned view of the board and stay current over self-hosted WebSocket connections.

Committed revisions reach browsers over persistent WebSocket sessions maintained by the delivery component. The change store retains replayable revisions, so a browser that reconnects can recover the edits it missed; browsers run subscription, reconnect, and catch-up logic against those revisions. The design accepts the work of managing connection capacity and reconnect behavior in exchange for fast updates while keeping delivery infrastructure self-hosted. It propagates committed edits well within the 15-second freshness target; subsecond delivery is a useful consequence, not a requirement.

Change storage, delivery, and browser recovery are designed together around this mechanism. The change store retains replayable revisions and an outbox for reliable publication, delivery manages WebSocket sessions and publishes each committed revision to connected browsers, and browser sync owns the reconnect and catch-up path.

## Architecture

- Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
- Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Owns revision history, read indexes, replayable revisions, and a publication outbox for reliable WebSocket delivery.
- Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket sessions and publishes committed revisions to connected browsers.
- Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser-side WebSocket subscription, reconnect, and catch-up logic.

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
- **Change delivery over self-hosted WebSockets.** Committed revisions reach browsers over persistent WebSocket sessions, with the change store retaining replayable revisions and an outbox for reliable publication and browsers running reconnect and catch-up. Five-second HTTPS polling and a hosted realtime service were rejected: polling adds repeated reads and a few seconds of lag, and a hosted service adds recurring fees and provider coupling. Self-hosted sockets give fast updates with delivery operated in-house, at the cost of owning connection capacity and reconnect handling.
```

This is the mandatory Phase 1 stop — I won't proceed to the three nodes until you approve. Four things need your ruling; I've deliberately not settled any of them:

1. **Review / approval.** Approve the HLD as written, or give numbered feedback and I'll revise. (I drafted it whole for review; say so if you'd rather work one concept at a time.)

2. **Decision doc — offer.** This choice was settled among the three options sketched last session and stays live for a cold reader: three credible options weighed against freshness/latency, operating cost, and vendor coupling, with the three delivery-side nodes about to be sized around the result. That clears the bar for a full decision doc. I've put the decision in **Key Design Decisions** as the lightweight record (with the rejected alternatives and rationale). Want me to expand it into a decision doc at `docs/decisions/` — with options, weighted criteria, and a Selection, linked from that row — or keep the row as the standing record, or record it some other way? I'll write the doc only if you say yes.

3. **Tenet to elicit.** Your choice leans one way on a decision that could reasonably go either way: accept extra connection/reconnect operations to get fast updates and avoid a realtime vendor. The existing tenet "Self-hosted and managed infrastructure are both permitted" reads as neutral on this. Should I record a one-line tie-breaker (e.g., "Lean toward self-hosted infrastructure over vendor coupling, accepting added operational work") and reconcile that line, or leave the Tenets as they stand? Any other leans you want captured? I won't add a tenet without your call.

4. **Cross-segment cascade flag.** `docs/intent/access/access-design.md` still says authorization is "independent of the **still-open** change-delivery approach" — now stale once the approach is committed. That's across a segment boundary, so I haven't touched it. Should I fix that wording now, or fold it into the node work after approval?

Please reply with your ruling on 1–4; I'm stopping here.