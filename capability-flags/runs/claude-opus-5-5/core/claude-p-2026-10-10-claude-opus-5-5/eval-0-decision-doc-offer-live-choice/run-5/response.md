I've updated `docs/high-level-design.md` to commit to self-hosted WebSockets. Nothing is committed to git, and I haven't started the three nodes — this is the review stop before them.

## What changed in the HLD

**Approach** (replaces the "still open" text):

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over WebSocket connections that MarketBoard hosts itself: each browser holds a socket for the event it is viewing, and the server pushes every committed revision to the sockets subscribed to that event.
>
> Self-hosting the sockets means MarketBoard operates its own connection capacity and its own recovery from dropped connections. Dropped sockets are treated as routine rather than exceptional, so the change store, delivery, and browser sync are designed together around one recovery path: a reconnecting browser states the last revision it applied and is brought up to the current revision before live pushes resume. The change store keeps revisions replayable and hands every committed revision to delivery reliably; delivery manages socket sessions and fan-out; browsers reconnect, catch up, and show when they are disconnected.

**Architecture** (the three unwritten nodes no longer say "depends on the approach"):

- **Change store:** owns revision history, replay of the revisions after a given revision, and reliable publication of each committed revision to delivery.
- **Delivery:** owns WebSocket sessions — accepting connections, per-event subscriptions, fan-out of published revisions, and connection capacity.
- **Browser sync:** owns the browser's socket lifecycle — subscribing, reconnecting, catching up from its last applied revision, and showing disconnected state.

**Key Design Decisions** (new entry):

> **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to browsers over sockets MarketBoard runs, giving fast updates with no recurring realtime-service fee and no dependence on a provider's subscription model. The accepted cost is operating connection capacity for 800 simultaneous browsers and owning reconnect and catch-up behavior. Five-second HTTPS polling was rejected: it is the simplest to operate and meets the 15-second freshness goal, but adds seconds of lag and repeated reads from every browser. A hosted realtime service was rejected: it is the quickest route to low latency with the least connection operations, but brings recurring fees and couples delivery and browser code to one provider.

Tenets, Goals and Non-Goals are unchanged. The 15-second freshness goal stays as the committed target, with sockets expected to beat it comfortably.

## Questions for you

1. **Is the HLD right as written?** One sentence goes slightly beyond your sketch: a reconnecting browser states its last applied revision and is caught up before live pushes resume. Whether catch-up is a replay or a fresh snapshot is left to the nodes.

2. **Do you want a full decision doc for this choice?** I'd lean yes. All three options meet the freshness goal, so a later reader could reasonably ask "why not just poll?", and three nodes are about to be sized around the answer. A doc at `docs/decisions/` would lay out the criteria and each option so the judgment can be re-run if vendor cost or ops load changes. The alternative is to leave it as the Key Design Decisions entry above, which is already in place.

3. **May I update the access design?** `docs/intent/access/access-design.md` still calls the delivery approach "still-open". It also says delivery-specific subscription credentials "will belong to the delivery node". The wording fix is trivial, but it is a different node, so I haven't touched it. The real question is who decides whether a browser may open a socket for an event, and what happens to an open socket when a session expires or an assignment is revoked. Today's access specs cover only HTTPS commands. I'd raise that when we draft delivery, unless you want it settled now.

4. **Should the vendor-independence preference become a tenet?** The existing tenet says self-hosted and managed infrastructure are both permitted, which is still true. If your preference is broader than this one decision (for example, it should also lean hosting or database choices), it could be a one-line tenet. If it's specific to realtime delivery, the decision entry is enough.

Once you approve the HLD, I'd take the nodes in the order change store, delivery, browser sync, pausing at each for review.