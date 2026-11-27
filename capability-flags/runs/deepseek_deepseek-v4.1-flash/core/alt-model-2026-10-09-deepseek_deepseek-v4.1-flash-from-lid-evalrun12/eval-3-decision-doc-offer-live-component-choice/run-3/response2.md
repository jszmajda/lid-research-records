Written to `docs/intent/record-store/decisions/whole-visit-revisions.md`, and linked from the LLD's Decisions & Alternatives table and References. Its shape:

**Context.** Why the choice exists (concurrent corrections, arrival order carries no authority), what it locks in (submission metadata, review shape, CSV eligibility), and the domain fact that field coupling isn't inferable from field names.

**Decision elements.** Weighted criteria, each tied to a tenet or non-goal: preservation of every submitted edit (major), inspectability of the exported value (major), coordinator operability (major), review workload (major), maintenance burden (major), scientific coherence of auto-combined records (major, turns on the *no inference of scientific intent* non-goal), offline continuation (moderate), submission size (minor). I also kept the latent criteria that cut *against* the recommendation — review workload and submission size both favor the merge approach.

**Options in the domain** — each at its strongest:
- *Whole-visit revisions*: strong on preservation, inspectability, coherence, and maintenance; weak on review workload and submission size.
- *Field-aware three-way merge* (why we'd still consider it): strong on review workload and submission size — disjoint edits merge with no coordinator, deltas are small, and the review step catches overlaps. Weak on coherence because it infers independence from field names, so it can silently join a species-ID edit with its cover-estimate edit, and weak on maintenance because per-field-kind rules must stay correct.
- *Arrival-order last-write-wins*: recorded and eliminated on the "never silently discard" tenet, so the boundary is explicit.

**Selection.** Turns on scientific coherence and maintenance burden; review workload is the accepted cost. Tenets engaged: *Do not silently discard a submitted edit* and *Keep the path from a submitted observation to an exported value inspectable* favor it; it accepts a cost against *Prefer workflows two coordinators can operate without a dedicated systems administrator*, mitigated by the simple review primitive.

**Implications** (what the other teams must accommodate, as cascade obligations):
- *Tablet-sync*: retain a base revision ID per draft and refresh it after each successful submission; represent a competing/unresolved submission to the worker; carry full visit payloads; decide how further edits to an unresolved visit are handled.
- *Review-export*: a revision comparison screen showing complete candidate revisions side by side (not field diffs/provenance); hold unresolved visits out of the CSV; a resolution operation recording coordinator identity and contributing submission IDs.

That completes Phase 2: the LLD plus its decision doc. Approve this and I'll move to Phase 3 — drafting the REC specs for the revision model, conflict detection, submission envelope, retrieval, and resolution (the existing REC-001–006 stay as they are). Two things I'll still fold into that pass unless you say otherwise: the edge-case gaps I listed last message (base-absent collisions, stale-base-after-resolution, concurrent resolutions, archived-plot submission), and the two calls you haven't explicitly ruled on — freezing the current revision while a visit is unresolved, and pick-one-only resolution.