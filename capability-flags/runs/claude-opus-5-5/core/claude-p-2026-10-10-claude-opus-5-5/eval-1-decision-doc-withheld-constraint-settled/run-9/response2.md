Overkill — the row in the registry design's Decisions table is enough.

A decision doc earns its place when someone reading the finished design cold would want to re-argue the choice and needs the full tradeoffs to do it. That isn't the case here:

- **The HLD already settles it.** The tenets say every lookup must complete from files on the kiosk with no runtime network access, and that signed USB snapshots are the only update channel. The HTTPS directory and the managed search service both fail that outright, so there is no weighing of criteria to preserve.
- **Nothing else is sized around it.** The index is private to the registry node, and the certificates node sees the same `findBySerial` result whichever backend sits behind it.
- **The row carries the reasoning.** It names both alternatives, why they're ruled out, and the cost you accepted: each kiosk validates and rebuilds its own index on every snapshot.

The options looking close at first is about how the deliberation felt, not about how the result reads. Once the tenets are on the page, SQLite reads as the only option that fits.

The one thing that would change this is if the no-network tenet itself is up for debate — say, a real prospect of kiosks getting a lab network route. That would be an HLD-level decision about the tenet, and it would deserve a doc at that level rather than one about the backend.

If you'd still like one for your own reasons, say so and I'll write it. Otherwise I'm still waiting on your answers to questions 1–6 before moving to the specs.