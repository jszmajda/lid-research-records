Phase 1 (HLD) updated. `docs/high-level-design.md`:

- **Approach** now commits to self-hosted WebSockets: server-owned connections push each committed revision; browsers reconnect and catch up from their last-seen revision. Names the trade you accepted (own connection capacity and reconnect behavior) and keeps the 15s bar with subsecond as a side effect.
- **Architecture** drops the "depending on the approach" language: change store owns the replayable revision log, delivery owns socket sessions plus reliable publication, browser sync owns the subscription lifecycle.
- **Key Design Decisions** gains *Delivery over self-hosted WebSockets*, naming polling and the hosted service as the considered alternatives with their reasons for rejection.

Two things before I stop:

1. **Approve this HLD change?** On approval I'll treat the HLD as settled and we'll leave the three nodes (change-store, delivery, browser-sync) for the follow-up.
2. **Record the delivery choice as a full decision doc?** It's a genuinely live-looking choice — three credible options weighed against latency, operating cost, and vendor coupling, with three nodes about to be sized around it. I've put a Key Design Decisions row in the HLD; a decision doc at `docs/decisions/delivery-transport.md` would preserve the full tradeoffs so a cold reader could re-run the judgment. Say the word and I'll write it, or leave it as the row.