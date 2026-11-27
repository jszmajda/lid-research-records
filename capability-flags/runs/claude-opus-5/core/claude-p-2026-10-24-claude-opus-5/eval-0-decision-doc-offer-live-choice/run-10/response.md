**Phase 1 — HLD updated** (`docs/high-level-design.md`). Three sections changed; the rest stands.

**Approach** — the open three-way choice is gone, replaced by the committed transport:

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over WebSocket connections the project runs itself: the server holds a connection per watching browser, publishes each committed event revision to the sessions subscribed to that event, and browsers reconnect and catch up by revision after an interruption. Fifteen-second freshness is the requirement; this transport delivers well inside it, and lower latency is welcome rather than required.
>
> Running the socket tier means the project owns connection capacity, fan-out under opening-time bursts, and reconnect behavior, and pays no recurring realtime-service fee and takes on no provider coupling in exchange.
>
> Delivery, change storage, and browser recovery are designed around this transport. The change store keeps a replayable per-event revision history and publishes committed revisions reliably enough that a missed publication cannot leave a browser permanently stale. Delivery owns socket sessions, subscription scope, and fan-out. Browser sync owns reconnect, catch-up from a last-known revision, and keeping a dropped connection visible rather than reading as an unchanged board.

**Architecture** — the three unwritten nodes now carry committed ownership instead of "depends on the approach": change store owns replayable revision history + publication path + seven-day retention; delivery owns socket sessions, per-event subscription scope, fan-out, capacity limits; browser sync owns subscribe, reconnect, catch-up from last-known revision, surfacing connection loss.

**Key Design Decisions** — added an entry recording the choice with both rejected options and their real upsides (polling's stateless simplicity; the hosted service's lower connection ops), the accepted cost, and the note that reconnect correctness rests on the change store's replay history, not on the transport.

Two things for you before Phase 2:

1. **Decision doc?** This one clears the bar I'd normally offer at: three credible options traded against latency, recurring cost, ops burden, and vendor coupling — and three nodes are about to be sized around the result, so a cold reader could reasonably be tempted to reverse it toward the hosted service. I've written it as a Key Design Decisions entry, which may well be enough. Want me to also write `docs/decisions/change-delivery-transport.md` laying out the criteria and all three options at re-litigation resolution, or leave the entry as the record?

2. **A tenet, or just this decision?** You chose to own the realtime path rather than rent it. The HLD currently says only "Self-hosted and managed infrastructure are both permitted," which no longer leans anything for the choices the three new nodes will raise (metrics backend, queue, connection-state store). A candidate: *"When a capability can be rented or run, prefer running it rather than coupling the board's behavior to a provider's model."* Its opposite is a real choice — a different project would reasonably lean on managed services to hold ops burden down — so it would do work. But I don't want to generalize one transport decision into a standing lean on your behalf. Is that your project-wide lean, is it narrower (realtime path only), or should the tenet list stay as it is?

Nothing cascades downstream yet — the three nodes are unwritten, so the arrow is consistent as of this edit. Say the word on these two and I'll start Phase 2 on the first node.