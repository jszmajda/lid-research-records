**Phase 1: HLD Review Stop**

I've updated the HLD to record your choice of self-hosted WebSockets. The Approach section now states the decision and its tradeoff explicitly; I've added a Key Design Decisions row explaining why this option was selected over polling and hosted services.

## Updated sections:

**Approach:**
- Now specifies self-hosted WebSockets for delivery
- Names the operational requirements this creates: connection lifecycle management, reconnection logic, and replay-based recovery
- Clarifies that storage, delivery, and browser sync must be designed in concert around this choice

**Key Design Decisions:**
- New row documents the WebSocket choice with rationale: fast updates without vendor costs, at the cost of owning connection operations
- Names the trade-offs against the rejected alternatives (polling lag + repeated reads; hosted service costs + coupling)

---

**Decision doc offer:** This choice is substantial and involved real trade-offs. The decision doc template suggests offering a full decision doc when a cold reader would re-litigate the choice without the competing options and criteria laid out. Would you like me to write a full decision doc (`docs/decisions/change-delivery-approach.md`) capturing the options, decision elements, and analysis? Or does the table row above suffice?

Once you confirm, we're ready to move to Phase 2 — the three leaf LLDs (change-store, delivery, browser-sync) you mentioned.