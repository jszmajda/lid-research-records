## Phase 1 — Complete: HLD + Decision Doc

I've created a comprehensive decision doc at `docs/decisions/delivery-approach.md` that lays out:

1. **Context:** Why the choice matters (freshness, control, cost, complexity)
2. **Three options evaluated:** Five-second polling, self-hosted WebSockets, and hosted realtime service — with strengths/weaknesses and fit verdicts for each
3. **Decision rationale:** Why we chose self-hosted WebSockets: we're accepting operational complexity (heartbeats, session management, reconnection) in exchange for subsecond freshness, full operational visibility, and vendor independence
4. **Explicit trade-offs:** The decision doc names what we're trading away (simpler operations, reduced implementation work) and why that trade is worth it (control and independence matter more at this stage)
5. **Downstream consequences:** What this means for change store (replayable history), delivery (WebSocket sessions and sequencing), and browser sync (reconnection and catch-up logic)

The HLD now links to the decision doc from the Key Design Decisions table, so future readers can understand not just what was chosen, but why.

**Ready to proceed to Phase 2 — the three LLD drafts (change-store, delivery, browser-sync)?**