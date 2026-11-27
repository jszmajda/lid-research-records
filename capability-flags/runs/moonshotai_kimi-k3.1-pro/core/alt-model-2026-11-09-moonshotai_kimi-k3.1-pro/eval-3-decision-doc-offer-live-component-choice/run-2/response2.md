## Phase 2 — Record-store LLD draft

I wrote the full design to `docs/intent/record-store/record-store-design.md`. It now covers:

- Immutable whole-visit revisions and idempotent submission envelopes.
- Current versus unresolved visit states.
- Competing candidates, complete-candidate resolution, and retained history.
- Atomic submission/resolution behavior and review-set versions.
- Why field-aware three-way merge remains worth reconsidering: it could reduce coordinator workload and export delays if the team becomes willing to maintain scientifically sound merge rules and field-level provenance.
- Tablet obligations: retain base revision IDs, send complete payloads, persist idempotency keys, preserve revision ancestry, and rebase after resolution.
- Review/export obligations: compare complete candidates, detect stale review sets, select exactly one candidate, and exclude unresolved visits from CSV exports.

The independent LLD probe found these gaps for your triage:

1. **First conflict:** When a late edit conflicts with the current revision, should the open candidate set contain the former current revision plus the new revision, with their common base retained as review context?  
   *Recommended: yes.*

2. **Submission versus resolution:** Should submissions and resolutions share one per-visit serialization boundary? A submission arriving first would advance the review-set version and invalidate the resolution; a resolution arriving first would make a submission based on the closed review set stale.  
   *Recommended: yes.*

3. **Eligible bases:** The draft currently permits both the “last uncontested lineage” and only the last uncontested revision or open candidates—an inconsistency.  
   *Recommended: while current, require the current revision; while unresolved, permit only the last uncontested revision or an open candidate; after resolution, require the selected revision.*

4. **Plot mismatch:** How should a base-less submission for an existing visit UUID but a different plot be handled?  
   *Recommended: reject it without mutation; require the plot UUID on creation and require every later submission to match it.*

5. **Consistent retrieval:** Should visit state, review-set version, and candidates be returned from one version-consistent snapshot?  
   *Recommended: yes.*

6. **API outcomes and errors:** The operations need explicit success variants and stable machine-readable errors for stale bases, stale review sets, idempotency mismatches, unknown IDs, and candidates outside the open set.  
   *Recommended: define these in the LLD, leaving HTTP status mapping to implementation.*

7. **Canonical retries:** Canonical JSON needs rules for key ordering, number formatting, and absent versus null fields; resolution retries also need their own persisted receipt.  
   *Recommended: define canonical request serialization and globally unique resolution idempotency keys.*

8. **History ordering:** Interleaved revisions and resolutions need deterministic ordering.  
   *Recommended: use one monotonically increasing per-visit event sequence.*

Please confirm which gaps to resolve as recommended and which to defer. The concurrency choice could also support a standalone decision doc because it shapes multiple downstream components; currently its rationale and alternatives are recorded in the LLD’s Decisions & Alternatives table.