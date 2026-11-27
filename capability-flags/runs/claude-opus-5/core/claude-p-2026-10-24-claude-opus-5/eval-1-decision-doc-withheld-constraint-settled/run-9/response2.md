Overkill — and the fact that it was a hard call is exactly the thing the test tells you to ignore.

The question isn't "was this hard to decide?" It's: once this has landed, would a cold reader of the result find the choice non-obvious — question it, or be tempted to reverse it, not knowing why it went this way? Here they wouldn't. They read the HLD tenets ("no runtime network access is permitted", "kiosks have no network route during normal operation"), they read that the backend is a local file on the kiosk, and the choice reads as native. Nothing to re-litigate.

A decision doc exists to let a future reader **re-run the judgment** — options weighed against criteria, so they can redo the weighing if circumstances change. There's no weighing here to preserve. An inherited constraint eliminated two of the three candidates outright; the third won by being the only one left standing. A doc would lay out an HTTPS directory and a managed search service in their strongest honest form, against criteria, and then conclude that both fail a gate. That's a document whose real content is one sentence.

That's why your experience of the choice and its landed shape diverge so much. The deliberation felt close because the sketch presented three live options; the result isn't close because the tenet had already cut two. The row captures the part worth keeping:

> Both network-backed candidates are eliminated by the tenet that lookup completes using files on the kiosk with no runtime network access. SQLite needs no service to operate and resolves an exact serial match well inside the 250 ms budget at 90,000 records. Accepted cost: every kiosk validates and rebuilds its own index on every snapshot import.

That last clause is the one doing future work — it's the thing a reader might push back on, and it's recorded.

One case would change my answer: if you expect the offline tenet itself to come under pressure — a routed lab network reaching the kiosks, a central index the shop actually wants. Then the live decision is the tenet, and the doc belongs at the HLD (`docs/decisions/`), not in the registry node, because that's where the substance would sit. Say so if that's on the horizon and I'll draft it there instead.

Otherwise the row stands, and my previous question is still open: which of the ten probe gaps to fix in the LLD now versus defer, and your ruling on #3 (does `ab-1` alongside `AB-1` abort the import?).