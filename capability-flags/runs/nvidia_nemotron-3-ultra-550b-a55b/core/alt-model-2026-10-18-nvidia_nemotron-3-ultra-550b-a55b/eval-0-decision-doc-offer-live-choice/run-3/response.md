**Phase 1–3 Complete — STOP for Review**

I've updated the approach to **self-hosted WebSockets** and created the three downstream design nodes:

### Changes Made

1. **HLD updated** (`docs/high-level-design.md`) — Approach now commits to self-hosted WebSockets with rationale; Architecture section references the three new LLDs.

2. **Three new LLDs** (leaf nodes under HLD):
   - `docs/intent/change-store/change-store-design.md` — Revision history, cursor queries, transactional outbox, 7-day retention
   - `docs/intent/delivery/delivery-design.md` — WebSocket session management, JSON protocol, outbox polling (100ms), fan-out, 15s/10s heartbeat, 50 unacked buffer
   - `docs/intent/browser-sync/browser-sync-design.md` — Subscription state machine, exponential backoff reconnect (500ms→30s, 20-min max), catch-up with per-revision ack, synchronous connectivity indicator, edit gating

3. **Three EARS spec files** (82 specs total):
   - `docs/intent/change-store/change-store-specs.md` (19 specs: CHANGE-001–019)
   - `docs/intent/delivery/delivery-specs.md` (30 specs: DELIVERY-001–030)
   - `docs/intent/browser-sync/browser-sync-specs.md` (33 specs: BROWSER-001–033)

4. **Phase 3 Consistency Report** (`docs/intent/phase3-consistency-report.md`) — Coverage ✅, Contradictions ✅, Scoping ✅, Context-free ✅; 5 cross-segment cascade points identified for Phase 4.

---

**Please review:**
- The HLD approach section and architecture references
- Each LLD's Decisions & Alternatives table and Open Questions
- The EARS specs for completeness and clarity
- The consistency report's cascade points

**Phase 4 (Intent-Narrowing Edge Audit)** will probe the 5 cross-segment interactions and per-spec divergence readings. Ready to proceed when you approve.