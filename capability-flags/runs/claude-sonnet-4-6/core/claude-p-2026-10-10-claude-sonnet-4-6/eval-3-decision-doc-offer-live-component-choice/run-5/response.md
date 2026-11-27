Phases 1–3 are done. Here's the full output for your review.

---

## Phase 1 — HLD (minor update)

Two changes to `docs/high-level-design.md`:
- record-store state: `Drafted; concurrency choice open` → `Drafted`
- The dependency note now reads: *"The concurrency mechanism is owned by record-store (whole-visit revisions). Tablet-sync and review-export depend on the contract record-store defines: the submission envelope with base revision IDs, the competing-revision representation, and export eligibility rules. Both designs are next and must link back to record-store rather than invent their own concurrency semantics."*

---

## Phase 2 — LLD (`record-store-design.md`)

Full rewrite replacing the open-choice scaffold. Key additions:

**Revision model** — every accepted submission creates an immutable revision with `revision_id` (server-generated), `visit_id`, `base_revision_id` (nullable), `submission_id`, and `created_at`.

**Visit states** — three: *unreviewed* (single head, no competing siblings), *conflicted* (two+ accepted submissions share the same base, or both are null for the same visit_id), *resolved* (coordinator named the winning revision).

**Submission processing** — idempotency check → validation → conflict detection (compare base_revision_id against existing revisions for this visit) → create revision → return revision_id and state.

**Resolution** — coordinator names a winning revision_id; system records coordinator identity, timestamp, and the competing revision IDs; marks visit resolved. Losers are retained, not deleted. A coordinator who wants neither competing revision can submit a corrected version normally, then resolve in its favor.

**Export eligibility** — unreviewed or resolved only; conflicted visits held out.

**Decisions & Alternatives table** captures: whole-visit vs. three-way merge (scientific relationship concern), server-generated revision IDs, resolutions as records not mutations.

**LLD-level edge-case probe** — gaps for you to triage:

1. **Invalid base_revision_id**: A submission names a `base_revision_id` that doesn't exist for this `visit_id`. The LLD is silent. Should this be rejected with a validation error, or treated as a new first submission? Likely reject — a silent fallback would hide tablet-sync bugs.
2. **Resolution targets a non-competing revision**: A coordinator names a `revision_id` that isn't currently competing for this visit. The LLD doesn't specify accept vs. reject.
3. **GET for unknown visit_id**: The LLD describes retrieval but doesn't specify the response for a visit that has never received a submission (404 vs. empty state).
4. **Resolution attempted on non-conflicted visit**: What happens if a coordinator calls the resolution endpoint on an unreviewed or already-resolved visit?

---

## Phase 3 — EARS specs (`record-store-specs.md`)

Existing REC-001–006 are retained with one update: REC-002 and REC-003 now explicitly note the idempotency key is scoped to `visit_id`.

New specs added:

- **REC-007** — server creates revision, returns revision_id on acceptance
- **REC-008** — non-null base, no collision → unreviewed
- **REC-009** — non-null base, collision → conflicted
- **REC-010** — null base collision (same visit_id, two first-submissions) → conflicted
- **REC-011** — coordinator resolution marks visit resolved; winning revision becomes head
- **REC-012** — conflicted retrieval returns competing revision IDs
- **REC-013** — export eligibility: unreviewed or resolved only (parenthetical naming review-export)
- **REC-014** — losing revisions are not deleted or modified

**Consistency report:**
- **Coverage**: all LLD behaviors have corresponding specs. One behavior not yet in the LLD or specs: rejection of an invalid (nonexistent) `base_revision_id` — this is probe gap #1 above; add a spec once you decide the behavior.
- **Contradiction**: none found.
- **Implicit scoping**: REC-008/009 now say "non-null" explicitly to avoid collision with REC-010's null-base case. REC-013 carries a parenthetical so it stands alone when grepped.
- **Context-free reading**: all specs name their conditions concretely; none rely on section headers for scope.

---

**Decision doc offer:** The whole-visit vs. three-way merge choice clears the bar for a decision doc — a cold reader would likely reach for three-way merge (smaller review queue) and would re-litigate it without knowing the scientific-relationship concern. The choice also sizes both tablet-sync and review-export. I can write a full decision doc in `docs/intent/record-store/decisions/`, or record it as the Decisions & Alternatives row already in the LLD. Let me know which you'd prefer.

**Waiting for your review.** Once you've approved Phases 1–3 (and triaged the four probe gaps), we'll move to Phase 4 (intent-narrowing edge audit) and then to tests and code.