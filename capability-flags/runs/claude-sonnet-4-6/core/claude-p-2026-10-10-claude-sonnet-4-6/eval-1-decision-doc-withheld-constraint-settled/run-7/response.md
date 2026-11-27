Phase 2 — here is the updated registry LLD for your review.

---

**`docs/intent/registry/registry-design.md`** (full rewrite)

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context and Design Philosophy

Technicians enter an equipment serial number and need its calibration date, due date,
and equipment description. A signed snapshot contains newline-delimited JSON records,
a schema version, a snapshot date, and a signature manifest.

The registry owns all snapshot handling and lookup. The certificates node sees only
the `findBySerial` result type; it never reads registry storage directly.

## Interface

`findBySerial(serial)` returns either `Found(record, snapshotDate)` or
`NotFound(snapshotDate)`. Record fields and result types are fixed. The snapshot date
is always present so callers can display it without a separate query.

## SQLite Index

One SQLite database file holds the active snapshot's records. A staging file is
written during import and replaces the active file atomically on success.

Schema:

  CREATE TABLE snapshot_meta (
      snapshot_date TEXT NOT NULL
  );

  CREATE TABLE records (
      serial_number    TEXT NOT NULL PRIMARY KEY,
      description      TEXT NOT NULL,
      calibration_date TEXT NOT NULL,
      due_date         TEXT NOT NULL
  );

`records` uses `serial_number` as its primary key, providing O(log n) lookup.
`snapshot_meta` holds exactly one row. Both tables reside in the same file.

## Snapshot Import

1. Verify the signature against the bundled public key. Reject if invalid.
2. Check the schema version. Reject unsupported versions.
3. Open a staging database file at a temporary path.
4. Stream records from the snapshot into the staging file. The UNIQUE constraint on
   `serial_number` (PRIMARY KEY) rejects duplicate serials at insert time.
5. On any failure: close and delete the staging file, report the failure reason.
   The active database file is untouched.
6. On success: rename the staging file over the active file. The rename is atomic
   on POSIX and Windows filesystems, preventing a crash from leaving a partial
   index exposed.

## Lookup

1. Read `snapshot_date` from `snapshot_meta`.
2. Normalize the query: strip surrounding whitespace, uppercase ASCII letters.
   Retain punctuation unchanged.
3. Execute SELECT with the normalized serial against `records.serial_number`.
4. Return `Found(record, snapshotDate)` or `NotFound(snapshotDate)`.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|----------|--------|------------------------|-----------|
| Lookup backend | Local embedded SQLite | On-site HTTPS directory; managed search service | The HLD tenet requires all lookup to complete from kiosk-local files with no runtime network access. Both alternatives require the lab network during lookup, violating that tenet. SQLite satisfies it; index rebuild on import stays entirely inside this component. |
| Staging and swap | Write staging file, then atomic rename over active file | In-place update of active file | Rename is atomic on both POSIX and Windows; an import crash cannot expose a partial index. In-place update leaves the active index undefined on failure. |
| Normalization scope | Strip surrounding whitespace and uppercase ASCII letters only | Full Unicode case folding | Serial numbers in this registry use ASCII only. Broader normalization would mask punctuation differences that distinguish valid serial numbers. |

## Open Questions & Future Decisions

### Resolved
1. ✅ Lookup backend: local embedded SQLite (see Decisions & Alternatives).

### Deferred
None.
```

Also updated: removed the stale "Its private lookup backend remains open." sentence from `docs/high-level-design.md`'s Architecture section.

---

A few things I want to flag before you approve and we move to Phase 3 (EARS):

1. **Snapshot date caching** — the LLD says "Read `snapshot_date` from `snapshot_meta`" on each lookup. The date doesn't change between imports, so caching it in memory is a natural optimization, but I left it out of the LLD on purpose: whether to hold it in a module-level variable or re-query is an implementation choice I don't think the design needs to fix. Let me know if you want a note on this.

2. **File paths** — the LLD doesn't specify where the active database file or staging file live on disk (a data directory, a path relative to the app root, etc.). Is that level of detail for the LLD, or is it a configuration concern?

3. **`NotFound` on an empty registry** — if no snapshot has ever been imported, there is no active database file. The current specs say REG-002 requires a snapshot date in every result, and REG-003 says a failed import retains the active snapshot — but there is no spec for the "no snapshot ever imported" state. The LLD is currently silent on this too. I want to call it out before we write specs: should the system refuse lookup entirely until a first valid snapshot is loaded, return a sentinel date, or something else?

Once you've reviewed the LLD and settled question 3 (at minimum), I'll proceed to Phase 3.