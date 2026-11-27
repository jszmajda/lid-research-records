The decision doc is in at `docs/intent/previews/decisions/eviction-policy.md`, and the LLD's Decisions & Alternatives row now points to it instead of carrying the rationale inline.

I still owe you a ruling on the two edge-case gaps from before I can move to Phase 3 (EARS):

1. **No ghost queue** — a sheet evicted from Am during sustained Am pressure loses its reuse history and has to requalify through A1 if requested again. I wrote this into the decision doc as deliberate (the two-queue variant you sketched, not three), with a ghost list named as the natural future extension if requalification cost ever bites. Accept that as-is, or add the ghost list now?
2. **Concurrent-miss promotion** — when several requests miss on the same key and share one job ticket (PREVIEW-003), does the shared completion count as one admission into A1 (current assumption), or could simultaneous waiters count as multiple hits and spuriously promote a sheet to Am on its very first render?

Once you rule on those, I'll move to Phase 3 and update the EARS specs for 2Q.