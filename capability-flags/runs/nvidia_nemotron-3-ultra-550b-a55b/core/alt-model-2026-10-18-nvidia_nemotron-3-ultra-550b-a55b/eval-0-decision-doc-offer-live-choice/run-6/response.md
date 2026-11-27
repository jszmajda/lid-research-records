**Phase 1 — HLD check complete.** I've updated the HLD to record the self-hosted WebSockets decision:

- **Approach**: Now states self-hosted WebSockets with the tradeoffs (subsecond updates, no vendor bill, but we own connection capacity, reconnect, and catch-up)
- **Architecture**: Updated each downstream node's description to reflect WebSocket-specific responsibilities
- **Key Design Decisions**: Added the decision row with rationale and downstream implications

The HLD now reads context-free — a fresh author would write this as the current intent.

**STOP for user review.** Please confirm this HLD update, and I'll proceed to **Phase 2 — LLD check/draft** for the three nodes (change-store, delivery, browser-sync).