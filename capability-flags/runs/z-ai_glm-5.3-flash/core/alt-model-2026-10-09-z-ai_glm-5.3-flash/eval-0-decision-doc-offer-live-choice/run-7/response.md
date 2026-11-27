I've updated the HLD (`docs/high-level-design.md`) to land the self-hosted WebSockets choice:

- **Approach** now states that committed changes are published over self-hosted WebSockets, with the three downstream consequences spelled out: replayable revisions in the change store, session ownership and reliable publication in delivery, and reconnect/catch-up logic in browser sync.
- **Architecture** descriptions for the delivery and browser-sync nodes now reflect the socket approach instead of the open choice.
- **Key Design Decisions** gains an entry recording the selection, with polling and the hosted realtime service named as the rejected alternatives and why (lag/repeated reads vs. recurring fees and provider coupling), and the accepted cost (connection capacity, publication reliability, reconnect work).

Per the workflow, the three nodes (change store, delivery, browser sync) come after your review of this, as you planned. Two questions for you at this stop:

1. Does the HLD update read right to you — in particular, does the Approach's framing of the three downstream obligations match what you intend those nodes to own?
2. This choice will shape all three nodes and a cold reader might reasonably want to re-litigate it (cost vs. ops vs. freshness were all live criteria). Want me to record it as a standalone decision doc under `docs/decisions/`, or is the Key Design Decisions row above enough?