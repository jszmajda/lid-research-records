Added the durable decision record at `docs/intent/record-store/decisions/whole-visit-revisions.md` and linked it from the Record Store LLD.

It documents:

- The whole-visit revision contract.
- The decision criteria, including scientific-context preservation, review volume, operational burden, and offline retry reliability.
- Field-aware three-way merge as a credible alternative, with its principal benefit: lower coordinator review volume.
- Why it is not selected: apparently unrelated field changes can encode one scientific correction, which merge rules cannot reliably infer.
- Required downstream accommodation:
  - Tablet sync retains base revision IDs, submits complete revisions, and preserves accepted competing local revisions.
  - Review/export compares complete competing revisions and excludes unresolved visits from the reviewed CSV.

`git diff --check` passes.

Please approve this Phase 2 record-store design and resolve the remaining design questions before I update the `REC` requirements:

1. Should the first revision of a new visit have no base revision ID, or should the tablet create an initial local revision ID and submit it as the base?
2. While review is pending, should the previous current revision remain readable but ineligible for export, as written, or should the visit have no current revision until resolved?
3. Must a coordinator select one submitted revision unchanged, or may they create a new complete revision that incorporates their own corrections?
4. Should submissions that name an unknown revision, a revision belonging to another visit, or an invalid plot be rejected without storing a revision?