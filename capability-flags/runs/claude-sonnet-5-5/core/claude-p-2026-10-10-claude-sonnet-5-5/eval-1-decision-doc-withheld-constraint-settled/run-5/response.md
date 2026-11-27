I've picked up the local SQLite choice and updated the registry design at `docs/intent/registry/registry-design.md`. This is the Phase 2 (LLD) stop, so I haven't touched specs, tests, or code.

## What changed in the registry LLD

- **Architecture:** lookups are served from a local embedded SQLite index on the kiosk. Each kiosk builds and validates its own index when a snapshot arrives, and nothing outside the registry reads it. The "backend not selected" language is gone.
- **Snapshot Import:** the new index is built in a separate file from the active one, so lookups never see partial records. It is activated only after the signature, schema, uniqueness, and index-build checks all pass. A failure leaves the previous snapshot and index active.
- **Lookup Behavior:** the query runs against the active index by normalized serial. The returned snapshot date is the date of the snapshot that index was built from.
- **Decisions & Alternatives:** I added two rows.
  - *Lookup backend:* SQLite chosen over the HTTPS directory and the managed search service.
  - *Index build location:* the index is built at import time, not lazily at first lookup.

## Why no decision doc

Two of the three options were already ruled out by the HLD tenets ("no runtime network access", "no network route during normal operation"). An inherited constraint settles the choice, so a Decisions row is enough. Tell me if you'd still like a standalone decision doc.

## Edge-case probe: gaps in this LLD

I recorded the first three as Deferred in the LLD. Please triage which to resolve now and which to leave open.

1. **Lookup during activation.** What does a `findBySerial` call see if it overlaps the switch to a new index? Old index, new index, or either? Whichever it is, the result should carry one consistent snapshot date.
2. **Missing or corrupt active index at startup.** Is the result an error, a fallback to the previous index, or a re-build from the retained snapshot?
3. **Retention.** Do we keep the superseded index and snapshot after activation (for rollback), and where do the index files live?
4. **Index build interrupted.** If power is lost mid-build, is the partial file discarded on the next start, and is the active snapshot untouched?
5. **First-ever import.** With no active snapshot, what does `findBySerial` return? NotFound needs a snapshot date, and there isn't one.
6. **Same or older snapshot date.** Is re-importing the same date, or an older snapshot, allowed? The HLD doesn't say.
7. **Disk space.** A 150 MB snapshot plus a second index file needs headroom. Should import check free space first and report a clear error?
8. **Serial normalization vs. duplicates.** Uniqueness is checked on serials, but lookup normalizes case and whitespace. Are `ab-1` and `AB-1` duplicates at import? If not, one record becomes unreachable.
9. **Lookup latency budget.** The 250 ms goal assumes the index is built ahead of time. Do you want a spec for it, or leave it as an HLD goal?

Item 8 looks like a genuine spec fork, and I'd want your answer before specs are drafted.

## Please check yourself

Models configured like me aren't known to be reliable at catching a design mechanism that works against an HLD tenet or goal when the two share no wording. Please check that the SQLite and rebuild-on-kiosk mechanism holds against the HLD goals (250 ms lookup, 150 MB snapshots, 4 GB RAM) and tenets (a failed import must leave the last valid snapshot available).

Once you've triaged the gaps, I'll move on to Phase 3 and update the REG specs.