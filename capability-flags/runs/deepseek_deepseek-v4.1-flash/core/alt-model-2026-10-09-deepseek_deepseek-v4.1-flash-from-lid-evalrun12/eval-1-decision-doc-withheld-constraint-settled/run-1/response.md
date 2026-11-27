Registry design updated for the local SQLite backend. Phase 2 is complete; stopping here for your review before EARS (Phase 3).

**Coherence pre-flight** — HLD, registry LLD, and registry specs were mutually coherent except that the HLD/LLD narrated the backend as still *open*. I replaced that with current intent (below). Certificates needs no change: its interface and behavior are untouched by this selection.

**Changes made**
- `docs/intent/registry/registry-design.md` — rewrote around the chosen backend, removed the "not selected yet" prose.
- `docs/high-level-design.md` — the Registry architecture bullet now reads "…Owns snapshot validation and lookup through a local embedded index private to this component" instead of "Its private lookup backend remains open."

**Registry LLD, as it now stands**
- *Architecture* — `findBySerial(serial)` → `Found(record, snapshotDate)` / `NotFound(snapshotDate)`; fixed fields and result types. Backend is a local embedded SQLite index; no certificate or interface impact. (Mermaid import/lookup diagram added.)
- *Snapshot Import* — four ordered stages: verify signature + reject unsupported `schemaVersion`; validate non-empty, normalized-unique serials; build new content; activate atomically. Any failure rejects the import and keeps the previous snapshot active with a useful error.
- *Local SQLite Index* — one SQLite file in a kiosk-local directory. Schema: `meta(key,value)` (active snapshot date, schema version) and `equipment(serial PK, calibration_date, due_date, description)`. Serials stored trimmed + ASCII-uppercased (punctuation preserved). WAL mode; activation replaces `equipment` rows and the `meta` date in one transaction, so readers see the old generation until commit and the new one all-at-once; crash/rollback leaves the prior snapshot active.
- *Lookup Behavior* — normalize the query the same way, exact PK probe, return record + active snapshot date, or NotFound + date. Read-only; does not block an import.
- *Performance* — log-time PK probe on 90k rows, well under 250 ms on 4 GB; build bounded by the 150 MB snapshot.
- *Failure & Recovery* — no active snapshot → NotFound with empty date + a "no snapshot loaded" report; missing/integrity-failed index → reported fault, not a silent result.
- *Decisions & Alternatives* — rows for (1) backend = local SQLite vs. on-site HTTPS directory / managed search service, rationale turns on the HLD offline tenet; (2) activation = single WAL transaction vs. separate-file swap; (3) normalized serial as PK vs. normalize-at-query.
- *Open Questions* — resolved: backend selection. Deferred: index-directory provisioning; whether to expose index health outside `findBySerial`.

**Decision record:** recorded as a Decisions & Alternatives row, not a decision doc — the offline tenet is an inherited constraint that eliminates the network options and the choice affects only this node, so it does not clear the "stays live for a cold reader" bar.

**LLD-level edge-case probe** (delegated to a fresh subagent; findings not applied — yours to triage). Ranked most-consequential first:

1. How does the registry *report* a fault when the result type is fixed to `Found`/`NotFound`? No channel is defined (throws a third variant? out-of-band?).
2. Does stage 3 "Build" write into the live `equipment` table? If so, the "no stage observable before success" claim is false; the schema names no staging area.
3. `NotFound` with empty date ("no snapshot") vs. `NotFound` with a date ("serial absent") differ only by a sentinel; plus `snapshotDate` itself is never validated, so the two can be conflated.
4. Are the record and the `meta` snapshot date read in one read transaction? As separate statements they can straddle a commit — a new record paired with an old date.
5. What governs two overlapping imports — serialized externally, last-commit-wins, second rejected, or undefined?
6. Which record fields are required, and how are missing/NULL fields stored and returned?
7. `meta` holds the schema version, but activation only replaces the date — where is the version written?
8. What is the supported `schemaVersion` set, and is downgrade allowed?
9. Do Validate's uniqueness check and the Activate PK abort always agree? Which stage/message is reported if they diverge?
10. What does a lookup whose query normalizes to empty return?
11. Is the USB snapshot assumed immutable between Validate and Build?
12. On crash during WAL activation, is WAL recovery guaranteed, and does an orphaned WAL count as the reportable index fault?

Please triage these — which to fix in the LLD now, and which to defer to Open Questions — and tell me whether to proceed to Phase 3 (EARS spec update for the registry). I have not touched the specs yet.