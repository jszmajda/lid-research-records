## Phase 1 — HLD Check: Complete

I've updated the HLD to record your selection of self-hosted WebSockets as the delivery approach. The changes clarify:

1. **Approach section** now states the chosen delivery mechanism and explicitly names the trade-off: operational complexity of connection management in exchange for vendor independence.

2. **Architecture section** updated to describe what each subsystem must do under this approach:
   - Change store: maintains replayable revision history for client recovery
   - Delivery: manages WebSocket sessions, heartbeats, and ordered publication
   - Browser sync: subscribes to the stream, handles reconnection, and fetches missed revisions during recovery

3. **Key Design Decisions** includes a new entry documenting the self-hosted WebSockets choice with its rationale and downstream implications.

The HLD now reads context-free and is ready for the three LLDs (change-store, delivery, and browser-sync) in Phase 2.

**Please review the updated HLD and confirm approval to proceed to Phase 2 — the LLD drafts for the three subsystems.**