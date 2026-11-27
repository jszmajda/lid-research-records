The registry design is drafted around the local SQLite index and is ready for your review; nothing is committed, and I have not touched the specs yet.

I recorded the backend choice as a row in the registry design's Decisions table. The HLD tenets (no runtime network access, signed USB snapshots as the only update channel) already rule out the HTTPS directory and the managed search service, so one line of rationale covers it.

## What changed

- **`docs/high-level-design.md`**: the Registry line now says lookup is served from a local embedded SQLite index private to the node, instead of "backend remains open".
- **`docs/intent/registry/registry-design.md`**: rewritten with the choice made. The interface and normalization rules are unchanged, and the certificates node is unaffected.

## The design as drafted

- **Index**: each snapshot is built into its own SQLite file, one row per record keyed by the normalized serial number. The snapshot date and schema version are stored in the same file, so a result can never pair one snapshot's records with another's date.
- **Import**: signature, schema version and serial uniqueness are all checked before the snapshot can replace the active index. The new index is built in a staging file on the same volume while lookups continue against the active one, then swapped in with a single atomic replacement.
- **Failure**: any failure discards the staging file, leaves the previous index active, and reports which step failed. This covers a bad signature, bad schema version, duplicates, a malformed record, removed media and a full disk. A staging file left by an interrupted import is discarded at next start.
- **Lookup**: an exact key match on the normalized serial against the active index, opened read-only. The snapshot date is returned on NotFound too.
- **Decisions table**: two rows, the backend choice and "fresh index file per snapshot, swapped atomically" over updating the active index in place.

## Gaps I need you to rule on

These are listed as deferred open questions in the design, and I did not pick answers:

1. **Duplicates after normalization**: if a snapshot contains `ab-100` and `AB-100`, is that a duplicate that rejects the import, or two distinct records? The index key is the normalized serial, so they collide, and I'd lean towards rejecting.
2. **No snapshot yet**: what does `findBySerial` return on a fresh kiosk before any import? Both result types carry a snapshot date, so this either needs a third outcome, which changes the interface the certificates node sees, or the kiosk refuses lookups until the first import.
3. **Older snapshot**: is a validly signed snapshot dated earlier than the active one accepted (allowing a deliberate rollback), rejected, or accepted with a warning?
4. **Previous index and corruption**: after a successful activation, is the previous index kept as a fallback or deleted? And if the active index is unreadable at start, does the kiosk fall back, or block lookups until a re-import?

Two smaller things to confirm:

5. A malformed record (bad JSON or a missing field) rejects the whole import, the same as a duplicate. The current design text didn't cover this case.
6. An import can run while technicians are doing lookups, rather than needing a maintenance mode.

Tell me your answers to 1–6 and any other changes to the design. Once you approve it, I'll move on to the EARS specs. REG-003 and REG-004 will need revisiting, with new lines for interrupted imports and whatever you decide above.