A table row is sufficient here. Apply the "earns-its-place" test: once the SQLite choice lands in the design, would a cold reader question it or be tempted to reverse it?

No — the rationale is self-evident from the HLD tenets. A reader seeing "predictable O(1) lookups with no runtime network dependency" and "all state remains local" would immediately understand why this was chosen. The structure documents itself. A full decision doc is for choices that **stay live** — where a reader would re-litigate without the full tradeoff analysis. This one reads as locally optimal once it lands.

The Decisions & Alternatives row you now have captures exactly the right amount: what was chosen, what was considered, and why. That's enough.

Now — back to the three divergences: how should the snapshot date behave on NotFound, concurrent import/lookup, and error reporting granularity?