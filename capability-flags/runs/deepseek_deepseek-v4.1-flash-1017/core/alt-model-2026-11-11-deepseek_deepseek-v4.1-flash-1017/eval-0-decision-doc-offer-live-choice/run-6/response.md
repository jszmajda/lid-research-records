Updated the HLD to commit to self-hosted WebSockets. Stopping here for your review before touching the three nodes.

**Approach** (revised)

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over self-hosted WebSockets: the server publishes each committed event revision to the open sessions for that event, and each browser holds a connection to the board it displays.
>
> Delivery, change storage, and browser recovery are designed together around that route. The change store keeps replayable revisions so a reconnecting browser can catch up from the last revision it saw. Delivery owns socket session lifecycle and publication of committed revisions. Browser sync owns connecting, reconnecting, and catching up after a drop. Operating the socket tier ourselves is accepted as the cost of fast updates without tying the board to a realtime vendor.

**Architecture** (revised)

- Change store: owns revision history and the replayable read path a reconnecting browser catches up through.
- Delivery: owns socket session lifecycle, publication of committed revisions, and handling of dropped connections.
- Browser sync: owns connecting, reconnecting, and catching up from the last revision the browser saw.

**Key Design Decisions** (new entry)

> **Self-hosted WebSockets for change delivery.** Committed revisions are published to browsers over sockets the project operates. Five-second HTTPS polling was rejected as the simplest stateless option: it repeats reads and leaves seconds of lag, and the project values prompt updates. A hosted realtime service was rejected for its recurring fees and coupling to a provider. Self-hosting accepts connection-capacity and reconnect work in exchange for fast updates without vendor dependence; it obliges the change store to retain replayable revisions and the browser to reconnect and catch up.

Four things for you:

1. **Approve this HLD revision?** On approval I'll take change-store, delivery, and browser-sync one segment at a time, stopping at each.
2. **Decision doc.** This choice stays live for a cold reader — three credible options weighed against operating cost, ops burden, latency, and vendor coupling, and three nodes are about to be sized around it. I've recorded a row in Key Design Decisions; want me to expand it into a full `docs/decisions/change-delivery.md` as well? (Your call — the row alone is sufficient.)
3. **Tenet candidate.** Your rationale implies a general lean: *when a self-operated option and a vendor option both meet the latency target, prefer self-operated to avoid provider coupling and recurring fees, accepting the added operational work.* I haven't added it — say the word if you want it under `## Tenets`.
4. **Cascade note.** `docs/intent/access/access-design.md:10` still describes delivery as "the still-open change-delivery approach." That line is now stale. Update it now, or fold it into the delivery node?