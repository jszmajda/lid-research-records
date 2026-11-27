Overkill, I'd say. The row already in the registry design's Decisions table is enough.

A decision doc earns its place when someone reading the finished design cold would want to re-argue the choice and couldn't without the full options and criteria laid out. That isn't the case here:

- **The tenets settle it.** The high-level design says lookups must complete from files on the kiosk with no runtime network access, and that kiosks have no network route. The HTTPS directory and the managed search service both answer lookups over a network, so they are eliminated outright, not outscored. One line of rationale covers that, and the row carries it.
- **Nothing else is sized around it.** The backend is private to the registry. Certificates sees the same `findBySerial` result whichever option was picked, so no other node leans on this choice.

The options looking close at first, and the time it took you to pick, are about the deliberation. The test is how the choice reads once it has landed, and a reader who sees the tenets and the row has no reason to reopen it.

Two things would change my answer:

- **The network tenet gets relaxed.** If kiosks were ever given a lab network route, the three options become a real trade-off again and the doc would be worth writing then.
- **You weighed something the tenets don't capture.** If part of your back-and-forth was about, say, how the inventory team's publishing effort compares across options, tell me and I'll add it to the row's rationale. If it's more than a line can hold, that would justify the doc.

If you'd still like one for your own reasons, say so and I'll write it at `docs/intent/registry/decisions/lookup-backend.md` and link it from the row.

The gap triage from my last message is still waiting on you: which of the ten to fix or defer, the open points in 3, 8 and 9, and whether I may update the certificates design for 1 and 2.