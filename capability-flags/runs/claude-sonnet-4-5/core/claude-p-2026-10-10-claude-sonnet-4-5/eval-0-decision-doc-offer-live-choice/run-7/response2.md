Created the decision doc at `docs/decisions/change-delivery-mechanism.md` and linked it from the HLD.

**Decision doc structure:**

**Context** — describes the operational need (40 markets, 800 browsers, up to 20 edits/sec) and why the mechanism choice is load-bearing for the three pending components.

**Decision Elements:**
- Gates: 15-second freshness, scale requirements (all three options pass)
- Weighted criteria: update latency (moderate), recurring cost (major), vendor coupling (major), operational complexity (major), implementation complexity (moderate)

**Options:**
- **HTTPS Polling** — stateless, simple, acceptable latency but higher request volume and noticeable lag
- **Self-hosted WebSockets** — fast updates, no vendor fees, accepts connection management complexity
- **Hosted Realtime Service** — fast implementation, introduces recurring fees and provider lock-in

**Selection** — WebSockets win on the two major criteria (cost and vendor independence), delivering strong latency without vendor coupling. Accepts operational complexity as the tradeoff. The decision turns on the tenet permitting both self-hosted and managed infrastructure—choosing self-hosted keeps future infrastructure decisions open.

The HLD's Key Design Decisions row now links to the full doc.