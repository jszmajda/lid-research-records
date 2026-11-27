Phase 1 (HLD) is updated for the self-hosted WebSockets choice. Here is what changed in `docs/high-level-design.md`.

**Approach** — rewritten; the three-way open question is gone and replaced with the committed approach plus the work it lands on each component:

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over self-hosted WebSocket connections: the server publishes each committed revision to the connections subscribed to that event, and browsers apply it on arrival. Subsecond updates are not required, but pushing revisions as they commit keeps delivery well inside the freshness target without repeatedly re-reading the board.
>
> Running the socket tier ourselves means the project owns connection capacity and reconnect behavior rather than buying them. Three consequences shape the component design, and the three components are designed together:
>
> - The change store keeps event revisions replayable by revision number, so any browser can be brought forward from the last revision it saw, and publication of a committed revision is reliable rather than best-effort.
> - Delivery owns socket sessions: accepting connections, tracking which session subscribes to which event, fanning committed revisions out to them, and surviving the loss of a connection without losing the revision.
> - Browser sync owns reconnect and catch-up: detecting a dropped connection, reconnecting, and requesting the revisions missed while disconnected before resuming live application.
>
> Connection capacity at the stated browser count, and behavior during mass reconnect, are the operational risks this approach accepts in exchange for low-latency updates with no realtime vendor in the path.

**Architecture** — the three unwritten nodes now state definite ownership instead of "depends on the approach": change store owns the revision sequence, replay by revision number, and reliable publication; delivery owns WebSocket sessions (acceptance, per-event subscription, fan-out, teardown); browser sync owns subscription, disconnection detection, reconnect, and catch-up from the last applied revision.

**Key Design Decisions** — new entry, *Committed revisions are delivered over self-hosted WebSockets*, naming both rejected options (polling's repeated reads and seconds of lag; the hosted service's recurring fee and provider coupling), the reason this one wins, and where the accepted cost lands.

Tenets, Goals, and Non-Goals are unchanged. "Self-hosted and managed infrastructure are both permitted" still holds — this is a choice made inside that permission, not a narrowing of it.

Three things for you before I move to Phase 2:

1. **Record this as a decision doc?** It clears the bar for one: three credible options traded against latency, cost, operational burden, and vendor coupling, and all three remaining nodes are about to be sized around the result — a cold reader six months from now could reasonably try to reverse it. I'd put it at `docs/decisions/change-delivery-approach.md` and link it from the Key Design Decisions entry, which would then shrink to a pointer. The alternative is to leave the full rationale inline as written above. Your call; inline is genuinely adequate here.

2. **One tenet to elicit.** This approach opens a fork no spec will anticipate: when connection capacity is exhausted or a mass reconnect hits, does the board protect commit latency for editors by refusing or shedding socket connections (shed browsers catch up on reconnect), or does it keep every browser connected and accept slower fan-out? Both are defensible for a staff-facing board. Which way should MarketBoard lean? If you'd rather leave it unleaned for now, say so and I'll leave the tenet list as it is.

3. **One cascade to confirm.** `docs/intent/access/access-design.md` says authorization "is independent of the still-open change-delivery approach" — now stale. That's a different segment, so I'm not editing it without your go-ahead. I'd change it to say authorization is independent of the delivery route, which keeps the intent and drops the staleness. The same doc's note that subscription credentials belong to the delivery node stays correct.