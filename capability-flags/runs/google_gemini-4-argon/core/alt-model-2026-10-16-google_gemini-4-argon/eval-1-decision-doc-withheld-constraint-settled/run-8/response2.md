It would be overkill — the single row in `registry-design.md`'s **Decisions & Alternatives** table is the right fit here.

In LID, the test for a standalone decision doc is looked at from the **landed state, forward** — *would a future cold reader find this choice non-obvious and be tempted to re-litigate it?* — rather than how much deliberation it took to reach. Even if we did write a full decision doc for this, it would live under `docs/intent/registry/decisions/` (since the substance stays entirely inside the `registry` segment and doesn't change `certificates`), not at the project root.

Here, three criteria from the earns-its-place heuristic rule out a standalone doc:

1. **Settled by an inherited constraint**: The HLD's Tenets and Non-Goals already forbid runtime network access, live sync, and external services on isolated kiosks. Both competing options (the on-site HTTPS directory and the managed search service) fail that inherited gate outright.
2. **One option dominates in the landed state**: To a cold reader who already knows the kiosks are offline-only and hold 90,000 records imported from USB snapshots, an embedded local index reads as native, while a brief one-line rationale in the table settles why SQLite was picked for the 250 ms / 90k-record target.
3. **Bounded to a single node**: No sibling component (`certificates`) has to size itself around how the registry stores or indexes records; `findBySerial(serial)` is unchanged.

Unless you foresee relaxing the HLD's offline-kiosk constraint (which would reopen networked backends as live contenders), keeping just the **Decisions & Alternatives** row in `registry-design.md` avoids doc clutter.

Would you like to keep it as the table row, and how would you like to handle the Phase 2 edge-case questions above before we move to Phase 3 (EARS specs)?