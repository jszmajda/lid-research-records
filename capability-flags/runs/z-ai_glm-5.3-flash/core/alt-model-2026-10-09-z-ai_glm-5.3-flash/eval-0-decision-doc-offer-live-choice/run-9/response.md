I've updated `docs/high-level-design.md` to record the self-hosted WebSockets choice:

- **Approach** — now states delivery is self-hosted WebSockets, with the two rejected alternatives and why: polling (lag and repeated reads in every browser) and a hosted realtime service (recurring fees, vendor coupling not justified for stall-status data). It names the accepted cost — owning connection capacity and reconnect handling — and how it runs through the downstream nodes: replayable revisions and reliable publication in the change store, session management in delivery, reconnect/catch-up in browser sync.
- **Architecture** — the three unwritten nodes' one-line scopes are updated to the WebSocket reality (they previously said "depends on the approach").
- **Key Design Decisions** — added a **Self-hosted WebSockets for change delivery** entry with the rationale and rejections.

No cascade was needed beyond the HLD itself: the access node doesn't touch delivery, and the three affected nodes haven't been written yet — we'll draft them next as you said (change store → delivery → browser sync, pausing at each).

One offer before we proceed: this choice will stay live for a cold reader — credible options traded on more than one criterion (latency, ops burden, cost/coupling), and all three nodes are about to be sized around it. I can record it as a **decision doc** in `docs/decisions/` (linking it from the HLD's decisions entry), or keep the current HLD row as the whole record. Which do you prefer? And does the HLD update as written look right to you?