My honest read: I'd keep the Decisions row and not write a full doc — but it's your call, and I'll write one if you want it.

The reasoning: LID's test is whether a cold reader of the *landed* result would re-litigate the choice, and the disqualifier here is that 2Q affects only the previews node. The HLD states no other node reads cache files, pins entries, or consumes eviction metadata, so nothing downstream is sized around this decision. How long the debate ran isn't the test — a row that names 2Q, LRU, and aged frequency with the retention-vs-bookkeeping rationale is enough for a reader to see why it landed where it did. A decision doc for a node-local choice is exactly the residue the "docs carry current intent" tenet strips, and a `decisions/` directory full of them is a smell.

The one genuine counter-argument: the A1/Am split is a tunable that a future maintainer might want to revisit, and 2Q vs. the alternatives is a real tradeoff. If that's what you want memorialized, the doc earns its place.

So, two things from me:

1. **Decision doc — yes or no?** If yes, I'd put it at `docs/intent/previews/decisions/2q-eviction.md` (segment-level, owned by previews), with the split-tuning question carried as a live decision element. If no, the row stays as written.
2. **The Phase 2 stop is still open:** do you approve the LLD as revised, and how do you want the probe gaps triaged (my read was to pin #1 and #3 before specs, defer the rest)?