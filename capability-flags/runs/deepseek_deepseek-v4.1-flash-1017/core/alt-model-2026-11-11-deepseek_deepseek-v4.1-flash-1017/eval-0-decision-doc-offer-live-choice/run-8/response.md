I've updated the HLD to settle on self-hosted WebSockets.

**Approach** (`docs/high-level-design.md:9-13`)
- Committed changes reach browsers over self-hosted WebSocket sessions; the server holds each browser connection and pushes revisions as they land.
- Self-hosting trades recurring vendor fees and provider coupling for owning connection capacity, reconnect handling, and reliable publication.
- The change store keeps replayable revisions for catch-up; delivery manages sessions and capacity; browser sync subscribes, reconnects, and catches up from its last-seen revision.
- Polling and hosted realtime are recorded as the rejected alternatives, with why.

**Architecture** (`:18-20`) — the three unwritten nodes now carry their socket-shaped responsibilities instead of "depends on the approach."

**Key Design Decisions** (`:46`) — added the self-hosted WebSockets entry naming the alternatives, the trade accepted, and the downstream obligations it creates.

Two things before we move on:

1. This choice sounds like one a cold reader could re-litigate — three credible options weighed against cost, operations, and vendor coupling, with three nodes about to be sized around it. Shall I record it as a full decision doc (with the HLD entry linking to it), or is the Key Design Decisions entry enough?

2. `docs/intent/access/access-design.md:10` still reads "independent of the still-open change-delivery approach," which is now stale. That's a cross-segment touch. May I fix that one line in the same pass, or leave it until we work the nodes?

Does the updated approach look right?