It would be overkill — the single row in `Decisions & Alternatives` is the right level here.

In LID, the test for a standalone decision doc is **forward-looking from the landed state**, not how much deliberation it took to get here: *once the design lands, would a cold reader find the choice non-obvious and be tempted to re-litigate it?*

Here, three factors make a full decision doc unnecessary:
1. **An inherited HLD constraint eliminates the alternatives.** The HLD tenets mandate that all lookups complete using files on the kiosk with no runtime network access and that kiosks have no network route during normal operation. Both the on-site HTTPS directory and the managed search service fail that gate outright.
2. **One option clearly dominates under the project's goals.** For ~90,000 read-only records (up to 150 MB) with a 250 ms lookup target on a 4 GB RAM offline kiosk, an embedded SQLite index is the standard fit, and a single line of rationale in the table settles "why SQLite?" for any future reader.
3. **The choice is strictly local to `registry`.** The `certificates` component only sees `findBySerial(serial)` and its fixed return types, so no other design nodes are sized around the SQLite choice.

Unless you foresee the offline/no-network tenet itself being revisited later (which would be an HLD-level change), the `Decisions & Alternatives` table row in `registry-design.md` captures everything a future maintainer needs.

Whenever you're ready, let me know if you'd like to keep the table row as-is and how you'd like to handle the 5 edge-case questions from the Phase 2 review above.