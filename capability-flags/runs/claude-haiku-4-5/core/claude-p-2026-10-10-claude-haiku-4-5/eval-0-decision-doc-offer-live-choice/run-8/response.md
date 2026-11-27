## Phase 1 — HLD check: STOP for user review

I've updated the High-Level Design to commit to the self-hosted WebSockets approach. Here's what changed:

**Approach section**: Removed the open question and committed to WebSockets, naming the tradeoff (connection complexity for vendor independence and speed) and the implications for each component.

**Architecture section**: Clarified each component's role under the WebSockets approach—the store maintains replayable history, delivery manages socket sessions, browser sync handles reconnection and catch-up.

**Key Design Decisions**: Added an entry recording the WebSockets choice with rationale (why it wins over polling and hosted services) and the downstream obligations it creates.

The updated HLD is at `docs/high-level-design.md`. Please review it—does this capture the intent correctly? Any adjustments needed before we move to Phase 2 (the three LLDs for change store, delivery, and browser sync)?