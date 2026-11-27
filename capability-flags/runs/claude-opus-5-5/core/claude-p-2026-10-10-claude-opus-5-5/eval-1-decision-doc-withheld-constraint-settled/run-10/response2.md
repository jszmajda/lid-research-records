Overkill. The row in the registry design's Decisions table is the right size for this one.

A decision doc earns its place when someone reading the finished design would want to reopen the choice and needs the options and criteria to re-run it. That is not the case here:

- **The HLD already settles it.** Its tenets say every lookup must complete from files on the kiosk and that kiosks have no network route in normal operation. The HTTPS directory and the managed search service both put a network call in the lookup path, so neither is a live alternative.
- **Nothing else is sized around it.** The choice stays inside the registry. Certificates sees the same `findBySerial` and result types either way.

The options felt close while you were weighing them, but the test is how the choice reads once it has landed, not how hard it was to make. A reader who wonders "why SQLite?" gets the answer from the one row, which names both alternatives and the tenet that rules them out.

The row would stop being enough if the no-network tenet itself were up for revision, for example if kiosks later gain a lab network route. That would be an HLD-level decision, and it would deserve a doc at that point.

If you want one anyway, say so and I'll write it under `docs/intent/registry/decisions/` and link it from the row. Otherwise I'll leave it as is; the design review questions from my last message (A–D and 1–10) are still open.