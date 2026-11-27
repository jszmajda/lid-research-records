It would be overkill—the `Decisions & Alternatives` table row in `registry-design.md` is the right fit here.

In LID, the test for a standalone decision doc is forward-looking from the landed state (*would a cold reader of the result find the choice non-obvious and be tempted to re-litigate it?*), rather than how much deliberation it took to get there. Three factors keep this below the bar for a full decision doc:

1. **An inherited constraint settles it:** The HLD tenets require all lookups to complete from local kiosk files with no runtime network access and signed USB snapshots as the sole update channel. That acts as a hard gate eliminating both the on-site HTTPS directory and the managed search service.
2. **One option dominates under those constraints:** Once network-backed options are ruled out, an embedded local index is the natural fit for 90,000 records within 250 ms and 4 GB RAM.
3. **The scope is strictly local to one node:** The `findBySerial(serial)` contract with `certificates` is unchanged, so no sibling nodes are sized around this choice.

A future cold reader might briefly wonder *"why SQLite rather than scanning the raw NDJSON file or calling a central service?"*, and the single table row in `registry-design.md` answers both in one line. (You can still have me write `docs/intent/registry/decisions/lookup-backend.md` if you want it recorded in full, though I'd recommend against it to keep `decisions/` reserved for choices that remain genuinely live.)

Whenever you're ready, let me know if you want to keep just the table row and how you'd like to triage the Phase 2 edge-case items (1–6) above.