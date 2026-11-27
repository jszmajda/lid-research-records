Overkill — the row in `registry-design.md`'s **Decisions & Alternatives** table is the right level here.

Judging from the landed design (rather than how close the options felt while deliberating):
- **Inherited HLD constraints settle it**: `docs/high-level-design.md` forbids runtime network access, states kiosks have no network route and update only via signed USB snapshots, and lists remote access / cloud services as non-goals — eliminating both the on-site HTTPS directory and the managed search service.
- **It affects only the registry node**: `certificates` only calls `findBySerial(serial)`, so no other design node is sized around the backend choice.

A standalone decision doc is for choices that remain genuinely live for a cold reader (multiple credible options traded against weighted criteria, with other nodes leaning on the result). Here, a single table row gives a future reader everything they need to see why local SQLite was chosen.

Whenever you're ready, let me know how you'd like to triage the Phase 2 probe items (1–7) or if you want to approve `registry-design.md` as-is and move to Phase 3 (`registry-specs.md`).