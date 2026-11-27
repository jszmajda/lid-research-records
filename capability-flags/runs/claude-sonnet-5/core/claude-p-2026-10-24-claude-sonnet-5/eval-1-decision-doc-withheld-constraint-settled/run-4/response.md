Registry LLD is updated with the SQLite backend selection — architecture, snapshot import, and lookup sections now describe the concrete design, plus a Decisions & Alternatives row recording the choice. I also fixed the now-stale "backend remains open" line in the HLD.

**Updated `docs/intent/registry/registry-design.md`:**
- **Architecture** — backend is now named: a local embedded SQLite index per kiosk, built from the active snapshot.
- **Snapshot Import** — index construction happens in a temp location from the incoming snapshot; the active index is untouched until signature, schema, uniqueness, and index construction all pass.
- **Lookup Behavior** — lookups query the active SQLite index by normalized serial.
- **Decisions & Alternatives** (new) — records the choice and why: kiosks have no network route during normal operation (an existing HLD tenet), which rules out the HTTPS directory and managed-service options outright — they're the only two that need the lab network or external connectivity during a lookup. That's worth flagging: the three options weren't actually equally live once that tenet is applied, even though they looked close on maintenance/cost tradeoffs alone. The cost of the SQLite choice is repeated per-kiosk validate-and-rebuild work, confined entirely to the registry node; `findBySerial` is unaffected.

**LLD-level edge-case probe** — gaps specific to this backend worth triaging before Phase 3 (EARS):
1. Kiosk loses power mid-rebuild — does a partial index file ever become the active one?
2. On-disk index file corrupts outside of import (disk fault) — does lookup detect and report that, or fail silently/crash?
3. Two snapshot imports triggered concurrently (e.g., two USB sticks in sequence) — is a second import rejected, queued, or racing the first?
4. Is the old index deleted after a successful cutover, or retained? Repeated imports over the kiosk's life could accumulate index files on constrained disk.
5. Is the on-disk index itself re-validated at lookup time, or only trusted at import time?
6. Rebuild time for a 90,000-record/150 MB snapshot on a 4 GB kiosk, relative to the HLD's 250 ms **lookup** goal — does rebuild block lookups, and for how long?

Also, one offer per the decision-doc rule: this was a genuinely multi-criteria choice (predictability/maintenance vs. network dependency vs. cost/credentials) that another node's work will size around (snapshot import, index rebuild). I recorded it as a Decisions & Alternatives row since the tenet makes the "why this" answerable in one line — but if you'd rather it get a full decision doc instead, say so and I'll write one instead of the row.

Two things to resolve before I move on: which of the six probe gaps above should land in this LLD now vs. be deferred as open questions, and whether the row-vs-decision-doc call above is right. Let me know and I'll fold in your answers — then we're at the Phase 2 stop for your review of the LLD as a whole.