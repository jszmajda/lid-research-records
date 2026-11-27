Updated `docs/high-level-design.md` to establish:

- Self-hosted WebSockets for committed-change delivery.
- HTTPS as the authoritative command boundary.
- Replayable revisions and reliable publication in the change store.
- WebSocket session ownership in delivery.
- Reconnect and catch-up ownership in browser sync.
- The polling and hosted-service alternatives, with the rationale for rejecting them.

`git diff --check` passes.

Before cascading into the three nodes, please confirm:

1. Do you approve the revised HLD?
2. This choice remains reasonably open to future re-litigation and sizes all three downstream nodes. Should it receive a full project-level decision document, or is the HLD decision entry sufficient?
3. `docs/intent/access/access-design.md` still calls the delivery approach “still-open.” May I include that non-behavioral wording correction in the downstream cascade?