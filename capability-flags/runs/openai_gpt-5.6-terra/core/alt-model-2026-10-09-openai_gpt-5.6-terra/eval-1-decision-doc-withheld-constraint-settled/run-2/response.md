## Registry LLD Review
Updated `docs/intent/registry/registry-design.md` to select and design the local embedded SQLite index.

The design now specifies:
- One immutable SQLite database per activated snapshot, with snapshot date stored alongside its records.
- Identical serial normalization for record insertion and lookup, with uniqueness enforced on the normalized key.
- Private staging, integrity checking, and atomic active-database-pointer replacement.
- Lookups in progress may complete from the prior database, but return its matching snapshot date.
- Single-import serialization, restart cleanup of unselected staging files, and storage capacity expectations.
- Rejected alternatives and rationale in the LLD's Decisions & Alternatives table.

The HLD, registry LLD, and existing registry specs remain coherent for the established import and lookup behavior. The new SQLite-specific behavior needs EARS coverage in the next phase.

Please review the LLD and decide these deferred interface and policy questions:

1. When no valid snapshot is active, or SQLite cannot serve a lookup, should the registry expose a distinct unavailable/error result, or should the kiosk handle this outside the `findBySerial` interface?
2. What maximum serial-number length should the registry accept, and should empty or whitespace-only input be rejected before lookup?
3. May a valid snapshot with an equal or older snapshot date replace the active snapshot?
4. What disk-space threshold and operator guidance should apply before starting an import?