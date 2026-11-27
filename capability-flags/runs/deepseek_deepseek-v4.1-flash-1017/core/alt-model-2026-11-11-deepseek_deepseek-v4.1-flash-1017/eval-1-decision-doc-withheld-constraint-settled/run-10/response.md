Phase 2 is drafted: `docs/intent/registry/registry-design.md`, with the HLD architecture line updated so the registry owns local index preparation.

The design selects a local embedded SQLite index:
- One complete `registry.sqlite` per validated snapshot under `registry/snapshots/<snapshot-id>/`
- An `active` pointer file replaced by atomic rename only after the new database is durable
- Serial normalization shared between import and lookup, with the normalized serial as the primary key
- Read-only lookups against one snapshot per request, so activation cannot mix two snapshots
- Retention of the active and immediately previous snapshot

This is recorded as decisions in the LLD table for backend, activation, serial key normalization, and retention. The offline/no-network tenet already eliminates the HTTPS-directory and managed-service options, so no standalone decision doc was created.

The LLD-level edge probe surfaced these unresolved gaps:

1. What exactly the signature covers: records only, or also schema version, snapshot date, and snapshot ID.
2. Whether re-importing an older correctly signed snapshot can replace a newer active one; no freshness/monotonicity rule is stated.
3. The exact normalization domain: which whitespace characters count, and whether non-ASCII case is unchanged.
4. Retention versus lookups spanning two activations, including the window between reading `active` and opening its database.
5. Whether imports are serialized, and how concurrent imports would interleave staging, pointer replacement, and cleanup.
6. Snapshot ID collisions and path safety, since the ID becomes a directory name.
7. Record validation: malformed fields, date formats, `due_date >= calibration_date`, and whether zero-record snapshots may activate.
8. Metadata cardinality: whether `metadata` must have exactly one row and what lookup does otherwise.
9. Cleanup and disk pre-flight: failed old-snapshot deletion, and disk filling during staging.

Please tell me which of these to resolve in the LLD and which to defer as open questions, and approve the LLD so I can move to the EARS spec update.