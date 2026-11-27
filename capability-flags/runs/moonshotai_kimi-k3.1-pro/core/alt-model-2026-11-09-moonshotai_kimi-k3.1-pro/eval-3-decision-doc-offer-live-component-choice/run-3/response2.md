### Phase 2 — Record-store LLD

Drafted the complete design in `docs/intent/record-store/record-store-design.md`.

It now covers:

- Immutable, complete visit revisions linked to their base revision.
- Linear edits, competing revisions, late submissions, and atomic coordinator selection.
- Idempotent submission behavior and historical retrieval.
- Unresolved visits remaining ineligible for export, including their baseline.
- Tablet obligations: retain base revision IDs, send complete payloads, preserve retry outcomes, and distinguish acceptance status from current server state.
- Review/export obligations: compare complete revisions, record selection provenance, and withhold unresolved visits.
- Why field-aware merging remains worth reconsidering if review volume becomes unmanageable, alongside its merge-rule, provenance, and scientific-relationship costs.

The edge-case probe found six design gaps for your triage:

1. **Plot corrections:** May a revision change the visit’s plot UUID, or is plot identity immutable after the first submission?
2. **Idempotency ownership:** If another authenticated worker reuses an existing key, should the store reject it or treat it as an independent submission?
3. **Review identity:** Should resolution requests carry a review/generation ID so delayed resolutions cannot affect a newer review? Should an already-resolved request return its original result or an explicit stale-resolution outcome?
4. **Acceptance freshness:** May I clarify that submission responses are historical acceptance snapshots, while current-state retrieval alone reports live status?
5. **History order:** Should history use acceptance/serialization order—the order explaining state transitions—rather than initial receipt order?
6. **Empty/error outcomes:** Should unknown visits return not-found, and should resolution against a visit with no open review return an invalid-state outcome?

Please indicate which of these to settle now and which to defer. After that, I’ll update the LLD for Phase 2 approval before drafting the EARS specifications.