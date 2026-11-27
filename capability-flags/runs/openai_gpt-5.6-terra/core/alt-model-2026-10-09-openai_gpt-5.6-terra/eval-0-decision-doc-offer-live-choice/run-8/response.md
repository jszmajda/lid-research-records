**Phase 1: HLD updated**

`docs/high-level-design.md` now records self-hosted WebSocket delivery as the selected architecture:

- Committed revisions are published through application-operated WebSocket sessions.
- The change store must retain replayable revisions and support reliable publication.
- Delivery owns connection capacity, sessions, and reconnect support.
- Browser sync reconnects, catches up from its last applied revision, then resumes live updates.
- The HLD records why five-second polling and a hosted realtime provider were rejected.

This is a load-bearing choice affecting three design nodes. It is recorded in the HLD’s Key Design Decisions; a standalone decision document could additionally preserve the option comparison for future review.

Please confirm:
1. Approve this HLD update and proceed to the change-store LLD.
2. Whether to create a standalone decision document for the WebSocket choice, or retain the HLD decision entry alone.