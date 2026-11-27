Phase 1 (HLD) — updated. `docs/high-level-design.md` now records self-hosted WebSockets as the delivery route. Three edits:

**Approach** (rewritten) — the open three-way choice is gone; it now reads:

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over WebSocket connections the project hosts itself: the server publishes each committed revision to the connections subscribed to that event, and a browser that has missed revisions catches up from retained revision history before resuming live updates. The freshness goal below is 15 seconds; this route normally delivers well inside it, and subsecond updates are welcome but not required.
>
> Delivery, change storage, and browser recovery are designed around that route. The change store holds per-event revisions that can be replayed from any point in the retention window, and a publication path that reliably carries each committed revision from commit to delivery. Delivery owns connection sessions: subscription, capacity, and fan-out to subscribed connections. Browsers own reconnect and catch-up. Operating connection capacity and reconnect behavior ourselves is accepted work; it buys fast updates without coupling the board to a realtime vendor.

**Architecture** — the three unwritten nodes lost their "depends on the approach" hedging and now state fixed ownership: change store owns revision history, replay from an arbitrary revision in the retention window, and the publication path; delivery owns WebSocket sessions, connection capacity, and fan-out; browser sync owns subscription, reconnect, and catch-up from last applied revision.

**Key Design Decisions** — new entry *Self-hosted WebSockets deliver committed revisions*, naming both rejected options (polling: simplest to operate but repeated reads and seconds of lag; hosted service: least connection ops but recurring fees and provider coupling) and the three downstream consequences.

Two things I'd like your call on before Phase 2.

**1. Two tenets this choice puts in play.** Both are decisions that will come up repeatedly across delivery, change store, and browser sync, and no spec will anticipate them. Which way do you want each to lean — or drop either if it isn't a real fork for you?

- *Catch-up completeness over immediacy.* A reconnecting browser gets its missed revisions in order before live updates resume. The defensible opposite: show the newest state at once and accept a gap in between — faster to look right, but a coordinator could miss that a stall closed and reopened.
- *Protect connected browsers before admitting new ones.* Under connection pressure, existing connections keep their delivery quality and new connections are the ones that suffer. The opposite — admit everyone and let latency rise for all — is also defensible, especially at opening time when the arriving staff are the ones who need the board.

Also: your existing tenet *"Self-hosted and managed infrastructure are both permitted"* still reads fine to me as a general infrastructure lean (database, hosting), now that delivery is settled self-hosted — but say if you'd rather narrow or drop it.

**2. A decision doc for the delivery choice?** Three credible options traded against latency, operating cost, vendor coupling, and operational burden, and all three remaining nodes are about to be sized around the result — a cold reader could reasonably re-litigate it. I can write `docs/decisions/change-delivery-route.md` laying out the options, criteria, and selection, linked from the HLD. The alternative is the Key Design Decisions entry I just wrote, which stands on its own. Your call; the entry alone is a fine answer.

Once you've ruled on these I'll apply any tenet changes to the HLD, then move to Phase 2 and ask which of the three nodes to draft first.