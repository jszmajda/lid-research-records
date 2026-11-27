Phase 2 is drafted and probed. Here's where it stands, for your review.

## Phase 2 — record-store LLD completed around whole-visit revisions

I rewrote `docs/intent/record-store/record-store-design.md` to replace the open-choice section with the actual contract. The shape:

- **Revisions and lineage** — a visit is an append-only sequence of whole-visit revisions; each submission names the **base revision** it was edited from. A submission extends the line (becomes the new current tip) *only* if its base is the current tip; any other base creates a **competing revision**. No automatic fast-forward — the server never reads field intent to decide a stale base is "safe."
- **Submission/retrieval** — envelope (visit UUID, base revision ID, idempotency key, full payload), acceptance rules, idempotency, and a current-state response that returns a single current revision when resolved or the competing set (with no usable value) when unresolved.
- **Resolution** — a coordinator selects a competitor or supplies a reconciling revision; records coordinator identity, contributing revision IDs, outcome, time; originals retained.
- **Downstream contract** — the base-revision tracking (tablet-sync) and resolved-only export eligibility (review-export) are stated as *cascade obligations* to those segments, not designed here (you said we'll do them next).
- **Decisions & Alternatives** captures whole-visit-revisions vs. field-aware merge and three follow-on rules; **Open Questions** records what's deferred.

## Edge-case probe (blind reviewer, given only the LLD) — your triage

Two of these are **internal contradictions in my draft** that I'd recommend fixing before Phase 3, not just open questions:

1. **"Competing" is defined two ways.** Lineage says competing revisions *share a base*; the re-open rule adds a late pre-fork submission "against the then-current tip," which does *not* share a base with it. These need one definition — most likely "not descended from the current line," but that's a real design call.
2. **Reconciling revision has one base pointer but "descends from the competing set" (plural).** The model gives each revision a single base; what does a reconciler's base point to?
3. **Submitting into an already-unresolved visit** (no current tip exists): always another competitor, or rejected? I handwaved this.

The rest are genuine gaps for you to triage into *fix-in-LLD now* vs. *defer*:

4. "Identical payload" for idempotency — byte-exact, or normalized (observer-list / species-entry reordering)?
5. Error shapes — three distinct rejections, no distinguishable representation given.
6. Idempotent retry returns "the original result" — the stale verdict, or the revision's current standing?
7. Idempotency key for a *first* submission (visit doesn't exist yet) — how is a duplicate create detected?
8. Two competing *first* submissions (both no base) for one visit UUID.
9. Validation ordering (idempotency vs. base vs. field/plot).
10. Semantic payload invariants beyond types (empty observer list, future date, cover bounds)?
11. Concurrent resolution by two coordinators.
12. Resolving an already-resolved visit (override) — allowed or no-op?
13. After re-open, is the formerly-current revision now just a member of the competing set?
14. Is server receipt time used for anything (ordering/tie-break) or display-only?
15. A coordinator's reconciling revision that fails validation.

My recommendation: fix 1–3 (they're incoherences), and I'd lean toward resolving 4, 5, 7, 11, 12 in the LLD too since tablet-sync and review-export will size their state machines around those answers — but you decide which land now and which defer.

## One decision to record

The concurrency-policy choice earns a full **decision doc** by the earns-its-place test: two credibly competitive options weighed across review workload, implementation burden, scientific-relationship safety, and whole-visit preservation, and two downstream nodes will be sized around it — a cold reader would re-litigate it without the tradeoffs laid out. It currently lives as a Decisions & Alternatives row in the LLD. **Do you want me to expand it into `docs/intent/record-store/decisions/concurrency-policy.md`, or leave the row as the record?**

## Note (not acted on)

Once this LLD lands, the HLD's record-store row (`Drafted; concurrency choice open`) and the line "Those two designs must wait for its contract" become stale — a status cascade, no architecture change. I'll update those when you approve, in the same pass.

**Stopping here for your review.** Tell me: (a) the probe triage (which to fix now vs. defer, and how you want 1–3 resolved), and (b) the decision-doc question. Then I'll fold your answers into the LLD and move to Phase 3 (EARS specs).