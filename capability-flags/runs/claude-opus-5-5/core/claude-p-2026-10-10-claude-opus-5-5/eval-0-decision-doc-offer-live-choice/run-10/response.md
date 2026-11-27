I've updated `docs/high-level-design.md` to commit to self-hosted WebSockets; nothing else is touched and nothing is committed. This is the Phase 1 stop, so please review the text below and answer the five questions before we start the three nodes.

## What changed

**Approach** (replaces the "still open" text):

> Keep one authoritative board per event. Editors submit commands over HTTPS; the server assigns each committed edit one event revision, and browsers display a revisioned view of the board.
>
> Committed changes reach browsers over WebSocket connections that MarketBoard hosts itself. Each open board holds one socket, and the server pushes every committed revision for that event to the sockets following it. This gives staff fast updates without a realtime vendor's fees or a dependency on its subscription model. In exchange, MarketBoard owns connection capacity for 800 simultaneous browsers and owns what happens when a connection drops.
>
> A socket is a delivery route, not a source of truth. Pushes can be missed while a browser is disconnected, so the revision history is replayable: a browser that reconnects states the last revision it holds and is caught up from the history. Publication from the change store to delivery is reliable, so a committed revision is never silently absent from what connected browsers receive.

**Architecture** (the three unwritten nodes now have fixed responsibilities):

> - Access: […]. Authorizes HTTPS commands.
> - Change store: […]. Not written yet. Owns the replayable revision history and the reliable publication of each committed revision to delivery.
> - Delivery: […]. Not written yet. Owns WebSocket sessions: accepting connections, tracking which event each one follows, pushing revisions, and connection capacity.
> - Browser sync: […]. Not written yet. Owns the browser's socket lifecycle: connecting, detecting a lost connection, reconnecting, and catching up to the current revision.

**Key Design Decisions** (new entry):

> - **Self-hosted WebSockets deliver committed changes.** Two alternatives were considered. Five-second HTTPS polling is the simplest to operate, stateless and able to meet the 15-second freshness goal, but it adds a few seconds of lag to every change and repeats reads that mostly return nothing. A hosted realtime service is the quickest route to low-latency updates and removes most connection operations, but it brings recurring fees and couples the board to one provider's subscription model. Self-hosted WebSockets were chosen for fast updates without that vendor dependency; the accepted cost is operating connection capacity and reconnect handling ourselves.

Problem, Tenets, Goals and Non-Goals are unchanged.

## Questions for you

1. **Decision doc or just the entry?** Polling also meets the 15-second goal, so a later reader may well ask why we took on socket operations. I can expand the entry into `docs/decisions/change-delivery.md` with the criteria and all three options laid out, or leave the one-paragraph entry as the whole record. Which do you want?

2. **Should the freshness goal tighten?** You chose sockets for fast updates, but the only stated goal is still "within 15 seconds", which polling satisfies. With no tighter target, the three nodes have no number to hold "fast" to. Do you want a latency goal added, and if so what figure?

3. **Should vendor independence become a tenet?** The current tenet says "Self-hosted and managed infrastructure are both permitted." Your reason for this choice leans further than that. I see three readings:
   - It applies to this decision only, and the tenet stays as is.
   - The project leans away from vendor coupling on the board's live path only.
   - The project leans away from managed services in general, which would also steer the change store's database choice.

4. **Who authorizes a socket connection?** The access design covers HTTPS commands only and says delivery credentials "will belong to the delivery node". The HLD doesn't settle whether opening a socket is checked by access or by delivery, or what happens to an open socket when a session expires or an assignment is revoked. Do you want to decide that here, or leave it to the delivery node?

5. **May I fix the stale line in the access design?** `docs/intent/access/access-design.md` still refers to "the still-open change-delivery approach". It is a wording fix with no spec change, but it is in another segment, so I'm asking first.