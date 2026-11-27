Phase 1 (HLD) is updated for the self-hosted WebSockets choice. Here's what changed in `docs/high-level-design.md`, with the open-choice framing stripped so the doc reads as current intent:

**Approach** — now states committed changes are delivered over self-hosted WebSocket connections (the board owns its own connection tier), names the trade it accepts (owning connection capacity and reconnect handling to avoid vendor coupling and recurring fees), and sets up the three nodes' shared design around that choice.

**Architecture** — the three unwritten nodes are now sized to the approach instead of hedged on it:
- *Change store* — replayable event revisions + a publication path (outbox) that hands committed revisions to delivery.
- *Delivery* — WebSocket session management; publishes committed revisions to connected browsers.
- *Browser sync* — the browser's subscription, reconnect handling, and catch-up of revisions missed while disconnected.

**Key Design Decisions** — added an entry recording the self-hosted-WebSockets choice with the two rejected options (polling; hosted realtime) and why.

I left the Tenets unchanged — "Self-hosted and managed infrastructure are both permitted" and "Connectivity failures must be visible, not mistaken for an unchanged board" both still hold and the second one directly governs the reconnect behavior ahead. The goals (15s freshness, 800 browsers / 20 edits/s, 20-minute reconnect recovery, 7-day retention) are unaffected.

**One thing to decide before we move on.** This choice stays live for a cold reader — three credible options traded against latency, operating cost, vendor coupling, and operational burden, with all three downstream nodes about to be sized around it. That clears the bar where a standalone decision doc can earn its place. I've recorded it as a Key Design Decisions entry for now; I can **expand it into a full decision doc** at `docs/decisions/websocket-delivery.md` (context, the decision elements, each option in its own right, and the selection), or **leave it as the Key Design Decisions entry**. Which would you prefer?

Once you've reviewed the HLD edit and settled the decision-doc question, say the word and we'll start on the three nodes (Phase 2 LLDs) — I'd expect to take them one segment at a time.