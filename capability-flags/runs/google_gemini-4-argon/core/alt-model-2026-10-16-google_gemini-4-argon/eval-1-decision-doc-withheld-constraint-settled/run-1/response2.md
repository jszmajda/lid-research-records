It would be overkill here—a row in the LLD's **Decisions & Alternatives** table is the right fit.

The test for a standalone decision doc is forward-looking from the landed state, not how much back-and-forth the deliberation took: *once this lands, would a cold reader find the choice non-obvious and be tempted to re-litigate it?*

Here, three things settle the question for any future reader right away:
1. **An inherited HLD constraint eliminates the other two options.** The HLD tenets state that kiosks have no network route during normal operation and that all serial-number lookups must complete using files on the kiosk with no runtime network access. Both the on-site HTTPS directory and the managed search service fail that gate.
2. **The substance is strictly local to `registry`.** The `certificates` interface (`findBySerial` returning `Found`/`NotFound` with `snapshotDate`) is unchanged regardless of backend, so no sibling component is sized around the internal storage choice.
3. **One line of rationale settles "why SQLite?"** Given 90,000 records, a 150 MB snapshot ceiling, 4 GB RAM, and a 250 ms lookup target on local files, an embedded SQLite index rebuilt on USB import is the natural fit.

When an inherited constraint eliminates the alternatives and one line in the table explains why, a standalone decision doc adds maintenance surface without giving a future maintainer new judgment to re-run. (If the offline tenet itself were ever reconsidered—say, if kiosks were being put on the lab network—that would be an HLD-level decision rather than a registry backend decision.)

Would you like to keep it as the table row in `registry-design.md`, and how would you like to handle the 5 edge-case questions above before we move to Phase 3 (EARS specs)?