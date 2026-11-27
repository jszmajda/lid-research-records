I updated the HLD to record the self-hosted WebSocket choice. Here's what's in `docs/high-level-design.md` now, and what I need from you before moving to the three nodes.

**Approach** — replaced the "still open" paragraph: browsers hold one socket per event, the server pushes each committed revision as it is assigned; the change store keeps replayable revisions and publishes them, delivery owns sessions and fan-out, browsers reconnect and catch up.

**Architecture** — the three unwritten nodes now name their WebSocket-shaped responsibilities (change-store: revision log, replayable reads, reliable publication; delivery: connection acceptance, subscription, fan-out, capacity; browser-sync: socket lifecycle, reconnection, catch-up).

**Tenets** — I replaced "Self-hosted and managed infrastructure are both permitted" with "Operate rather than rent… prefer operating it in-house, unless the operational burden would threaten the availability goal." This narrows the old tenet to a general lean; flag it if you'd rather keep both.

**Goals** — the freshness goal went from 15 seconds to 2 seconds, since socket push makes the old polling-era number arbitrary. Two seconds is my pick, not yours — say a different number if you have one in mind.

**Key Design Decisions** — added "Self-hosted WebSocket delivery for committed changes", naming five-second polling and a hosted realtime service as rejected alternatives and why.

Three things I need from you:

1. **Freshness target** — 2 seconds, or another number?
2. **The new tenet** — keep it as written, or reword/restore the "both permitted" wording?
3. **Decision doc** — the delivery-mechanism choice traded cost, vendor coupling, and operational burden against each other, and the change-store, delivery, and browser-sync nodes will be sized around it. A cold reader would likely re-litigate it. That clears the bar for a standalone decision doc at `docs/decisions/`. Want one, or is the Key Design Decisions row enough?

One cross-segment item I'll raise when we design the nodes: the access LLD currently puts delivery-specific subscription credentials outside access, so nothing yet says who authorizes a browser's socket subscription to an event. I'll settle it with you during the node work rather than editing access now.