Registry LLD drafted at `docs/intent/registry/registry-design.md`. HLD check: no HLD change needed — it already leaves the lookup backend private to the registry node, and SQLite keeps all lookup work on-kiosk.

The design now specifies:

- A local embedded SQLite index, rebuilt per snapshot during import.
- One immutable `registry.sqlite` per snapshot, selected through an atomic `active` pointer file.
- Import sequence: verify signature, reject unsupported schema, normalize and reject duplicate serials, build in staging, integrity-check, atomically activate, then prune.
- Read-only lookup by normalized serial as the primary key, returning `Found(record, snapshotDate)` or `NotFound(snapshotDate)`.
- Retention of the active and previous snapshots; failed imports leave the active snapshot untouched.
- Backend, activation, retention, and read-only-access decisions recorded in the LLD’s Decisions & Alternatives table.

The LLD edge-case probe surfaced gaps that need your call before I lock the design:

- **Lookup failure surface:** `findBySerial` only returns `Found`/`NotFound`. If `active` is missing, unreadable, or the database is corrupt, should the registry refuse to start, extend the result type with an error, or treat it as `NotFound` with a snapshot date?
- **Import concurrency and durability:** should imports be serialized by a single lock, and must the staged index, pointer file, and parent directory be fsynced before activation? What cleanup is expected after a crash?
- **Validation strictness:** is `snapshot.json` covered by the signature and source digest? Are malformed records rejected wholesale or skipped? What are the exact rules for blank lines, missing fields, and invalid UTF-8?
- **Snapshot identity and retention:** how is the snapshot ID derived, what happens when the same snapshot is re-imported, and does “older” mean snapshot date or import order? Is manual rollback required, or only in-flight lookup safety?
- **Normalization contract:** what should empty or whitespace-only serials and non-ASCII characters produce, and is one normalization implementation shared by import and lookup?
- **Pruning semantics:** if pruning fails after activation, is the import reported as successful or failed?
- **Import error shape:** what fields identify the failed step and snapshot, and is the error returned, logged, or persisted?

Please review the LLD and tell me which of these to settle in the design now versus defer as open questions. Once you approve, I’ll update the EARS specs against the final LLD.