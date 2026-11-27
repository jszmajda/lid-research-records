Updated `docs/high-level-design.md` to lock in self-hosted WebSockets as the delivery approach:

**Approach** — now states delivery is self-hosted WebSockets (push on commit), with change store/delivery/browser-sync responsibilities described around that choice instead of three open options.

**Architecture** — the three not-yet-written nodes' descriptions now name their WebSocket-specific obligations: change store owns a replayable outbox, delivery owns socket session lifecycle and publication, browser sync owns reconnect/catch-up.

**Key Design Decisions** — added a row:

> **Self-hosted WebSockets for delivery.** Committed revisions are pushed to browsers over a connection the project hosts itself, rather than delivered through five-second HTTPS polling or a hosted realtime service. Polling was rejected: push delivery avoids repeated reads and the few seconds of lag polling would add during opening-time bursts. The hosted realtime service was rejected: self-hosting avoids recurring provider fees and vendor coupling to the board, in exchange for owning connection capacity and reconnect handling directly.

This is a real cross-criteria tradeoff (latency vs. cost vs. ops burden) that the three downstream nodes are about to be sized around, so it clears the bar where I'd normally offer a standalone decision doc instead of just the row above. Want a full decision doc for this, or is the row sufficient?

Separately — this is the Phase 1 stop: please review the HLD changes before I move on to the three LLDs (change store, delivery, browser sync).