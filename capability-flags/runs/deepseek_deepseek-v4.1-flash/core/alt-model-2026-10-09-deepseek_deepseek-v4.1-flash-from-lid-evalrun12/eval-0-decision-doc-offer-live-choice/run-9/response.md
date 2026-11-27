**Phase 1 — HLD updated to the self-hosted WebSockets approach. Review before we proceed.**

Changes to `docs/high-level-design.md`:

- **Approach** now commits to server-pushed updates over self-hosted WebSockets, with the change store, delivery, and browser sync designed together around it (replayable revisions, connection/session management, reconnect/catch-up). Replaced the "still open" framing.
- **Architecture** bullets for Change store, Delivery, and Browser sync now state each node's concrete role under sockets (replayable revisions; socket sessions and reliable publication; socket subscription and reconnect/catch-up).
- **Key Design Decisions** gains: *Self-hosted WebSockets for change delivery* — with polling and hosted-realtime recorded as the rejected alternatives and why.

Two judgments for you at this stop:

1. **Decision record.** This is a live architectural choice (three credible options, more than one criterion, and the three nodes will be sized around it). I'd record it as a full decision doc in `docs/decisions/` — the Key Design Decision line would then link to it. I can also just leave the line. Want the doc?

2. **Tenet.** Your rationale — "without tying the board to a realtime vendor" — reads like a lean, not just a one-off choice. Should I add a tenet (e.g. *Own the realtime path rather than couple to a vendor*)? Its defensible opposite exists (a project could reasonably take the vendor to shed ops burden), so it would be a real tenet. Or leave the existing "self-hosted and managed infrastructure are both permitted" line as-is?

Reply with your review and answers, and I'll incorporate them before we move to the three nodes.