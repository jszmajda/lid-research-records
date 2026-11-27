I've updated the HLD to the self-hosted WebSockets approach in `docs/high-level-design.md`. It's ready for your review before we start the three nodes.

**Changes**

- **Approach** now states the chosen approach. The server commits each edit as one revision and pushes committed revisions to browsers over WebSocket connections the project operates. Browsers apply pushed revisions in revision order. Revisions are kept in a replayable sequence so a reconnecting browser can catch up from its last applied revision. Publication to connected sockets is reliable. The paragraph also names the accepted cost (connection capacity, session lifecycle, reconnect handling) and the benefit (no realtime vendor pricing or provider coupling). A browser whose connection is down shows that state rather than a stale board.
- **Architecture** bullets for change store, delivery, and browser sync now describe what each node owns under this approach. Their "depends on the approach" wording is gone. None of the three nodes is written yet.
- **Key Design Decisions** has a new entry for this choice. It records why polling and the hosted service were rejected, and the cost accepted.

**Decision doc**

This choice is still live for a cold reader, since three nodes will be sized around it. Do you want it recorded as a standalone decision doc in `docs/decisions/`? The Key Design Decisions entry already stands on its own, so I'll only write the doc if you say yes.

**Next**

Please review the HLD. If it reads right, I'll draft the three nodes next: change store, delivery, and browser sync. Tell me if you want any change to the Approach wording first.