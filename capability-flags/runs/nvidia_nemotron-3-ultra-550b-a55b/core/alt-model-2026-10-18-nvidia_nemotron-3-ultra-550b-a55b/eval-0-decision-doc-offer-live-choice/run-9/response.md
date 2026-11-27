I've updated the HLD with the self-hosted WebSockets choice and created the three LLDs with their EARS specs. Here's a summary:

**Phase 1 — HLD Updated** (`docs/high-level-design.md`):
- Approach now specifies self-hosted WebSockets with downstream implications
- Architecture section updated to reflect the three new nodes
- Key Design Decisions table includes the self-hosted WebSockets choice with rationale

**Phase 2 — Three Leaf LLDs Created**:
1. **Change Store** (`docs/intent/change-store/`) — Replayable revisions + transactional outbox
2. **Delivery** (`docs/intent/delivery/`) — WebSocket session management, publication pipeline, reconnect/catch-up
3. **Browser Sync** (`docs/intent/browser-sync/`) — Client-side connection lifecycle, reconnect with exponential backoff, visible sync state

**Phase 3 — EARS Specs Drafted** (8 + 12 + 15 specs respectively):
- CHANGE-001–008: Revision commits, outbox, snapshot/cursor reads, retention, burst writes
- DELIVERY-001–012: WELCOME/REVISION/CATCH_UP frames, heartbeat, 800 sessions, outbox polling, backpressure, capacity handling
- BROWSER-001–015: Connection with cursor, revision apply, gap detection, reconnect/backoff, cursor persistence, UI sync state visibility

Ready for **Phase 4 — Intent-Narrowing Edge Audit**. I'll probe cross-spec interactions (e.g., delivery's outbox polling vs. change-store's transaction boundary; browser's RESYNC trigger vs. delivery's CATCH_UP contract; cursor semantics across all three). Want me to proceed with the edge audit, or would you like to review the LLDs/specs first?