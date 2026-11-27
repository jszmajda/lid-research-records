Coherence pre-flight: no code or tests exist yet (design-stage repo), the registry LLD traces to the HLD, and the certificates interface is unchanged by this choice, so the change is confined to the registry segment — no cross-segment pause needed. One stale line in the HLD ("Its private lookup backend remains open") no longer reads as a fresh author would write it, so I removed it.

One judgment to surface before you read the draft: two of the three options you weighed — the on-site HTTPS directory and the managed search service — require runtime network access at lookup time, which the HLD tenet "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted" rules out. So the backend decision is effectively settled by that inherited constraint, not by a live tradeoff. That is why I recorded it as a Decisions & Alternatives row rather than opening a decision doc — per the skill, a choice an inherited constraint settles does not earn one. If you'd rather capture the fuller deliberation anyway, say so and I'll write one.

Registry LLD, revised:

---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Kiosks have no network route, so snapshots arrive on USB media and every lookup must complete from files on the kiosk.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed; the certificates node uses only this interface.

The lookup backend is an embedded SQLite index on the kiosk disk. A snapshot import validates the snapshot, builds a complete SQLite index for it in a staging file, and activates the new index by an atomic rename over the active one. Lookup is a single indexed query against the active database. SQLite is selected because it needs no service and keeps every lookup on-kiosk, which no network-backed backend can do here.

### On-disk layout

- `registry/active.db` — the active SQLite index; the only file a lookup reads.
- `registry/staging.db` — the index under construction during an import.
- `registry/import.lock` — guards against concurrent imports.

### Index schema

- `records(serial_key TEXT PRIMARY KEY, serial TEXT, calibration_date TEXT, due_date TEXT, description TEXT)`
- `meta(key TEXT PRIMARY KEY, value TEXT)` — holds `snapshot_date` and `schema_version`.

`serial_key` is the normalized serial number (surrounding whitespace trimmed, ASCII letters uppercased); `serial` preserves the serial number as it appears in the snapshot. Punctuation is not altered.

## Snapshot Import

1. Verify the manifest signature with the bundled public key, reject unsupported schema versions, and confirm record serial numbers are unique under normalization (two serial numbers that differ only by surrounding whitespace or ASCII letter case are a duplicate).
2. Build the snapshot's index into `staging.db`: insert every record and write the snapshot date and schema version into `meta`.
3. Run SQLite's integrity check on the staged database and close it cleanly.
4. Atomically replace `active.db` with `staging.db` by a rename within the same directory, then remove the staging file.

A failure at any step leaves `active.db` untouched and reports a useful error. A lookup never observes records from a snapshot that has not completed import; it sees either the entire previous index or the entire new one. A staging file left by an interrupted import is discarded before the next import begins.

## Lookup Behavior

Form `serial_key` by trimming surrounding whitespace and uppercasing ASCII letters; punctuation remains significant. Query `records` by `serial_key`. On a match, return the record together with the active snapshot date read from `meta`; on no match, return `NotFound` with the active snapshot date. Reads open the active database read-only, so a lookup cannot mutate the index.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Embedded local SQLite index | On-site HTTPS directory; managed search service | The HLD tenet requires every serial-number lookup to complete from files on the kiosk with no runtime network access, which excludes both network backends. SQLite needs no service, keeps reads local, and indexes 90,000 records well within the 250 ms budget. Accepted cost: each kiosk builds its own index when a snapshot arrives. |
| Snapshot activation | Build to `staging.db`, atomic rename over `active.db` | Update `active.db` in place; keep versioned index slots and swap a pointer | A same-directory rename is atomic, so a concurrent lookup sees the whole old index or the whole new index and no rollback path is needed. In-place updates risk exposing a half-written index; a versioned-slot pointer adds state without buying a property the rename lacks. |

## Open Questions & Future Decisions

### Deferred

1. Whether to bundle the SQLite library with the kiosk installation or rely on a platform-provided one.

## References

- High-level design: `docs/high-level-design.md`
---

LLD-level edge-case probe (delegated to an unbiased reader, grouped). Please triage which to settle in the LLD now vs. defer:

Import / validation
1. Required order of signature → schema-version → uniqueness checks, and short-circuiting on first failure.
2. Which schema versions are supported, and whether that set is fixed or derived from the index schema.
3. What the signature covers, and what to do when the manifest parses but doesn't match the payload.
4. Error shape per import-failure step, and whether it distinguishes the failing step.
5. Duplicate normalized serials: reject outright, or dedupe (and which record wins).
6. Whether uniqueness is checked within the snapshot only or also against `active.db`.
7. Serial field missing/null/empty/normalizes-to-empty; date fields missing or malformed; date-format validation.
8. Whether "whitespace" and case normalization is ASCII-only or Unicode, and whether internal whitespace is trimmed (affects duplicate detection).
9. Handling of blank lines, trailing newlines, BOM, or malformed JSON lines in the NDJSON.
10. Whether a zero-record snapshot is valid.

Index build / activation
11. Whether `staging.db` is removed on non-interrupted failure and whether stale staging is cleared before or after acquiring the lock.
12. fsync of staging and of the directory before rename; rename interrupted mid-operation.
13. First import when `active.db` does not yet exist.
14. Whether rename atomicity is assumed on every target filesystem, and behavior if not.
15. Whether the integrity check is mandatory before rename and its error shape; schema-version match between staged and active.

Lookup
16. **What `findBySerial` returns before any snapshot has ever been imported** — the fixed result carries a `snapshotDate`, so there is no defined value on a fresh kiosk.
17. Missing/unreadable/corrupt `active.db`, or read-only open failure.
18. `meta` with no `snapshot_date`, and where `NotFound`'s snapshot date comes from then.
19. Serial argument null/empty/whitespace-only; non-ASCII case-folding interaction.
20. Whether a lookup holds `active.db` open across the activation rename, and whether that is explicitly safe.

Storage / concurrency
21. Lock acquisition/release, staleness detection after crash, removal on failure, second-import behavior.
22. Lookup during the activation rename; serialized vs. independent connections; single-writer enforcement.

Failure recovery
23. State after a crash between rename and staging removal; leftover lock auto-clear rule; disk-full during build or rename.

The one I'd flag as a genuine spec fork rather than a detail is #16: `Found`/`NotFound` both require a `snapshotDate`, so before the first successful import there is no defined result, and the certificates node depends on this interface. That needs your call, not mine.

May I proceed to draft the EARS specs (Phase 3) on this LLD — and if so, how would you like the gaps triaged: pick the ones to fold in now, or defer them to Open Questions and let me carry the rest into the Phase 3 coverage pass?