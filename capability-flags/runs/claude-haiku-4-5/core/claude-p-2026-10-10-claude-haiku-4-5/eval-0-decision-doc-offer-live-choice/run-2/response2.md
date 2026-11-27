**Updated HLD recorded** with the self-hosted WebSockets decision now documented in `docs/decisions/realtime-delivery-approach.md`.

The decision doc lays out the tradeoff transparently:

- **Polling** is simplest operationally but wastes compute on repeated full-state queries.
- **Hosted realtime service** minimizes operational burden but introduces vendor dependency and recurring costs.
- **Self-hosted WebSockets** (chosen) requires managing connection lifecycle and reconnection recovery, but gives subsecond updates and operational independence.

The doc traces how this decision cascades: Change Store must support revision replay for catch-up, Delivery owns session management and publication, and Browser Sync needs reconnection logic and state reconciliation. The HLD now links to this doc from its Key Design Decisions section.

**Phase 1 stop — HLD check complete.** The approach is now settled, the decision rationale is documented, and the downstream component requirements are explicit. Ready for your approval before moving to Phase 2 (LLD check/draft for Change Store, Delivery, and Browser Sync)?