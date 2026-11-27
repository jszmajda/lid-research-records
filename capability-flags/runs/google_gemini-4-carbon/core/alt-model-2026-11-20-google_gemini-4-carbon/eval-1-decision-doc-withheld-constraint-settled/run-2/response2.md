It would be overkill—the `Decisions & Alternatives` row already in `registry-design.md` is the right fit.

A standalone decision doc earns its place when a choice remains genuinely live after landing—where a future cold reader would see multiple viable options, trade them against competing criteria, and be tempted to re-litigate the decision, especially when sibling components are sized around the outcome. Judged from the landed state rather than how long the deliberation took, three things settle this one quickly:

1. **Inherited HLD constraints eliminate the network options**: `docs/high-level-design.md` forbids runtime network access on kiosks, restricts updates to signed USB snapshots, and marks remote/cloud services as non-goals—ruling out both the on-site HTTPS directory and the managed search service outright.
2. **One local option clearly dominates on the resource budget**: Across 90,000 serial numbers and snapshots up to 150 MB on a 4 GB RAM kiosk with a 250 ms lookup target, an indexed local SQLite file avoids both linear NDJSON scans and holding the full snapshot in memory.
3. **The impact stays strictly inside `registry`**: `certificates` calls only `findBySerial(serial)` and never sees storage paths, index rebuilds, or query mechanics, so no other node leans on this choice.

For a future reader who wonders *"why rebuild a SQLite file instead of querying a directory or scanning the NDJSON?"*, the single row in `registry-design.md` settles the question in one glance without maintaining an extra artifact under `docs/intent/registry/decisions/`. (If the kiosk offline constraint ever changed, that would start as an HLD change anyway.)

If keeping it as the table row sounds good, let me know your feedback on `registry-design.md` and how you'd like to triage the Phase 2 edge-case items (1–8) before we move to Phase 3 (`registry-specs.md`).