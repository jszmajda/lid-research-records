Finished the record-store design around whole-visit revisions. Here's what changed and what needs your ruling.

## Phase 2 — record-store LLD (docs/intent/record-store/record-store-design.md)

Rewritten with the choice landed, as a fresh design:

- **Append-only revision store.** Every accepted submission becomes a revision holding the worker's complete visit, its author, and receipt time. Revisions are never merged or rewritten; review selects among them.
- **Submission envelope**: visit UUID, plot UUID, base revision ID (absent for a first submission), full payload, author ID, idempotency key; the server assigns a per-visit monotonic revision ID.
- **Conflict rule**: a submission based on the current record replaces it; anything else is held as an *unresolved candidate* and the visit becomes *unresolved*. While unresolved, **every** further submission is held too — even ones based on the current record — so the review's comparison set stays complete.
- **Resolution**: the coordinator adopts one candidate or affirms the current record; losers are marked superseded, retained, still queryable. The coordinator never edits fields inline — a correction is a new coordinator-authored submission, same path as a worker.
- Decisions & Alternatives table records whole-visit-revisions vs. three-way merge, hold-while-unresolved, and selection-only resolution, each with rationale.

## Phase 3 — EARS (record-store-specs.md)

REC-001–006 kept (text mutated to name the revision fields); added REC-007–014 covering first submission, conflict holding, retrieval of unresolved visits, adopt/affirm outcomes, validation rejection, and history retrieval.

**Consistency report**: Coverage — history retrieval and validation rejection were described in the design but had no spec; now REC-014 and REC-013. Contradiction — none found; REC-008 (arrival of a competing edit) and REC-009 (submissions during unresolved state) cover disjoint triggers. Scope — REC-009's "while unresolved" is stated in the WHEN clause. Context-free read passes: candidate/current-record/superseded are defined in the LLD.

## Phase 4 — forks before tests are written

1. **Archived plots** (cross-node with site-catalog): may a worker submit a *new* edit to an archived plot? Site-catalog keeps archived UUIDs resolvable for history but only hides them from the new-visit picker. Reject at submission, or accept? I left it as an open question in the LLD rather than guessing.
2. **Hold-all-while-unresolved** — the alternative reading (a clean-base submission applies immediately during a conflict) would get workers unblocked faster but shrinks what the coordinator sees. I chose hold-all; flag it if you want the other behavior.
3. **Selection-only resolution** — if you want coordinators to be able to fix fields inline during resolution, the LLD and REC-011/012 need changing before tests.
4. **Cross-segment drift**: site-catalog-design.md still says tablet-sync's submission behavior "remains pending that choice." Proposed fix: drop that sentence, keep the (still true) catalog-independence note. Say the word and I'll apply it.

**Decision doc?** The whole-visit-revisions choice is one a cold reader might re-litigate — two credible options, real criteria, and tablet-sync/review-export will size around it. Want a full decision doc under `docs/intent/record-store/decisions/`, or is the Decisions row enough?

Please review the LLD and specs (and answer 1–4 plus the doc question); Phases 5–6 for record-store, then tablet-sync and review-export, wait on your approval.