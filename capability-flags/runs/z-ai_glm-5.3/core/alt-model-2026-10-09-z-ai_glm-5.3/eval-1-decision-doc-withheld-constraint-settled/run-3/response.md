**Registry design completed — Phase 2 stop for your review.**

Pre-flight: HLD, registry LLD, and specs were coherent; the only staleness was the HLD line "Its private lookup backend remains open," now removed (the backend choice is registry-internal, so it lives in the registry LLD, not the HLD). Working tree was clean.

On recording: the HLD's offline tenets (kiosk-local lookup, no runtime network, USB as the only update channel) already rule out the HTTPS and managed-service options, so I recorded the selection as a Decisions & Alternatives row rather than a decision doc.

Full updated LLD (`docs/intent/registry/registry-design.md`):

> # Registry Design
>
> ## Context
>
> Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Kiosks have no network route; each kiosk validates a snapshot and rebuilds its own local index when one arrives.
>
> ## Architecture
>
> Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed. The certificates node uses only this interface.
>
> Snapshot validation, index building, and lookup all belong to this node. The lookup backend is an embedded SQLite index stored in the registry's private kiosk-local data directory; no other component reads it.
>
> ## Storage and Index Layout
>
> The registry keeps at most two SQLite database files in its private data directory:
>
> - `registry.db` — the active index. All lookups read this path.
> - `registry.staging.db` — the build target during an import; deleted on completion or failure.
>
> The active index holds a `records` table with the record fields plus a `serial_key` column — the normalized serial number, UNIQUE and indexed — and a `meta` table with the snapshot schema version, snapshot date, and record count. The database file format is private to the registry and versioned internally, independent of the snapshot schema version.
>
> ## Snapshot Import
>
> 1. Verify the signature manifest with the bundled public key.
> 2. Reject unsupported snapshot schema versions.
> 3. Stream records into `registry.staging.db`, enforcing serial-number presence and uniqueness via the UNIQUE `serial_key` constraint as records load.
> 4. On success, activate atomically: rename `registry.staging.db` over `registry.db` on the same filesystem, so the active path never names a partially built index.
> 5. On any failure — invalid signature, unsupported schema version, duplicate serial numbers, a malformed record, or a staging error such as a full disk — delete the staging file and report a useful error.
>
> An import never mutates the active index, so a failed import leaves the last valid snapshot available, and lookups continue against the previous index for the whole rebuild.
>
> ## Lookup Behavior
>
> Normalize surrounding whitespace and uppercase ASCII letters before lookup; serial-number punctuation remains significant, and non-ASCII characters match exactly as stored. The normalized input is matched against `serial_key` in a single point query on the UNIQUE index, over a short-lived read-only connection opened on the active path — an activation is therefore picked up on the next lookup, and no pooled connection outlives the renamed file. The query path touches no network resource. Return the snapshot date from `meta` even when no matching record exists.
>
> ## Decisions & Alternatives
>
> | Decision | Chosen | Alternatives Considered | Rationale |
> |---|---|---|---|
> | Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | The HLD's offline tenets — lookups complete from kiosk-local files, no runtime network, USB snapshots as the only update channel — eliminate network-dependent backends regardless of their maintenance advantages. SQLite gives atomic activation and an indexed point query that meets the 250 ms lookup goal with no service to run, at the cost of each kiosk rebuilding its index when a snapshot arrives. The `findBySerial` interface is unchanged for certificates under all three options. |

**LLD edge-case probe — gaps for your triage** (delegated to a fresh reader; fix in the LLD, or defer as open questions — your call):

1. **No active index at startup.** `findBySerial` on a kiosk before any import (or with a corrupt/missing `registry.db`): `Found`/`NotFound` both carry a `snapshotDate` — error out, return `NotFound(null)`, or a third state? Note this touches the certificates contract, so resolving it may cascade there.
2. **Concurrent imports.** A second snapshot arrives while one is still building into staging — wait, reject, or replace the staging file?
3. **Crash mid-import.** Power loss leaves a stale `registry.staging.db` — overwrite on next import, garbage-collect at startup, or attempt resume?
4. **Import error shape.** "Report a useful error" is unspecified — is the error type distinguishable by cause (bad signature vs. duplicate vs. disk full), and what fields does it carry?
5. **Older snapshots.** A valid signed snapshot whose date is older than the active index — always accept, reject as stale, or treat as supported rollback?
6. **Write-side normalization.** Is `serial_key` computed with the exact same normalization rule at load time as at lookup, making raw-distinct but normalized-identical serials a load-time duplicate?
7. **`record_count` invariant.** What is `meta.record_count` checked against, and what does a mismatch mean for import success or lookup?

Give me numbered feedback on the LLD and triage the seven gaps (e.g., "fix 1 and 5 in the LLD, defer the rest"), and I'll fold in the resolutions before drafting the EARS updates.