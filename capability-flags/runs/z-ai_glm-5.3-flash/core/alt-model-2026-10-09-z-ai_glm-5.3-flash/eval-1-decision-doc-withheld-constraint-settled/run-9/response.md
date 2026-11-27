Registry design is finished around the local SQLite index, ready for your review.

**Updated LLD** (`docs/intent/registry/registry-design.md`)
- **Architecture**: backend is a local embedded SQLite database file, one per imported snapshot — no service, no network. Certificates interface untouched.
- **Snapshot Import**: verify signature → reject bad schema versions → build candidate DB in a temp location (unique index on the normalized serial column catches duplicates; snapshot date in a `meta` table) → atomic rename activates it. Import failure leaves the previous snapshot active and reports which validation rejected it.
- **Lookup Behavior**: normalize (trim whitespace, uppercase ASCII, keep punctuation), then a single prepared-statement point lookup on the unique index; snapshot date comes from the active file's `meta` table, so `NotFound` still carries it.
- **Decisions & Alternatives**: the backend choice is recorded as a table row with the HTTPS-directory and managed-service alternatives and why they lost (no-runtime-network tenet). I did *not* offer a standalone decision doc: the alternatives are recorded in the row, and the choice affects only this node's internals — certificates sees no change.

**Cascade (same segment, free)** — `registry-specs.md`
- **REG-003** extended: rejected imports must report *which* validation failed.
- **REG-005** new: lookups keep working against the previous snapshot while an import runs.
- **REG-006** new: point-lookup response within 250 ms at up to 90,000 records (promoted from the HLD goal so it gets a test).
- REG-001/002/004 unchanged; no IDs deleted or renumbered.

**Consistency report**: coverage — every LLD behavior now maps to a spec (import rejection REG-003, atomic activation REG-004, concurrent lookup REG-005, lookup path REG-001/002/006); no contradictions; scopes are explicit; specs read context-free. LLD still matches the HLD's no-network tenets.

**Open gap needing your call before tests (Phase 4 fork):**
1. **Lookup before any snapshot has ever been imported** — `findBySerial` returns `Found`/`NotFound`, but with no active snapshot there's no snapshot date to return. Options: (a) return `NotFound` with a null/absent snapshot date, (b) return a distinct "registry not ready" result the certificates node must handle (that would touch CERT-001/002), or (c) kiosks always ship with an initial pre-imported snapshot so the state can't occur. Which do you want?
2. Do you want REG-006 (the 250 ms budget) kept as a tested spec, or demoted back to a goal?

Also, one flag per my workflow: models configured like me are known to occasionally miss tenet conflicts in design mechanisms — worth your own skim of the import/activation flow against the "failed import leaves last valid snapshot" tenet.