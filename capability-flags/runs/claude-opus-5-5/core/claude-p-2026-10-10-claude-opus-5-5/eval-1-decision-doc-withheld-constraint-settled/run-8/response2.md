Overkill, I'd leave it as the row in the registry's Decisions table.

The test is whether someone reading the finished design cold would be tempted to reopen the choice, not how long it took to make. Here they wouldn't:

- **A tenet settles it.** The HLD says lookup must complete from files on the kiosk with no runtime network access, and that kiosks have no network route. The HTTPS directory and the managed search service both answer lookups over a network, so they are eliminated rather than outweighed. A decision doc would have one surviving option and nothing to weigh.
- **Nothing else is sized around it.** The backend is private to the registry; certificates see the same `findBySerial` result either way.

The row already names both alternatives, the tenet that rules them out, and the cost accepted (each kiosk rebuilds its own index).

A doc would become worthwhile if the no-network tenet were ever relaxed, because then the three options would be a real trade-off. That would be an HLD change, and the doc would belong with it.

If you'd still like one for the record, say so and I'll write it. Otherwise the design is still waiting on your triage of the 11 gaps before I draft the specs.