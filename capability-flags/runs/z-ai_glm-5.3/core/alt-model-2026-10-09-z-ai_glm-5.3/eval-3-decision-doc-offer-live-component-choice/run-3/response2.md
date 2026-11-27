Done on both fronts. Phase 3 stop:

## Decision doc

`docs/intent/record-store/decisions/concurrent-edit-policy.md` — records the choice as a re-runnable judgment:

- **Gates** (from the HLD tenets): no silent discard — which eliminates last-write-wins and reject-stale outright — and operability by two coordinators.
- **Weighted criteria**: safety of scientifically related edits (major), coordinator review load (major), implementation/maintenance burden (moderate), explainability to field workers (moderate), export readiness (minor).
- **Why field-aware merge stays credible**: it wins review load and export readiness, passes both gates, and would become the right call again if measured queue volume overwhelms two coordinators *and* the team gains sustained engineering capacity to own merge rules — the doc names that as the re-run point.
- **Why whole-visit wins**: the failure asymmetry — a wrong merge is invisible when it happens and hard to catch at export, while a big queue is visible and staffed by the people qualified to judge it.
- **Downstream obligations**: tablet-sync must retain base revision IDs across restarts, submit whole payloads, distinguish accepted-as-current from accepted-as-competing, and warn when a held visit is under review; review-export needs a revision comparison screen, export exclusion of unresolved visits, a resolution interface (adopt or correct), and contributor attribution for every exported value.

The LLD's Decisions table now links to it.

## EARS specs — `record-store-specs.md`

REC-001…006 retained (REC-004 tightened, REC-006 aligned to "contributing revision IDs"); eighteen new specs REC-007…024 cover the revision semantics: fast-forward vs. competing outcomes (007/008), invalid-base and missing-base rejections (009/010), first-submission and active-plot rules (011/012), plot immutability per visit (013), rejection response and non-retention (014), submission outcomes (015), idempotency scoping per worker (016), the three resolution paths (017/018/019), invalid/concurrent resolutions (020/021), coordinator role check (022), and retrieval of the revision list and resolution metadata (023/024).

**Consistency report**: coverage — every behavior in the LLD maps to at least one spec, and no spec exceeds the LLD; contradiction — none found after the REC-006 alignment; scoping — each spec names its trigger context explicitly (visit edit, resolution, retrieval); context-free reading — specs were checked to stand alone under grep, no reliance on section headers. One judgment note: REC-006's original "submission IDs" wording and the design's "revision IDs" are the same thing one-to-one in this design — I treated submissions and revisions as interchangeable handles for one stored object, so REC-006 now uses the revision vocabulary. Flag me if you'd rather keep both terms distinct in the spec text.

On approval, I'll proceed to Phase 4 — the cross-spec narrowing audit (REC vs. CAT interactions, divergent readings per new spec) — with its own stop.