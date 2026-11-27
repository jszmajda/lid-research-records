Overkill — the row in the registry design's Decisions table is the right size for it.

A decision doc earns its place when someone reading the finished design cold would want to re-argue the choice and couldn't without the full tradeoffs laid out. That isn't the case here:

- **Your own tenets settle it.** The high-level design says every lookup must complete from files on the kiosk and that kiosks have no network route. The HTTPS directory and the managed search service both put a network call in the lookup path, so they are eliminated, not merely outscored.
- **Nothing else is sized around it.** The backend is private to the registry. Certificates see the same `findBySerial` result whichever option was chosen.
- **The length of the deliberation isn't the test.** It felt close while you were weighing it, but a reader who sees the tenets and then the row will not wonder why SQLite won.

The row already names both rejected options, the reason, and the cost accepted (each kiosk validates and rebuilds its own index).

The one thing that would change my answer is if the no-network tenets are themselves likely to be relaxed, say if kiosks may get a lab network route later. Then the choice becomes live again and the fuller comparison would be worth keeping. If that's a real possibility, tell me and I'll write the doc; otherwise I'll leave it as the row.

The thirteen design questions from my last message are still open whenever you're ready.