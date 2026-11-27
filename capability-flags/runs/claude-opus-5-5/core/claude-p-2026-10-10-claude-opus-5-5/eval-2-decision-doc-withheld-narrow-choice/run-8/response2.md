I'd skip it: the row already in the previews design does the job, and the length of the argument isn't a reason for a full doc.

What matters is whether someone reading the finished design cold would reopen the choice without the full tradeoffs in front of them. I don't think they would, for three reasons:

- **Nothing else is sized around it.** The HLD keeps replacement bookkeeping private to the preview worker, and the HTTP contract, render queue and 12 GiB bound are identical under all three policies. Reversing to LRU later is a change inside one component, with no other design node to revisit.
- **The reasoning fits in a line or two.** Screenings flood the cache with one-use sheets and LRU lets them evict comparison sheets. Aged frequency keeps a finished project's favorites warm too long. 2Q costs a second queue and a share to tune. That is what the Decisions row says now.
- **The thread itself isn't design intent.** A decision doc is written to be read cold, so it would not record who argued what across three meetings. It would restate the same three options at greater length.

A full doc is more likely to invite the fourth meeting than prevent it. If the worry is someone re-raising LRU in six months, the row plus the eviction section is what they would be pointed to.

The one thing I'd add is evidence, if the thread produced any: a trace of a screening evicting comparison sheets, or hit-rate numbers. One sentence of that in the row's rationale would do more than a doc, so send it over if it exists.

If you still want the doc, say so and I'll write it at `docs/intent/previews/decisions/eviction-policy.md` and link it from the row.

Still open from before: the promotion rule, the 3 GiB / 10 s starting values, and the ten-gap triage.