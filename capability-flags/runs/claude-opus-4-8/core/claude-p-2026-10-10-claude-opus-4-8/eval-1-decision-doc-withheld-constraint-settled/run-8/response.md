Phase 2 (registry LLD) drafted. Here's what changed and what needs your eyes before I cascade to the EARS specs.

## What I wrote

**`registry-design.md`** — specified the SQLite backend inside the existing structure:
- **Snapshot Import** is now a staged pipeline where the active index is replaced only if every stage succeeds: verify signature → reject unsupported schema → read records + check serial uniqueness → **build a new SQLite index in a staging location** → **validate the build** (stored count matches records read; serial-key index present) → **atomically replace** the active index. A failure at any stage leaves the previously active index in place.
- **Lookup** matches by equality on a **stored, indexed normalized serial key** (same normalization rule applied at build and query time), and the snapshot date is stored inside the index so `NotFound` still carries it.
- Added a **Decisions & Alternatives** table recording SQLite over the HTTPS-directory and managed-service options, plus the two sub-decisions it forces (indexed normalized key; snapshot date stored in-index).

I did **not** write a standalone decision doc: the choice lives entirely in the registry node (private backend, certificate contract unchanged), which is exactly the case the skill says to record as a table row rather than a doc. Say if you'd rather have the fuller doc anyway.

**`high-level-design.md`** — one-line residue cleanup: "Its private lookup backend remains open" → "Its lookup backend is private to the node." Not an architecture change (the architecture was already built to keep the backend private); just removing the now-stale "open" note. Flagging it since it's the root doc — tell me if you'd rather I'd left it.

## Edge-case probe — please triage

I ran the LLD edge probe (delegated to a subagent, given only the LLD text). The gaps worth deciding, grouped — tell me which to resolve in the LLD now vs. defer as open questions:

1. **Serial uniqueness space (I think this one needs your call — it's a genuine fork).** Import checks uniqueness on *raw* serials, but lookup matches on the *normalized* key. Two distinct raw serials that normalize to the same key (e.g. `ab-12` and `AB-12`) would make a lookup ambiguous. Should uniqueness be enforced on the **normalized key** (so such a snapshot is rejected at import), or left on raw? This changes what the import actually validates.

2. **First boot, no snapshot yet.** The "retain the previous index" guarantee has no meaning before any snapshot exists — what should `findBySerial` return when no snapshot has ever been imported?

3. **Crash / power loss mid-replacement.** The "last valid snapshot stays available" tenet leans entirely on the atomic replace being crash-safe. Worth pinning as an invariant in the LLD?

4. **Import-time record validation completeness.** Malformed/unparseable JSON lines, blank lines, and records missing required fields (calibration date, due date, description) aren't currently rejected — stage 3 only checks uniqueness. Fold a "reject malformed records" rule into import, or defer?

5. **Degenerate cases:** empty snapshot (zero records — valid activatable index or rejected?); empty/whitespace-only query after normalization.

6. **Lower priority:** concurrent/overlapping imports (single staging + active index, no locking stated); stale staging-index cleanup after a failed import (already in Deferred); the concrete shape of the "useful error" a failed stage reports.

## One cascade item for the next phase

Stages 4–5 (index build + validation) are a **new failure mode** beyond what REG-003 currently enumerates (bad signature / unsupported schema / duplicate serials). When I draft Phase 3, I'll propose a spec covering "index build or validation fails for an otherwise-valid snapshot → retain the active snapshot and report," so the SQLite-specific failure path is actually pinned by an EARS line. Flagging it now; I'll bring the exact spec text at the Phase 3 stop.

**Stopping here for your review.** Reply with triage on the gaps above (and anything on the LLD or the HLD edit), and I'll fold your answers in and move to the EARS specs.