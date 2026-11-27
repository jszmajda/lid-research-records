**Phase 1 complete — HLD updated with self-hosted WebSockets approach.**

The HLD now records:
- **Approach**: Self-hosted WebSockets for change delivery (subsecond updates, store provides replayable revisions, delivery manages socket sessions, browser sync handles subscription/reconnect/catch-up)
- **Architecture**: All three downstream nodes (change-store, delivery, browser-sync) now have defined responsibilities
- **Key Design Decision**: Self-hosted WebSockets chosen over polling and hosted services, accepting connection/reconnect complexity for vendor-free fast updates

Ready for **Phase 2 — LLD drafts** for the three nodes:
1. `change-store` — revision history, read indexes, publication outbox
2. `delivery` — WebSocket sessions, publication, server-side reconnection state
3. `browser-sync` — WebSocket subscription, client-side reconnection, revision catch-up

Shall I proceed with drafting the three LLDs?