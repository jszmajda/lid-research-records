Done. The HLD now commits to self-hosted WebSockets. Here's what changed in `docs/high-level-design.md`:

1. **Approach** — rewritten to state that committed changes are pushed to browsers over self-hosted WebSocket connections (fast updates, no realtime vendor), explicitly accepting connection-capacity and reconnect work as owned infrastructure. The second paragraph now describes only the chosen approach's implications for the three downstream nodes, instead of hedging across all three options.

2. **Architecture bullets** — change-store, delivery, and browser-sync descriptions are no longer phrased as "depends on the delivery approach"; they now name the WebSocket-shaped responsibilities (replayable revisions + reliable publication; socket session management + publication; subscribe/detect-loss/catch-up).

3. **Key Design Decisions** — added a *Self-hosted WebSockets for delivery* entry recording the choice, the two rejected alternatives (polling, hosted service) and why, and the accepted trade-off.

I left the tenet *"Self-hosted and managed infrastructure are both permitted"* as-is — it still leans future, unspecified choices (e.g. the change store's or ops' hosting), so it remains live rather than being resolved by this one decision.

Two things for you:

- **One choice to make: how to record this.** The decision clears the bar for a full **decision doc** — three credible options, traded against latency, operating cost, vendor coupling, and operational burden, with all three downstream nodes about to be sized around the result; a cold reader would plausibly re-litigate "why not just poll?" The Key Design Decisions entry above is the lighter alternative and is already in place. Want me to also write a `docs/decisions/` decision doc (linked from that entry), or leave the entry as the sole record?

- **Please sanity-check the Approach prose against the HLD's own goals/tenets yourself** — in particular that "fast updates" doesn't over-promise against the 15-second freshness goal and that nothing contradicts the availability/burst goals.

This is the Phase 1 stop. On your go-ahead (and your call on the decision doc), we'll move to the three nodes — I'd treat change-store, delivery, and browser-sync as separate LLD segments and pause between them.