Phase 1 – HLD check
- Updated `docs/high-level-design.md:14` to record the preview worker eviction policy as 2Q with private bookkeeping, replacing “remains open”.

Phase 2 – LLD check / update
- `docs/intent/previews/previews-design.md` revised:
  * Private Cache section now specifies 2Q with A1 first-use queue and A2 main queue, promotion on second access, eviction A1-first then A2, configurable split remaining private.
  * Added Decisions & Alternatives table recording the choice of 2Q over LRU and frequency-based eviction with aging, with rationale tied to protecting comparison sheets during big screenings.
  * Open Questions & Future Decisions moved the eviction policy to Resolved and deferred the exact A1/A2 size split and promotion thresholds to pilot tuning.

Phase 3 – EARS consistency
- Existing PREVIEW specs remain valid: PREVIEW-001 to PREVIEW-005 cover unknown revision, cache hit, deduplication, 12 GiB bound, and job failure release. Eviction algorithm is private to the worker per the tenet “Keep cache paths and replacement bookkeeping private to the preview worker”, so no new external EARS requirement is needed for the 2Q selection.
- Coverage check: LLD-described 2Q behavior is design-internal and traces to PREVIEW-004’s bound-enforcement requirement. No contradiction detected.

Stop for user review
Please review the HLD and previews LLD changes above and confirm:
1. The 2Q description, A1/A2 promotion model, and decision rationale are accurate and context-free.
2. You want to proceed to Phase 4 intent-narrowing edge audit, then Phase 5 tests-first and Phase 6 code for the preview cache implementation.