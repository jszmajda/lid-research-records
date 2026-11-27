I've updated `docs/high-level-design.md` to the self-hosted WebSockets approach; nothing is committed, and I have three questions before starting the three nodes.

## What changed

**Approach** now reads:

> Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit one event revision and pushes it to connected browsers over WebSocket connections that MarketBoard hosts itself. Browsers display a revisioned view of the board and use revisions to notice gaps and catch up after a reconnect.
>
> Self-hosting the connections gives push delivery with no recurring realtime-vendor fee and no provider coupling. In exchange, MarketBoard owns connection capacity and reconnect behavior: up to 800 browsers hold open sockets, and each must be able to drop, return, and end up on the latest board.
>
> Change storage, delivery, and browser recovery are designed together because the event revision is the contract between them. The change store keeps replayable revisions and publishes each committed revision reliably; delivery manages socket sessions; browsers reconnect and catch up from the last revision they displayed.

**Architecture** — the three unwritten nodes now have fixed responsibilities (the Access line is unchanged):

> - Change store: … Not written yet. Owns revision history, replay of the revisions after a given revision, and reliable publication of committed revisions to delivery.
> - Delivery: … Not written yet. Owns socket sessions: accepting connections, subscription credentials, pushing published revisions to each event's connected browsers, and connection capacity.
> - Browser sync: … Not written yet. Owns the browser's socket subscription, reconnect, catch-up from its last displayed revision, and showing when the connection is down.

**Key Design Decisions** — one new entry:

> - **Self-hosted WebSockets for delivering committed changes.** The server pushes each committed revision to connected browsers over sockets it hosts. Five-second HTTPS polling and a hosted realtime service were the alternatives; all three meet the 15-second freshness goal. Polling is the simplest to operate and stateless, but repeats reads across 800 browsers and adds seconds of lag to every change. A hosted service gives low latency with the least connection operations work, but brings recurring fees and provider coupling. Self-hosted sockets were chosen for fast updates without a realtime vendor, accepting the connection capacity and reconnect operations work the other two avoid.

Tenets, Goals and Non-Goals are untouched.

## Questions

1. **Should this choice get a full decision doc?** All three options meet the 15-second goal, so someone reading this later could fairly ask why not polling, and three nodes are about to be sized around the answer. A doc at `docs/decisions/change-delivery.md` would lay out the criteria and each option so the judgment can be re-run; the entry above would shrink to a pointer. If the entry is enough for you, I'll leave it as is.

2. **Does the freshness goal stay at 15 seconds?** You chose sockets for fast updates, but the only written target is still "within 15 seconds". If you want a tighter number, such as a couple of seconds, it belongs in Goals now, because the delivery node will be sized against it. Otherwise 15 seconds stays the requirement and speed is best-effort.

3. **May I fix a stale line in the access design?** `docs/intent/access/access-design.md` still says authorization "is independent of the still-open change-delivery approach". I'd reword it to say authorization of HTTPS commands is independent of how changes are delivered. No access spec changes. I left it alone because it is a different node.

Once you've approved the approach and answered these, I'll start the three nodes. Which would you like first? I'd suggest the change store, since the other two build on its revisions.