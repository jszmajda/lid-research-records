The approach in `docs/high-level-design.md` now commits to self-hosted WebSockets. Nothing else is touched: no design nodes drafted, nothing committed.

## What changed

**Approach** (replaces the "still open" text):

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over WebSocket connections that MarketBoard hosts itself: each browser holds a connection for the event it is viewing, and the server pushes each committed revision over it.
>
> Hosting the sockets means MarketBoard owns connection capacity and reconnect behavior. Connections drop, so pushing alone is not enough. The change store keeps revisions replayable and publishes every committed revision reliably, delivery manages the socket sessions, and a browser that reconnects catches up from the last revision it applied instead of assuming the board is unchanged. Change store, delivery, and browser sync are designed together around that contract.

**Architecture** (the three unwritten nodes no longer say "depends on the approach"):

- **Change store:** owns revision history, replay of the revisions after a given one, and reliable publication of committed revisions to delivery.
- **Delivery:** owns socket sessions: accepting connections, pushing committed revisions, and connection capacity.
- **Browser sync:** owns the browser's socket subscription, reconnect, and catch-up behavior.

**Key Design Decisions** (new entry):

> **Self-hosted WebSockets deliver committed changes.** Updates arrive quickly with no realtime vendor fee and no dependence on a provider's subscription model. The cost is operational: MarketBoard runs the connection capacity for 800 browsers and owns reconnect and catch-up. Five-second HTTPS polling was rejected: it is the simplest to operate and meets the 15-second goal, but adds seconds of lag and repeated reads. A hosted realtime service was rejected: it gives low latency with the least connection operations work, but brings recurring fees and couples the board to one provider.

I removed the sentence saying neither operating cost nor operational burden is the overriding criterion, since it only described the open choice. Tenets, goals and non-goals are unchanged.

## Questions for you

1. **Decision doc?** All three options meet the 15-second goal and three nodes are about to be sized around this one, so someone reading later may well reopen it. I can write `docs/decisions/` with the full criteria and options and link it from the entry above, or leave the one-paragraph entry as the record. Which do you want?

2. **Is vendor independence a general lean?** The tenets still say self-hosted and managed infrastructure are both permitted. If "accept more operations work to avoid provider coupling" should guide later choices too, I'll add it as a tenet; if it was specific to realtime delivery, the tenets stay as they are.

3. **Access design is now stale in one line.** `docs/intent/access/access-design.md` says command authorization is "independent of the still-open change-delivery approach". It's a different node, so I left it. OK to reword that sentence? No access spec changes.

Once you've approved the approach and answered these, I'll start on the three nodes.