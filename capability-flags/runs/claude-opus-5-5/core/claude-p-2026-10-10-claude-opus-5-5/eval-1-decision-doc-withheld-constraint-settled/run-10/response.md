The registry design is drafted around the local SQLite index and is ready for your review. I have not touched the EARS specs yet; they follow once you approve this design.

I recorded the SQLite choice as a row in the design's Decisions table, not a standalone decision doc. The HLD's no-runtime-network tenet rules out the other two options, so a cold reader has nothing left to re-litigate.

## Changes outside the registry design

- **`docs/high-level-design.md`**: one line in Architecture changed. "Its private lookup backend remains open" became "answered from a SQLite index each kiosk builds locally from the snapshot."
- **Certificates**: untouched. `findBySerial` and its result types are unchanged.

## `docs/intent/registry/registry-design.md`

> # Registry Design
>
> ## Context
>
> Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.
>
> ## Architecture
>
> Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of how the registry stores records. The certificates node uses only this interface.
>
> Snapshot validation, index building, and lookup all belong to this node. Lookups are answered from a SQLite index file on the kiosk's local disk, opened through a SQLite library bundled with the kiosk application. Each kiosk builds its own index from the signed snapshot it is given; the index file, its schema, and its location are private to this node.
>
> ## Index
>
> One index file holds exactly one snapshot:
>
> - a records table keyed by normalized serial number (see Lookup Behavior), carrying the equipment description, calibration date, and due date;
> - a metadata table carrying the snapshot date and schema version.
>
> Keeping the snapshot date in the same file as the records means a lookup result can never pair records from one snapshot with the date of another.
>
> The kiosk holds at most one active index. Lookups open it read-only, and each lookup reads the record and the snapshot date inside one read transaction.
>
> ## Snapshot Import
>
> Import runs in four steps, and the active index is untouched until the last one. One import runs at a time; a second request while one is running is refused.
>
> 1. **Copy.** Copy the snapshot from the USB medium to a staging location on the same local volume as the active index. Every later step reads this local copy, never the medium.
> 2. **Verify.** Verify the signature manifest against the copied snapshot using a bundled public key, then reject unsupported schema versions. The signature covers the records, the schema version, and the snapshot date. No record is parsed from a snapshot whose signature has not been verified.
> 3. **Build.** Create a new index file in the staging location and load every record into it. Records are keyed by normalized serial number, so a duplicate serial number fails the build. A record that cannot be parsed or lacks a required field also fails the build.
> 4. **Activate.** Once the staged index is complete and flushed to disk, rename it over the active index in a single atomic rename; the superseded index ceases to exist in that same step. The snapshot copy is then deleted.
>
> A failure at any step — including the USB medium being removed during the copy or the disk filling during the build — discards the staged files, leaves the previous index active, and reports an error naming the step and the cause. Lookups continue against the active index while an import runs, and see the new snapshot only once activation completes.
>
> Anything left in the staging location by an interrupted import (power loss, application exit) is deleted at the next startup; it is never activated.
>
> ## Lookup Behavior
>
> Before lookup, trim surrounding whitespace from the entered serial number and convert its ASCII letters to uppercase. Serial-number punctuation remains significant. The same normalization is applied to each record's serial number when the index is built, so lookup is a single exact-match read on the records table's key. Return the snapshot date from the active index even when no matching record exists.
>
> A keyed read over 90,000 records sits far inside the 250 ms lookup goal on a 4 GB kiosk; no cache or in-memory copy of the registry is kept.
>
> ## Decisions & Alternatives
>
> | Decision | Chosen | Alternatives Considered | Rationale |
> |---|---|---|---|
> | Lookup backend | SQLite index file on the kiosk | On-site HTTPS directory; managed search service | Kiosks have no network route in normal operation and every lookup must complete from files on the kiosk. Both alternatives put a network call in the lookup path. The cost accepted is that each kiosk validates and rebuilds its own index on every snapshot. |
> | Replacing a snapshot | Build a separate index file, then atomically rename it over the active one | Delete and reload records inside the active index in one transaction | A failed or interrupted import can never leave the active index altered, and lookups are not blocked behind a long write transaction during a 150 MB import. |
> | Where duplicate serial numbers are detected | The records table's key, during the build | A separate uniqueness pass over the snapshot before building | One pass over the snapshot instead of two; the staged file is discarded on failure either way. |
>
> ## Open Questions & Future Decisions
>
> ### Deferred
>
> 1. What `findBySerial` returns on a kiosk that has never imported a snapshot. Both result types carry a snapshot date, and there is none.
> 2. Whether serial numbers that differ only by letter case or surrounding whitespace count as duplicates at import. The design above keys records by normalized serial number, which treats them as duplicates and rejects the snapshot.
> 3. Whether a snapshot whose date is earlier than the active snapshot's is accepted.
> 4. Whether the superseded index is kept after activation so a kiosk can be returned to the prior snapshot. The design above does not keep it.

## Things I added that you did not say

Please confirm or correct these:

- **A.** The signature covers the snapshot date and schema version as well as the records. This is my assumption about the snapshot format.
- **B.** A record that fails to parse or lacks a required field rejects the whole snapshot.
- **C.** The snapshot is copied to local disk before verification, so the build reads exactly the bytes that were verified.
- **D.** Only one import runs at a time; a second is refused.

## Gaps that need your call

I ran a cold-read probe of the design with a subagent that saw only the two docs. The first four below are the deferred questions in the design; the rest came from the probe. For each, tell me whether to settle it in the design now or leave it deferred.

1. **No snapshot ever imported.** Both `Found` and `NotFound` require a snapshot date. Settling this may add a third result type, which changes the interface certificates depends on, so I would pause and confirm before touching that node.
2. **Duplicates after normalization.** If `ab-12` and `AB-12` both appear in a snapshot, is that a duplicate that rejects the import (what the draft does), or two distinct records?
3. **Older snapshot.** Is a validly signed snapshot dated earlier than the active one accepted or rejected?
4. **Rollback.** The draft discards the superseded index at activation. Do you want the prior one kept?
5. **Unreadable active index.** If the index file is corrupt or hits an I/O error, `findBySerial` has no error shape. This is the same interface question as item 1.
6. **Kiosk operating system.** Renaming over a file that a lookup has open works on Linux and macOS but is refused on Windows. Which do the kiosks run?
7. **Degenerate but validly signed snapshots.** Does a snapshot with zero records, a missing or malformed snapshot date, or more than 150 MB activate, or is it rejected?
8. **Normalization edges.** What counts as whitespace (tabs, non-breaking spaces)? Is whitespace inside a serial number significant? What happens when the entered serial is empty after trimming?
9. **App update versus active index.** If an updated application no longer supports the schema version of the index already on disk, what should happen at startup?
10. **Error reporting.** Who sees an import error, and does a duplicate-serial failure name the offending serial number?

Reply with corrections to A–D, your call on 1–10 by number, and any other changes to the draft. Once you approve the design, I will update `registry-specs.md` to match and bring that to you next.