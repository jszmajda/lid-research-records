The registry design is now drafted around the local SQLite index in `docs/intent/registry/registry-design.md`. It needs your review and a few answers before I move on to the specs.

One thing to know about the choice: the two networked options were never really in contention. The high-level design forbids runtime network access and says kiosks have no network route, so I recorded the choice as a row in the design's decisions table and did not write a separate decision doc.

## What the design now says

- **Index:** one SQLite file holds one complete snapshot — a records table keyed by normalized serial number, plus a single row with the snapshot date and schema version. The active file is opened read-only and never written after activation.
- **Lookup:** a single point query on the primary key. Serial numbers are normalized the same way when loaded into the index as when queried.
- **Import:** three steps, and the active index is untouched until the last.
  1. Verify the signature and schema version.
  2. Build a new index file in a staging location in one transaction; the primary key rejects duplicate serials.
  3. Activate by atomic rename.
- **Failure:** any failure discards the staged file, keeps the previous index active, and reports which step failed. A staged file left by a crash or power loss is discarded at startup.
- **During import:** lookups keep running against the active index. The kiosk needs disk space for one staged index alongside the active one.

| Decision | Chosen | Alternative | Why |
|---|---|---|---|
| Lookup backend | Local SQLite index built on each kiosk | On-site HTTPS directory; managed search service | The no-network tenets rule out both alternatives. |
| Applying a new snapshot | Build a separate file, swap by rename | Replace records inside the active database in one transaction | A failed or interrupted import cannot damage the active file. |
| Uniqueness check | Primary-key constraint during the build | Separate pre-pass over the snapshot | One pass over a 150 MB snapshot instead of two. |

I also replaced the "lookup backend remains open" sentence in `docs/high-level-design.md` with one naming the SQLite index. The certificates docs and the registry specs are untouched, and nothing is committed.

## Questions for you

A blind reviewer probed the draft for gaps. These need your call:

1. **No usable snapshot.** `findBySerial` can only return Found or NotFound, both with a snapshot date. A kiosk that has never imported a snapshot, or whose index file is unreadable, has no honest answer. I recommend a third result, `Unavailable`, that blocks certificate export. That changes what the certificates component receives, so I need your go-ahead to touch that design.
2. **Duplicates after normalization.** Should `ab-1` and `AB-1` in one snapshot count as duplicates and fail the import? I recommend yes; otherwise one of them can never be looked up.
3. **Malformed records.** Should a record with a missing serial or unparsable date fail the whole import? I recommend yes, so a kiosk never serves a partly loaded registry.
4. **Older snapshots.** May a snapshot dated earlier than the active one be imported? I recommend refusing it, which protects against a stale USB stick but removes rollback to a previous snapshot.
5. **What the signature covers.** Does the manifest bind the record bytes, snapshot date and schema version, for example with a content hash? If so, I would check the hash while streaming records into the build and fail before activation.
6. **Kiosk operating system.** Windows will not rename over a file that is open, so the swap mechanism depends on what the kiosks run. Which OS is it?

Unless you object, I will also fold these into the design:

- Only one import runs at a time; a second is refused.
- An empty or whitespace-only serial returns NotFound.
- Import results are shown on screen to the person running the import, with no persistent log.
- Signing-key rotation is recorded as a deferred question; the key changes only with a kiosk software update.

Once you answer and approve the design, the next step is updating the registry specs.