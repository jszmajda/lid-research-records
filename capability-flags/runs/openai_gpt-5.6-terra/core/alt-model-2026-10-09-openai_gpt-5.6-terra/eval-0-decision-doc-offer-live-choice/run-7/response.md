## Phase 1: HLD Update

Updated `docs/high-level-design.md` to select self-hosted WebSockets for committed board-change delivery.

- The approach now requires replayable revisions, managed WebSocket sessions, reliable publication, and browser reconnect/catch-up.
- The three dependent nodes now have fixed responsibilities:
  - Change store: revision retention and replay.
  - Delivery: WebSocket sessions, publication, and capacity.
  - Browser sync: subscription, reconnect, and catch-up.
- The HLD records why polling and a hosted realtime provider were rejected.
- The infrastructure tenet now prefers avoiding vendor coupling when the team can operate the necessary infrastructure.

Please review and explicitly approve this HLD update before I draft the change-store, delivery, and browser-sync nodes.