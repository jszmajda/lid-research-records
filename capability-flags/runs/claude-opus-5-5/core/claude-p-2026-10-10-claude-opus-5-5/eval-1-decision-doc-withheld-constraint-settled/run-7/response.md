The registry design is finished around the local SQLite index and is ready for your review. I've stopped here before touching `registry-specs.md`; nothing is committed.

## What changed

- **`docs/high-level-design.md`**: one line. The Registry entry no longer says the backend "remains open"; it now says lookup is "served from a local embedded SQLite index that is private to this node."
- **`docs/intent/registry/registry-design.md`**: rewritten, shown in full below.
- **Certificates**: untouched. The `findBySerial` interface and result types are unchanged.

I recorded the backend choice as a row in the Decisions table rather than offering a standalone decision doc. Once written down, the HLD's own tenets (no runtime network access, no network route) rule out both networked options, so one line of rationale settles it.

## Registry design as drafted

> ## Context
>
> Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.
>
> ## Architecture
>
> Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of how lookup is implemented. The certificates node uses only this interface.
>
> Snapshot validation, index preparation, and lookup all belong to this node. Lookups are served from a local embedded SQLite index: a single database file on kiosk storage, built on the kiosk from each signed snapshot and opened read-only for lookup. The file, its schema, and its queries are private to this node.
>
> ## Index
>
> Each active snapshot is represented by exactly one index file. It holds:
>
> - one row per registry record, keyed by serial number, carrying the equipment description, calibration date, and due date;
> - the snapshot date and schema version of the snapshot the index was built from.
>
> The snapshot date returned by `findBySerial` is read from the same index file as the record, so a result never pairs a record from one snapshot with the date of another.
>
> The index is derived data. The kiosk never edits it in place; its contents change only when a snapshot import replaces the whole file.
>
> ## Snapshot Import
>
> Verify the signature using a bundled public key and reject unsupported schema versions before indexing any records. Then build a new index in a staging file on kiosk storage, on the same volume as the active index, reading the snapshot as a stream so that a 150 MB snapshot does not have to fit in memory. Serial-number uniqueness is enforced by the index key while the staging file is built; a duplicate fails the import.
>
> Activate the new snapshot only after every record has been indexed and all validation has succeeded. Activation replaces the active index file with the staging file in one atomic file-system step, so a lookup sees either all of the previous snapshot or all of the new one. The active index file is not touched before that step: an import failure at any earlier point discards the staging file, leaves the previous snapshot active, and reports a useful error.
>
> ## Lookup Behavior
>
> Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Look the normalized serial up by exact match on the index key; there is no prefix, partial, or fuzzy matching. Return the snapshot date even when no matching record exists.
>
> An exact-match keyed lookup over 90,000 rows in a local file stays within the 250 ms goal without a warm-up step or a resident service.
>
> ## Decisions & Alternatives
>
> | Decision | Chosen | Alternatives Considered | Rationale |
> |---|---|---|---|
> | Lookup backend | Local embedded SQLite index built on each kiosk | On-site HTTPS directory; managed search service | Kiosks have no network route during normal operation and lookup must complete using files on the kiosk, which rules out both networked alternatives. An embedded index gives predictable lookup time with no service to run; the cost is that every kiosk validates and rebuilds its own index when a snapshot arrives. |
> | Index update | Build a complete new index file in staging, then replace the active file atomically | Update the active index in place inside a transaction | A whole-file replacement leaves the active index untouched until the new one is fully validated, so an interrupted or failed import cannot damage the last valid snapshot. |

Two things in there are my additions, not something you chose: the staging-file-then-atomic-replace import, and exact-match-only lookup. Push back on either if it isn't what you meant.

## Gaps for you to triage

I ran an edge-case probe with a cold reader. It read the previous version of the design, because my first write was blocked; I re-checked each finding against the text above and these still stand. For each, tell me: fix in the design now, defer as an open question, or not a concern.

1. **Duplicates and normalization.** Is uniqueness checked on serials as signed or after normalization? As drafted, `ab-1` and `AB-1` could both pass import, and a lowercase serial in a snapshot might be unreachable. My lean is to normalize at import and key on the normalized form, so such a pair fails the import.
2. **No snapshot yet.** On first boot or wiped storage there is no snapshot date to return, and the result type has no variant for that. Resolving it could touch the interface certificates depend on, so I won't decide it alone.
3. **Lookup failure.** A corrupt or unreadable index file has no result shape. Returning `NotFound` would be indistinguishable from "serial not in registry".
4. **Older or same-date snapshot.** A validly signed but older snapshot would currently be accepted, which rolls the kiosk back to stale calibration data. Options are accept anything valid, reject older, or warn and confirm.
5. **Record-level validation.** A malformed JSON line, a missing field, or a blank serial is not covered. Does one bad record reject the whole snapshot, or is it skipped?
6. **Import error reporting.** "A useful error" has no shape: distinguishable causes, first offence or all of them, shown to the technician or logged.
7. **Interrupted import.** Power loss mid-build leaves a staging file behind; nothing says startup clears it.
8. **Lookup during activation.** Whether lookups already in flight finish against the old snapshot or are blocked is unstated.
9. **Signature scope and key rotation.** Does the signature cover the snapshot date and schema version, or only the records? With one bundled key and USB as the only channel, how is the key replaced?
10. **Odd inputs.** Empty or whitespace-only serials, internal whitespace, and non-ASCII characters have no defined result.

Once you've ruled on the design and these gaps, the next step is the EARS update in `registry-specs.md`.