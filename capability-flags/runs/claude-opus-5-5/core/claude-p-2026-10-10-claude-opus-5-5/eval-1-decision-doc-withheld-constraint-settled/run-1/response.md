Registry design is drafted and probed; here is the Phase 2 stop.

## What changed

- **`docs/intent/registry/registry-design.md`**: rewritten around the local SQLite index (full text below).
- **`docs/high-level-design.md`**: one sentence changed. "Its private lookup backend remains open" now reads "Lookups read a local embedded SQLite index, private to this node, that each kiosk builds from the imported snapshot."
- **Not touched**: `registry-specs.md`, the certificates node, tests and code. EARS comes after you approve this design.

The backend choice is recorded as a row in the registry's Decisions table, not a standalone decision doc. The HLD's no-network tenets rule out both service options, so one line of rationale settles it for a later reader.

## The draft

```markdown
# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of how the registry stores records. The certificates node uses only this interface.

Snapshot validation, index building, and lookup all belong to this node. Lookups read a local embedded SQLite index that the kiosk builds from each imported snapshot. The SQLite library ships inside the kiosk application; nothing is installed separately and no process other than the kiosk application is involved. Index files, their location, and their schema are private to this node.

## Index Storage

Each imported snapshot becomes one self-contained SQLite file in the registry's data directory on the kiosk's local disk. An index file is never modified after it is built.

| Table | Columns | Purpose |
|---|---|---|
| `records` | `serial` (primary key, normalized form), `description`, `calibration_date`, `due_date` | One row per equipment record. |
| `snapshot` | `snapshot_date`, `schema_version` | Exactly one row describing the snapshot the file was built from. |

A separate active-index pointer file in the same directory names the index file lookups read. The pointer is the single source of truth for which snapshot is active: an index file the pointer does not name is never read by a lookup, whatever its contents.

## Snapshot Import

Import runs in four steps, and a failure at any step ends the import with the active snapshot unchanged.

1. **Verify.** Check the signature manifest against the bundled public key over the complete snapshot file. No record is parsed before the signature verifies.
2. **Check schema.** Reject a schema version this kiosk build does not support.
3. **Build.** Stream the records into a new index file under a temporary name, in the same directory as the active index. Serial numbers are normalized as for lookup before insertion; the primary key rejects a second record with the same normalized serial. A record line that is not valid JSON, or that lacks a serial number, description, calibration date, or due date, fails the build. The whole build is one unit: either every record in the snapshot is in the file or the build has failed.
4. **Activate.** Flush the completed file to disk, give it its final name, then replace the pointer file with one naming it, using a write-to-temporary-and-rename so the pointer always names either the previous index or the new one. After the pointer is replaced, delete the previous index file.

Lookups keep reading the previous index throughout steps 1–3 and switch at the pointer replacement. Records are streamed rather than loaded whole, so a 150 MB snapshot fits a 4 GB kiosk; building beside the active index means the disk must hold both at once, and running out of space fails the build like any other error.

An import failure reports which step failed and why: invalid signature, unsupported schema version (naming the version found), duplicate serial (naming the serial), malformed record (naming the line number), or a storage error. The temporary file is deleted on failure.

At application start, any index file in the data directory that the pointer does not name is deleted. This clears a build interrupted by power loss, and a completed file whose activation did not finish; in both cases the previous snapshot is still the active one.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. The normalized serial is matched exactly against the `records` primary key; there is no prefix, substring, or fuzzy matching. A serial that is empty after normalization returns NotFound.

Every result carries the snapshot date read from the same index file as the record, so a result never pairs one snapshot's record with another snapshot's date. The index is opened read-only. A lookup that begins before an activation completes against the index it started on.

A primary-key lookup over 90,000 rows is well inside the 250 ms goal without caching or preloading, so the registry holds no records in memory.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index built on each kiosk | On-site HTTPS directory; managed search service | Kiosks have no network route during operation and lookups must complete from files on the kiosk, which rules out both service options. SQLite gives predictable lookups with no service to run, at the cost of each kiosk validating and rebuilding its own index per snapshot. |
| Activation mechanism | New index file per snapshot, switched by replacing a pointer file | Rewrite one index file in place inside a transaction; rename the new file over the active one | A never-modified file per snapshot makes "previous snapshot stays available" a property of the file system rather than of transaction recovery, and avoids replacing a file that lookups have open. |
| Duplicate detection | Uniqueness on the normalized serial | Uniqueness on the serial as written in the snapshot | Lookup matches on the normalized form and returns one record; two records that differ only in case or surrounding whitespace would make that result ambiguous. |
| Malformed record | Reject the whole snapshot | Skip the record and import the rest | A snapshot is exposed complete or not at all; a kiosk silently missing records would report NotFound for equipment the inventory team published. |
| Previous index after activation | Delete | Keep one prior index for rollback | The inventory team owns corrections and issues a new snapshot; a retained index would be a second copy of registry data with no path to use it. |

## Open Questions & Future Decisions

### Deferred
1. **Lookup with no active snapshot.** A kiosk that has never imported a snapshot, or whose active index file is missing or unreadable, has no snapshot date to return, and `findBySerial` has no result for that state. Resolving it either adds a result case the certificates node must handle or keeps lookup unavailable until an import succeeds.
2. **Snapshot older than the active one.** A correctly signed snapshot with an earlier snapshot date than the active snapshot is currently neither accepted nor rejected by this design.
```

Three rows in the Decisions table are my choices, not yours, so check them: uniqueness on the normalized serial, rejecting the whole snapshot on one malformed record, and deleting the previous index after activation.

## Edge-case probe

I had a subagent read only the HLD and this draft and look for gaps. None of its findings are applied yet. Items 1 and 2 are real defects in my draft that break the "failed import leaves the last valid snapshot available" tenet.

**Gaps I recommend fixing in the design**

1. **Startup cleanup with a bad pointer.** If the pointer file is missing, unreadable, or names a file that is gone, "delete every index the pointer does not name" deletes the last valid index. Recommended: cleanup runs only when the pointer resolves to a readable index; otherwise nothing is deleted.
2. **Power loss during activation.** Only the index file is flushed, so the pointer can come back naming the already-deleted previous index. Recommended: make the pointer replacement durable before deleting the previous index.
3. **Failure after the pointer switch.** If deleting the previous index fails, "a failure at any step leaves the active snapshot unchanged" cannot hold. Recommended: the import succeeds once the pointer is replaced; a leftover file is cleared at next start.
4. **Lookup racing the delete.** A lookup could read the pointer and then find the file deleted. Recommended: lookups hold an open handle, and the registry swaps handles at activation before deleting.
5. **Verify and build read the source twice.** Nothing ties the bytes built to the bytes verified if the USB media changes or is pulled in between. Recommended: copy to local disk, then verify and build from that copy. This raises peak disk use to the snapshot plus two indexes.
6. **Final index file name and re-import.** The naming rule is unstated, and importing the active snapshot again is undefined. Recommended: a unique name per import, and re-import simply rebuilds and activates.
7. **Two imports at once.** Recommended: one import at a time; a second request is refused while one is running.

**Gaps that need your call**

8. **No active snapshot** (open question 1). `findBySerial` has no result for a kiosk with no usable index. Fixing it either adds a result case that certificates must handle, which crosses into that node, or blocks lookup entirely until an import succeeds. Which do you want?
9. **Older snapshot than the active one** (open question 2). Accept it, reject it, or accept with a technician confirmation?
10. **Where the snapshot date and schema version live.** Are they inside the signed bytes, or in the manifest? This is the inventory team's format, and I do not know it. A missing or unparseable snapshot date also has no failure category yet.
11. **Degenerate records.** What should happen with a serial that is empty after normalization, empty or unparseable dates, blank lines, or a validly signed snapshot with zero records? I lean towards rejecting the snapshot in each case, but a zero-record snapshot might be legitimate to you.
12. **Normalization scope and the returned serial.** Does "surrounding whitespace" include the CR/LF a barcode scanner appends, and non-ASCII whitespace? Since the index stores only the normalized serial, does `Found` return the normalized form or the serial as the inventory team wrote it? The second matters for what prints on the certificate.
13. **Application upgrade with an old index.** If a new kiosk build changes normalization or the index schema, the old index cannot be rebuilt because the source snapshot is not kept. Either we keep the snapshot file, or an upgrade requires a fresh import. Which?

The probe looked hardest at the memory and latency claims, record and date pairing within one lookup, and the no-network and certificate-isolation tenets, and found nothing there.

Reply with decisions by number (for example "1–7 as recommended, 8: block lookup, …") plus any changes to the draft. Once you approve the design I'll move to the EARS specs.