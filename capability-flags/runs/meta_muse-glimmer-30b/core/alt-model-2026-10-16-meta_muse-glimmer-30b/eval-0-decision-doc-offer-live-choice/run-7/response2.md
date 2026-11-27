HLD updated and the delivery trade-off is now written up for a cold reader.

**HLD changes**
- Approach now states committed changes are delivered via self-hosted WebSockets, with replayable revisions, reliable publication, session management, and browser reconnect/catch-up.
- Architecture bullets for Change store, Delivery, and Browser sync are updated to the WebSocket shape.
- Key Design Decisions references `docs/decisions/websocket-delivery.md`.

**Decision doc created**
`docs/decisions/websocket-delivery.md`

Contains Context, Decision Elements with gates and weighted criteria, and honest analyses for all three options in the domain:

- Five-second HTTPS polling — simplest stateless operation, repeated reads and seconds of lag.
- Self-hosted WebSockets — fast updates without a realtime vendor, team owns connection capacity and reconnect problems.
- Hosted realtime service — quickest low-latency route with less connection ops, recurring fees and provider coupling.

Selection records why WebSockets wins: latency/freshness is a major criterion, operational cost and vendor coupling are moderate, and the team accepts extra connection and reconnect work to avoid vendor coupling and fees. Implications for store, delivery, and browser sync are listed.

Review the HLD update and the decision doc. Confirm approval to proceed to Phase 2 LLD drafting for change-store, delivery, and browser-sync, or provide numbered feedback for changes.