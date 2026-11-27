**Coherence pre-flight (resuming prior work):** HLD, record-store LLD, and REC specs were mutually coherent as an *open* choice; your selection is what makes the "choice open" wording stale. No code or tests exist yet (docs-only repo), so test-traceability has nothing to check against — tests arrive in Phase 5. One known same-segment fix queued for Phase 3: REC-004 is phrased around "the concurrency policy's outcome" and needs its text updated (ID stays) once the policy is named. Working tree was clean. Scope held to record-store per your instruction; no cross-segment cascade into tablet-sync/review-export.

---

## Phase 1 — HLD check

**Findings:**
1. `docs/high-level-design.md` exists and covers the change's domain. The HLD already allocates the concurrency mechanism to record-store, so the selection does **not** alter the architecture — no restructuring needed.
2. Two spots were stale the moment you chose: the record-store status cell read "concurrency choice open", and the dependency paragraph called the choice "unresolved".
3. No tenet currently leans the class of future choices this decision touches (e.g., future pressure to auto-resolve "trivial" conflicts to shrink the review queue) — candidate surfaced at the stop below.

**Edits made to `docs/high-level-design.md` (in full):**

Architecture table row:
```markdown
| record-store | Accept visit submissions and define how concurrent edits become a current record | docs/intent/record-store/record-store-design.md | Drafted; concurrency policy selected |
```

Dependency paragraph (replaces the "unresolved choice / must wait" paragraph):
```markdown
The concurrency mechanism belongs to record-store, not this HLD. Tablet-sync and review-export take their submission metadata, review-work shape, and export-eligibility rules from that node's concurrency contract; neither may invent its own concurrency semantics.
```

Rest of the HLD (Problem, Approach, Tenets, Goals, Non-Goals) reads clean against whole-visit revisions — no other edits.

---

**STOP — Phase 1 review.** Number your feedback; I proceed only on explicit approval.

1. **Approve the HLD edits above?** (Approve as written / revise — say how.)
2. **Decision doc offer (once, as the skill directs):** whole-visit revisions vs. field-aware three-way merge clears the earns-its-place bar — credible options, multiple criteria (review workload, scientific correctness, implementation burden), and tablet-sync/review-export get sized around it, so a cold reader could be tempted to reverse it toward auto-merge. Accept a full decision doc at `docs/intent/record-store/decisions/whole-visit-revisions.md`, or decline and I record only a Decisions & Alternatives row in the record-store LLD (default if you say nothing: row only).
3. **Candidate tenet for `## Tenets`** (defensible opposite: a different project could reasonably prefer trusted automation to cut coordinator load; it leans choices no spec anticipates, e.g. future auto-resolve features): *"Prefer review-visible resolution over automated combination when edits may be scientifically related."* Add it / reword / reject?

On approval I proceed to **Phase 2**: the record-store LLD — whole-visit revisions contract (base revision IDs, submission envelope, competing-revision states, resolution operation), Decisions row (or decision doc if you accepted #2), then the LLD-level edge-case probe — stopping again for your review.