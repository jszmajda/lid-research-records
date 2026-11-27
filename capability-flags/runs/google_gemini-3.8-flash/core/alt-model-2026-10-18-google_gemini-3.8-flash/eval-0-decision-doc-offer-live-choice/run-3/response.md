I have updated the high-level design (`docs/high-level-design.md`) and refreshed the context in `docs/intent/access/access-design.md` to reflect the self-hosted WebSockets decision.

### Summary of Changes

1. **`docs/high-level-design.md`**:
   - **Approach**: Updated to establish self-hosted WebSockets as the delivery mechanism for committed board changes, outlining the responsibilities for server-side session management, publication, and reconnect catch-up.
   - **Architecture**: Clarified the roles of the three upcoming nodes:
     - `change-store`: Persists ordered event revisions and supports replay queries.
     - `delivery`: Manages WebSocket sessions, client heartbeats, and broadcast distribution.
     - `browser-sync`: Handles browser WebSocket connections, reconnection backoff, and catch-up via replay or snapshot.
   - **Key Design Decisions**: Recorded the self-hosted WebSockets decision, its rationale (low-latency updates without vendor lock-in or recurring fees), and the accepted operational tradeoffs (connection management, heartbeats, and reconnect replay).
2. **`docs/intent/access/access-design.md`**:
   - Updated context to note that command authorization remains independent of the WebSocket change-delivery mechanism.

---

### Phase 1 Review & Decision Recording

1. Would you like to record this architectural choice as a standalone project-level decision doc in `docs/decisions/` (e.g., `docs/decisions/change-delivery-mechanism.md`), or does the entry in the HLD's **Key Design Decisions** section suffice?
2. Do you approve the updated HLD to proceed to Phase 2 (drafting the downstream design nodes: `change-store`, `delivery`, and `browser-sync`)?