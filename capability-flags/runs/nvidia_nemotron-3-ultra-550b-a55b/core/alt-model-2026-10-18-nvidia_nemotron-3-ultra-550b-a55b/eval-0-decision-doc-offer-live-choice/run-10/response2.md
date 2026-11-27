**Phase 1 complete — HLD updated with decision doc.**

Created `docs/decisions/change-delivery-approach.md` with:
- **Context**: 800 browsers, 15s freshness target, 20min recovery, vendor independence gate
- **Three options** analyzed against gates + 5 weighted criteria (operational complexity major, latency major, recurring cost moderate, implementation effort minor, browser recovery moderate)
- **Selection rationale**: Option 3 eliminated by vendor-independence gate; Option 2 chosen over Option 1 because latency (major) and recurring cost (moderate) outweigh operational complexity (major) — which the user explicitly accepted

The HLD now references the decision doc for the full tradeoff analysis.

---

Ready for **Phase 2 — LLD drafts** for the three nodes:

1. **`change-store`** — append-only revision log, read indexes (cursor queries for catch-up), publication outbox (ordered, at-least-once to delivery)
2. **`delivery`** — WebSocket session lifecycle (accept, heartbeat, backpressure, graceful drain), server-side reconnection state (per-socket last-acked revision), outbox consumer with idempotent publish
3. **`browser-sync`** — WebSocket connection with exponential-backoff reconnection, catch-up query on resume (revisions since `lastSeen`), seamless transition from catch-up to live updates

Shall I draft all three LLDs?