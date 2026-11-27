Pre-flight and the HLD check are done; here is the registry LLD with the local SQLite backend selected. I'm stopping here for your review before I touch EARS specs.

## Coherence pre-flight

- HLD covers the domain; the registry LLD traces to it; the existing REG-001…004 specs still trace to the LLD sections; no tests or code are present in this repo yet.
- One HLD line had gone stale once the backend is chosen: the registry bullet said "Its private lookup backend remains open." It now reads "Its lookup backend is a private implementation detail." No architectural change, so nothing cascades into the certificates node.

## Phase 1 — HLD check

No architectural change. The choice is already bounded by the HLD tenets ("no runtime network access is permitted"; "kiosks have no network route during normal operation"), which is why the two network options drop out below.

## Phase 2 — Registry LLD

`docs/intent/registry/registry-design.md`:

---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, index preparation, and lookup all belong to this node. Lookup reads a local embedded SQLite database built on the kiosk from the active snapshot. The database file, its schema, its location, and the query path are private to this node — the certificates node sees only the result of `findBySerial`.

## Snapshot Import

Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness. A serial number is stored under the same normalized form lookups use, so the uniqueness check and the lookup key agree.

Prepare the incoming snapshot by building a new SQLite database in a staging location beside the active one; the active database stays readable and unchanged throughout the build. Activate the staged database only after every validation and the full build succeed, by atomically replacing the active database. A failure at any point discards the staged database and leaves the previous snapshot and its database active, reporting a useful error.

The snapshot date is stored as database metadata, so the active database always yields the date it was built from.

## Lookup Behavior

Normalize surrounding whitespace and uppercase ASCII letters before lookup. Serial-number punctuation remains significant. Query the active database by the normalized serial number. Return the snapshot date even when no matching record exists.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite database built on the kiosk | On-site HTTPS directory; managed search service | Both alternatives require runtime network access, which the HLD forbids ("no runtime network access is permitted"; kiosks have no network route during normal operation). SQLite keeps lookup local and self-contained: predictable lookups, no service to run, and no service-timeout handling on the kiosk. It meets the 250 ms lookup, 90,000-record, and 150 MB snapshot targets. The accepted cost is that each kiosk validates and rebuilds its own index when a snapshot arrives; this stays inside the registry node. |

I recorded this as a Decisions & Alternatives row, not a decision doc — the no-network tenet eliminates the other two options, so a cold reader wouldn't re-litigate the choice. Say the word if you'd rather I write a full decision doc.

## LLD-level edge probe (gaps for you to triage)

1. **SQLite build failure.** If the snapshot is valid but the database build fails (e.g., disk full), the import should fail and keep the previous snapshot. REG-003 currently names only invalid signature, unsupported schema, and duplicate serials — a build failure isn't covered.
2. **Atomic replace assumption.** The design assumes the staging file and active database share a filesystem so the replace is atomic. Should that be stated as a requirement?
3. **Lookups during activation.** What should an in-flight lookup see while the active database is being swapped — the old snapshot or the new one?
4. **No snapshot yet (first boot).** What does `findBySerial` return, and what snapshot date, before any snapshot has been imported?
5. **Uniqueness vs. normalization.** Uniqueness is checked on the normalized serial number, so two raw serials differing only by case/whitespace collide. Confirm that's intended.
6. **Disk headroom.** Staging a second database means room for two databases during import. Acceptable on the kiosk?
7. **Empty snapshot.** Is a valid snapshot with zero records accepted?
8. **Re-import.** If the same snapshot arrives again, rebuild anyway or skip?

1. Do you approve the registry LLD as written?
2. Which of the edge-probe gaps (1–8) should I fold into the LLD now, and which do you want deferred?
3. Once these are settled, shall I proceed to Phase 3 — update the registry EARS specs and run post-draft consistency verification?