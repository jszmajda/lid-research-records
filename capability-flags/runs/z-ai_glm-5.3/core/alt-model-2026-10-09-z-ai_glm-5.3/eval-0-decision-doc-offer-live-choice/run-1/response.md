The HLD is updated and coherent with the choice. This is the Phase 1 stop — presenting for review before the three nodes.

---

**HLD updated for self-hosted WebSocket delivery** — `docs/high-level-design.md`. The changed sections:

**Approach** (line 9): Committed changes reach browsers over WebSocket connections the board operates itself: delivery pushes each committed revision to every connected browser session, so updates arrive with push latency rather than on a polling cadence.

The second paragraph names the three obligations this puts on the design, as present-intent cost: the change store must publish each committed revision reliably and replay a revision range; delivery must own WebSocket session capacity, per-session ordering, and reconnection; browsers must detect drops, reconnect, and catch up. The connection and reconnect operations work is accepted in exchange for fast updates with no realtime vendor dependency.

**Architecture** (lines 16–18): the three unwritten nodes now state what each owns under this approach — change store gets reliable publication plus revision-range replay; delivery owns WebSocket sessions, per-session ordering, and replay-on-reconnect; browser sync owns the browser side: subscribe, detect drop, reconnect, catch up.

**Key Design Decisions** (line 44): new entry "Self-hosted WebSockets for change delivery," recording why five-second polling (seconds of lag, cursor queries, per-browser polling loop) and a hosted realtime service (recurring fees, provider coupling) were rejected, and that connection-capacity and reconnect operations work is the accepted cost.

**Also**: `docs/intent/access/access-design.md` line 10 said authorization is "independent of the *still-open* change-delivery approach" — stale now, so I dropped "still-open." Nothing else in the access segment is affected; its specs, tests, and code territory is untouched, and no code or tests exist yet anywhere. Goals, Tenets, and Non-Goals are unchanged — "self-hosted and managed infrastructure are both permitted" remains accurate (permitted, not mandated), and the 15-second freshness goal now has headroom. I don't see a new load-bearing tenet in the delivery choice itself — the existing four cover revision authority and visible connectivity failure — but tell me if you'd add one.

Two things for your review:

1. **Decision doc offer (one time).** The delivery choice traded three genuinely competitive options across latency, ops burden, cost, and coupling, and three design nodes are about to be sized around it. I can expand the Key Design Decisions entry into a full decision doc at `docs/decisions/` (context, weighted criteria, the three options with their strongest honest representation, and the selection) so a future cold reader can re-run the judgment — or the KDD entry above stands as the record. Which would you like?

2. **The updated HLD itself** — please review the Approach, Architecture, and Key Design Decisions text as drafted.

On your approval, I'll start the three nodes — change store, delivery, browser sync — one LLD at a time.