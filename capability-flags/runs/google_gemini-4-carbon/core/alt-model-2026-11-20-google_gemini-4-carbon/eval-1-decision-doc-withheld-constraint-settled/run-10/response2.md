It would be overkill — the `Decisions & Alternatives` row in `registry-design.md` is the right fit here, and a standalone decision doc isn't warranted.

Evaluating from the **landed design** rather than how much back-and-forth it took to get here, three things settle it:

1. **An inherited HLD constraint eliminates the other contenders.** GaugeDesk's HLD forbids runtime network access on kiosks (*"All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted"*; *"Kiosks have no network route during normal operation"*). Both the on-site HTTPS directory and the managed search service fail that gate outright, and among local-only options an indexed SQLite file clearly beats scanning up to 150 MB of NDJSON per query or holding all 90,000 records in 4 GB of RAM. A cold reader won't be tempted to re-litigate those options unless the offline constraint itself changes.
2. **One line of rationale settles "why this?"** A standalone decision doc earns its place when multiple credible options survive the gates across competing criteria so a future reader needs the full scoring machinery to re-run the judgment. Here, a single table row naming the offline constraint plus the 250 ms / 90k-record / 4 GB RAM envelope answers the question completely.
3. **The choice stays private to `registry`.** `certificates` consumes only `findBySerial(serial)` (`Found` / `NotFound`) and isn't sized around or coupled to how `registry` indexes snapshots internally.

If you still want a standalone `docs/intent/registry/decisions/lookup-backend.md` anyway, I can write one — otherwise we'll keep it as the `Decisions & Alternatives` row in `registry-design.md`.

Whenever you're ready, let me know how you'd like to triage the Phase 2 edge-case questions above (or if you approve `registry-design.md` as-is to move to Phase 3 specs).