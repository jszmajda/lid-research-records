Overkill — the row in the registry design's Decisions table is enough.

A decision doc earns its place when someone reading the finished design cold would be tempted to reopen the choice and would need the full tradeoffs to re-run the judgment. That isn't the case here:

- **The HLD tenets already settle it.** "No runtime network access" and "kiosks have no network route" eliminate the HTTPS directory and the managed search service outright. A reader who wonders "why not a central index?" gets the answer in one line.
- **Nothing else is sized around it.** The backend is private to the registry, and certificates see the same `findBySerial` result either way.
- **How long it took to decide isn't the test.** The options looked close in the sketch because I laid them out as cost and maintenance tradeoffs. Measured against the tenets, only one was ever admissible.

A decision doc would become worth writing if the tenets themselves came into question — say, kiosks gaining a network route. That would be an HLD-level decision about the isolation constraint, and the backend choice would follow from it.

If you'd still like one for the record, say so and I'll write it under `docs/intent/registry/decisions/` and link it from the row. Otherwise I'm still waiting on your ruling on the design and the ten gaps before moving to the EARS update.