Updated `docs/high-level-design.md` to establish:

- Self-hosted WebSockets for committed changes.
- Replayable event revisions and reliable post-commit publication.
- Delivery-owned connection capacity and WebSocket sessions.
- Browser reconnect, catch-up, and visible connectivity behavior.
- The accepted tradeoff: more connection operations in exchange for low latency, no recurring realtime-service fees, and no provider coupling.

The existing Access design remains behaviorally coherent, although one sentence still calls the delivery approach “open”; that should be corrected during the downstream cascade.

This choice is significant enough that a future reader could reasonably reconsider it. Please confirm:

1. Do you approve this HLD update?
2. Should the WebSocket choice remain the concise Key Design Decision now recorded, or should I add a full project-level decision document before we proceed to the three nodes?