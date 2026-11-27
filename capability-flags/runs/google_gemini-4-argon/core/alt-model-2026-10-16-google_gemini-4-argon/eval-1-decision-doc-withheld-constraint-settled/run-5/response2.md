It would be overkill — a row in `Decisions & Alternatives` is the right level here.

In LID, the test for a standalone decision doc is judged from the **landed state looking forward**, not from how much deliberation it took in the session: *would a cold reader of the landed system find this choice non-obvious and be tempted to re-litigate it without the full option-by-criterion breakdown?*

Here, three factors settle it without needing a full decision doc:

1. **An inherited HLD constraint eliminates the other options**: The HLD tenets explicitly prohibit runtime network access (`All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted` and `Kiosks have no network route during normal operation`), which rules out both the on-site HTTPS directory and the managed search service as gates.
2. **One option dominates under the constraints**: With 90,000 records, a 150 MB snapshot ceiling, and a 250 ms lookup budget on 4 GB RAM, a local embedded SQLite index is the natural, local-only fit.
3. **The choice stays inside one node**: The `certificates` component only sees `findBySerial(serial)` and its fixed return types (`Found` / `NotFound`), so no sibling nodes are sized around the SQLite internals.

A single line in `registry-design.md`'s `Decisions & Alternatives` table is enough for any future reader to immediately see why network-backed indices were ruled out and why each kiosk builds its own local SQLite index.

Would you like to keep it as the table row and proceed with reviewing the LLD and the 5 edge-case questions above?