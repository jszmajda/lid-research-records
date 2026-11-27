It would be overkill — the single `Decisions & Alternatives` row in `registry-design.md` is the right level here.

In LID, whether a choice earns a standalone decision doc (`docs/intent/registry/decisions/...`) is judged from the **landed state** for a future cold reader, not from how much back-and-forth it took to decide:

1. **Inherited HLD constraints settle the networked options**: `docs/high-level-design.md` forbids runtime network access, states kiosks have no network route during normal operation, and rules out remote/cloud services — eliminating both the on-site HTTPS directory and the managed search service outright. Among offline local options, an indexed SQLite file dominates scanning a 150 MB NDJSON file or holding all 90,000 records in RAM under the 250 ms / 4 GB targets.
2. **Contained inside one leaf node**: No other node is sized around this choice — `certificates` still consumes `findBySerial(serial)` with the exact same `Found`/`NotFound` contract regardless of how `registry` indexes records.
3. **One line settles "why this?"**: A cold reader won't be tempted to reverse local SQLite once they see the offline kiosk constraint and lookup latency target, which the table row already captures. Reserve full decision docs for choices that remain genuinely live across surviving options and shape downstream nodes.

Whenever you're ready, let me know how you'd like to triage the Phase 2 edge-case items above (fix in `registry-design.md` now vs. defer to `Open Questions & Future Decisions`) so we can move to Phase 3 (`registry-specs.md`).