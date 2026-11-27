Updated both record-store documents:

- `docs/intent/record-store/record-store-design.md`
- `docs/intent/record-store/record-store-specs.md`

The LLD now includes all six approved clarifications and explicitly records:

- **Why field-aware merging remains worth reconsidering:** if unrelated concurrent edits create enough review work to threaten the Friday export, and the team can specify, test, and maintain rules for scientific relationships such as species identification and cover. Its benefits remain lower review volume and more export-ready visits; its costs remain structured tablet changes, base snapshots, field-level provenance, and overlap review.
- **Tablet-sync obligations:** retain base revision IDs and complete snapshots, persist idempotency keys, distinguish original acceptance from latest state, explain pending review, support submissions during unresolved states, and handle late conflicts after earlier resolutions.
- **Review-export obligations:** compare complete candidates, review against an exact conflict version, reload after version changes, select rather than merge candidates, preserve attribution, exclude unresolved visits without falling back to the last settled revision, and recheck eligibility after late submissions.

The EARS draft now contains **REC-001 through REC-049**, all marked as active implementation gaps. Existing IDs were retained.

Post-draft consistency verification covered LLD coverage, contradictions, implicit scope, and standalone readability. It caught and I corrected:

- An idempotency-key reservation contradiction.
- Missing settled/unresolved state transitions.
- Ambiguous open-conflict and post-resolution wording.
- Authentication and distinct-error omissions.
- Incomplete retrieval and resolution result contracts.
- Atomic key-reservation and acceptance-result storage.
- Resolved-conflict candidate preservation.
- Unknown versus known-but-non-candidate revision errors.

Please review the EARS specs. Once approved, I’ll proceed to the intent-narrowing edge audit before any tests or implementation.