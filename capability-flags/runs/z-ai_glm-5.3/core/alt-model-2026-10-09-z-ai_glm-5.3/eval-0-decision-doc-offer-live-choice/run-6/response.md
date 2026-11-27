The delivery approach is now settled in the HLD. I updated `docs/high-level-design.md` in place — Approach now states self-hosted WebSockets as the mechanism (server pushes each committed revision to connected sessions; we own connection capacity and reconnect handling), and the three node descriptions in Architecture are sized to match:

- **Change store** — revision history, read indexes, and a replayable publication log consumed by delivery.
- **Delivery** — owns WebSocket sessions: connection management, fan-out of committed revisions, reliable publication from the store.
- **Browser sync** — owns socket subscription, reconnect, and catch-up by replaying revisions from the last one received.

I also added a Key Design Decisions entry recording the choice, with polling (repeated reads, seconds of lag) and a hosted service (recurring fees, provider coupling) named as the rejected alternatives. The access node needed no changes — it's written to be delivery-agnostic. Per the plan, the three unwritten nodes come next session; there was nothing downstream to cascade into yet.

**Phase 1 stop — please review.** Two things for you:

1. Does the updated HLD (Approach, Architecture node descriptions, and the new Key Design Decisions entry) match your intent?

2. This choice will stay live for a cold reader — three credible options traded against latency, operating burden, cost, and vendor coupling, and the three nodes are about to be sized around it. Want me to record it as a full decision doc at `docs/decisions/delivery-approach.md` (context, criteria, options, selection), or is the Key Design Decisions row enough?