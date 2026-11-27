Decision doc written: `docs/decisions/change-delivery-transport.md`, linked from the HLD's Key Design Decisions entry. A cold reader gets:

- **Context** — why the route choice matters (it shapes the store/delivery/browser contracts) and the weekend-only load pattern that makes a standing vendor bill comparatively costly.
- **Decision elements** — six weighted criteria; no gates, since all three routes meet the 15-second floor. The reconnect-resilience criterion is derived from the "connectivity failures must be visible" tenet.
- **Options** — each described in its strongest form with a verdict per criterion, so polling's statelessness and the vendor's burst absorption are given their due, not strawmanned.
- **Selection** — why the accepted tradeoff is the right one at this scale, what committing obligates in the three nodes, what it forecloses (stateless operation), and that it doesn't foreclose a later vendor migration since the replay/catch-up contracts carry over.

Worth your own read: the Selection section's judgment that the connection-operations burden is *bounded* at this scale — that's the load-bearing claim justifying the tradeoff, and you're the one who knows whether weekend ops capacity agrees.

Still open from before:

1. The stale line in `docs/intent/access/access-design.md:10` ("independent of the still-open change-delivery approach") — may I make that one-line fix, or leave it for when we next touch access?
2. With the HLD and decision doc settled, shall I proceed to the three nodes — change store, delivery, browser sync — one at a time?