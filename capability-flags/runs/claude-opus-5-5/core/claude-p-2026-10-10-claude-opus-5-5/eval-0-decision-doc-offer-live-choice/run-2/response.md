The approach in `docs/high-level-design.md` now commits to self-hosted WebSockets; nothing is committed to git, and I've stopped here for your review before the three nodes.

## What changed

**Approach** (replaces the "still open" paragraphs):

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over WebSocket connections that MarketBoard hosts and operates itself: each connected browser holds a socket for the event it is viewing, and the server pushes each committed revision down it.
>
> Pushing over self-hosted sockets delivers changes well inside the freshness goal — typically in under a second, which is useful though not required — without a recurring realtime-service fee or a dependency on a provider's subscription model. The price is operational: MarketBoard owns connection capacity for every simultaneous browser and owns the behavior of dropped and resumed connections.
>
> A socket is a delivery route, not a source of truth. A browser that misses pushes while disconnected catches up from the stored event revisions, so change storage, delivery, and browser recovery are designed together:
>
> - Change storage keeps event revisions replayable from the revision a returning browser last saw, and publishes every committed revision to delivery reliably.
> - Delivery manages socket sessions: which browsers are connected to which event, pushing revisions to them, and capacity for the simultaneous-browser and burst goals.
> - Browsers reconnect after a drop, catch up from their last seen revision, and show the disconnected state while they are behind.

**Architecture**: the three unwritten nodes no longer say "depends on the approach". Each now states what it owns:
- **Change store**: revision assignment and history, replay of the revisions after a given revision, and reliable publication to delivery.
- **Delivery**: WebSocket sessions, pushing published revisions to connected browsers, and connection capacity.
- **Browser sync**: the socket subscription, reconnect and catch-up, and the visible disconnected state.

**Key Design Decisions** (new entry):

> **Self-hosted WebSockets deliver committed changes.** Browsers hold a socket to servers MarketBoard operates, and committed revisions are pushed down it. Two alternatives also meet the 15-second freshness goal. Five-second HTTPS polling is the simplest to operate — stateless request/response over cursor queries — but leaves a few seconds of lag on every change and repeats reads from every browser whether or not anything changed. A hosted realtime service gives low-latency updates with the least connection operations work, but adds recurring fees and couples delivery and browser subscription code to one provider. Self-hosting takes on connection capacity and reconnect handling as MarketBoard's own operational work in exchange for fast updates with no realtime vendor dependency.

Tenets, Goals and Non-Goals are untouched.

## Questions for you

1. **Decision doc?** All three options meet the stated goals and three nodes are about to be sized around this one, so someone reading it cold may want to re-argue it. I can write `docs/decisions/change-delivery.md` with the criteria and each option's strongest case, linked from the entry above. Otherwise the entry stands as the whole record. Which do you want?

2. **Freshness goal.** You chose sockets for fast updates, but the goal still reads "within 15 seconds", and I wrote sub-second as "useful though not required". Should the goal tighten (and to what), or stay at 15 seconds with speed as a bonus? The delivery and browser-sync specs will be written against this number.

3. **Vendor tenet.** The fourth tenet still says "Self-hosted and managed infrastructure are both permitted." Your reason for this choice suggests a lean such as "prefer infrastructure we operate over provider coupling on the path that carries board updates." Do you want that as a tenet, or was this a one-off call with the tenet left as is?

4. **Access design is now stale in two places.** It calls the delivery approach "still-open" and says subscription credentials "will belong to the delivery node". Access is a separate node, so I haven't edited it. May I update that wording? The delivery node will also have to settle who authorizes opening a socket and what happens to an open socket when the eight-hour session expires or an assignment is revoked.

Once you approve the approach (with any changes), I'll start on the change store, delivery and browser sync nodes.