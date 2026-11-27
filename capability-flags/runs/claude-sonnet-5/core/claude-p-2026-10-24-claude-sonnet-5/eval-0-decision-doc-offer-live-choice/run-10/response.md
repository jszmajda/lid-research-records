Updated `docs/high-level-design.md` to lock in self-hosted WebSockets as the chosen delivery approach. Changes:

**Approach** — replaced the three-option framing with the committed choice: the server pushes revisions to browsers over self-hosted WebSockets, no polling loop or third-party realtime vendor. Spelled out what that commits each downstream node to: change store keeps revisions replayable, delivery owns WebSocket session lifecycle and reliable publication, browser sync owns the connection and runs reconnect/catch-up logic.

**Architecture** — updated the change-store, delivery, and browser-sync bullets to name their WebSockets-specific obligations instead of "depends on the approach."

**Key Design Decisions** — added a row recording the choice and why: self-hosted WebSockets over five-second polling (simpler but laggier) and a hosted realtime service (less connection ops, but recurring fees and provider coupling), accepting the added connection/reconnect ops to avoid vendor coupling.

This is a consequential architectural choice with real tradeoffs (latency vs. ops burden vs. vendor coupling) that three downstream LLDs will now be sized around — that clears the bar for offering a full decision doc as an alternative to the Key Design Decisions row I just added. Want one (`docs/decisions/change-delivery-approach.md`), or is the HLD row enough?

Also, please review the HLD edit above — once you approve (and answer the decision-doc question), I'll move to Phase 2 and draft LLDs for the three nodes: change store, delivery, and browser sync.