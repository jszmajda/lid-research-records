HLD updated for the self-hosted WebSockets delivery route. **Phase 1 stop — please review before we move to the three nodes.**

## What changed in `docs/high-level-design.md`

**Approach** — resolved the open delivery choice:
> Committed changes reach browsers over self-hosted WebSockets: the server holds persistent connections it operates itself and pushes each new event revision to the subscribed browsers, with no third-party realtime service in the path. […] The change store keeps replayable revision history and reliably publishes each committed revision to delivery. Delivery owns socket sessions — subscription, revision fan-out, and connection lifecycle. Browsers hold a subscription and run reconnect and catch-up logic to recover revisions missed while disconnected.

(The "approach is still open / all three options / neither cost nor burden is overriding" wording is gone — it was residue of the pending decision.)

**Architecture** — the three downstream node descriptions now name socket-specific responsibilities instead of hedging across approaches (publication outbox → delivery; socket sessions + fan-out + lifecycle; WebSocket subscription + reconnect/catch-up).

**Key Design Decisions** — added a row recording the choice and naming the rejected alternatives and why:
> **Self-hosted WebSockets for change delivery.** […] giving low-latency updates with no realtime-vendor dependency, in exchange for owning connection capacity and reconnect/catch-up handling. Five-second HTTPS polling was rejected for its repeated reads and multi-second lag; a hosted realtime service was rejected for recurring fees and provider coupling, despite its lighter connection-operations burden.

I left the goals (15-second freshness, 800 browsers, 20-minute recovery) unchanged — those are requirements, not the delivery route.

## Three things for you to decide

1. **Record this as a full decision doc?** Three credible options were traded against latency, operating cost, operational burden, and vendor coupling, and the change-store / delivery / browser-sync nodes are all about to be sized around the result — so it clears the bar for a standalone decision doc at `docs/decisions/`. My default is the Key Design Decisions row above (already written); say the word if you'd rather I also write the fuller doc.

2. **A vendor-independence tenet?** You chose this route specifically to avoid tying the board to a realtime vendor. That's a lean that will shape future calls, so it's a tenet candidate: *"Realtime delivery runs on infrastructure we operate, not a third-party realtime vendor."* Want me to add it? If so, note that the existing tenet *"Self-hosted and managed infrastructure are both permitted"* still reads fine as a general stance (managed DBs etc. remain allowed) — I'd keep it, but flag the mild tension for your call.

3. **One cross-segment cascade to confirm.** `access-design.md:10` still says authorization is "independent of the still-open change-delivery approach." That's now stale wording in the `access` segment (a different boundary from this change), so I didn't touch it. May I make that one-word fix ("still-open" → settled), or leave access alone until we revisit it?

Once you've reviewed, we'll go on to the three nodes (change-store, delivery, browser-sync) as LLD drafts.