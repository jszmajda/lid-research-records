Phase 1 is updated in `docs/high-level-design.md`:

- Self-hosted WebSockets are now the settled delivery approach.
- The 15-second freshness goal remains authoritative; subsecond updates are a benefit, not a new requirement.
- Change store owns replayable revisions and publication reconciliation state.
- Delivery owns WebSocket sessions, subscriptions, fanout, capacity, and connection lifecycle.
- Browser sync owns connection visibility, reconnects, and revision catch-up.
- The alternatives and rationale are recorded under Key Design Decisions.
- The existing Access node remains coherent and unaffected.
- `git diff --check` passes.

This project-level choice may warrant `docs/decisions/realtime-delivery.md` because future readers could reasonably reconsider the tradeoff and all three upcoming nodes depend on it.

Please reply with one option:

1. Approve the HLD and keep the decision record in the HLD.
2. Approve the HLD and add a full decision document.
3. Request changes to the HLD.