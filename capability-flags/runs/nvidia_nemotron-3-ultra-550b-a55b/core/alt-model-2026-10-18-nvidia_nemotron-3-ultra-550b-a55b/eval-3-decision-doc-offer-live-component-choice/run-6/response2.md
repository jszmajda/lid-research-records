Record-store design complete. Updated artifacts:

**`docs/intent/record-store/record-store-design.md`** — Added:
- Full concurrency policy specification (submission envelope, revision model, current-state response, resolution operation)
- Expanded **Decisions & Alternatives** with why field-aware merge remains credible and what tablet-sync/review-export would need (structured diffs, field-level provenance, overlapping-change review view)
- **Open Questions & Future Decisions** capturing 6 forks from Phase 4 edge audit

**`docs/intent/record-store/record-store-specs.md`** — Added REC-007 through REC-013 covering the whole-visit revision mechanics and plot validation.

The remaining forks (simultaneous submissions, competing-status submissions, resolution baseRevisionId, ancestor-with-competing, export endpoints, error payload) are recorded as Open Questions. We can resolve them when designing tablet-sync and review-export, or now if you want to lock them down.

Ready for tablet-sync design next?