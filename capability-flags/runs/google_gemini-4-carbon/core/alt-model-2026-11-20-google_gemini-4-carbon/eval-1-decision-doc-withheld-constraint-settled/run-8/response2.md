It would be overkill—the row in `registry-design.md`'s `Decisions & Alternatives` table is the right fit here.

Looking at the landed design from a future cold reader's perspective rather than how much deliberation it took:

1. **Inherited HLD constraints rule out the networked options.** The HLD prohibits runtime network access (`no network route during normal operation`; signed USB snapshots only; remote/cloud services are explicit non-goals). A cold reader won't be tempted to switch to an on-site HTTPS directory or managed search service because those fail a standing project constraint, not a nuanced criterion trade-off.
2. **Locally, one line of rationale settles it.** Given 90,000 records, 150 MB snapshots, 4 GB RAM, and a 250 ms lookup budget, a B-tree-indexed SQLite file clearly beats linear NDJSON scans or holding the dataset in memory.
3. **The blast radius stays inside `registry`.** No other node is sized around this choice—`certificates` consumes the same `findBySerial(serial)` interface and result types either way.

A standalone decision doc earns its place when multiple viable options remain genuinely live against competing criteria and other parts of the system lean on that reasoning; here, the table row captures everything a future reader needs without extra ceremony.

Whenever you're ready, let me know how you'd like to handle the Phase 2 `registry-design.md` review and edge-case items 1–7 before we move to Phase 3 (`registry-specs.md`).