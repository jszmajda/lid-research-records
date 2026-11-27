The HLD is updated for the self-hosted WebSockets selection. The updated sections:

**Approach** — Committed changes are pushed over self-hosted WebSockets: delivery publishes each committed event revision to connected socket sessions; browsers that miss revisions while disconnected catch up by replay from the change store. The three coupled nodes are named: the change store keeps replayable revisions and a reliable publication path, delivery owns socket session management and publication, browser sync owns reconnect and catch-up. Operating our own connections is stated as accepted work in exchange for fast updates without a realtime vendor dependency.

**Architecture** — the three unwritten nodes' scope notes now state their WebSocket-era obligations instead of "depends on the approach."

**Key Design Decisions** — added: *Self-hosted WebSockets for change delivery*, with the rejections recorded — polling (repeated reads and a few seconds of lag; stateless polling buys little when the store must support replay anyway) and hosted realtime (recurring fees and provider coupling for a single update stream).

One cross-segment note: `docs/intent/access/access-design.md:10` still describes change delivery as "still-open" — a one-word staleness in the access segment. I've left it alone per cascade discipline; it can be fixed when we touch that segment next, or now if you prefer.

Two things for you:

1. **Decision doc?** Three credible options were weighed on latency, ops burden, cost, and vendor coupling, and the change store, delivery, and browser sync are about to be sized around the result — a cold reader might be tempted to reverse the choice without the tradeoffs laid out. Want me to record it as a full decision doc at `docs/decisions/` (linked from the Key Design Decisions entry), or is the table row as written enough?

2. **Phase 1 stop:** please review the updated HLD sections above. On your approval, I'll proceed to the change store, delivery, and browser sync nodes.