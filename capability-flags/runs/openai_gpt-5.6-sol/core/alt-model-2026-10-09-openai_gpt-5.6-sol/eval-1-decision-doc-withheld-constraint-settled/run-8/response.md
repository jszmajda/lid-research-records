**Phase 2: Registry Design**
Updated `docs/intent/registry/registry-design.md` to define:

- A per-kiosk embedded SQLite index built by streaming the signed NDJSON snapshot.
- Uniqueness enforcement using normalized serial numbers.
- Staged construction, integrity checking, and atomic activation.
- Read-only indexed lookups with no runtime network access.
- Explicit unavailable behavior distinct from `NotFound`.
- Registry-owned storage and generation-consistent concurrent lookups.
- A Decisions & Alternatives table recording SQLite, on-site HTTPS, and managed search tradeoffs.

The design remains consistent with the HLD and does not change the certificate interface. The current EARS specs do not yet cover the new SQLite lifecycle behavior; that update belongs to Phase 3 after this design is approved.

The LLD edge-case probe found these decisions that should be resolved or explicitly deferred:

1. Should snapshots activate in import order, or must a kiosk reject snapshots with an older or equal snapshot date?
2. Should concurrent imports be rejected or serialized?
3. Must activation survive power loss at every publication step while preserving the previous database? This may require generation files plus an atomic active-generation pointer rather than replacing one database file.
4. What exact `findBySerial` result should represent no active snapshot, corruption, or storage failure?
5. When and how should active-database integrity be checked: startup, each connection open, or only after import?
6. Should the signed manifest bind the exact snapshot payload, schema version, and snapshot date before ingestion begins?
7. Should empty serial numbers, malformed NDJSON, unknown fields, and oversized records be rejected during import?
8. Should disk-space admission remain deferred, or should the design require enough free space for both the active and staged databases?

Please approve the Phase 2 draft and indicate which numbered gaps should be resolved in the design versus left deferred.