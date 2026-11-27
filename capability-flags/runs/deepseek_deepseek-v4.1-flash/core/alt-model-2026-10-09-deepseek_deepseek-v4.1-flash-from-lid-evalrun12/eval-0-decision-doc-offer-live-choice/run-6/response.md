Updated `docs/high-level-design.md` to commit to self-hosted WebSockets. The three edits:

**Approach** — now states that committed changes reach browsers over self-hosted WebSockets (a connection per browser, each committed revision pushed as it lands, reconnect/catch-up after a drop), and that this buys sub-second updates at the cost of owning connection capacity and reconnect behavior. A second paragraph ties the three downstream nodes to sockets: the change store keeps replayable revisions and a reliable publication path; delivery manages socket sessions and publishes revisions; browser-sync owns reconnect and catch-up.

**Architecture** — change store now "Owns revision history, read indexes, and the replay/publication path that sockets draw on"; delivery "Owns socket sessions and the publication of committed revisions to them"; browser sync "Owns the socket subscription, reconnect, and catch-up behavior that recovers the latest board." The branching "depending on the approach" hedges are gone.

**Key Design Decisions** — gained "Committed changes delivered over self-hosted WebSockets," with five-second polling and the hosted realtime service named as the rejected alternatives and why.

Tenets are unchanged; self-hosting already sits inside your existing "self-hosted and managed infrastructure are both permitted" tenet.

That's the Phase 1 stop. Please review and approve, and then we'll take the three nodes — change-store, delivery, browser-sync — in turn.

One thing to settle before I record it in stone: this choice weighed three credible options against several criteria (latency, connection/ops burden, cost, vendor coupling), and the three downstream nodes are about to be sized around it — the bar where a standing record earns its keep. Would you like it captured as a full decision doc at `docs/decisions/self-hosted-websockets.md`, laid out with options, criteria, and selection so a future reader can re-run the judgment? Or is the Key Design Decisions entry it has now sufficient?