I updated `docs/high-level-design.md` to take the self-hosted WebSockets approach. Nothing is committed. Per the workflow, this is the HLD stop, so I'm waiting for your review before the three nodes.

**What changed in the HLD**

- **Approach:** Editors still submit commands over HTTPS. The server commits each edit with one revision and pushes committed revisions to browsers over WebSockets the project runs. Reconnecting browsers request the revisions they missed. The approach now states the trade you accepted: operating connection capacity and reconnect handling, in exchange for fast updates without a realtime vendor fee or provider coupling. The open-choice language is gone, and the 15-second freshness goal is stated as the target.
- **Architecture:** The change store, delivery, and browser-sync entries now say what each node owns under this approach. Those nodes are still unwritten.
  - Change store: an ordered, replayable revision log and reliable publication to delivery.
  - Delivery: WebSocket sessions, connection capacity, heartbeats, and fan-out.
  - Browser sync: reconnect, catch-up from the last applied revision, and visible connection state.
- **Key Design Decisions:** A new entry records the choice. It names the two rejected alternatives, five-second polling and a hosted realtime service, with the reason each was rejected, and the costs accepted.

**Choices I made that you may want to change**

- I kept the tenet "Self-hosted and managed infrastructure are both permitted." It leaves room for a managed service later. If you'd rather the board stay self-hosted only, that tenet should change.
- I wrote the Approach so that subsecond updates are explicitly not required. That follows from the HLD's earlier text, which said they were useful but not required.
- The Goals and Non-Goals are unchanged.

**Decision doc (optional)**

This choice has three real options traded on several criteria, and the three nodes will be sized around it. I can record it as a standalone decision doc in `docs/decisions/` and link it from the HLD row. The row alone is enough if you'd rather not have a separate file. Which do you want?

**Next**

Please review the HLD. Once you approve it, I'll draft the three nodes (change store, delivery, browser sync) in the order the workflow requires, starting with their LLD design docs.