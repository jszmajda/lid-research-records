It would be overkill—the table row in `registry-design.md` is the right level.

In LID, the test for a standalone decision doc is judged from the **landed state looking forward**, not from how much deliberation it took to get here: *would a future cold reader of the system find the choice non-obvious and be tempted to re-litigate it?* A decision doc earns its place only when:

1. **Multiple options remain genuinely live** against competing criteria (none eliminated by a hard gate), and
2. **Other design nodes are sized around the outcome** (cross-node impact).

Here, neither holds once the design lands:
- **An inherited constraint settles it**: The HLD tenets explicitly prohibit runtime network access, specify that kiosks have no network route during normal operation, and require all lookups to complete from local kiosk files. That acts as a hard gate that eliminates both the on-site HTTPS directory and the managed search service.
- **It is strictly node-local**: The `certificates` component consumes only `findBySerial(serial)` and its fixed return types (`Found` / `NotFound`), so no sibling node's design changes based on how the index is stored.

For a future cold reader wondering "why SQLite instead of a network service or raw file scan?", the single row in **Decisions & Alternatives** answers the question completely without the overhead of a separate file. (Of course, if you want a full decision doc recorded in `docs/intent/registry/decisions/` anyway, say the word and I will write one.)

Whenever you're ready, let me know how you'd like to handle the 6 edge-case questions above so we can finalize the LLD and move to Phase 3 (EARS specs).