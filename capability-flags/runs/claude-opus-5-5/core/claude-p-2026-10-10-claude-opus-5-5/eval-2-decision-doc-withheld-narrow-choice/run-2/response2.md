I'd skip it: the row already in the Previews Decisions table is the right size for this choice.

The test for a decision doc is whether someone reading the finished design cold would re-argue the choice without the full tradeoffs laid out, not how hard it was to reach. Here I don't think they would:

- **Nothing else leans on it.** The eviction policy is private to the preview worker. The review API, the 202/retry contract, the render queue and the 12 GiB budget are identical under all three policies, so no other design is sized around 2Q.
- **One line settles the "why".** The HLD already says editors alternate long screenings with repeated comparisons. Given that, "LRU loses the comparison set to a screening; aged frequency keeps a finished project's favourites" is a complete answer, and it's in the row.
- **It's cheap to reverse.** If pilot hit rates say 2Q was wrong, swapping the policy touches one section of one design and its specs. A decision doc earns its keep when reversal is expensive and the reasoning has to survive intact.

The three meetings and the 180-message thread are deliberation history, and that is exactly what these docs are meant to shed. A decision doc would not preserve the thread anyway: it is written in the present tense, with no record of who argued what.

What I'd do instead, if the worry is that someone reopens this in six months, is strengthen the row slightly. I'd add the condition that would justify revisiting: for example, pilot data showing that comparison sheets are still being evicted during screenings, or that the queue split can't be tuned to work across productions. That gives a future challenger a bar to clear rather than a debate to restart.

That said, it's your call. If you want the doc, I'll write it at `docs/intent/previews/decisions/eviction-policy.md` and link it from the row. One case where I'd change my recommendation: if people outside this repo (the editors' leads, whoever was in those meetings) need something to point at when the question comes back, a standalone doc serves them better than a table row.

Row with a revisit condition, or the full doc? Separately, I still need your ruling on the four defaults and the ten probe gaps before I draft the specs.