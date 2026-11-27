The HLD now commits to self-hosted WebSockets. I edited only `docs/high-level-design.md`, nothing is committed, and the three unwritten nodes are untouched. This is the Phase 1 stop: please review the text below and answer the four questions before I start on the nodes.

## What changed

**Approach** (the first two sentences are unchanged; the rest replaces the "still open" text):

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over WebSocket connections that MarketBoard hosts itself: each connected browser holds a socket for the event it is viewing, and the server pushes each committed revision down it.
>
> Push delivery normally lands well inside the 15-second freshness goal; subsecond delivery is welcome but not required. Hosting the sockets keeps fast updates free of a recurring realtime-vendor fee and of a provider's subscription model. In exchange, MarketBoard operates the connection capacity for 800 simultaneous browsers and owns the reconnect behavior that a hosted service would otherwise absorb.
>
> Change storage, delivery, and browser recovery are designed together around this route. The change store keeps revisions replayable, so a browser can be brought forward from the last revision it saw, and publishes every committed revision to delivery reliably. Delivery manages socket sessions. Browsers reconnect after a connection loss and catch up before presenting the board as current.

**Architecture** (the three "depends on the approach" bullets now state ownership; all three are still marked "Not written yet"):

> - Change store: … Owns revision history, replay of the revisions after a given one, and reliable publication of committed revisions to delivery.
> - Delivery: … Owns WebSocket sessions: accepting connections, tracking which event each one views, and pushing committed revisions to them.
> - Browser sync: … Owns the browser's socket subscription, reconnect, and catch-up from its last seen revision.

**Key Design Decisions** (new entry):

> - **Committed changes are pushed over self-hosted WebSockets.** Fast updates without a recurring vendor fee or provider coupling are worth operating the connections ourselves. Five-second HTTPS polling was rejected: it is the simplest stateless operation and meets the freshness goal, but every browser repeats reads and sees a few seconds of lag. A hosted realtime service was rejected: it is the quickest route to low-latency updates with less connection operations work, but it adds recurring fees and couples the store, delivery, and browsers to one provider's publication and subscription model. The accepted cost is owning connection capacity and reconnect handling.

Problem, Tenets, Goals and Non-Goals are unchanged.

## Questions for you

1. **Decision doc or just the entry?** I recorded the choice as the Key Design Decisions entry above. I can also write `docs/decisions/change-delivery.md` with the three options and the criteria they trade on, linked from that entry. I lean towards writing it, because three nodes are about to be sized around this choice and a later reader could reasonably want to reopen it. Do you want the doc, or is the entry enough?

2. **Is "own it rather than rent it" a tenet?** The current tenet says self-hosted and managed infrastructure are both permitted, which is neutral. Your reason for this choice suggests a lean, something like "when a managed service would couple the board to a provider, prefer operating it ourselves". That lean would steer later calls, such as how sockets fan out across server instances or how publication is queued. Should I record it as a tenet, or keep this as a one-off decision and leave the tenet neutral?

3. **Does the freshness goal stay at 15 seconds?** I left the goal alone and kept "subsecond is welcome but not required". If you want the goal tightened now that updates are pushed, give me the number; otherwise 15 seconds stays the bound, including after a reconnect.

4. **May I update the Access node?** `docs/intent/access/access-design.md` still calls the delivery approach "still-open" and says "delivery-specific subscription credentials" will belong to delivery. I'd like to fix the stale wording, but it is a separate node so I haven't touched it. The real question underneath is who authorizes a socket connection. It could be Access (extending its session and assignment check to viewers opening a socket) or Delivery (calling Access). Which do you want, or should I raise it again when we draft the Delivery node?

Once you approve the HLD, I'd take the nodes in this order: change store, then delivery, then browser sync, with a stop after each.