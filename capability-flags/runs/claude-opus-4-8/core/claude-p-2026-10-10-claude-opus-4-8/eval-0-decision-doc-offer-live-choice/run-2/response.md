Phase 1 (HLD) update is drafted and I've stopped here for your review before touching any node.

## What changed in `docs/high-level-design.md`

**Approach** — rewritten from "the delivery choice is still open" to describe the committed route: the server holds a persistent WebSocket per browser, publishes each new revision to the connections subscribed to that event, and browsers apply revisions in order. The three downstream concerns are now stated concretely (replayable revision history + reliable publication; WebSocket session management + publication; subscribe/detect-disconnect/catch-up) instead of as per-option conditionals.

**Architecture** — the change-store, delivery, and browser-sync bullets now describe their WebSocket-specific responsibilities rather than "depends on the approach."

**Key Design Decisions** — added a *Self-hosted WebSockets for change delivery* entry naming the two rejected alternatives (polling, hosted service) and the accepted trade: owning connection capacity and reconnect handling in exchange for low latency with no realtime-vendor dependency.

I left the Goals, Non-Goals, and Tenets untouched — the 15s freshness target and the "self-hosted and managed infrastructure are both permitted" tenet still hold as written.

## Three things for your judgment

1. **Decision doc?** This choice clears the bar for a full decision doc (three credible options weighed against latency, cost, vendor coupling, and operational burden — and three nodes about to be sized around the result; a cold reader would re-litigate it without the tradeoffs laid out). I can write `docs/decisions/change-delivery-route.md` capturing the options and criteria, and shrink the Key Design Decisions entry to a one-line pointer to it. The alternative is to keep the choice recorded as just the Key Design Decisions entry I drafted. Which do you want?

2. **A standing tenet, or not?** Your rationale ("without tying the board to a realtime vendor") reads as a possible lean for *future* decisions, not just this one. The current tenet says both self-hosted and managed infra are permitted, and I've left it as-is since picking self-hosted for one path doesn't forbid managed elsewhere. If you want "avoid realtime-vendor coupling" recorded as a standing lean, say so and I'll add a tenet; otherwise it stays captured as this decision's rationale.

3. **Cross-segment cascade (access node).** `docs/intent/access/access-design.md` still says authorization is "independent of the **still-open** change-delivery approach." That phrasing is now stale. It's a different segment, so I didn't touch it — want me to drop "still-open" there as part of this cascade, or leave access for later?

Once you've ruled on these, we'll move to the three nodes (change-store → delivery → browser-sync) as you said.