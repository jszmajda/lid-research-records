It would be overkill — the row in the LLD's **Decisions & Alternatives** table is the right level here.

In LID, the test for a standalone decision doc is judged from the **landed state looking forward**, not from how much deliberation it took to get there: *once this lands, would a cold reader find the choice genuinely live and be tempted to re-litigate it without a full criteria-and-options breakdown?*

Three reasons this choice doesn't cross that bar:

1. **An inherited constraint already eliminates the alternatives**: The HLD tenets explicitly require that all serial-number lookups complete using files on the kiosk with no runtime network access, and that kiosks have no network route during normal operation. That immediately rules out both the on-site HTTPS directory and the managed search service.
2. **One option clearly dominates under the kiosk constraints**: For 90,000 records (up to 150 MB) with a 250 ms lookup target on a 4 GB RAM offline kiosk, an embedded local SQLite index is a natural fit that a one-line rationale settles for any future reader.
3. **The scope is strictly local to `registry`**: Because the `findBySerial(serial)` contract and result types are unchanged, `certificates` isn't sized around or coupled to this choice.

A single row in `registry-design.md`'s **Decisions & Alternatives** table answers "why SQLite and why does each kiosk rebuild its own index on import?" without cluttering `docs/intent/registry/decisions/` with a doc no future maintainer would need to re-run.

Does keeping it as the table row work for you, and how would you like to handle the five Phase 2 edge-case questions above before we move to Phase 3 (EARS specs)?