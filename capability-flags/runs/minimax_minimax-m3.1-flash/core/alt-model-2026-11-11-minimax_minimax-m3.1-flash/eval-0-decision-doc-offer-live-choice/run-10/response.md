**Phase 1 — HLD updated with the WebSocket approach.** `docs/high-level-design.md` now reads as follows (only the parts that changed):

- **Approach**: committed revisions reach browsers over self-hosted WebSocket connections; the change store keeps revisions durable/replayable, the delivery service publishes them to event sessions, browsers apply and catch up on reconnect. Ownership of connection capacity, session lifecycle, and reconnect handling is stated as the accepted cost.
- **Architecture**: the change-store, delivery, and browser-sync entries now state their socket-era obligations instead of "depends on the approach" (all three still "Not written yet").
- **Key Design Decisions**: new row — *Self-hosted WebSocket delivery*, with polling and hosted-realtime named as rejected alternatives and the downstream consequences spelled out.
- **Tenets**: added one candidate — "Own the commodity, buy the specialized" (commodity capability, prefer operating it over a recurring vendor contract).
- **Goals**: freshness tightened from *15 seconds* to *1 second*, since the 15s target was a polling-shaped bound. **Please ratify or give me the number you want** — I did not want to silently own that value.

Three things need your call before I go on to the three nodes:

1. **Freshness goal** — 1 second, or another target?
2. **The new tenet** — keep, reword, or drop it? Any other lean you want recorded (e.g. a durable read path outranking live delivery)? Note the Access node's existing specs are unaffected by this switch.
3. **Decision doc** — the delivery approach is project-level, trades credible options against latency/cost/ops burden, and the three nodes are about to be sized around it, so it may stay live for a cold reader. I recorded the HLD row; say the word and I'll also write `docs/decisions/` laying out context, criteria, options, and selection. Say no and the row stands alone.

Two flags for the record:

- **Cross-segment cascade**: socket sessions need to be authorized somehow, and `access-design.md` currently says delivery-specific subscription credentials "will belong to the delivery node." That is an obligation in the Access segment, so I have not touched it. When we draft the delivery node I will bring the exact wording to you before editing Access.
- The HLD has no `## Target Users` or `## Success Metrics` sections (the project uses a leaner shape than the template). I left that as-is; say if you want them filled in.

Next, per your plan, is Phase 2 for the three nodes: change-store, delivery, browser-sync — starting with the LLD drafts and the choices each of them still leaves open.