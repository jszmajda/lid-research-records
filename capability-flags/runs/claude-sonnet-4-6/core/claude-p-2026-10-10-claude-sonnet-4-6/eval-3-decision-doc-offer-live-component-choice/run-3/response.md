LLD is written. Now running the Phase 2 edge-case probe — questions aimed at this LLD's own gaps, not cross-segment concerns.

**LLD-level edge-case probe:**

1. **Concurrent coordinator resolution.** Two coordinators simultaneously submit a resolution for the same fork. The LLD doesn't specify the outcome — last-write-wins, first-write-wins, or rejection of the duplicate. An unspecified race here could leave the resolution outcome non-deterministic.

2. **Submission response detail on contested.** The acceptance response returns `visit_status: contested`, but not which revision(s) it now competes with. A tablet has no way to tell the field worker "your edit now competes with one submitted by Alice at 14:32." The LLD doesn't specify how much competing-revision context the submission response carries.

3. **Identical competing revisions.** Two workers submit identical payloads starting from the same base (both corrected the same typo independently). They technically compete — same base, two revisions — but the payloads are the same. The LLD is silent on whether the server auto-resolves this or requires coordinator confirmation.

4. **No coordinator claiming on the review queue.** Two coordinators could simultaneously fetch the same contested fork and submit conflicting resolutions, which (per gap 1) is already an open race. The LLD has no concept of a coordinator "claiming" a fork for review.

---

Here is the full updated LLD for your review. The EARS specs come next (Phase 3) after you approve this.

---

**Updated record-store LLD** — `docs/intent/record-store/record-store-design.md`

```markdown
# Record Store

## Context and Design Philosophy

This node owns visit persistence and defines how a visit's authoritative state is
determined when independently edited copies arrive. A visit is identified by a
client-generated UUID and refers to a plot in the site-catalog. Workers submit
complete visit snapshots; the server retains every submitted snapshot and uses a
revision model to detect and surface conflicts for coordinator review.

Arrival order is not treated as authority.

## Revision Model

Every accepted submission creates a revision: a complete, immutable snapshot of a
visit's fields. A revision carries: revision_id, visit_id, base_revision_id (UUID
or null), author_id, received_at, and payload (observation_date, observers,
species_cover, notes).

Revisions form a DAG rooted at null. Sequential edits produce a linear chain.
Competing revisions arise when two revisions share the same parent.

## Visit State Machine

Three states — Unsubmitted, Current, Contested.

- First submission → Current
- Submission whose parent is the current tip → Current
- Submission whose parent already has a child → Contested
- All forks resolved → Current

Contested visits are excluded from the export-eligible set.

## Submission Envelope

Fields: visit_id, idempotency_key, base_revision_id (UUID | null), payload.

Acceptance response includes submission_id, revision_id, and visit_status
(current or contested).

## Concurrent Submission Detection

On acceptance, the server checks whether the new revision's base already has a
child for this visit. If yes, a fork is recorded and the visit becomes Contested.

Multiple forks can coexist; each requires a separate resolution.

## Review Work Representation

Per fork: base_revision_id (or null), base payload for context, and all competing
revisions with author/received_at/payload. Multiple forks are presented in
base-first order (closest to root resolved first).

## Resolution Operation

Coordinator selects an accepted_revision_id, records coordinator_id,
contributing_revision_ids, and resolved_at. Accepted revision becomes the new tip
for that fork. If no forks remain, visit becomes Current.

A post-resolution stale-base submission creates a new fork handled identically to
any other.

## API Contract

POST /submissions, GET /visits/{id}, GET /visits/{id}/revisions,
GET /review/contested, GET /review/contested/{id},
POST /review/contested/{id}/resolve.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Concurrency policy | Whole-visit revisions | Field-aware three-way merge | Larger review queue is preferable to maintained merge rules that cannot reliably detect scientifically related edits |
| Competition detection | Same base_revision_id | Any second submission | Allows sequential edits without generating review work |
| Initial base | Null sentinel | Server-created epoch revision | Explicit null keeps first submission unambiguous |
| Fork resolution order | Base-first | Any order | Later forks may depend on parent fork outcomes |

## Open Questions & Future Decisions

### Deferred
1. Whether coordinators may submit synthesis revisions (new payloads combining
   competing fields) rather than selecting an existing revision.
2. Validation rules for contributing_revision_ids: must it exactly match the
   server's known competitors, or is a subset acceptable?
```

---

**Four probe gaps to triage** — tell me for each: fix it in the LLD, or defer as an open question:

1. **Concurrent resolution race** — two coordinators simultaneously resolve the same fork. Fix now (add a first-write-wins or optimistic-lock rule), or defer?
2. **Submission response detail** — should `visit_status: contested` include the competing revision IDs, or just the status flag?
3. **Identical competing payloads** — auto-resolve without coordinator review, or always require manual confirmation?
4. **No coordinator claiming** — add a claim/lock mechanism to the review queue, or leave it to the workflow (coordinators coordinate out-of-band)?