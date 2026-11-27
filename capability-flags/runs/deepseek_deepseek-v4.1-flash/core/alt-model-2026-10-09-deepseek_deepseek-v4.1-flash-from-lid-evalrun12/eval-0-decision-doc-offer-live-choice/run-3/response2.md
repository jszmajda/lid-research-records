Done. The decision is recorded as a full decision doc at `docs/decisions/change-delivery-transport.md` (owned by `high-level-design`), and the HLD's Key Design Decisions entry now links to it.

What it contains, so a cold reader can re-run the judgment:
- **Context** — the transport choice and what each downstream node (change store, delivery, browser sync) must provide; pointer to the revision-invariant decision it builds on; the stakes if wrong.
- **Decision Elements** — no gates (all three met the 15s goal, so it's described as background, not a selection driver); six weighted criteria — vendor coupling and connection operations burden (major), recurring cost, recovery after long disconnects, burst durability (moderate), latency headroom (minor) — each naming the tenet it turns on where one applies, plus the latent criteria considered and dropped.
- **Options in the Domain** — five-second polling, self-hosted WebSockets, and hosted realtime, each with its strongest honest description and a per-criterion verdict (strong/partial/weak), not a comparison table.
- **Selection** — self-hosted WebSockets, justified against the criteria, naming the tenet it turns on and the one it preserves, and stating what it obligates downstream (replayable revisions + reliable publication, session capacity, reconnect/catch-up) and what it forecloses.

Two notes:
- I named it `change-delivery-transport.md`. The tenet-coverage loop closes on *Self-hosted and managed infrastructure are both permitted*; no tenet argued against the choice — independence was a weighed preference, not a tenet, and I recorded it that way rather than inventing one.
- The earlier "we" phrasing isn't in the doc — it's written present-tense and cold.

Want any edits to the doc, or shall we move on to the three nodes — change store, delivery, browser sync — starting with Phase 2 LLDs?