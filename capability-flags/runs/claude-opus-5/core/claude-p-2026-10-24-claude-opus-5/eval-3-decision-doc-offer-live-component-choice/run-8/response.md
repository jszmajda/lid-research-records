Phase 1 — HLD check. The selection doesn't change TidePlot's architecture: no new nodes, same four responsibilities, concurrency still owned by record-store. But two places in `docs/high-level-design.md` described the choice as open, so they'd have read as stale to a fresh reader. Both edits applied:

**Architecture table, record-store State cell**

- was: `Drafted; concurrency choice open`
- now: `Drafted`

**The paragraph under the table**

- was: "The concurrency mechanism belongs to record-store, not this HLD. Tablet-sync and review-export depend on that node's unresolved choice: it determines submission metadata, the shape of review work, and which record states can enter an export. Those two designs must wait for its contract."
- now: "The concurrency mechanism belongs to record-store, not this HLD. A submitted visit stays intact as a whole revision, and concurrent edits to one visit become competing revisions a coordinator resolves. Record-store's contract therefore determines submission metadata, the shape of review work, and which record states can enter an export; tablet-sync and review-export take those semantics from it rather than restating them."

That keeps the mechanism's detail in record-store while letting a cold reader see why two nodes wait on a third. Tenets, Goals, and Non-Goals are unchanged and all still hold — "do not silently discard a submitted edit" is what whole-visit revisions buy most directly, and your reason for choosing it (no merge rules silently combining scientifically related edits) is already covered by the "no automated botanical validation or inference of scientific intent" non-goal.

Coherence pre-flight, for the record: `REC-001`–`006` trace to the current record-store LLD and are policy-neutral enough to survive the selection, site-catalog's snapshot format is genuinely independent of it, and no tests or code exist yet — so there's no stale downstream work to repair before drafting.

**One decision to make before I draft the LLD.** This choice clears the bar for a full decision doc rather than just a Decisions & Alternatives row: both options were credible, you traded them across more than one criterion (review queue size vs. merge-rule maintenance vs. the risk of auto-combining scientifically related edits), and tablet-sync and review-export are both about to be sized around the result. A coordinator joining next season who sees a growing revision queue would plausibly ask "why didn't we just merge disjoint fields?" and try to reverse it.

So: record it as `docs/intent/record-store/decisions/concurrent-visit-edits.md` — context, criteria, both options with their downstream consequences, and the selection — linked from the LLD's Decisions row? Or keep it as a single Decisions & Alternatives row in the LLD, which is lighter but won't carry enough for a reader to re-run the judgment?

Say which, and whether the HLD edits above are right, and I'll move to Phase 2: rewriting the record-store LLD around whole-visit revisions — the submission envelope with its base revision ID, the current-state and competing-revisions responses, the resolution operation, and what happens to a stale-base submission — then running the LLD-level edge probe over it before we touch specs.