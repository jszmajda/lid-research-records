I've written the decision doc at `docs/decisions/delivery-transport.md` and trimmed the HLD's row to point at it.

**`docs/decisions/delivery-transport.md`** — lays out the context (why one transport choice sizes the change store, delivery, and browser sync together), the decision elements (vendor cost, operational ownership, provider coupling as major/moderate criteria, latency margin as minor, with the 15-second freshness goal as shared background all three options clear), each of the three options analyzed against those elements with its own strongest honest case, and a Selection section explaining why self-hosted WebSockets wins — ties on cost with polling, ties on latency with hosted, but is the only option strong on both cost *and* provider independence — and what it forecloses and obligates downstream (replayable revisions in the change store, live session/reconnect ownership in delivery, reconnect/catch-up logic in browser sync).

The HLD's Key Design Decisions row now just states the choice and its core trade, linking to the doc for the full reasoning.

Ready to move on to the three nodes — change store, delivery, and browser sync — whenever you are.