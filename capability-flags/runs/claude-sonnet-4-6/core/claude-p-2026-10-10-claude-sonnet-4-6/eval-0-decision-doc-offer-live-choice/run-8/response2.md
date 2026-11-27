Here's the decision doc at `docs/decisions/delivery-approach.md`. The structure:

- **Context** — sets up the problem (800 browsers, 20-minute recovery, three nodes unwritten) so a reader understands the stakes before touching the options.
- **Decision Elements** — two gates (freshness, recovery) that eliminate options outright; four weighted criteria (latency and operational burden as major; vendor coupling and store/browser complexity as moderate). The latency and burden criteria carry the weight of the tenet *self-hosted and managed infrastructure are both permitted*.
- **Options in the Domain** — each option gets its strongest honest representation, then a per-element verdict. Polling fails latency; hosted realtime fails on vendor coupling; self-hosted WebSockets takes partial marks on operational burden but passes everything else.
- **Selection** — states what wins and why, names the tradeoff accepted, and spells out the three downstream obligations the choice creates (change store, delivery, browser sync).

The HLD decisions row now links to it.

Ready to move on to the three nodes whenever you are.