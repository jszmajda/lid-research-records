## Phase 2 — Registry LLD (backend selected: local SQLite index)

Coherence pre-flight came back clean except for the now-stale "backend open" language, which this pass resolves. I finalized the registry LLD and updated the HLD's registry bullet to name the selected backend. No full decision doc was warranted — the choice affects only the registry node, so it is recorded as a Decisions row.

The finalized LLD (`docs/intent/registry/registry-design.md`):

---

**# Registry Design**

**## Context**

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

**## Architecture**

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed. The certificates node uses only this interface.

The lookup backend is a local embedded SQLite index. One index file is active at a time; it is built entirely from a validated snapshot and queried read-only. Snapshot validation, index preparation, and lookup all belong to this node. No lookup depends on a network service.

**## Snapshot Import**

Import proceeds in two stages so a failed import never disturbs the active index:

1. **Validate.** Verify the signature using the bundled public key, reject unsupported schema versions, and validate that serial numbers are unique.
2. **Build.** Stream the validated records into a staging SQLite index, writing each normalized serial alongside its record. Records are streamed rather than held in memory, so a snapshot up to 150 MB fits the kiosk's 4 GB budget. The staging build is complete only when every record is written and the database is closed cleanly.

Activation is a single atomic filesystem replace that makes the staging index the active index. Until that replace succeeds, lookups continue against the previous index. An import failure at any stage deletes the staging file, keeps the previous snapshot active, and reports a useful error.

The snapshot date and schema version are stored inside the index, so a lookup result is self-contained.

**## Lookup Behavior**

Normalize the serial number by trimming surrounding whitespace and uppercasing ASCII letters; serial-number punctuation remains significant. Query the active index for the normalized serial. Return `Found(record, snapshotDate)` when a row matches and `NotFound(snapshotDate)` otherwise. The snapshot date is always the active index's snapshot date.

Lookup is read-only and must not block a concurrent import.

**## Decisions & Alternatives**

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index built from each snapshot | On-site HTTPS directory; managed search service | Only a local index satisfies the HLD tenet that lookup complete from files on the kiosk with no runtime network access. The network-backed alternatives would make the registry depend on the lab network. The local index accepts a per-kiosk rebuild on each snapshot in exchange for predictable lookups and no service to operate. |
| Index activation | Build a staging index and atomically replace the active file | Apply the snapshot in place with a transaction against the live index | Replacement keeps the previous index intact and available until the new one is complete, so a failed import cannot leave a partial snapshot exposed. |
| Snapshot metadata | Store the snapshot date and schema version inside the index | Encode them in the index filename or a sidecar file | Metadata travels with the data it describes, avoiding a second file that could disagree with the index. |

**## Open Questions & Future Decisions**

**### Deferred**

1. Removing orphaned staging files left when a kiosk is interrupted mid-import (crash or power loss).

---

## LLD edge-case probe

Gaps I found pointed at this LLD itself, for you to triage (fix in the LLD vs. defer):

1. **First run / no snapshot ever imported** — what does `findBySerial` return before any snapshot is active? Today the LLD assumes an active index exists.
2. **Uniqueness vs. normalization** — are two records whose serials normalize to the same value (e.g. `abc` and `ABC`, or differing only by surrounding spaces) duplicates? REG-003 is written on raw serials.
3. **Concurrent imports** — the LLD says lookup must not block import, but says nothing about two imports overlapping; is only one import allowed at a time?
4. **Atomicity across filesystems** — the replace is only atomic if the staging file sits on the same volume as the active index; does the design require that?
5. **Disk space** — building staging alongside the active index needs roughly twice the index size free; is an out-of-space failure just a generic "useful error"?
6. **Corrupt/unreadable active index** — no defined behavior if the active index is damaged or unreadable at startup or lookup.
7. **Staging-file identity on restart** — how does startup tell an orphaned staging file from the active index (naming convention), which pairs with Deferred item 1?
8. **Malformed/blank serial fields** — does validation reject a record with a missing or empty serial?

Please review the LLD and tell me which of the eight gaps to fold into the design now versus defer. Once you approve, I'll move to Phase 3 (EARS specs).