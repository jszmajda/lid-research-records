Registry design is finished around your SQLite choice — Phase 2 output below, for your review.

## What changed in `docs/intent/registry/registry-design.md`

- **Architecture** — commits to a local embedded SQLite index per kiosk; no service, no network dependency; certificates node unchanged.
- **Snapshot Import** — concrete mechanism: build a fresh SQLite database beside the active one, unique index on a normalized-serial column, snapshot date stored in the database, activation by atomic rename over a fixed active path. Failed import deletes the partial file and leaves the previous snapshot serving.
- **Lookup Behavior** — normalization applied on both load and lookup; read-only open of the active database; and one newly pinned rule: a missing/unreadable database reports a **lookup failure**, not a fabricated `NotFound`.
- **Decisions & Alternatives** — two rows: backend selection (rationale: the HLD offline tenet rules out both networked options) and atomic-rename activation (rejected in-place updates). Since the HLD's no-network tenet already settles the backend, I recorded it as a row rather than offering a full decision doc.
- **Open Questions** — backend marked resolved; deferred: database file location, concurrent import-during-lookup, superseded-snapshot retention.

## LLD edge-case probe (delegated blind reader)

The probe found these unanswered "what happens when..." questions. Please triage: which should the LLD fix now, and which defer as open questions?

1. Same snapshot imported twice — detected/no-op/full rebuild?
2. Crash or power loss after build but before rename — which database is active on restart, and is the orphaned file cleaned up?
3. The atomic rename itself fails — error shape, and is the old active database guaranteed intact?
4. First-ever import on an empty kiosk fails — there is no previous snapshot to keep serving; what state results?
5. Lookup before any snapshot was ever imported — failure, or something the UI must handle differently?
6. Import running while a technician looks up — currently only "revisit during implementation."
7. Uniqueness validated against raw or normalized serials (normalization can collide two raw serials)?
8. Normalization edge cases — internal whitespace, tabs, non-ASCII characters?
9. Snapshot with an older or equal snapshot date — any monotonicity check, or does any validly signed snapshot win?
10. What "unsupported schema version" means numerically (≤ current, exact match?) and where the current version lives.
11. Import size/duration limits and disk exhaustion mid-build.
12. A validly signed but zero-record snapshot — failure or a legitimate empty registry?
13. Validation ordering and partial acceptance when the manifest is valid but content checks fail.
14. Leftover partial files after a kill — any startup reconciliation sweep?
15. What "useful error" concretely is — error type, message, distinguishable cause?

**Please review**: the revised LLD text above, plus your triage of the 15 gaps (fix in LLD vs. defer). After your approval I'll cascade to the EARS specs (REG-001…004 will need revision and additions for the pinned behaviors), then continue through the remaining phases.