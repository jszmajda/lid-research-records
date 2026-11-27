A standalone decision doc would be overkill here. Per the earns-its-place heuristic:

1. **Inherited constraints settle it**: The HLD tenets mandate that all lookups occur locally with no runtime network route permitted, eliminating the HTTPS directory and managed search service.
2. **Single-node scope**: The lookup mechanism is internal to `registry`; the `findBySerial` interface consumed by `certificates` remains unchanged.
3. **Landed-state obviousness**: To a cold reader of an offline kiosk system, an embedded local SQLite database is the native, expected choice rather than a contentious design that invites re-litigation.

A row in the `Decisions & Alternatives` table of `docs/intent/registry/registry-design.md` is the appropriate level of record and has been added.

---

### Registry LLD Update Summary

`docs/intent/registry/registry-design.md` has been updated with:
- **SQLite Schema & Concurrency**: Read-only connection with primary key B-tree index on `serial_normalized` and metadata storage.
- **Atomic Import Pipeline**: Two-phase staging build in `registry.staging.db` with atomic filesystem swap (`rename`) to guarantee zero downtime and no exposure of partial snapshot state.
- **Decisions & Alternatives**: Documented rationale and rejected alternatives for both the SQLite backend selection and the staged atomic swap strategy.

---

### Phase 2: LLD Edge-Case Probe

Before proceeding to EARS spec updates (Phase 3), please triage the following edge-case gaps identified in the registry LLD (which to resolve in the LLD vs. defer as open questions):

1. **Cold start state**: What should `findBySerial` return if queried before any snapshot has ever been imported (no active database file exists on the kiosk)?
2. **Snapshot timestamp rollback**: If an imported snapshot contains a timestamp older than or identical to the active snapshot, should the registry reject it, or allow validly signed historical snapshots to overwrite current state?
3. **Concurrent query during swap**: When `rename(staging, active)` executes, should in-flight read queries on the prior file handle complete undisturbed, or does connection rotation require a brief reader lock/drain?
4. **Collision during normalization**: If two raw records differ in casing or whitespace but normalize to the exact same serial number, should the staging import fail with a duplicate-key error, and at what phase?
5. **Orphaned staging cleanup**: If a kiosk loses power mid-import, how should stale `registry.staging.db` artifacts be detected and pruned on subsequent startup or import attempts?