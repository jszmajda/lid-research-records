## Phase 1 (HLD Check) Complete — Updated Approach

I've updated the HLD to record your WebSockets decision and created supporting documentation:

**High-Level Design (`docs/high-level-design.md`)**
- **Approach section**: Now states that "Delivery of committed changes uses self-hosted WebSockets for fast, cost-effective updates without vendor coupling" and explains the implications for the three downstream components.
- **Architecture section**: Updated to describe what each component now owns: change-store provides replayable revisions and publication outbox; delivery manages WebSocket sessions and subscriptions; browser-sync handles reconnection and state reconciliation.
- **Key Design Decisions section**: Added a new entry for "Self-hosted WebSockets for delivery" that names the competing options and links to the detailed analysis.

**Decision Doc (`docs/decisions/delivery-approach.md`)**
- Records the context (why the decision is needed), the weighted criteria (latency, operational complexity, cost, store requirements), and detailed analysis of all three options.
- Explains why WebSockets was selected: fast updates without vendor coupling, with operational complexity accepted as a reasonable tradeoff.
- Specifies downstream implications for each of the three LLDs.

The HLD is now context-free and ready to guide the three components. Ready to move forward to drafting the change-store, delivery, and browser-sync LLDs?