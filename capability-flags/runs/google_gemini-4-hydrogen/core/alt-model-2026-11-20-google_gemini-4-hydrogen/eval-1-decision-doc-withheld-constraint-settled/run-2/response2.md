It would be **overkill** — the `Decisions & Alternatives` row in `docs/intent/registry/registry-design.md` is the right level.

Applying the landed-state test from `linked-intent-dev`:
- **Settled by inherited constraints:** The HLD tenets prohibit runtime network access and network routes during kiosk operation, which rules out both the on-site HTTPS directory and the managed search service. A cold reader would not see those as live, re-litigable options.
- **Scoped to a single node:** The lookup backend is private to `registry`; `certificates` depends only on `findBySerial(serial)` and is unaffected.

Whenever you're ready, let me know how you'd like to triage the Phase 2 edge-case gaps above (fix in `registry-design.md` vs. defer) and whether to proceed to Phase 3 (`registry-specs.md`).