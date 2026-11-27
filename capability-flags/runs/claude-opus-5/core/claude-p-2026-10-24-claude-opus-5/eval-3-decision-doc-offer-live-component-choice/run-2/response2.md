**Decision doc written** — `docs/intent/record-store/decisions/concurrent-visit-edits.md`, linked from the LLD's Decisions row (the row now points at the doc instead of restating it).

How it's structured, and the judgment calls I made in writing it:

**Context** frames the stakes in both directions — resolving too eagerly sends the partner a record no observer submitted; resolving too reluctantly builds a queue two coordinators can't clear and the CSV arrives incomplete. First failure silent, second visible.

**Decision elements.** One gate, inherited from the *don't silently discard a submitted edit* tenet: no submitted edit is overwritten without a human deciding. Six weighted criteria, two major — *no server-side combination of scientifically related edits* (turns on the no-inference-of-scientific-intent non-goal) and *maintenance burden without a dedicated administrator* (turns on the two-coordinators tenet). Probing for criteria that cut *against* the choice surfaced **export completeness under review backlog**, which I kept and marked moderate; it's the honest counterweight and it's what makes the deferred escalation-threshold question a real one.

**Options** — three, not two. I added **last write wins** so the gate is load-bearing: it's the team's current spreadsheet behavior, it's the cheap option a cold reader would ask about, and it's the only option the gate eliminates.

**Field-aware merge gets its advocate's case**, as you asked: the common evening collision (observer typo vs. added species) needs no human at all, review attention concentrates where disagreement actually is, and per-cell provenance is arguably a *finer* audit trail than whole revisions. It's **strong** on review workload and export completeness and **weak** on the two major criteria — and I named why it stays reconsiderable rather than just losing: either the team gains someone who can own merge rules, or the field model gains explicit relationships (a cover estimate owned by its identification) so disjointness would mean scientific independence instead of merely positional independence. A sustained unclearable queue is the trigger to re-run the judgment.

**Selection** says plainly that the choice is taken *against* review workload and export completeness, and forecloses field-level provenance entirely — nothing downstream can attribute a single exported cell, because the unit of authorship is a whole revision.

**Downstream obligations** are spelled out per node: tablet-sync carries base revision IDs across restarts and 48-hour windows, treats acceptance as *stored* not *current*, shows the worker a contested state, re-bases on the coordinator's revision, and branches retries on the rejection vocabulary. Review-export gets a whole-revision comparison view (no field diff is possible), a queue sized for unrelated-field collisions, resolution-with-open-set, the single-open-revision export predicate, and an account of what each export held back — so a short CSV is explainable rather than just short.

Still outstanding from the last stop, both unanswered:

1. **The five probe gaps I recommended fixing in the LLD now** — can a worker submit to an already-contested visit (I lean yes, accepting churn); atomicity of accept-and-report plus concurrent coordinator resolutions; whether the plot UUID is editable after the first revision and whether archived plots are accepted; the payload-identity rule and idempotency-key scope; and the rejection error shape. Take all five, a subset, or tell me to defer them to Phase 3 where the specs will force the question anyway. The six lesser gaps I'd leave in Open Questions.

2. **The HLD cascade** — the record-store row's state cell still reads "Drafted; concurrency choice open," and a paragraph still says tablet-sync and review-export must wait for this contract. Architecture is unchanged; want me to refresh those two spots?