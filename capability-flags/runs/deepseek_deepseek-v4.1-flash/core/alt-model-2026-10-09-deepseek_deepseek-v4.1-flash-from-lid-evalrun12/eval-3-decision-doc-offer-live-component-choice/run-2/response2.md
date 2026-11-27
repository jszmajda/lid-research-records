Done. Both changes are on disk.

**Decision doc** — `docs/intent/record-store/decisions/whole-visit-revisions.md` (linked from the LLD's Decisions row). It records:
- The criteria the choice turns on, with the HLD tenets/non-goal each derives from (*don't silently discard an edit*, *keep the submitted→exported path inspectable*, two-coordinator operability), plus review load, submission size, and implementation effort.
- Both options at their strongest. The case for still considering field-aware three-way merge is stated plainly: it wins on review load and submission size, and it becomes the right answer if either becomes binding or if the domain's field relationships could be made machine-representable enough for rules to honor.
- Why whole-visit wins: it never combines fields, so it can't land a species/cover combination no one submitted.
- Downstream obligations as explicit cascades: **tablet-sync** retains base revision IDs, submits complete-visit revisions under idempotency keys, sizes storage for full payloads, and shows pending competing revisions; **review-export** needs a whole-revision comparison view and holds unresolved visits out of the export.

**Phase 3 — record-store EARS specs** (cascaded from the approved LLD), `docs/intent/record-store/record-store-specs.md`:

- Revised **REC-001** (assign revision ID; retain base revision ID) and **REC-004** (retain every original submission for competing revisions).
- Added **REC-007/008** (first revision, and base-matches-current, become current), **REC-009** (stale base → competing + unresolved), **REC-010** (coordinator designation → current + resolved), **REC-011** (history retrieval), **REC-012** (acceptance reports current vs. competing), **REC-013** (current-state retrieval), **REC-014** (unresolved visits expose competing revision IDs).
- **REC-002/003/005/006** unchanged.

Consistency report: **coverage** — every LLD behavior now traces to a spec; **contradiction** — none (REC-007 vs. REC-008 have disjoint triggers); **implicit scoping** — REC-007, REC-009, and REC-014 carry their scope in the trigger; **context-free** — each line stands alone. Tablet-sync and review-export remain untouched.

Approve these specs so I can run the Phase 4 intent-narrowing edge audit?