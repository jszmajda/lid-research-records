The local SQLite index is recorded and the registry design is finished around it. A note first: the HLD's no-runtime-network tenet independently rules out the two networked options — your selection is the only one consistent with it, so I recorded it as a Decisions row in the LLD rather than offering a standalone decision doc.

I also updated the stale HLD line (`docs/high-level-design.md` § Architecture) from "lookup backend remains open" to name the SQLite index. Here is the revised registry design in full for your review (Phase 2 stop):

---

# Registry Design

## Context and Design Philosophy

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

The registry is read-only on the kiosk outside snapshot import: lookups never mutate the index, and the only writes happen during import. Every lookup is served from files on the kiosk.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed. The certificates node uses only this interface.

Snapshot validation, index preparation, and lookup all belong to this node. The lookup backend is an embedded SQLite database built on the kiosk from each accepted snapshot.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. An import failure leaves the previous snapshot active and reports a useful error.

For each accepted snapshot, build a fresh SQLite database at a staging path: load all records in a single transaction, store the snapshot date and schema version in a metadata table, and key the records table on the normalized serial. Only after the database is fully built does the registry activate it by replacing the active database file. The previously active database is retained until activation succeeds, so the active path always refers to a completely validated snapshot.

## Index and Lookup

The records table holds one row per record with the normalized serial as its primary key. Normalization trims surrounding whitespace and uppercases ASCII letters; serial-number punctuation remains significant. The same normalization runs at import, for the stored key, and at lookup, for the query, so a lookup is a single indexed equality query.

Snapshot metadata — snapshot date, schema version, record count — lives in a small metadata table, so every result, including NotFound, carries the snapshot date without touching the records table.

A 90,000-row table with a primary-key index resolves an equality lookup in well under the 250 ms goal on kiosk hardware. Snapshots up to 150 MB load in a single transaction during import, so lookup cost is independent of snapshot size.

## Decisions & Alternatives

| Decision | Chosen | Rationale |
|---|---|---|
| Lookup backend | Local embedded SQLite index | Keeps lookups on-kiosk and predictable with no service to run, per the HLD's no-runtime-network tenet; each kiosk validates and rebuilds its own index when a snapshot arrives, and that work stays inside this component. An on-site HTTPS directory and a managed search service were considered and rejected: both make registry lookups depend on the lab network or an external service, contradicting that tenet, and add timeout and credential handling to the registry. The certificate interface is unchanged by the selection. |

---

I ran the LLD-level edge-case probe (delegated to a fresh reader given only the design text). Its gap questions, most load-bearing first — please triage which to fix in the LLD now versus defer as open questions:

1. First-ever import fails or no snapshot has ever been activated — what does `findBySerial` return, and what `snapshotDate` does `NotFound` carry when no snapshot exists at all?
2. Active database missing, unreadable, or corrupted at lookup time — the result type has no error shape; is a corrupt DB silently reported as `NotFound` with a stale date, or is behavior undefined?
3. "Replacing the active database file" operationally — rename vs copy, power loss mid-replacement, and what invariant guarantees the active path never points at a half-written file?
4. A lookup in flight during activation — are lookups permitted during staging build and replacement, and does an already-open connection see old data, new data, or an error?
5. SQLite sidecar files (`-wal`, `-shm`, journal) — is "the active database file" singular, and is a journal mode specified?
6. Serial uniqueness before or after normalization — two raw-distinct serials that normalize to the same key: rejected at validation, or caught by the primary-key constraint mid-transaction, and is that the same "useful error"?
7. Normalization precision — which characters count as whitespace, what happens to non-ASCII letters and interior spaces, and what exactly is "serial-number punctuation"?
8. Empty or whitespace-only serials, both in records and in queries — rejected at import? guaranteed to miss? unspecified?
9. Ordering among signature verification, schema-version rejection, and uniqueness validation — which error wins when several fail at once, and is the signature verified before any parsing?
10. Record count in metadata — informational or validated against the manifest's count?
11. Import resource footprint — old DB + staging DB + raw 150 MB snapshot on disk simultaneously; disk floor, memory ceiling, and cleanup of orphaned staging files after a crash mid-build?
12. Snapshot-date constraints — well-formedness, monotonicity across activations, and whether re-importing the active snapshot is defined and idempotent?

Which gaps should I fold into the LLD, and which do you want deferred? Once you've triaged and approved the design, I'll move to the EARS update (Phase 3) — REG-001–004 are backend-neutral today and the new design content will need corresponding specs.