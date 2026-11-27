## Phase 1: HLD Review

Updated `docs/high-level-design.md` to select self-hosted WebSockets for committed-change delivery.

- The approach now defines one synchronization path: replayable revisions, reliable publication, server-managed WebSocket sessions, and browser reconnect/catch-up.
- The change-store, delivery, and browser-sync node responsibilities now reflect that path.
- The prior infrastructure tenet is replaced with: provider independence is preferred over minimizing connection-operations work for realtime delivery.
- The decision records why five-second polling and a hosted realtime service were rejected.

This is a consequential, durable choice with credible alternatives. Would you like a standalone decision document under `docs/decisions/`, or is the HLD’s Key Design Decisions entry sufficient?

Please review and approve the HLD update before I draft the three downstream design nodes.