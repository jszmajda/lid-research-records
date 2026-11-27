## Phase 2: Record-Store Design

Completed the whole-visit revision draft in `docs/intent/record-store/record-store-design.md` and removed stale “choice open” language from `docs/high-level-design.md`.

The design now defines:

- Immutable complete submissions and revisions.
- Base revision IDs and idempotent retries.
- Automatic advancement only from the uncontested current revision.
- A stable current revision while review is open.
- One open review case per visit containing all competitors.
- No field-level merging or payload-equivalence inference.
- Coordinator resolutions as new complete revisions.
- Exact conflict-membership checks to prevent stale resolutions.
- Per-visit transaction serialization and atomic state changes.
- Boundary obligations for tablet-sync and review-export without designing those segments.

The whole-visit versus field-aware merge choice remains sufficiently credible that a future reader could re-litigate it. I recorded it in the LLD’s Decisions & Alternatives table. Would you prefer a standalone decision document preserving the fuller tradeoff analysis, or is the table row sufficient?

### Edge-Case Probe

Please review these gaps before I draft the EARS requirements:

1. **Rejected idempotent requests:** Should idempotency keys be recorded only after acceptance, allowing a corrected request to reuse a key that previously failed validation? On an accepted retry, should authorization still be checked before returning the original result?

2. **Canonical equality:** Should retry equality be based on normalized structured values, making JSON key order and equivalent number encodings irrelevant, while preserving array order for observers and species entries?

3. **Closed conflict cases:** When an edit based on an old revision arrives after resolution, should it always open a new review case while the previous case remains permanently closed?

4. **Resolution races:** If a resolution races a worker submission, should serialization determine the outcome so that submission-first makes the resolution stale, while resolution-first causes the worker edit to open a new case?

5. **Resolution validation:** Should coordinator resolutions undergo the same visit payload, plot-reference, and field validation as worker submissions?

6. **Visit validation scope:** The design currently says field types are validated but does not define scientific constraints such as cover ranges, duplicate species, duplicate observers, or permissible observation dates. Should those rules be defined in record-store now, or deferred to a separate validation design?

7. **Rejected-edit auditability:** The HLD says submitted edits must not be silently discarded, while the draft excludes rejected requests from visit history. Should structurally valid but rejected edits be retained in an audit record, or does the tenet apply only once a submission is accepted?

8. **API errors and read ordering:** Should this LLD define stable error codes, deterministic history ordering, and transactionally consistent retrieval now, or leave those as implementation-level contract work?

Reply with numbered decisions, any changes to the draft, and whether you approve Phase 2 after those changes.