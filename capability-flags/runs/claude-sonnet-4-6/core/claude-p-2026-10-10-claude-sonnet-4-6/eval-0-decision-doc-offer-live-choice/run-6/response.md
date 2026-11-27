The HLD looks good. Here's what changed and one question for you:

---

**HLD updated** — three edits to `docs/high-level-design.md`:

1. **Approach**: removed the "still open" language; states self-hosted WebSockets as the delivery mechanism, and describes what each subsystem needs to support it (monotone revisions + outbox in the store, session management + replay in delivery, reconnect + catch-up in the browser).

2. **Architecture**: each unwritten node now carries its WebSocket-shaped responsibility rather than "depends on the approach."

3. **Key Design Decisions**: added the WebSocket entry naming both rejected alternatives (polling and hosted realtime) with their specific rejection rationale.

---

**Decision doc offer (one-time):** This choice traded three credible options against multiple criteria — latency, read load, vendor coupling, connection ops burden — and the three LLD nodes (change-store, delivery, browser-sync) will be sized around it. A cold reader landing on the Key Design Decisions entry would have the reasoning inline, but a full decision doc would hold the criteria comparison at a depth they could re-run. Worth doing, or is the table row enough?

Ready to move to the three LLD nodes whenever you are.