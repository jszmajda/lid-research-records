## Phase 1 — HLD check

The HLD is unchanged and still coherent. Selecting a lookup backend is private to the registry node — the HLD already leaves "its private lookup backend open" and fixes the certificate-facing interface regardless of backend, so no architectural change and no HLD edit.

One thing worth naming: the HLD tenet *"All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted"* is what eliminated the on-site HTTPS directory and managed search service, not just preference. That reasoning is recorded as the backend row in the LLD below.

## Phase 2 — Registry LLD

I updated `docs/intent/registry/registry-design.md`. Full current text:

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Snapshots arrive on approved USB media; a kiosk has no network route during normal operation.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, backend preparation, and lookup all belong to this node. The lookup backend is a local embedded SQLite index. Its storage layout, build path, and query path are private to this node; the certificate interface is unaffected.

### Storage

The active index is a single SQLite database file on local kiosk storage.

- A metadata table records the snapshot date and schema version the database was built from, so a lookup reports the date of the snapshot that actually produced its result.
- A records table holds the equipment description, calibration date, and due date, keyed by the normalized serial number and indexed for lookup.

### Snapshot Import

Import runs in four stages:

1. Verify — check the manifest signature against the bundled public key.
2. Validate — reject an unsupported schema version; parse the records and reject duplicate serial numbers.
3. Build — write a new SQLite database at a temporary path beside the active one.
4. Activate — after the build completes, atomically replace the active database file.

A failure in any stage leaves the previous database active and reports a useful error. Because activation is a single atomic replace, a lookup running concurrently with an import continues to read the previous database until the new one is whole; no lookup can observe a partially built snapshot. A crash mid-build leaves only a temporary file.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Query the normalized-serial index for the record. Return `Found(record, snapshotDate)` on a match and `NotFound(snapshotDate)` otherwise; the snapshot date is read from the active database's metadata and is returned in both cases.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | The tenet that all lookup completes from files on the kiosk, with no runtime network access, eliminates both network-backed options. SQLite is embedded, needs no service to run, and indexes 90,000 records within the 4 GB / 250 ms budget. Accepts that each kiosk validates and rebuilds its own index when a snapshot arrives. |
| Activation model | Build a new database, then atomically replace the active file | Swap tables in place inside one long-lived database | Atomic replace keeps a failed or interrupted import from exposing partial records and keeps concurrent lookups on the previous snapshot without in-database locking. Accepts temporary double storage during import. |
| Snapshot date source | Metadata row inside the active database | Sidecar metadata file read at lookup | Ties the reported date to the exact database that produced the record; no second file to keep in sync across activation. |

## Open Questions & Future Decisions

### Resolved

1. ✅ Lookup backend: local embedded SQLite index (see Decisions & Alternatives).

### Deferred

1. Whether duplicate-serial validation applies to the raw serial or the normalized serial.
2. Startup handling of a stale temporary build file left by a crash.
3. Whether an import prechecks free disk space for the second database.

## References

- `docs/intent/registry/registry-specs.md`
```

## Phase 2 edge-case probe

A blind reader probed the LLD for its own internal gaps. Findings, most load-bearing first:

**Needs your decision (genuine ambiguity, not derivable from the LLD):**
1. **Normalization rule is under-specified.** "Surrounding whitespace" could mean trim-only or strip-all-whitespace; `" A 12"` resolves to `"A 12"` or `"A12"` depending on reading, and a record stored under one is unreachable under the other. Non-ASCII letters and empty-after-normalization are also unaddressed.
2. **Snapshot staleness on activation.** Nothing says whether an older snapshot may replace a newer one, or whether re-importing the same snapshot is a no-op. Both "newest-wins" and "last-imported-wins" are consistent with the current text.

**Internal gaps I'd fold into the LLD (tell me which):**
3. **No-snapshot initial state** — `findBySerial` before any import (or with a missing/corrupt active DB) has no value for the mandatory `snapshotDate` in either result arm.
4. **Duplicate check vs. normalized key** — records are keyed by normalized serial, but duplicate validation isn't qualified; raw-only comparison would let case/whitespace variants collide on the primary key. (Currently deferred item 1.)
5. **Signature coverage unstated** — what the signature is computed over (records + manifest, or manifest alone) is not defined; manifest-only would leave the records unauthenticated.
6. **Atomic replace details** — SQLite journal/WAL sidecar files and OS rename semantics are unstated; a WAL sidecar or a Windows-style locked-file replace breaks the "concurrent lookups keep reading the previous database" guarantee.
7. **Returned record's serial** — raw or normalized value in the `Found` record (the certificate prints it).
8. **Field/parse validation** — missing fields, null/malformed dates, malformed NDJSON lines, record-count mismatch with the manifest.
9. **Concurrent imports** — serialization and temp-file naming if two imports race.
10. **Import error contract** — a defined error shape per stage, beyond "reports a useful error."

The registry's four existing specs (`REG-001`–`REG-004`) already cover normalization, snapshot-date-in-result, rejection/retention, and all-or-nothing activation, so Phase 3 looks like a consistency pass rather than new behavior — with the caveat that finding #1 (normalization) and #2 (staleness) would each narrow or add a spec line.

**Stop for your review.** Two questions:

1. Which of the internal gaps (3–10) should I settle in the LLD now, and which stay deferred?
2. For the two genuine ambiguities: what normalization rule do you want (trim-only vs. strip-all-whitespace; non-ASCII handling), and may an older snapshot replace a newer active one?

Once you rule, I'll fold the decisions in and move to the EARS pass.