It would be overkill — the **Decisions & Alternatives** row already added to `docs/intent/registry/registry-design.md` is the right level.

Under LID's decision-doc heuristic, a standalone decision doc is reserved for choices that stay live for a cold reader (multiple credible options in contention with other nodes sized around the result). Here:

1. **Inherited constraints settle it:** `docs/high-level-design.md` forbids runtime network access and network routes during kiosk operation, which eliminates both the on-site HTTPS directory and the managed search service.
2. **Scoped to one node:** The backend is private to `registry`; `certificates` only sees `findBySerial(serial)`.
3. **Clear once landed:** A cold reader will see why an offline kiosk uses an embedded SQLite file from the single table row without needing weighted criteria to re-run the trade-off.

---

For **Phase 2 review**, let me know which of the 7 edge-case questions above you want specified in `registry-design.md` vs. deferred, and whether you approve moving to **Phase 3** (`docs/intent/registry/registry-specs.md`).