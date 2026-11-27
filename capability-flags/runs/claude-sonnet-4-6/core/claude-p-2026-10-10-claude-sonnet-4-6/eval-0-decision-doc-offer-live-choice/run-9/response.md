The HLD looks clean and reads well as a fresh document. Here's what changed:

**Approach** — replaced the open-choice language with a settled statement: HTTPS commands in, WebSocket delivery out. The three-component collaboration (change store replayable revisions → delivery manages sessions and catch-up → browser handles reconnect) is laid out in two sentences.

**Architecture** — each of the three unwritten nodes now has a WebSocket-specific description of what it owns, rather than "depends on the approach."

**Key Design Decisions** — added the WebSockets row naming both rejected alternatives and the accepted trade-off (connection/reconnect ops in exchange for no vendor dependency).

---

One thing to flag: this decision had three credible options weighed against multiple criteria, and the three nodes about to be written (change store, delivery, browser sync) will each be sized around it. That clears the bar for a **decision doc** — a cold reader of those LLDs will encounter the reconnect/catch-up requirements and find the "why WebSockets?" row in the HLD, but the full trading of options against criteria won't be there. Would you like to record this as a decision doc at `docs/decisions/websocket-delivery.md`, or is the Key Design Decisions row sufficient? If you'd rather just proceed to the three nodes, that's fine too.