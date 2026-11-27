The HLD now records the self-hosted WebSockets choice — `docs/high-level-design.md` is updated for your review:

- **Approach**: delivery maintains a socket session per connected browser and pushes each committed revision as it lands; the second paragraph now names the three consequences for the siblings (replayable revision history in the store, delivery-owned session admission/publication/disconnect, browser reconnect-and-catch-up that keeps a visibly stale board while disconnected).
- **Architecture**: change-store, delivery, and browser-sync entries rewritten around the sockets approach, still marked not-written-yet for the next three nodes.
- **Key Design Decisions**: added a row choosing self-hosted WebSockets, with polling and hosted-realtime recorded as rejected alternatives and their reasons.

Two things for you:

1. **Cross-segment drift flag**: `docs/intent/access/access-design.md` still says authorization is "independent of the *still-open* change-delivery approach" — no longer true, though access itself is unaffected. Fix that one phrase now, or leave it for when we walk the access node next?
2. This choice clears the bar for a **decision doc** (three credible options traded on cost, latency, and ops burden, with three nodes about to be sized around it): want me to record it as one in `docs/decisions/`, with the HLD row linking to it? The existing HLD row alone is the alternative.

Ready to start the three nodes (change store, delivery, browser sync) on your go-ahead.