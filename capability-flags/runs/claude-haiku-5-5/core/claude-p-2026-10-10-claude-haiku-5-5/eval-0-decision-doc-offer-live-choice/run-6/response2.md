I wrote the decision doc at `docs/decisions/committed-change-delivery.md` and linked it from the HLD's Key Design Decisions entry.

The doc is written to be read cold. It covers:

- **Context:** what the delivery choice affects, including the 800-browser load, opening-time bursts, and the 20-minute recovery goal.
- **Decision elements:** two inherited gates (the 15-second freshness goal and one authoritative revision per edit), then weighted criteria. Each criterion is tied to its HLD tenet where one exists. Operational burden and vendor independence are major; update latency and recurring cost are moderate.
- **Three options:** five-second polling, self-hosted WebSockets, and a hosted realtime service. Each has a description and a fit rating per criterion. Polling's main weakness is about 160 read requests per second from 800 browsers even when nothing changes.
- **Selection:** self-hosted WebSockets. It wins on latency, independence from any provider, and recurring cost. It loses on operational burden, and the doc says plainly that the project accepts that loss. It also names what the choice forecloses (a hosted provider would need an adapter and subscription migration) and what it obligates in the change-store, delivery, and browser-sync nodes.

Two things to check:

- `git status` shows `docs/high-level-design.md` as staged. I didn't stage it, so you may want to check the index before committing.
- Nothing is committed.

Once you've reviewed the doc and the HLD, I'll draft the three nodes, starting with the change store.