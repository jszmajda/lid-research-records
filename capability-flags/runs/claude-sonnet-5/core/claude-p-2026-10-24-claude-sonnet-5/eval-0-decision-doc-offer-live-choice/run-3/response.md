Good, this matches the edits I intended. Now I'll stop here per Phase 1's mandatory stop, present the update, and ask about decision-doc recording.

I won't take further action until the user responds.

---

I've updated the HLD's **Approach** and **Architecture** sections in `docs/high-level-design.md` to commit to self-hosted WebSockets:

- **Approach**: delivery is now stated as self-hosted WebSockets (server-owned push connections), with the change store needing replayable revisions and reliable publication, delivery owning socket session lifecycle, and browsers carrying reconnect/catch-up logic.
- **Architecture**: the Change store, Delivery, and Browser sync entries now describe their roles in WebSocket terms instead of "depends on the approach."

Before I add this to **Key Design Decisions**: this looks like a case for a full decision doc rather than just a table row — it was a genuinely live choice among three options with real tradeoffs (latency vs. ops burden vs. vendor coupling), and the change-store, delivery, and browser-sync nodes you're about to write are sized around it. Want me to write a full decision doc at `docs/decisions/delivery-approach.md` capturing the three options and why self-hosted WebSockets won, or would a one-line row in the HLD's Key Design Decisions table do?