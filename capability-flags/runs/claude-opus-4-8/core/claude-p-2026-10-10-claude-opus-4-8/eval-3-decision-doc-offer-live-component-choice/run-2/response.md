Phase 2 is drafted. The delegated probe looked hardest at the settled⇄unresolved transition cycle and the idempotency/validation shapes, and surfaced several genuine gaps. Stopping here for your review.

---

## Phase 2 — record-store LLD, finished around whole-visit revisions

Full doc: `docs/intent/record-store/record-store-design.md`. The shape I landed:

- **Revision** = a complete stored version of a visit's fields + author + receipt time + the **base revision** it started from. First submission has no base.
- A visit is **settled** (one *current revision*, usable, exportable) or **unresolved** (≥2 *competing revisions*, no current, held from export).
- **Landing rule:** base = current → clean successor (stays settled); base = a superseded revision → the incoming edit and the existing current both become competing revisions, visit goes unresolved (so arrival order never crowns a winner — honours the no-authoritative-order tenet); already-unresolved → recorded as another competitor.
- **Resolution:** a coordinator designates the new current revision + contributing submission IDs; visit returns to settled; all originals retained unchanged.
- **Public contract** (what the two undesigned nodes size against): submission envelope, current-state response, unresolved-work representation, resolution operation — tabled in the doc.
- **Downstream cascades** recorded as notes only (not owned here): tablet-sync retains/sends base revision IDs; review-export owns the comparison workflow and the "settled-only" export rule.

## 1. How to record the decision

This choice clears the bar for a standalone **decision doc** — two credible options, traded across review-workload vs. implementation burden vs. preservation of whole-visit scientific intent, with tablet-sync and review-export about to be sized around the result. I've recorded it as a **Decisions & Alternatives row** in the LLD for now. Do you want me to also write a full decision doc (`docs/intent/record-store/decisions/`), or is the row enough?

## 2. Edge-probe gaps — please triage (fix in the LLD now vs. defer)

The two Deferred items already in the LLD (coordinator-authored vs. pick-one winner; basing an edit on a competing revision) are excluded below.

1. **Edit based on a now-superseded revision *after* a resolution** — does a late edit whose base is an old/non-winning revision re-open the just-settled visit as unresolved, or is it a client error? The "superseded" category is currently defined against a linear chain, not resolution history.
2. **Idempotency-key scope** — per-visit, per-author, or global? "Same key + identical payload" is defined but not the namespace, so a cross-visit key collision has no outcome.
3. **Idempotency replay vs. re-evaluate** — if a retry's payload is identical but the visit's state changed since the original accept, do we replay the stored outcome or re-evaluate against current state? These can disagree.
4. **Author identity** — the envelope carries a client-supplied author ID *and* we authenticate the worker. Which is stored, and what happens on mismatch? (This one I introduced; I lean toward storing the authenticated identity and dropping client-claimed author — your call.)
5. **First submission that nonetheless names a base revision** — it's both "first submission" and "names a non-existent base." Accept as first, or reject?
6. **Resolution-record completeness** — must every competing revision be accounted for in "contributing submission IDs," and what state are omitted competitors left in? The invariant tying the competitor set to the resolution record is unstated.
7. **Retrieval of an empty/unknown visit** (no revisions, or only a rejected submission) — the current-state response enumerates only settled/unresolved; the not-found shape is missing.

My suggestion: 1, 2, 4, 5 are cheap to pin now and genuinely narrow behavior; 3 and 6 are worth a line each; 7 is a small outcome-shape addition. But tell me which you want folded into this LLD and which to leave as open questions.

## 3. One small cascade to confirm

The HLD still annotates record-store as *"Drafted; concurrency choice open."* Once this LLD is approved I'd update that one status line to reflect the resolved choice — that's the only HLD touch, no architecture change. OK to make it when we close this phase?

Next after your review: Phase 3 (EARS). The existing REC-001…006 stay largely valid, but I'll add specs for base-revision naming, the stale-base→unresolved transition, the settled/unresolved retrieval distinction, and resolution details — shaped by your triage answers above. I have not touched the specs or any tests yet.