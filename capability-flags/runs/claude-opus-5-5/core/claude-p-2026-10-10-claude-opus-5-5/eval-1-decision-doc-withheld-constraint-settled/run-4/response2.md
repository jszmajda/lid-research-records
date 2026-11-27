Overkill. The row already in the registry design's decisions table is enough.

A decision doc earns its place when someone reading the finished design cold would want to reopen the choice and needs the full tradeoffs to re-run it. That isn't the case here:

- **The tenets settle it.** The high-level design forbids runtime network access and says kiosks have no network route. Both alternatives need a network at lookup time, so they are eliminated rather than outweighed, and one line of rationale says so.
- **Nothing else is sized around it.** The index is private to the registry, and the certificates component sees the same lookup result whichever backend sits behind it.

It felt close while you were deciding, but the test is how the choice reads once it lands, not how long the deliberation ran. With the tenets in view, a cold reader would not be tempted to reverse it.

The one thing that would change this is if the no-network tenets themselves are in doubt — say, the lab might get a network route to the kiosks later. Then the live question is the tenet, and that would deserve a project-level decision doc. If you want one anyway, say so and I'll write it.

The six questions from my last message are still open before I move on to the specs.