Self-hosted WebSockets it is — the HLD is updated to record the choice. Here is the revised `docs/high-level-design.md` (Phase 1 stop for your review):

## Approach (revised)

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are pushed to connected browsers over self-hosted WebSocket connections, so a connected browser sees a change as soon as the server publishes its revision; the 15-second freshness goal remains the required bound.
>
> Delivery, change storage, and browser recovery are designed together around this choice: the change store needs replayable revisions and reliable publication, delivery manages socket sessions, and browsers need reconnect and catch-up behavior. Connection capacity and reconnect operations are owned by the system rather than delegated to a provider.

## Architecture (segment pointers made concrete)

- **Change store** (not written yet): revision history and read indexes, plus replayable revisions and reliable publication for delivery.
- **Delivery** (not written yet): owns WebSocket sessions — connection capacity, per-browser subscriptions, and publication of committed revisions to connected browsers.
- **Browser sync** (not written yet): subscribes over WebSocket, reconnects with backoff, and catches up on revisions missed while disconnected.

## Key Design Decisions (new entry)

> **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to connected browsers over server-owned WebSocket connections, with the change store providing replayable revisions and reliable publication. Five-second HTTPS polling was rejected: it keeps delivery stateless and request/response, but at the cost of repeated cursor reads and a few seconds of lag, while the board still needs replayable revisions for reconnect catch-up. A hosted realtime service was rejected to keep the board's core delivery path free of recurring fees and provider coupling. The accepted cost is owning connection capacity and reconnect operations during published event hours.

Three things need your judgment before I proceed to the three nodes (change store → delivery → browser sync):

1. **Decision doc?** This choice had three credible options traded on multiple criteria, and three nodes are about to be sized around the result — a cold reader might be tempted to reverse it toward a hosted service. I can record it as a full decision doc at `docs/decisions/delivery-approach.md` (options, gates, weighted criteria, selection), or the Key Design Decisions entry above suffices. Which?
2. **Freshness goal.** The 15-second goal was written when polling was a candidate; with sockets, a connected browser is updated on publish — the goal is met by construction. Should it tighten to something like "within one second for connected browsers," or stay as the loose bound?
3. **Access segment drift.** `access-design.md` still says authorization is "independent of the still-open change-delivery approach" — now stale. The substance is unaffected (commands stay over HTTPS), so this is a wording fix cascading into that segment. OK to propagate it, or leave the access node untouched for now?