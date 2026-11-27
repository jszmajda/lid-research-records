I'd skip it: the row already in the previews design does the job, and the length of the argument isn't what a decision doc is for.

A decision doc earns its place when a cold reader of the finished design would re-litigate the choice without the full options and criteria in front of them, and when other parts of the system are sized around the result. This one doesn't meet that:

- **Nothing else leans on it.** The HTTP contract, render queue and 12 GiB bound are identical under all three policies, and the review API can't see which one is running. Swapping 2Q out later touches one section of one doc.
- **One line settles the "why".** Editors alternate long screenings with repeated comparisons, LRU loses the comparison sheets to a screening, and aged frequency keeps a finished project's favourites too long. That is in the Decisions row now, with both rejected alternatives named.
- **The debate itself isn't durable content.** A decision doc is written to be read cold, so the three meetings and the thread wouldn't appear in it anyway. It would restate the row at greater length.

If the real worry is that someone reopens this in a month, the row is what they will hit when they read the design, and it names what was traded away. If you would point people at a standalone document more readily than at a table row, that is a fair reason and I'll write it at `docs/intent/previews/decisions/eviction-policy.md` and link it from the row. It costs a second place to keep in step with the design.

Do you want the doc, or shall we keep the row? Either way, I still need your call on the promotion rule, the starting values and the restart question before I move on to the specs.