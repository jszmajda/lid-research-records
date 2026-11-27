I have updated the High-Level Design in `docs/high-level-design.md` to reflect the selection of self-hosted WebSockets for change delivery:

- **Approach**: Updated to establish self-hosted WebSockets as the delivery mechanism, defining the coordinated responsibilities across change store (replayable revisions and publication triggers), delivery (persistent WebSocket sessions and connection capacity), and browser sync (connection management, reconnect backoff, and catch-up logic).
- **Architecture**: Aligned the downstream component descriptions (`change-store`, `delivery`, and `browser-sync`) with WebSocket delivery obligations.
- **Key Design Decisions**: Recorded the self-hosted WebSockets decision with rationale, trade-offs, and alternatives considered (HTTPS polling and hosted realtime services).

Per the linked-intent-dev workflow, this completes Phase 1 (HLD check/update).

Would you like to record this choice as a full decision doc in `docs/decisions/` or keep it as an HLD Key Design Decision entry? And when you are ready, may we proceed to Phase 2 to draft the first of the three downstream design nodes?