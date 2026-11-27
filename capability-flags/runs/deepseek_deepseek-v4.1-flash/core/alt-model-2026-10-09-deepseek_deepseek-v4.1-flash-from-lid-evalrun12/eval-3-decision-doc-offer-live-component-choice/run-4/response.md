**Phase 1 — HLD check.** The coherence pre-flight turned up one drift: the record-store row still read "concurrency choice open" and the delegation paragraph still called the choice unresolved. I updated `docs/high-level-design.md` — the row now reads "Drafted," and the paragraph states the mechanism belongs to record-store and that tablet-sync / review-export consume its contract. The HLD keeps only the dependency, not the mechanism (that assignment was already the HLD's own decision).

**Phase 2 — Record Store LLD.** I rewrote `docs/intent/record-store/record-store-design.md` as a fresh author around whole-visit revisions. Shape:

- **Revisions** — each accepted submission is a *complete* visit payload plus a server-assigned revision ID, author, receipt time, and a `base_revision_id` naming the revision it edited (absent for a visit's first submission). Nothing is mutated or discarded.
- **States** — *resolved*: the graph is a single chain to one tip; that tip is the current revision and is export-eligible. *Unresolved*: the graph contains a fork; the competing branch tips are the coordinator's review work.
- **Fork rule** — if the visit is resolved and the base equals the current revision (and has no child), the submission extends the chain and becomes current, creating no review work. Otherwise it is a competing revision; the store retains it and the visit becomes unresolved. Arrival order never privileges a revision.
- **Envelope / retrieval** — `visit_id`, `base_revision_id`, `idempotency_key`, payload (date, observers, cover estimates, notes, plot ID). Retrieval returns `resolved` + current revision, or `unresolved` + competing revisions; history returns all revisions with their base pointers.
- **Resolution** — a coordinator selects one competing revision as current; the store records the coordinator's identity and contributing revision IDs and retains the losers. Later edits on a losing revision are ordinary competing revisions.
- **Downstream contract** — tablet-sync keeps base revision IDs and shows pending competing revisions; review-export compares revisions and holds unresolved visits out of the CSV.
- A **Decisions & Alternatives** row records whole-visit vs. field-aware merge, with the rationale you gave (no maintained merge rules that could silently combine scientifically related edits), and a **Deferred** list holds the design's open points.

**LLD edge-case probe** (delegated to a no-context subagent). It returned these gaps in *this LLD's* internals:

1. An unresolved visit — is there still a "current revision," or only competing tips? (currently ambiguous)
2. Two submissions naming the same current revision as base — the rule reads sequentially, but arrival order is disclaimed.
3. Multi-fork graphs (3+ children, or two separate fork points) — "competing revisions" is only defined for a single two-way fork.
4. `base_revision_id` absent on a populated visit, or supplied for an empty visit — falls through the fork rule.
5. Base points to a nonexistent revision or one from another visit — no rejection path.
6. Idempotency-key uniqueness scope (per visit / per worker / global).
7. A retry after the visit was since resolved/forked — which visit state does the returned result reflect?
8. Post-resolution graph shape and whether non-selected tips remain "competing."
9. Selecting a stale tip at resolution — rejection only covers "unresolved" + "is a competing revision."
10. Resolved → re-forked by a later submission — transition semantics unstated (affects export eligibility).
11. Error/response shapes for rejected submissions and resolutions.
12. Receipt-time ties vs. "receipt order" history.

I already captured a subset as **Deferred** in the LLD: #1/#2 (submission against an unresolved visit), #8/#9 (coordinator corrective revision vs. selection only), #10 (undo/re-open), and retention horizon. The rest are unaddressed. My recommendation is to fold #3, #4, #5, #7, and #11 into the LLD now as missing invariants, since tests can't be written against them otherwise; #6 and #12 could go either way.

**Two questions before I continue to Phase 3 (EARS) and then tests/code:**

1. Which probe gaps do you want fixed in the LLD now vs. left deferred? (My recommendation above is a starting point.)
2. This concurrency choice clears the decision-doc bar — credible options traded against more than one criterion, and tablet-sync and review-export will be sized around it. Want me to record it as `docs/intent/record-store/decisions/whole-visit-revisions.md` (owned by record-store, with the table row as the fallback), or keep just the table row?

I'll hold here for your response; tablet-sync and review-export stay untouched as separate segments.