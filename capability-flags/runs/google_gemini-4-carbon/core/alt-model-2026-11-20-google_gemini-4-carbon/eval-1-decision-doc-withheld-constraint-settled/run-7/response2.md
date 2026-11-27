It would be overkill — the single row in `registry-design.md`'s `Decisions & Alternatives` table is the right fit.

A standalone decision doc earns its place when a cold reader of the **landed** design would still see genuinely live, competing options and be tempted to re-litigate the choice, or when sibling components are sized around it — not based on how much back-and-forth it took to get there. Here, two things settle it quickly once landed:

1. **An inherited HLD constraint eliminates the network alternatives.** `docs/high-level-design.md` specifies that kiosks have no network route and all lookups must complete from local files with updates arriving only via signed USB snapshots, which rules out both the on-site HTTPS directory and the managed search service outright.
2. **The choice stays private to `registry`.** `certificates` consumes the unchanged `findBySerial(serial)` result contract and isn't shaped around SQLite.

The table row already answers why an on-disk SQLite index beats both the eliminated network options and local alternatives (raw NDJSON scan or a full in-memory map on a 4 GB kiosk) in one line.

If you'd still prefer a standalone doc at `docs/intent/registry/decisions/lookup-backend.md`, say the word and I'll write it; otherwise, let me know your thoughts on `registry-design.md` and how you want to triage edge-case items 1–7 so we can move to Phase 3 (`registry-specs.md`).