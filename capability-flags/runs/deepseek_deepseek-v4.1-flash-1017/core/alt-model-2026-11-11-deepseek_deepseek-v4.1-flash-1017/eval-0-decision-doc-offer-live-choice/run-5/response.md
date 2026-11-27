Updated the HLD to commit to self-hosted WebSockets.

- **Approach** now describes server-held socket sessions pushing each committed revision to watching browsers, with replayable revisions for catch-up. Polling and hosted realtime remain only as rejected alternatives.
- **Architecture** assigns the change store replayable revisions and reliable publication, delivery socket sessions/capacity/publication, and browser sync reconnect/catch-up.
- **Key Design Decisions** records the choice, both rejected options, and the accepted trade: owning connection and reconnect operations to avoid recurring vendor fees and provider coupling.

Anything to adjust before I proceed to the three nodes?

Three calls for you:

1. This choice is load-bearing and all three nodes will be sized around it. Want a full decision doc at `docs/decisions/self-hosted-websockets.md`, or is the HLD decision entry enough?
2. Access's Context still calls delivery "still-open" (`docs/intent/access/access-design.md:10`). I left it alone because it is outside this segment — update it now, or when we do the nodes?
3. Should the anti-vendor-coupling lean become a project tenet (e.g. "prefer self-hosted infrastructure over vendor coupling when operationally feasible"), or stay as rationale for this decision only?