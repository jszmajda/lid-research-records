I've updated the HLD to land the self-hosted WebSockets choice. Here's what changed and one decision for you before we move to the nodes.

**Phase 1 — HLD update (for your review)**

**Approach** — the delivery choice is no longer open; it now reads as the chosen design:
- Para 1: committed changes are delivered over self-hosted WebSockets — the server holds a live connection per browser and pushes new revisions, meeting the freshness target with low latency and no realtime vendor, at the cost of owning connection capacity and reconnection handling.
- Para 2: the three downstream concerns are now stated against this choice — change store retains replayable revisions and publishes each reliably; delivery manages socket sessions and fans revisions out; browsers reconnect and catch up from their last held revision.

**Architecture** — the three unwritten nodes' one-liners were conditional ("depends on the approach"); they now state their WebSockets obligations concretely (replayable history + publication outbox + replay-for-catch-up; WebSocket sessions + fan-out; subscribe + reconnect/catch-up).

**Key Design Decisions** — added an entry recording the choice plus both rejected alternatives (polling → read load + lag; hosted service → fees + provider coupling) and the trade accepted.

I did **not** add a tenet: existing tenet 4 keeps both self-hosted and managed infrastructure permitted, so this reads as a scoped decision for delivery, not a project-wide lean — tell me if you'd rather it be a standing lean.

**One decision for you:** this choice stays live for a cold reader — three credible options traded against latency, operating cost, operational burden, and vendor coupling, with all three downstream nodes about to be sized around it. That clears the bar for a full **decision doc** (`docs/decisions/delivery-transport.md`), which would lay out the options and criteria at enough resolution to re-run the judgment if, say, the vendor-cost calculus changes. The alternative is to leave it as the Key Design Decisions entry I just added. Which do you want?

Once you've confirmed the HLD reads right and picked doc-vs-row, we'll proceed to the three nodes (Phase 2 onward), pausing at each segment.