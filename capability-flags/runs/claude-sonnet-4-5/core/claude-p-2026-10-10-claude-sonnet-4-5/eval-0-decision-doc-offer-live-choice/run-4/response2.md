Created `docs/decisions/delivery-approach.md` with the full decision analysis. It covers:

**Decision Elements:**
- Gates: Both the 15-second freshness target and 800-browser capacity (all options pass)
- Weighted criteria ranked by importance:
  - Update latency (major) — subsecond delivery is useful
  - Vendor independence (major) — preserves deployment flexibility
  - Operational complexity (moderate) — connection management work
  - Recurring service costs (minor) — no declared budget constraint

**Options analyzed:**
- Five-second HTTPS polling: strong on independence and simplicity, weak on latency (2–5 second lag)
- Self-hosted WebSockets: strong on latency and independence, weak on operational complexity
- Hosted realtime service: strong on latency, eliminated on vendor coupling, weak on recurring costs

**Selection rationale:**
Self-hosted WebSockets wins on both major criteria (subsecond latency + vendor independence). Accepts the operational work of connection management because it's bounded to two subsystems and buys deployment flexibility and cost predictability.

**Downstream implications** spell out what change-store, delivery, and browser-sync must each handle.

The HLD now links to this decision doc from its Key Design Decisions section. Ready to proceed with the three LLD nodes?