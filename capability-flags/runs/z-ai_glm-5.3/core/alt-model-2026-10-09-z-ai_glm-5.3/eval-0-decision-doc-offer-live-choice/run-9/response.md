Phase 1 is complete — the approach revision is done. Here is the changed portion of the HLD in full for your review (Problem, Tenets, Goals, Non-Goals are unchanged):

## Approach

> Keep one authoritative board per event. Editors submit commands over HTTPS; the server commits each edit as one event revision. Committed changes are pushed to connected browsers over WebSocket connections the service hosts itself. A browser that reconnects after a connection gap catches up from the change store's replayable revision history.
>
> Change storage, delivery, and browser recovery are designed together: the change store publishes committed revisions reliably, delivery manages WebSocket sessions for connected browsers, and browser sync handles reconnect and catch-up.

## Architecture

> - Access: `docs/intent/access/access-design.md`, with `docs/intent/access/access-specs.md`. Written below the stable HTTPS command boundary.
> - Change store: `docs/intent/change-store/change-store-design.md`, with `docs/intent/change-store/change-store-specs.md`. Not written yet. Replayable revision history, read indexes, and reliable publication to the delivery node.
> - Delivery: `docs/intent/delivery/delivery-design.md`, with `docs/intent/delivery/delivery-specs.md`. Not written yet. Owns WebSocket session management, fan-out of committed revisions to connected browsers, and connection capacity.
> - Browser sync: `docs/intent/browser-sync/browser-sync-design.md`, with `docs/intent/browser-sync/browser-sync-specs.md`. Not written yet. Owns the browser's WebSocket subscription, reconnect behavior, and revision catch-up after a connection gap.

## Key Design Decisions (new entry)

> - **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to browsers over WebSocket connections the service hosts itself. Five-second HTTPS polling was rejected: simplest stateless operation, but every browser re-reads the store on a timer and each change lags by up to the polling interval. A hosted realtime service was rejected: quickest route to low-latency updates with the least connection operations, but recurring fees and a provider coupled into the board's delivery path. Self-hosted WebSockets give fast updates without tying the board to a realtime vendor, at the accepted cost of owning connection capacity and reconnect behavior in-house.

Also fixed: `docs/intent/access/access-design.md` still called the delivery approach "still-open"; that phrase is now stale, so I corrected it (one word — no behavior or spec change in the access segment).

**Phase 1 stop — three things for you:**

1. **Tenet candidate from this choice.** The three new nodes will face a recurring question: does delivery own missed-update recovery? I'd propose recording a lean — *"The change store is the source of truth for recovery; delivery connections are transport, not storage."* It bites when the delivery node is tempted to buffer missed revisions per offline browser in socket-layer state; the tenet would lean "no, the store's replayable revisions cover it." The opposite is defensible (a delivery layer with its own retention), so it's a real lean, not a platitude. Add it, or leave the tenets as they are? Any other leans you want recorded before we size the three nodes?

2. **Decision doc offer.** The delivery choice stays live for a cold reader — three credible options weighed on ops burden, cost, latency, and vendor coupling, and three nodes are about to be sized around the result. I can record it as a full decision doc (`docs/decisions/self-hosted-websocket-delivery.md`, options and criteria at re-runnable depth), or the Key Design Decisions entry above stands as the record. Which would you like?

3. **Order of the three nodes.** When you approve the HLD, we move to Phase 2. Change store seems the natural first — delivery and browser sync both consume its revisions — but you may have a different order in mind.

Approve the HLD revision as shown, or give numbered feedback and I'll iterate.