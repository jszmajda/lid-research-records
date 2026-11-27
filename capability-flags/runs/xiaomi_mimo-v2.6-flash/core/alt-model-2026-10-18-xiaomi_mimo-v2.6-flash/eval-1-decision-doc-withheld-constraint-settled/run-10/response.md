**Registry LLD — Phase 2 stop.** Pre-flight: specs REG-001–004 still trace to the LLD; no tests/code exist yet in this docs-only repo; certificates segment is untouched (interface fixed, no cross-boundary cascade). One HLD line had gone stale and was closed with the selection:

> Registry: … Owns snapshot validation and lookup. **Its private lookup backend is a local embedded SQLite index rebuilt from the active snapshot.** *(was: "remains open")*

The backend choice is recorded as a Decisions & Alternatives row in the registry LLD, not a decision doc — the HLD's no-network tenet settles it for any cold reader.

**Finished `docs/intent/registry/registry-design.md`:**

---
**Context** — Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Kiosks have no network route during normal operation, so every lookup is answered from files on the kiosk.

**Architecture** — Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed. The certificates node uses only this interface and never sees registry storage.

The lookup backend is a local embedded SQLite index, built and owned entirely inside the registry component. The snapshot file is the source of truth; the index is derived data that the registry validates and rebuilds whenever a snapshot arrives. Snapshot validation, index construction, and lookup all stay inside this component.

**Snapshot Import** — Verify the signature using a bundled public key, reject unsupported schema versions, and validate record serial numbers for uniqueness on the lookup key — the same normalization that lookup applies — so two records can never collide at query time.

Build the replacement index completely in a temporary location; nothing about the incoming snapshot is visible while this runs. Activate the snapshot and its index together in a single step only after validation and index construction both succeed. An import failure leaves the previous snapshot and index active and reports a useful error identifying what was rejected.

**Index Lifecycle** — The index lives in kiosk-local storage at a path only the registry component reads or writes. It is derived data: if it is missing or fails to open at startup, the registry rebuilds it from the retained active snapshot before serving lookups, with no technician action. The index carries the schema version and snapshot date of the snapshot it was built from.

**Lookup Behavior** — Normalize surrounding whitespace and uppercase ASCII letters on both sides of the match — when building the index's serial key at import, and on the requested serial at query time. Serial-number punctuation remains significant. A lookup that begins before an activation completes against the previous snapshot; a lookup that begins after activation uses the new one; no lookup observes a mixture. Return the snapshot date even when no matching record exists.

**Performance** — An indexed point lookup over ~90,000 rows sits far inside the 250 ms budget on a 4 GB kiosk. Index size is modest relative to the snapshot itself, so rebuild storage fits alongside the retained snapshots within kiosk disk limits.

**Decisions & Alternatives**

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index inside the registry component | On-site HTTPS directory; managed search service | The HLD requires all lookup from kiosk files with no runtime network, which eliminates both network-backed options; a local index gives predictable lookups with no service to run, and each kiosk's validate-and-rebuild cost stays inside this component. |
| Index status | Derived data, rebuilt from the retained snapshot | Index as the primary record store | A corrupted or missing index recovers without technician action; the signed snapshot remains the only source of truth. |
| Uniqueness key | Normalized serial (trimmed, ASCII-uppercased) | Raw serial as stored | Lookup normalizes before matching, so uniqueness on raw serials alone could let two records collide at query time. |
| Activation | Build completely off to the side, then swap snapshot and index together | In-place update of the live index | A partially imported snapshot must never be visible; an in-place update would expose intermediate state. |

**Open Questions & Future Decisions — Deferred:** index storage path and file naming (settled with kiosk packaging).
---

**LLD edge-case probe** — "what happens when…" gaps in this LLD. Which fix now vs. defer?

1. **Mid-lookup I/O failure.** The result type is only `Found`/`NotFound`. If the index read fails during a lookup, how does that surface — a raised/failed call to the certificates node, or something else? (Interface is fixed, so this needs a ruling.)
2. **Snapshot over 150 MB** (validly signed, otherwise valid): is 150 MB a rejection threshold at import, or only a sizing target?
3. **Schema-version policy:** are versions *older* than the current build but previously supported still accepted, or only the exact current version?
4. **Re-import of the already-active snapshot** (same date/signature): rebuild anyway, no-op, or reject as redundant?
5. **Degenerate valid snapshot:** zero records, or records with empty serials — does import accept an empty registry?
6. **Error detail audience:** who receives the "useful error" from a failed import — technician at the kiosk, or whoever handles the USB import?

Give numbered feedback on the LLD (and the HLD line), triage the six gaps, and approve explicitly before I draft the Phase 3 EARS updates.