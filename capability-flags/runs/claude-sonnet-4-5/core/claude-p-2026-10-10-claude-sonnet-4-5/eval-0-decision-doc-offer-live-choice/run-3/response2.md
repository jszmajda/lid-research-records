Created a decision doc at `docs/decisions/change-delivery-mechanism.md` with the full tradeoff analysis.

## Structure

**Context** — why the delivery mechanism choice matters and what it shapes (storage, server responsibilities, browser behavior).

**Decision Elements:**
- Gate: 15-second freshness (all three options pass)
- Major criterion: Update latency
- Moderate criteria: Operating cost, operational burden, infrastructure independence  
- Minor criterion: Implementation complexity

**Options in the Domain** — each option analyzed against all elements:

1. **Five-second HTTPS polling** — simplest and lowest operational risk, but 2–5 second lag and repeated database reads
2. **Self-hosted WebSockets** — fast updates without vendor coupling, but connection management and reconnect logic increase operational burden
3. **Hosted realtime service** — fastest route to low-latency updates with less connection work, but ongoing cost and tight provider coupling

**Selection** — self-hosted WebSockets chosen because coordinators will notice the latency improvement (subsecond vs. multi-second) without tying the board to a vendor. The decision accepts higher operational burden to secure lower long-term cost and vendor independence.

**Implications** spelled out: what the change store, delivery layer, and browsers must now implement, and what this forecloses.

The HLD's Key Design Decisions section now links to the doc instead of inlining the summary.

Ready to proceed with the three nodes (change-store, delivery, browser-sync)?