The registry design is finished and the docs are updated. Per the workflow, here are Phases 2 and 3 for your review — please confirm before tests and code are written against them.

## What changed

**Phase 1 — HLD (cascade to docs only):** `docs/high-level-design.md` Architecture now names the registry's backend as "a local embedded SQLite index on each kiosk" instead of "open."

**Phase 2 — Registry LLD** (`docs/intent/registry/registry-design.md`): rewritten around your selection, reading as a fresh design doc:
- **Snapshot Import** is now a two-stage flow: validate + build a complete new SQLite index in a staging file (no record visible during staging), then activate by atomic rename. Any failure discards the staged file and keeps the old index serving.
- **Lookup Behavior**: queries the active SQLite index keyed by normalized serial (whitespace stripped, ASCII uppercased, punctuation significant); snapshot date stored in index metadata and returned even on NotFound.
- **Decisions & Alternatives**: the backend choice is recorded as a table row with the two rejected options and rationale. Since the decision affects only the registry node (certificates explicitly treats the backend as invisible), I recorded a row rather than offering a full decision doc — say the word if you'd like the doc anyway.

**Phase 3 — EARS** (`registry-specs.md`): added **REG-005** (atomic staged-build-and-activate) and **REG-006** (old index keeps serving during/after a failed import). REG-001–004 unchanged.

**Consistency report:** Coverage — the LLD's import staging, activation, and continued-service behaviors each map to REG-004/005/006. Contradiction — none; REG-005's atomic replace and REG-004's no-partial-exposure say the same thing from different triggers. Scope — each new spec names its trigger (import vs. lookup) explicitly, so they read correctly via grep. Cross-segment — no certificates spec or design text needed to change; the certificates node's contract (`findBySerial`, result types) is untouched, so no cross-boundary cascade was required.

## Phase 2 edge-case probe — please triage

These are gaps in the registry LLD itself. Tell me which to fix into the design/specs now vs. defer:

1. **First boot, no snapshot ever imported** — what should a lookup return before any snapshot is activated? (I left this as a deferred open question in the LLD; a fabricated NotFound seems wrong, but the alternative needs your intent.)
2. **Snapshot arrives mid-lookup** — a technician is mid-lookup when activation happens. Rename-based swap makes the choice atomic per connection, but should an in-flight lookup complete against the old index or fail and retry?
3. **Corrupt/partial USB copy** — the signature check catches tampering, but what if the snapshot file is truncated before validation even starts? Treat as invalid-signature-class failure, or a distinct error message?
4. **Kiosk disk full during index build** — staging will fail partway. Same retain-and-report path as a validation failure, presumably, but should the error be distinguishable?
5. **Schema version downgrade** — a kiosk receives an older-but-signed snapshot than the one currently active. Accept it, or reject downgrades?

Does the LLD, the spec additions, and the HLD line read as what you intended — and how do you want the five probe gaps triaged?