Phase 1 (HLD revision) is drafted. Here's what changed in `docs/high-level-design.md`, written as present intent — no record of it having been an open choice remains in the body:

**Approach** — now commits to the route: committed revisions pushed to browsers over WebSocket connections the project operates itself; the board owns its connection capacity and reconnection handling rather than renting them from a realtime provider. The old "still open / three options" paragraph and the "neither cost nor burden is overriding" deliberation line are gone.

**Architecture** — the three unwritten nodes now describe their WS-shaped ownership (still marked not-written-yet):
- **Change store**: replayable event revision history + a reliable publication path (outbox) handing each committed revision to delivery in order.
- **Delivery**: WebSocket session management; publishes committed revisions to subscribed browsers.
- **Browser sync**: subscription, dropped-connection detection, reconnect, catch-up from last acknowledged revision.

**Key Design Decisions** — added a row recording the choice, naming the two rejected alternatives (polling; hosted realtime) and why self-hosting won (fast updates without vendor coupling, accepting the connection/reconnect ops).

Tenets and Goals I left unchanged — the existing "one authoritative revision regardless of delivery route" and "connectivity failures must be visible" tenets carry straight over, and the 15-second freshness goal still governs.

Two things for your judgment before I treat this phase as settled:

1. **Record as a decision doc?** This choice clears the bar for one — credible options traded against several criteria (latency, operating cost, operational burden, vendor coupling), and all three downstream nodes are about to be sized around it, so a cold reader could reasonably re-litigate WS-vs-hosted. I've recorded it as a KDD row for now. Do you want a full decision doc at `docs/decisions/` instead (I'd link it from the KDD row), or is the row enough?

2. **A vendor-independence tenet?** The selection leans on "don't couple the board to a realtime vendor," but the current tenet says self-hosted and managed infra are *both* permitted (neutral). If avoiding managed realtime infra is now a standing lean for future unanticipated choices, that's a tenet worth adding — but it would narrow the existing one, so I don't want to decide it for you. Add a "prefer self-hosted over managed when both are viable" tenet, or keep the neutral stance and treat this as a one-off decision?

Once you've ruled on these, we'll move to the three nodes. I'd suggest change-store first (delivery and browser-sync both depend on its revision/outbox contract), but tell me if you'd rather sequence it differently.