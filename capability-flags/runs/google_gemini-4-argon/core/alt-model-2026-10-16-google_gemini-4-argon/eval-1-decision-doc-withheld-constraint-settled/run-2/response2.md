It would be overkill — the row in `registry-design.md`'s `Decisions & Alternatives` table is the right level here.

Under LID's earns-its-place test, we judge from the **landed state** (what a future cold reader needs), not from how close the deliberation felt in flight:

1. **An inherited constraint already eliminates the competing options:** The HLD's Tenets and Non-Goals mandate that all lookups complete from local files on the kiosk with no runtime network access, and that signed USB snapshots are the only update channel. That hard gate rules out both the on-site HTTPS directory and the managed search service before graded criteria even come into play.
2. **The substance is purely local to `registry`:** The `certificates` component only sees `findBySerial(serial)` and its fixed return types, so no other design node is sized around the SQLite choice.
3. **A single line settles "why this?":** A cold reader looking at the landed system won't be tempted to re-litigate a network service once reminded of the offline-kiosk constraint and the 90,000-record / <250 ms lookup target. A full decision doc is reserved for choices that stay genuinely live across credible options that all pass the project's gates.

If you're happy keeping it as the table row, let me know how you'd like to triage the 6 LLD edge-case questions above (or which ones to defer to `Open Questions & Future Decisions`) so we can lock Phase 2 and move to Phase 3 (EARS specs).