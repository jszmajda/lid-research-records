**Phase 1 — HLD updated**

I've updated `docs/high-level-design.md` to reflect the self-hosted WebSockets decision:

**Changes made:**

1. **Approach section** — replaced "still open" language with the chosen approach: self-hosted WebSockets for fast updates without vendor coupling.

2. **Key Design Decisions** — added new entry documenting the choice:
   - Self-hosted WebSockets chosen for subsecond updates without recurring vendor fees
   - Accepts operational work: connection management, reconnect/catch-up logic, replayable revisions
   - Rejected HTTPS polling (higher latency) and hosted realtime (vendor lock-in, recurring costs)

3. **Architecture section** — updated the three dependent nodes to reflect WebSocket-specific responsibilities:
   - Change store: maintains replayable revision history, handles reliable publication
   - Delivery: manages WebSocket sessions, broadcasts changes, handles connection lifecycle
   - Browser sync: implements WebSocket subscription, reconnect logic, catch-up queries

The HLD now reads as if this decision was made from the start, with no conversation residue. The three design nodes (change-store, delivery, browser-sync) are ready to be drafted against this approach.

Does this capture the decision correctly?