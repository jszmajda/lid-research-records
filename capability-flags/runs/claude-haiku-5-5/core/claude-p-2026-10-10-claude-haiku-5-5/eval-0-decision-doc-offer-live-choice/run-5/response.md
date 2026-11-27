I updated the HLD to choose self-hosted WebSockets for committed-change delivery. I haven't touched the three node docs yet, since you want those after this review.

**What changed in `docs/high-level-design.md`:**
- **Approach:** replaced the "still open" framing with the chosen approach. The project runs its own connection service, so there's no realtime vendor dependency or recurring fee. A browser whose socket drops shows a disconnected state, not an unchanged board, then reconnects and catches up from its last applied revision.
- **Architecture:** the change store, delivery, and browser-sync entries now state what each owns under this approach, instead of "depends on the approach." They are still marked "Not written yet."
- **Key Design Decisions:** added a row for the choice. It records the accepted costs (connection capacity and reconnect handling are ours; the change store needs replayable revisions and reliable publication) and why polling and a hosted service were rejected.

**Things to check before the nodes:**
- **Availability:** the 99.5% goal now depends on a connection service we run ourselves. The HLD doesn't yet say how that's met (redundancy, capacity headroom for the 800-browser peak). That belongs in the delivery node.
- **Tenets:** nothing conflicts. "Connectivity failures must be visible" is now carried into browser sync as the disconnected state.

**Decision record:** this choice will stay live for a cold reader, since it trades cost, operations work, and latency against each other and sizes three nodes. Do you want it recorded as a standalone decision doc in `docs/decisions/`, with the HLD row as the pointer? Or is the Key Design Decisions row enough?

Please review the HLD changes. Reply with any feedback, and I'll proceed to the change store, delivery, and browser-sync nodes once you approve.