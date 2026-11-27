The HLD now records the decision. Updated `docs/high-level-design.md`:

**Approach** — Committed changes deliver over self-hosted WebSockets: fast updates without a realtime-vendor fee or provider coupling, exceeding the 15-second goal (subsecond delivery is a consequence, not a target). The downstream obligations are named — replayable revisions in the store, session management and reliable publication in delivery, reconnect/catch-up in browsers — along with why polling (lag plus repeated reads) and the hosted service (fees plus vendor coupling on the core update path) were rejected.

**Architecture** — The three pending nodes now state their WebSocket-shaped responsibilities instead of "depends on the approach."

**Key Design Decisions** — Added the decision row with the rejected alternatives.

One thing I did **not** touch: `docs/intent/access/access-design.md` line 10 says authorization is "independent of the still-open change-delivery approach" — that's now stale wording in the access segment. Fixing it is a cross-segment cascade, so I paused per the workflow; it's a one-line edit, and I can fold it in when we work the nodes.

Two questions before we proceed to the three nodes (change store, delivery, browser sync):

1. This choice clears the bar for a **decision doc** — three credible options traded against latency, cost, ops burden, and coupling, with all three nodes about to be sized around the result and a cold reader plausibly tempted to reverse it to polling. Want me to write `docs/decisions/self-hosted-websockets.md`, or is the Key Design Decisions row enough?
2. Shall I apply the one-line access-design wording fix above, or leave it for the access segment?