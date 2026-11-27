It would be overkill—the `Decisions & Alternatives` row in `docs/intent/registry/registry-design.md` is the right fit.

A standalone decision doc is reserved for choices that stay live for a cold reader (credible options competing across multiple criteria, with other nodes sized around the outcome). Here, two things settle it once landed:
1. **Inherited constraints eliminate the alternatives:** `docs/high-level-design.md` forbids runtime network access and cloud services on kiosks, which rules out both the on-site HTTPS directory and the managed search service.
2. **Impact stays inside one node:** The backend is private to `registry`—`certificates` sees only `findBySerial(serial)`, so no sibling nodes are sized around SQLite.

If you'd still like a decision doc written anyway, say the word; otherwise, let me know how you'd like to triage the Phase 2 edge-case items above and whether we're good to move to **Phase 3 (EARS specs update)**.