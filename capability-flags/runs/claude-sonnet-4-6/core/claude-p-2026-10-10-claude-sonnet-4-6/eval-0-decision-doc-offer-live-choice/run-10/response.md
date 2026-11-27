**Phase 1 — HLD update for review**

Here's the updated `docs/high-level-design.md`:

---

**Approach** (updated)

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to browsers over self-hosted WebSockets: the server pushes an event to all connected sessions as soon as a command is committed, keeping update latency well under the 15-second target without tying the board to a realtime vendor.
>
> Delivery, change storage, and browser recovery are designed together around this choice. The change store maintains replayable revision history and a reliable publication outbox so in-flight events survive server restarts. The delivery layer manages WebSocket sessions and tracks per-connection sequence positions. Browsers maintain reconnect logic and issue a catch-up request on reconnect to recover any events missed while disconnected.

**Architecture** (updated — removed stale "depending on the approach" qualifiers):

> - Change store: … Owns revision history, read indexes, and the publication outbox for WebSocket delivery.
> - Delivery: … Owns WebSocket session management, per-connection sequence tracking, and event fan-out.
> - Browser sync: … Owns WebSocket subscription, reconnect logic, and catch-up on reconnect.

**Key Design Decisions** (new entry):

> **Self-hosted WebSockets for change delivery.** Polling rejected (0–5 s lag, read load multiplication at burst). Hosted realtime service rejected (recurring fees, provider coupling). Self-hosted WebSockets accepted — adds outbox, session tracking, and browser reconnect complexity, but delivers subsecond latency with no third-party dependency.

---

One thing to offer before we move to the LLDs: this choice is genuinely live for a cold reader — three credible options, multiple criteria, three design nodes about to be sized around the result. Would you like a decision doc at `docs/decisions/delivery-approach.md` to capture the full option comparison, or is the Key Design Decisions row sufficient?

Either way, does this HLD update look right to you?