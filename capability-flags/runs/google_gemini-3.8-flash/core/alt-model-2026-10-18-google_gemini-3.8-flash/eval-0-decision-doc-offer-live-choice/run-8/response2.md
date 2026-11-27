I have documented the decision in `docs/decisions/change-delivery.md` following the LID decision-doc template, and linked it from `docs/high-level-design.md`.

### Summary of Documentation
- **Decision Doc (`docs/decisions/change-delivery.md`)**:
  - **Context**: Problem scope across 40 weekend markets, 800 concurrent browsers, and 20 edits/sec peak bursts.
  - **Decision Elements**: Evaluates freshness latency, vendor independence / operating cost, operational connection overhead, backend query efficiency, and client gap catch-up complexity against project tenets.
  - **Options Analyzed**: Five-second HTTPS polling, self-hosted WebSockets, and hosted realtime services (Pusher/Ably).
  - **Selection & Downstream Obligations**: Records why self-hosted WebSockets was chosen and details the downstream obligations cascaded to `change-store`, `delivery`, and `browser-sync`.
- **HLD Reference (`docs/high-level-design.md`)**: Linked from the Key Design Decisions section.

---

### Phase 1 Stop: Review & Approval

Per the linked-intent-dev workflow, we pause here at the Phase 1 boundary for your review before proceeding down the arrow.

When you are ready: which of the three downstream nodes (`change-store`, `delivery`, or `browser-sync`) would you like to design first in Phase 2?