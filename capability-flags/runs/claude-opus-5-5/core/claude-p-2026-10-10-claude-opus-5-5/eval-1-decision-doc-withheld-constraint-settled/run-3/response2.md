Overkill — the row in the registry design's Decisions table is enough.

A decision doc earns its place when a future reader would want to re-argue the choice and needs the full trade-offs to do it. That isn't the case here, for two reasons:

- **The project's own rules settle it.** The high-level design requires every lookup to complete from files on the kiosk with no runtime network access, and says kiosks have no network route. The HTTPS directory and the managed search service both put a network call in the lookup path, so they were never eligible. One line of rationale covers that, and the row already carries it.
- **Nothing else is sized around it.** The index is private to the registry. The certificates component sees the same `findBySerial` interface whichever backend sits behind it, so no other design depends on the outcome.

That it felt close while you were deciding doesn't change this. The test is whether someone reading the finished design would question the choice, and a reader who sees the no-network tenet next to the row won't.

The one thing that would change my answer: if the no-network rule itself is likely to be relaxed (say, kiosks getting a lab network connection). Then the other two options become live again and the comparison is worth preserving. If that's a real prospect, tell me and I'll write the doc; otherwise I'll leave the row as is.

The gap list from my last message is still waiting on your rulings before I move to the specs.