I've rewritten `docs/intent/registry/registry-design.md` around the local SQLite index. It needs your review before I move on to the specs, and a gap probe turned up 11 questions the draft doesn't answer.

## What changed

- **Registry design**: the "backend not selected" language is gone, replaced by the design below.
- **High-level design**: the Registry line said the backend "remains open"; it now says lookup is served from a private embedded SQLite index on each kiosk.
- **Recording the choice**: it is a row in the registry's Decisions table, not a separate decision doc. The HLD's "no runtime network access" tenet rules out both other options, so one line of rationale settles it.

Nothing is committed, and `registry-specs.md` is untouched.

## The draft

> **Context.** Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. The registry answers every lookup from files on the kiosk. Each kiosk turns an arriving snapshot into its own lookup index, so a kiosk's answers depend only on the last snapshot it imported successfully.
>
> **Architecture.** Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed. The certificates node uses only this interface. Snapshot validation, index building, and lookup all belong to this node. The lookup backend is an embedded SQLite index: one database file per imported snapshot, stored on the kiosk's local disk and opened in-process. Index files, their schema, and their paths are private to this node.
>
> **Index.** Each index file holds the records of exactly one snapshot, keyed by normalized serial number, together with that snapshot's date and schema version. An index file is never modified after it is built; a new snapshot produces a new file. Exactly one index file is active at a time. A small pointer on local disk names the active file, and it is the only thing activation changes.
>
> **Snapshot Import.** Import runs in this order and stops at the first failure:
> 1. Verify the signature manifest against the bundled public key.
> 2. Reject a schema version the kiosk does not support.
> 3. Build a new index file in a staging location on local disk, rejecting duplicate serial numbers.
> 4. Activate the new index by replacing the active pointer in a single atomic file-system step.
>
> Nothing is read from the snapshot's records until the signature has been verified. The staged index is invisible to lookup until step 4, so a lookup sees either all of the previous snapshot or all of the new one. A failure at any step discards the staged file, leaves the previous index active, and reports which check failed. Lookups continue against the previous index while an import is running.
>
> **Lookup Behavior.** Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Look the normalized serial up by key in the active index, opened read-only, and return the index's snapshot date whether or not a record matches. A keyed read of one row from a 90,000-row index is well inside the 250 ms goal on a 4 GB kiosk.
>
> **Decisions & Alternatives**
>
> | Decision | Chosen | Alternatives | Rationale |
> |---|---|---|---|
> | Lookup backend | Embedded SQLite index built on each kiosk | On-site HTTPS directory; managed search service | Lookup must complete from files on the kiosk with no runtime network access, and kiosks have no network route. Both alternatives answer lookups over a network. The cost is that every kiosk validates and rebuilds its own index for each snapshot. |
> | Applying a new snapshot | Build a separate index file, then switch the active pointer | Update the active index in place inside a transaction | A failed or interrupted import can only leave an unused staged file behind, so the last valid snapshot stays available without relying on rollback. Costs temporary disk space for a second index. |
>
> **Deferred.** Which kiosk-side component triggers an import and displays its error is outside this node.

The build-then-switch import is my proposal, not something you chose; say so if you'd rather update the index in place.

## Gaps to triage

I had a subagent that saw only the docs probe the draft. For each, tell me whether to fix it in the design now (and which way) or defer it as an open question.

**Need your call — these change what technicians see or what data is accepted:**

1. **No usable index.** A fresh kiosk, or a missing or corrupt index file, has no snapshot date to return, and `findBySerial` has only `Found` and `NotFound`. Should there be a third result such as `NoSnapshot`? That would change the interface the certificates component consumes.
2. **Older or same-date snapshot.** If a validly signed snapshot is older than the active one, should the kiosk accept it (a deliberate rollback), reject it, or treat it as a no-op?
3. **Serials that collide after normalization.** If `ab-12` and `AB-12` are both in a snapshot, is that a duplicate that rejects the import? The existing design says "uniqueness" without saying raw or normalized.
4. **Malformed records.** For bad JSON, a missing field, an empty serial, or a truncated last line, should the whole import fail or the line be skipped? I'd fail the whole import, since a silently missing record looks like NotFound.
5. **What the signature covers.** My draft says no records are read before the signature is verified. That only holds if the manifest signature is checked first and the record file is then hashed against it. Is that how the inventory team's manifest works?
6. **Odd serial input.** Is a serial that is empty after trimming, or has internal spaces or non-ASCII characters, a `NotFound` or an invalid-input error?
7. **Approved media and key rotation.** The HLD says "approved USB media", but this design checks only one bundled key. Is media approval the registry's job, and does key rotation need designing now?

**Mechanics I'd settle as follows unless you object:**

8. **Power loss during activation.** Flush the staged file to disk before switching the pointer, and sweep leftover staged files at startup.
9. **Old index files.** Keep only the active index, and delete the superseded one after activation once no lookup has it open.
10. **Concurrent imports and pointer caching.** Allow one import at a time and reject a second. Resolve the active index per lookup so a new snapshot is served without a restart.
11. **Non-validation failures and load.** Disk full, USB removed, or an I/O error are reported as an import failure distinct from the three validation checks. The build streams records rather than loading 150 MB into memory, so lookups stay within 250 ms during import.

Once you've triaged these and approved the design, I'll draft the updated registry specs.