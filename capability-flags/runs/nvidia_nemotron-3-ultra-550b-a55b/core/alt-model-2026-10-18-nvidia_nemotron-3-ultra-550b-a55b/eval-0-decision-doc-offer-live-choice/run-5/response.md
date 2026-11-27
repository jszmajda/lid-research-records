**Phase 1 — HLD updated** with the self-hosted WebSockets decision. The HLD now records:

- **Approach**: Self-hosted WebSockets chosen, accepting connection/reconnect complexity for fast updates without vendor fees
- **Architecture**: Three new nodes marked "To be written" — change-store (revision history + publication outbox), delivery (WebSocket sessions + replay), browser-sync (subscription + catch-up)
- **Key Design Decisions**: New entry documenting the choice over polling and hosted service, with downstream consequences

The HLD reads context-free — rationale and alternatives are recorded, no conversation residue.

**STOP for your review.** Approve to proceed to Phase 2 (draft LLDs for change-store, delivery, browser-sync), or request changes.