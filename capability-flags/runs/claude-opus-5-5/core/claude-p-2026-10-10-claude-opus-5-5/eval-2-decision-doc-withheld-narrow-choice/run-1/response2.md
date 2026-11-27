I'd skip it: the row in the design's Decisions table already does the job, and the length of the argument isn't what a decision doc is for.

A decision doc earns its place when someone reading the finished design cold would want to reopen the choice and needs the full options and criteria to re-run it. This one doesn't read that way once landed:

- **It affects only the preview worker.** The endpoint, the render queue and the 12 GiB budget are identical under all three policies, so nothing else is sized around 2Q. Swapping it later is a change inside one component.
- **The reasoning fits in a few sentences.** Screenings evict comparison sheets under LRU, aged frequency lags a project switch, and 2Q costs two queues plus a split to tune. That is what the row says, alongside both rejected alternatives.
- **The meeting history isn't design intent.** A doc written to memorialize the debate would mostly record who argued what, which goes stale and which the design docs deliberately leave out.

The one thing that would change my mind is if you expect people who weren't in those meetings to keep relitigating it. In that case a short doc to point them at is worth having for that reason alone, and I can make the row's rationale fuller first to see if that's enough.

It's your call. If you want the doc, say so and I'll write it at `docs/intent/previews/decisions/` and link it from the row.

Either way, I still need your picks on the two open decisions (what counts as "reused", and the starting split) and the gap triage before I can finish the design.