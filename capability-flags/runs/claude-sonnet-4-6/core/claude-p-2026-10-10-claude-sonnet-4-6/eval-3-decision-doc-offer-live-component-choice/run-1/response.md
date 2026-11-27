Here is what was produced across Phases 1–3, along with the LLD edge-case probe and the Phase 3 consistency report. Please review before I move to Phase 4 (intent-narrowing edge audit).

---

## Phase 1 — HLD update

Two edits to `docs/high-level-design.md`:

1. Architecture table status for record-store: `Drafted; concurrency choice open` → `Drafted; concurrency: whole-visit revisions`
2. Downstream-dependency paragraph: updated to name the chosen policy so tablet-sync and review-export authors have a concrete contract to design against.

---

## Phase 2 — LLD: `docs/intent/record-store/record-store-design.md`

Rewrote the doc around the chosen approach. Key sections:

**Revision Model** — Each accepted submission is a complete revision. Revisions form a directed graph via `base_revision_id`. The *head set* (revisions no other revision names as its base) governs visit state: one head → `current`; two or more → `contested`.

**Submission Envelope** — Concrete table of required fields (`visit_id`, `base_revision_id`, `idempotency_key`, `payload`), validation rules (auth, field types, plot ID, base revision existence), and what the acceptance response carries (`revision_id` + resulting state).

**Visit States and Retrieval** — `current` returns the single head; `contested` returns all competing heads. Contested visits excluded from export-eligible set. Submissions against a non-head base (including a formerly losing revision) are accepted; the visit re-contests if they create a second head.

**Resolution** — Coordinator designates one competing head as winner; server records coordinator identity, winning revision ID, all competing revision IDs, and timestamp; visit returns to `current`.

**Decisions & Alternatives** — Table records the concurrency policy choice with rationale, base revision validation, resolution mechanism, and the decision to accept submissions from non-head bases.

**Deferred open questions** — Maximum competing revisions before an alert; whether exports carry full history; coordinator-submitted composite revision; required vs. optional payload fields.

### LLD edge-case probe

| Scenario | Gap found? |
|---|---|
| Two first-ever submissions with null base (race on a brand-new visit) | No — REC-009's "both null" clause covers it |
| Submission with base pointing to a revision from a different visit | No — REC-007 rejects "not known for that visit" |
| Long-offline tablet: only final edit submitted, intermediate local drafts not sent | No — base is the last synced revision; local drafts are tablet-sync's concern |
| Coordinator tries to resolve an already-current visit | **Gap → added REC-016** |
| Coordinator names a revision that was never in the head set | **Gap → added REC-017** |
| New submission after resolution, base = previously losing revision | No — REC-012 explicitly permits it; re-contests if it creates a second head |
| Retrieval of a visit that has never received any submission | Not specified; likely 404 — deferred as basic API contract |

---

## Phase 3 — EARS specs: `docs/intent/record-store/record-store-specs.md`

17 specs in four groups. Changes from the prior 6-spec draft:

- **REC-001** updated: adds `revision_id` and `base_revision_id` to retained fields.
- **REC-004** updated: uses "competing revisions" terminology consistent with the revision model.
- **REC-005** updated: distinguishes `current` vs. `contested` rather than just "unresolved review work exists."
- **REC-006** updated: adds "competing revision IDs" and "resolution timestamp" to what's retained.
- **New REC-007** — reject submission with missing or unknown base (when prior revisions exist).
- **New REC-008** — assign and return revision ID with resulting state on acceptance.
- **New REC-009** — contested state triggered when two submissions share the same base.
- **New REC-010** — contested visits excluded from export-eligible set.
- **New REC-011** — resolution returns visit to current state.
- **New REC-012** — accept submission from any known revision as base, including a formerly losing one.
- **New REC-013** — retrieval of contested visit returns all competing head revisions.
- **New REC-014** — reject unauthenticated submission.
- **New REC-015** — reject submission for unknown plot ID.
- **New REC-016** — reject resolution attempt on non-contested visit (from edge-case probe).
- **New REC-017** — reject resolution that names a non-head revision (from edge-case probe).

### Phase 3 consistency report

| Check | Finding |
|---|---|
| Coverage: LLD behaviors without a spec | None found |
| Contradiction | None found |
| Implicit scoping | None found; each spec names its own condition |
| Context-free reading | All specs stand alone; no reliance on section headers for meaning |

---

Ready to proceed to **Phase 4 — intent-narrowing edge audit** when you approve. That phase targets cross-spec interactions and places where my interpretation could diverge from your intent (e.g., how re-contesting after resolution should appear to coordinators, whether the export eligibility check is point-in-time or live). Does this look right, or do you want any changes first?