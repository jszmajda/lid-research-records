It would be overkill — the `Decisions & Alternatives` row in `docs/intent/registry/registry-design.md` is the right fit.

By the earns-its-place test (judged from the landed state, not how close the options felt during deliberation), a standalone decision doc is reserved for choices that stay genuinely live for a cold reader. Here:
- **Inherited constraints settle it:** The HLD tenets forbid runtime network access and limit updates to signed USB snapshots, which eliminates both the on-site HTTPS directory and the managed search service.
- **It affects only its own node:** Storage and indexing stay private to `registry`, with no impact on `certificates` or the `findBySerial(serial)` interface.

A cold reader has everything they need from the HLD tenets and the `Decisions & Alternatives` row.

Whenever you're ready, let me know how you'd like to triage the 10 Phase 2 edge-case items (fix in `registry-design.md` vs. defer) and whether to proceed to Phase 3 (`registry-specs.md`).