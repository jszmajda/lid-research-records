Phase 1 – HLD pre-flight complete. HLD `docs/high-level-design.md` exists and covers the registry domain. The tenets prohibit runtime network access, so a local SQLite backend is coherent. No HLD change needed.

Phase 2 – LLD updated. `docs/intent/registry/registry-design.md` now records the backend choice and design details.

Key changes:
* Architecture now states the lookup backend is a local embedded SQLite index maintained inside the registry component, rebuilt atomically when a new valid snapshot is activated. Each kiosk validates and rebuilds its own index; no runtime network required.
* Lookup Behavior specifies prepared-statement queries against a normalized serial column with an index for sub-250 ms resolution.
* Decisions & Alternatives table added:
  * Lookup backend – Chosen: Local embedded SQLite index. Alternatives considered: On-site HTTPS directory; Managed search service. Rationale: predictable local lookups, no service to run, per-kiosk validation/rebuild, stays inside registry, aligns with HLD no-network tenet.
  * Index rebuild strategy – Chosen: Atomic rebuild to new database file then swap. Alternative: In-place updates. Rationale: guarantees no partially imported snapshot is visible; import failure leaves previous snapshot active.
* Open Questions & Future Decisions updated with Resolved lookup backend selection and Deferred SQLite schema versioning/migration and storage location/backup.

Phase 3 – EARS specs updated. `docs/intent/registry/registry-specs.md` now contains:
* REG-001 – normalize whitespace and ASCII letter case before lookup
* REG-002 – include active snapshot date in result
* REG-003 – reject import on invalid signature / unsupported schema / duplicate serials, retain active snapshot
* REG-004 – activate valid replacement snapshot without exposing partial import
* REG-005 – When a valid replacement snapshot is activated, the system SHALL rebuild the local SQLite index from the snapshot records and make lookups use the new index only after the rebuild completes successfully

Consistency check:
* Coverage – SQLite rebuild and atomic activation now have spec coverage via REG-004 + REG-005
* Contradiction – none found
* Implicit scoping – REG-005 scoped to valid replacement snapshot activation
* Context-free reading – specs stand alone

Phase 4 – Intent-narrowing edge audit surface:
1. In-flight lookups during rebuild: REG-005 requires lookups use new index only after rebuild completes, but does not state whether lookups during rebuild must continue to serve from the old index or may be paused/blocked. Which behavior do you want?
2. Normalization storage: REG-001 normalizes on lookup. Does the SQLite index store the normalized serial as the indexed column, or store original and normalize at query time? The LLD implies an indexed normalized column; confirm.
3. Failure mode: If the rebuild succeeds but the file swap fails, REG-004’s “no partial exposure” and REG-005’s “only after rebuild completes successfully” could be read as requiring the old index to remain active. Should a failed swap be treated as a rejected import with error reporting?

Stop for your review. Please confirm the LLD and spec changes above, and resolve the three edge-audit points before I proceed to Phase 5 tests-first and Phase 6 code.
