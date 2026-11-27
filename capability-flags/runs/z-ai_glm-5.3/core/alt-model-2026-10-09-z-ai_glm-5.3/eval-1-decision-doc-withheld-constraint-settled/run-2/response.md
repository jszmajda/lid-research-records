The probe surfaced 10 gaps. Per the skill, Phase 2 ends at a mandatory stop — here is the phase output and the gap list for your triage.

Your choice is recorded. Two notes on how I recorded it:

- The on-site HTTPS directory and managed search service both conflicted with the HLD's tenets (no runtime network access, no network route), so the Decisions row records them as eliminated by that inherited constraint — the SQLite index was also the only tenet-compatible option.
- The HLD line "Its private lookup backend remains open" was now false, so I updated it to name the SQLite index. Everything else stayed inside the registry segment; the certificate-facing interface is unchanged.

**Revised registry LLD** (`docs/intent/registry/registry-design.md`):

> # Registry Design
>
> ## Context
>
> Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.
>
> ## Architecture
>
> Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.
>
> Snapshot validation, index preparation, and lookup all belong to this node. The lookup backend is an embedded SQLite index stored on the kiosk: one index file per snapshot, built locally when a snapshot is imported and read locally at lookup time. No runtime network access is involved in either path.
>
> ## Snapshot Import
>
> Verify the snapshot signature with a bundled public key and reject unsupported schema versions before any record is read. Then stream the newline-delimited JSON records into a new SQLite index built in a temporary file in the same directory as the active index, so activation is a single atomic rename on one filesystem. The normalized serial number (surrounding whitespace trimmed, ASCII letters uppercased) is the unique lookup key; a duplicate serial number fails the import. Records are parsed and inserted row by row, so a snapshot is never held in memory whole — snapshots up to 150 MB import on a 4 GB kiosk without paging pressure. The index carries a metadata table holding the snapshot date, schema version, and record count.
>
> An import failure at any stage — signature, schema version, record parsing, duplicate serials, or disk error — discards the temporary file and leaves the previous snapshot active and available to lookups. Activation renames the fully built index over the active index; a lookup already in flight completes against the snapshot it opened. The rename replaces the previous index, so the data directory never accumulates snapshot files, and the last valid snapshot stays available because only a fully validated index can replace it.
>
> ## Lookup Behavior
>
> Normalize surrounding whitespace and uppercase ASCII letters before lookup; serial-number punctuation remains significant. Lookups open the active index read-only and resolve the normalized serial through a prepared statement against the unique key; the index keeps resolution well inside the 250 ms goal at 90,000 records. Every result — Found or NotFound — carries the active snapshot's date from the index metadata table.
>
> ## Storage
>
> Index files live in a kiosk-local data directory owned by this node. During import the directory holds the active index plus the temporary one being built (roughly twice the index size transiently); at rest it holds the single active index. Registry storage is private to this node: no other component reads it directly.
>
> ## Decisions & Alternatives
>
> | Decision | Chosen | Alternatives Considered | Rationale |
> |---|---|---|---|
> | Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | The HLD forbids runtime network access and kiosks have no network route, which eliminates both networked options regardless of their maintenance advantages. SQLite keeps lookups local and predictable, well inside the 250 ms goal, with no service to operate. The cost — each kiosk validates and rebuilds its own index when a snapshot arrives — is bounded inside this node, and the certificate-facing interface is unchanged either way. |
> | Index activation | Build to a temporary file, activate by atomic rename | In-place update of a single database | An in-place update would expose a partially imported database to concurrent lookups and require lock handling; the rename makes activation indivisible and keeps the previous snapshot valid until the new index is fully built and validated. |
>
> ## Open Questions & Future Decisions
>
> ### Deferred
>
> 1. Exact on-disk schema and column types for the record table — settle at implementation.

**Edge-case probe — gaps to triage.** A blind reader given only the LLD surfaced these. Which should I fix in the LLD now, and which do you want deferred as open questions? My read: gaps 1, 2, and 8 force real interface/behavior decisions; the rest could plausibly be deferred or settled at implementation.

1. **No active snapshot yet (first boot):** `Found/NotFound` both require a `snapshotDate` — there is no result state for "no snapshot has ever been imported."
2. **Corrupt/unreadable active index at lookup time:** no stated outcome or error shape, only import failures are covered.
3. **Concurrent imports:** no mutual-exclusion or last-wins rule between two imports racing to activate.
4. **Power loss mid-import:** an orphaned temp file survives a crash — who cleans it up, and when?
5. **Snapshot-date ordering:** may a validly signed *older* snapshot replace a newer active one? Is re-import of the same snapshot a no-op or full rebuild?
6. **Duplicate detection scope:** raw duplicates only, or also normalization collisions (`" ab-1 "` vs `"AB-1"`)? Is the metadata record count cross-checked against the file or trusted?
7. **Malformed record bodies:** do missing fields, empty lines, or a trailing newline count as import-failing parse errors?
8. **Connection lifecycle and SQLite sidecars:** per-call open vs. persistent connection (is open time inside the 250 ms?), and what happens to WAL/journal sidecar files across the atomic rename?
9. **Degenerate lookup inputs:** all-whitespace, non-ASCII, or very long serials — `NotFound(snapshotDate)`, or a distinct client-error case the interface doesn't express?
10. **What the signature covers:** whole file, per-record manifest, or manifest over records — and does it bind snapshot date and record count? Also: one full verification pass before insertion, or interleaved?

Please give numbered feedback on the LLD and triage the gaps (fix in LLD / defer as open question), and I'll fold in your rulings before drafting the EARS updates in Phase 3.