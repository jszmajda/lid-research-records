I have updated `docs/intent/registry/registry-design.md` to specify the local embedded SQLite index backend.

### Phase 2 Output: `docs/intent/registry/registry-design.md`

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context and Design Philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Kiosks run in an isolated production environment without network connectivity; all data access and lookup processing remain strictly local to the kiosk to guarantee deterministic, offline operation.

## Architecture & Interface

The registry component exposes a stable lookup interface:
`findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`.

Record fields and result types are fixed and independent of storage mechanics. The certificates node consumes only this interface.

Internal storage and indexing use a local embedded SQLite index (`registry.db`). Snapshot validation, database indexing, atomic file activation, and query execution are wholly contained within this node.

## Storage & SQLite Index Schema

The local SQLite database stores equipment records and snapshot metadata:

- **`equipment` table**:
  - `serial_normalized` (TEXT, PRIMARY KEY): Whitespace-trimmed, uppercase ASCII serial number.
  - `serial_raw` (TEXT, NOT NULL): Original serial number preserving author formatting.
  - `calibration_date` (TEXT, NOT NULL): ISO 8601 date string.
  - `due_date` (TEXT, NOT NULL): ISO 8601 date string.
  - `description` (TEXT, NOT NULL): Equipment description text.
- **`snapshot_meta` table**:
  - `snapshot_date` (TEXT, NOT NULL): Active snapshot creation date.
  - `schema_version` (INTEGER, NOT NULL): Snapshot schema version.

The primary key on `serial_normalized` provides indexed B-tree lookups completing well within the 250 ms kiosk latency budget for the ~90,000 record dataset. The database is opened in read-only mode during kiosk query operations.

## Snapshot Import & Activation

When a new snapshot is provided via approved USB media:

1. **Signature & Schema Verification**: Verify the manifest signature against the bundled public key and confirm the snapshot schema version is supported.
2. **Staged Database Build**: Validate JSON records for schema conformity and ensure serial-number uniqueness. Write records directly into a temporary SQLite database file (e.g., `registry.db.staging`) on local storage.
3. **Atomic Activation**: Upon successful validation and index build, atomically replace the active database file (`registry.db`) with the staging database (via filesystem rename) and refresh the active database handle. No partially imported records or intermediate states are exposed.
4. **Failure Isolation**: If signature verification, schema validation, record uniqueness checks, or database compilation fail at any step, abort the operation, delete the staging database, retain the existing active SQLite database without interruption, and report a diagnostic error.

## Lookup Behavior

1. **Input Normalization**: Trim leading and trailing whitespace and convert ASCII letters to uppercase. Serial-number punctuation and casing of non-ASCII characters remain intact.
2. **Index Query**: Execute an indexed lookup on `serial_normalized` against the active SQLite database.
3. **Result Formation**:
   - If a matching row exists, return `Found(record, snapshotDate)`.
   - If no matching row exists, return `NotFound(snapshotDate)`.
   The active snapshot date is retrieved from `snapshot_meta` and returned in both outcomes.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory, Managed search service | Keeps kiosk operation fully self-contained and offline per HLD tenets (no network dependencies, predictable sub-250ms lookup latency). Validating and rebuilding the SQLite index locally on snapshot import avoids central service dependencies and recurring external costs, while keeping backend mechanics strictly private to the registry component. |

## Open Questions & Future Decisions

### Resolved
1. ✅ Lookup backend: Local embedded SQLite index chosen to ensure offline kiosk operation and predictable lookup latency without external network dependencies.

### Deferred
*(Pending user triage of edge-case probe findings)*
```

---

### Phase 2 LLD-Level Edge-Case Probe Findings

An independent probe of internal LLD gaps surfaced the following questions for triage:

1. **Cold-start state**: What does `findBySerial` return before any snapshot has been imported on a freshly provisioned kiosk? Does the interface need an uninitialized/no-snapshot return variant?
2. **Query failure shape**: If `registry.db` encounters an unreadable file or SQLite I/O error during lookup, should `findBySerial` expose an error channel or fallback?
3. **Snapshot import API contract**: What is the formal return type/diagnostic shape when import fails (distinguishing signature, schema version, duplicate serial, and disk/I/O errors)?
4. **In-flight queries during activation**: How should active read queries and open SQLite connections behave during the atomic file rename/handle swap?
5. **Normalization collision**: If two records in a snapshot have distinct raw serials that normalize to identical keys (e.g., `"SN-1"` and `"sn-1"`), should validation reject the snapshot as a duplicate collision?
6. **Freshness ordering**: Does the kiosk permit importing a snapshot with an older `snapshot_date` or lower `schema_version` than the currently active database, or is downgrade blocked?

---

### Stop: User Review & Triage

Please review the LLD draft above and indicate:
1. Which of the probe items (1–6) you would like resolved directly in the LLD now versus deferred to implementation/open questions.
2. Approval to proceed to Phase 3 (EARS specs update).