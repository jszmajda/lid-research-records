Now I need to record this decision. This choice affects multiple components (change-store, delivery, browser-sync) and involved weighing real tradeoffs. I can record it either as:

**Option A: Full decision doc** at `docs/decisions/realtime-delivery-approach.md` — captures the three options, their tradeoffs (latency vs. vendor coupling vs. operational burden), and why self-hosted WebSockets was selected. A cold reader wanting to understand or reconsider this choice would have the full analysis.

**Option B: Key Design Decisions row** — a concise entry in the HLD naming the choice and one-line rationale.

Which would you prefer? Given that this decision shapes three downstream components and traded latency/coupling/operations concerns, a full decision doc would preserve the reasoning, but a Key Design Decisions entry may suffice if the rationale is straightforward enough.

---

**Updated HLD Approach section:**

```markdown
## Approach

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to browsers through self-hosted WebSockets, providing fast updates without tying the board to a realtime vendor.

The change store maintains replayable revisions so reconnecting browsers can catch up from their last-seen revision. Delivery manages WebSocket sessions, connection lifecycle, and reliable publication of committed changes. Browsers implement reconnect and catch-up logic, requesting missed revisions on reconnection.
```

Does this capture the approach correctly? Once you confirm and select how to record the decision, we'll move to the three nodes (change-store, delivery, browser-sync).