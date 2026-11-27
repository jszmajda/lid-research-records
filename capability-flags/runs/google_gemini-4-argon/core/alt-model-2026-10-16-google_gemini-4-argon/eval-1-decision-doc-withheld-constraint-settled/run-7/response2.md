It would be overkill — the row in `registry-design.md`'s **Decisions & Alternatives** table is the right fit here.

In LID, the test for a standalone decision doc is applied from the **landed state looking forward**, not from how much back-and-forth the decision took while in flight: *once this lands, would a cold reader find the choice non-obvious and be tempted to re-litigate or reverse it?*

Here, three factors settle the choice cleanly in one line:
1. **An inherited HLD constraint eliminates the other options:** `docs/high-level-design.md` establishes as Tenets and Non-Goals that kiosks have no network route during normal operation, all lookups must complete using local files on the kiosk, and live sync/remote access/cloud services are non-goals. That rules out both the on-site HTTPS directory and the managed search service at the gate.
2. **One option clearly dominates at project scale:** 90,000 records / 150 MB on 4 GB RAM is small enough for an embedded SQLite index to answer lookups well within the 250 ms budget without external services.
3. **It stays encapsulated inside one leaf node:** As you noted, the `certificates` interface (`findBySerial(serial)`) is unaffected, so no sibling nodes are sized around this choice.

Because a cold reader seeing the offline kiosk constraint and the 90,000-record scale gets their "why SQLite?" question completely answered by that single rationale row, a full decision doc (`docs/intent/registry/decisions/...`) isn't needed.

Whenever you're ready, let me know how you'd like to triage the 6 edge-case questions from the LLD probe (or if you're happy with `registry-design.md` as drafted) so we can move to Phase 3 (EARS specs).