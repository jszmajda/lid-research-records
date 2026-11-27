Updated `docs/intent/record-store/record-store-design.md` with the whole-visit revision design. It now defines immutable complete revisions, submission and retrieval contracts, open review cases, export blocking, coordinator-created resolutions, provenance, and race-safe case closure.

The Phase 2 edge-case probe found three decisions needing your judgment:

1. **Two edits from the same base:** I recommend that when the second edit arrives, the shared base becomes current again and both edits enter review. This avoids letting arrival order select either worker’s edit.
2. **Two initial creations with the same visit ID:** I recommend accepting both into review with no usable current revision until a coordinator resolves them. The alternative is rejecting the later creation as an invalid null-base submission.
3. **Coordinator replacement provenance:** I recommend requiring every resolution to review the anchor revision and every competitor, while allowing a replacement revision to cite any subset as contributors. This distinguishes “considered” from “used.”

The probe also found mechanical details I propose tightening without changing the design: transactional ordering between submission and resolution, idempotent resolution retries, canonical envelope comparison, coordinator-revision metadata, validation and authorization failures, atomic retrieval snapshots, deterministic history ordering, and retained closed-case provenance.

This choice is substantial enough that a future reader could plausibly re-litigate it. Should it receive a full decision document, or is the existing Decisions & Alternatives row sufficient?

Please approve the recommendations or provide numbered changes. I’ll then finalize Phase 2 and its HLD status cleanup before drafting the EARS requirements.