I've updated `docs/high-level-design.md` to commit to self-hosted WebSockets. Nothing else is touched and nothing is committed; this is the HLD stop before the three nodes.

## What changed

**Approach** (replaces the "still open" paragraphs):

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over WebSocket connections that MarketBoard hosts itself: each browser viewing an event holds a connection, and the server pushes each revision to it once the revision is committed.
>
> Self-hosting the sockets means MarketBoard owns the work a realtime vendor would otherwise absorb: connection capacity for 800 simultaneous browsers, detection of connections that have died without closing, and recovery after a drop. A pushed message can be lost and a connection can fail silently, so the push is never the record. The change store's revision sequence is the record; a browser that reconnects, or that sees a gap in the revisions it receives, catches up from the last revision it applied.
>
> Change storage, delivery, and browser recovery are designed together around that contract: the store keeps revisions replayable and publishes every committed revision reliably, delivery manages socket sessions, and browsers reconnect and catch up.

**Architecture** (the three unwritten nodes now state what they own; Access is unchanged):

> - Change store: … Not written yet. Owns the authoritative revision history, replay of revisions after a given revision, and reliable publication of each committed revision to delivery.
> - Delivery: … Not written yet. Owns the self-hosted WebSocket endpoint: socket sessions, connection capacity, detection of dead connections, and pushing published revisions to the browsers subscribed to an event.
> - Browser sync: … Not written yet. Owns the browser's socket subscription, reconnection, catch-up from its last applied revision, and showing the coordinator when the board is not connected.

**Key Design Decisions** (new entry):

> - **Committed changes are pushed over self-hosted WebSockets.** Five-second HTTPS polling and a hosted realtime service were the alternatives, and all three meet the 15-second freshness goal. Polling is the simplest to operate, stateless and request/response throughout, but every browser repeats reads whether or not anything changed and sees each change a few seconds late. A hosted service gives low latency with the least connection operations work, but adds a recurring fee and couples the board to one provider's subscription model. Self-hosted sockets were chosen for fast updates without that coupling, accepting that MarketBoard operates connection capacity and reconnect handling itself.

Problem, Tenets, Goals and Non-Goals are unchanged.

## Questions for you

1. **Decision doc or just the entry?** All three options meet the stated goals and three nodes are about to be sized around this one, so a cold reader may well want to reopen it. I recorded it as the Key Design Decisions entry above. Do you also want a full decision doc at `docs/decisions/` with criteria and per-option analysis, linked from that entry?

2. **Freshness goal.** The goal still says changes appear "within 15 seconds", which polling would also have met. You chose sockets for fast updates. Should the goal tighten (for example to a couple of seconds), or stay at 15 seconds as the floor with speed as a bonus? The answer sets what the delivery specs get tested against.

3. **Vendor tenet.** The fourth tenet says "Self-hosted and managed infrastructure are both permitted." Your reason for this choice leans away from vendor coupling. Is that a project-wide lean I should record as a tenet (prefer self-hosted when both work), or specific to realtime delivery, in which case the tenet stays as written?

4. **Access node wording.** `access-design.md` still refers to "the still-open change-delivery approach" and says subscription credentials "will belong to the delivery node". Its specs are unaffected. That is a different segment, so I haven't edited it. May I update the stale wording, and do you still want authorizing a socket subscription to sit with Delivery rather than Access?

Any other edits to the wording above? Once you approve the HLD I'll start on the change store, delivery and browser sync designs.