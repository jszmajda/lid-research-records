The registry LLD is updated around the SQLite choice (`docs/intent/registry/registry-design.md`); pre-flight found the HLD, specs, and tests coherent, so no other docs needed repair. Full Phase 2 output below.

---

---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. The kiosk has no network route during normal operation: the registry keeps its entire lookup index on local disk, and signed USB snapshots are its only update channel.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields — serial, description, calibration date, due date — and the result types are fixed. The lookup backend is an embedded SQLite index stored on the kiosk's local disk. Snapshot validation, index construction, and lookup all belong to this node; the SQLite database is private to the registry, and no other node reads registry storage directly.

## Snapshot Import

Verify the signature over the entire snapshot file using a bundled public key, reject schema versions outside the supported list (the list is bundled with the kiosk software), and stream records into the new index, rejecting duplicates. An import succeeds only as a whole:

1. Validation and index construction write to a temporary database file only. Each import recreates that file at a fixed build path, so a temp file orphaned by a crash or power loss is simply overwritten by the next import — it never blocks an import or affects lookups.
2. On success, the new snapshot becomes active through a single atomic rename onto the active database path.
3. On any failure — invalid signature, unsupported schema version, duplicate serial numbers, invalid record fields, exhausted disk space during the build, an interrupted build, or a failed final rename — the temporary file is discarded, the previous snapshot stays active, and an error carrying a machine-readable reason (signature, schema-version, duplicate-serial, invalid-record, resource) is reported.

Imports are serialized: only one import runs at a time; a request arriving while an import is running is rejected rather than queued.

### Index construction

- Records are streamed into the temporary database; snapshots reach 150 MB, and no full in-memory pass is required on the 4 GB kiosk.
- Duplicate serials are caught by a UNIQUE index on the normalized serial column: a constraint violation rejects the import.
- Each record stores its original serial, its normalized serial, the equipment description, the calibration date, and the due date (ISO 8601, `YYYY-MM-DD`). A record is invalid, and its import rejected, if its serial normalizes to an empty string or if any field is not valid UTF-8 without NUL bytes.
- The snapshot's schema version and snapshot date are stored in the database beside the records.

## Storage Layout

A single active database file at a fixed registry-owned path, plus one temporary build file during imports. The active file is never modified in place — it is only ever replaced by rename — so a reader always sees one complete snapshot. Lookups open the database read-only.

## Lookup Behavior

Normalize the input with the single shared normalization function — trim surrounding whitespace and uppercase ASCII letters. Normalization touches only ASCII letters `a`–`z` and leading/trailing ASCII whitespace; every other character — digits, punctuation, non-ASCII letters, internal whitespace — is left exactly as entered, so serial-number punctuation remains significant. The same function produces the stored normalized serial at import time, so normalization cannot drift between index and query. Exact-match the normalized input against the indexed normalized serial column.

Lookups open a fresh read-only connection per call: a newly activated snapshot is picked up on the next lookup, and a lookup in flight during activation completes against the previous snapshot. A match returns `Found(record, snapshotDate)`; otherwise `NotFound(snapshotDate)`. The 90,000-row unique index resolves comfortably inside the 250 ms kiosk budget.

Until a first snapshot has been activated (fresh install or wiped disk), or when the active database cannot be opened or read, `findBySerial` reports the registry as unavailable — an operational fault, distinct from `NotFound` (see Open Questions).

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | HLD tenets require lookups to complete on-kiosk with no runtime network access, which rules out both network-dependent options; the managed service would also add recurring cost, credentials, and external connectivity to a self-contained component. SQLite gives predictable lookups with no service to run; each kiosk rebuilds its own index when a snapshot arrives, and that cost stays inside this node where validation already lives. |
| Snapshot activation | Build to a temporary database, activate by atomic rename | In-place rewrite of the active database; pointer-table switching between two database files | Rename makes whole-snapshot activation and failure preservation structural — no window of partial visibility and no extra switch state to keep consistent. |
| Lookup connections | Open a read-only connection per lookup | One cached long-lived connection | Per-lookup open costs a fraction of the 250 ms budget and makes activation visible on the next lookup without stale-handle bookkeeping. |

## Open Questions & Future Decisions

### Resolved

1. Lookup backend: local embedded SQLite index; network-dependent alternatives conflict with the HLD's offline tenets (see Decisions & Alternatives).

### Deferred

1. **No-active-snapshot representation.** The draft treats it as an operational fault on `findBySerial`, keeping `Found`/`NotFound` unchanged. If the certificates node should distinguish it explicitly (a third result variant), that crosses into its segment and needs a coordinated change.
2. **Empty lookup input.** When the technician's input normalizes to an empty string, whether `findBySerial` returns `NotFound(snapshotDate)` or an input error.
3. **Date validation.** Whether a record with a malformed date, or a due date earlier than its calibration date, rejects the import or imports as-is.
4. **Zero-record snapshot.** Whether a validly signed snapshot containing no records may be activated (making every lookup `NotFound`), or is rejected.
5. **Re-import policy.** Whether a snapshot older than the active one may be activated (e.g., the inventory team re-issues a corrected earlier snapshot).
6. **Corrupt active database.** On a disk fault, whether the registry reports the same operational fault and waits for re-import, or keeps the last snapshot file around for automatic rebuild.
7. **Post-import tampering.** Whether the threat model includes local modification of the database file after import; if so, lookups need an integrity check.
8. **Schema-version layout.** Whether a supported schema version can imply a different record layout or parsing rules, or whether all supported versions share one layout.
9. **Import progress.** A 150 MB build takes noticeable time; whether the import path owes the technician progress feedback is an application-level question.

## References

- docs/high-level-design.md
- docs/intent/certificates/certificates-design.md (consumer of `findBySerial`)

---

**Edge-case probe report.** A fresh-reader probe found gaps; I folded the mechanical ones into the draft above (crash-orphaned temp files, concurrent imports, failed rename, transient read faults, UTF-8/NUL validity, exact normalization scope, machine-readable error reasons). The nine Deferred items are what I could not settle for you — please triage: for each, tell me to resolve it in the LLD (with your call, or mine if you defer to it) or leave it deferred.

Item 1 is the one I'd resolve first — it's the only one that crosses into the certificates segment (a third result variant would touch CERT-002's territory), and it shapes the EARS updates in the next phase. My draft keeps `Found`/`NotFound` unchanged and reports no-snapshot as an operational fault, but it's your call.

On your approval of this LLD (plus any numbered feedback), I'll proceed to Phase 3: the corresponding EARS updates to `registry-specs.md`.