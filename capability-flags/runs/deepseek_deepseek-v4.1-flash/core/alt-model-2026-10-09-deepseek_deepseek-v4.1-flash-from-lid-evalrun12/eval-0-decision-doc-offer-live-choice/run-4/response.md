Phase 1 — HLD update (self-hosted WebSockets)

I updated `docs/high-level-design.md`:

**Approach** now commits to the socket route and drops the open-choice framing:

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach connected browsers over self-hosted WebSockets: the server holds a persistent connection per browser and pushes each committed revision as it lands. Subsecond updates would be useful, but are not required; the socket route meets the 15-second freshness target while keeping the board independent of a realtime vendor.
>
> Delivery, change storage, and browser recovery are designed together around this route. The change store keeps replayable revisions and a reliable publication path so a reconnecting browser can catch up from the last revision it saw. Delivery owns socket sessions, connection capacity, and reconnect handling. Browser sync maintains the subscription and the reconnect and catch-up logic.

**Architecture** now names each node's socket-route responsibility (change store: replayable revisions + reliable publication; delivery: session management, capacity, reconnect; browser sync: subscription, reconnect, catch-up from last-seen revision).

**Key Design Decisions** gained:

> **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to connected browsers over server-held WebSocket sessions rather than five-second HTTPS polling or a hosted realtime service. Polling was rejected: it repeats reads and adds seconds of lag for the same freshness target. A hosted realtime service was rejected: recurring fees and provider coupling outweigh the connection operations it would offload. Self-hosting accepts connection-capacity and reconnect work in exchange for low-latency updates with no realtime vendor dependency.

Two things for you before I proceed:

1. **Record this as a decision doc?** The choice traded three credible options against latency, cost, operational burden, and vendor coupling, and the three downstream nodes will be sized around it — so a cold reader may well re-litigate it. I can write a project-level decision doc at `docs/decisions/` (leaving the HLD's Key Design Decisions bullet as the summary row), or leave the bullet alone. Your call.

2. **A tenet?** Your rationale — "without tying the board to a realtime vendor" — reads like a lean that could govern future infrastructure choices, not just this one. The existing tenet "Self-hosted and managed infrastructure are both permitted" currently stays neutral, so adding a vendor-independence lean would refine (not contradict) it. Want me to add a one-line tenet like *"Prefer self-hosted over vendor-coupled infrastructure for the realtime path"* — or keep the vendor-coupling reasoning confined to this decision?

Approve the HLD as written, or send numbered feedback. Once you approve, we'll take the three nodes (change store, delivery, browser sync) in turn.