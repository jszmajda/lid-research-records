I have updated `docs/high-level-design.md` to reflect the selection of the self-hosted WebSockets approach.

### Changes Made
- **Approach**: Replaced the open trade-off discussion with the chosen self-hosted WebSockets model, specifying server socket connection and session management, revision notification broadcasts, change store monotonic revisions and replayability, and browser reconnect/catch-up logic.
- **Architecture**: Clarified responsibilities for the downstream nodes (`change-store`, `delivery`, and `browser-sync`) given the WebSocket architecture.
- **Key Design Decisions**: Recorded the choice of self-hosted WebSockets along with the rejected alternatives (5-second HTTPS polling and hosted realtime vendors) and the rationale.

### Next Steps & Decision Recording
Under Phase 1 guidance for consequential architectural decisions:
1. Would you like to record this choice as a standalone project-level decision doc in `docs/decisions/change-delivery.md` (for future readers to re-run the detailed trade-offs across connection ops, latency, and vendor lock-in), or does the summary entry in the HLD's Key Design Decisions suffice?
2. Shall we proceed to Phase 2 to draft the three dependent design nodes (`change-store`, `delivery`, and `browser-sync`), and if so, which would you like to tackle first?