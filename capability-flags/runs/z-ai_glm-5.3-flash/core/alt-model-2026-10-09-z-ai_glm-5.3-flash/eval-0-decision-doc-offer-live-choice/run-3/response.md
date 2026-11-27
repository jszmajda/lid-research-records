The HLD now records the self-hosted WebSockets choice. Here's what changed in `docs/high-level-design.md`:

**Approach** (now reads):

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to connected browsers over self-hosted WebSocket connections, which push each new event revision as it commits. This meets the 15-second freshness goal with seconds to spare and keeps the board independent of any realtime vendor. The cost is owning connection capacity, session lifecycle, and reconnect behavior in-house.
>
> Delivery, change storage, and browser recovery are designed around this choice. The change store keeps a replayable revision history so a reconnecting browser can catch up from the revision it last saw. Delivery owns WebSocket sessions — accepting connections, pushing revisions, and pruning dead connections. Browser sync holds the client-side reconnect and catch-up loop: on disconnect, it resubscribes and requests the revisions it missed rather than refetching blindly.

**Architecture bullets** for change-store, delivery, and browser-sync were updated to state their WebSocket-shaped obligations instead of "depends on the approach." **Key Design Decisions** gained a row recording the choice with the polling and hosted-service rejections and why.

Two questions before we move on to the three nodes:

1. **Decision doc?** This choice clears the bar for one: three credible options traded on more than one criterion (latency, ops burden, cost, coupling), and all three nodes are about to be sized around it. Want a standalone decision doc under `docs/decisions/` memorializing the debate, or is the Key Design Decisions row enough? (Row-only is the default if you say nothing.)
2. **Review:** does the Approach section say what you intended — in particular that "replayable revision history" is the store's obligation, and that browser catch-up is request-missed-revisions rather than refetch-the-whole-board?

One process note: no capability flags apply to my configuration, so nothing further to flag there. On your approval, I'll start Phase 2 with the three leaf LLDs (change-store, delivery, browser-sync) — expect stop-and-review at each.