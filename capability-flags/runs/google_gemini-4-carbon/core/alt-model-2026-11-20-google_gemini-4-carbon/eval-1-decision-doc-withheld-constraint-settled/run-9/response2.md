It would be overkill—the `Decisions & Alternatives` row in `registry-design.md` is the right fit here.

Looking at the landed design from a cold reader's perspective rather than how much back-and-forth it took to get there, three things keep this below the bar for a standalone decision doc:

1. **An inherited HLD constraint eliminates the main alternatives.** `docs/high-level-design.md` forbids runtime network access, gives kiosks no network route during normal operation, and marks remote/cloud services as non-goals. Both the on-site HTTPS directory and the managed search service fail that standing gate outright, so there is no live multi-option trade-off a future maintainer would be tempted to re-open unless the HLD itself changes.
2. **Among valid offline options, one choice clearly dominates.** At 90,000 records and up to 150 MB under a 250 ms lookup target and 4 GB RAM budget, an on-disk B-tree index avoids scanning raw NDJSON on each query or re-parsing the full snapshot into RAM on startup.
3. **Its blast radius stays inside `registry`.** `certificates` still consumes `findBySerial(serial)` → `Found | NotFound` with no visibility into storage, so no sibling nodes are sized around this choice.

A full decision doc earns its place when multiple viable options survive standing constraints, pull against competing criteria, and shape other nodes that lean on the result. Here, a future reader might only wonder *"why build a SQLite index on import?"*, and the single table row settles that cleanly without extra doc maintenance.

Whenever you're ready, let me know how you'd like to handle `registry-design.md` and the numbered Phase 2 probe questions before we move to `registry-specs.md`.