Phase 2 LLD update is complete and ready for your review.

**Coherence pre-flight**
- HLD tenets (no network, signed USB snapshots, 250 ms lookup, snapshot date on every result) are intact.
- LLD now reflects the chosen backend; existing EARS specs REG-001 to REG-004 remain coherent with the design.

**Updated LLD — `docs/intent/registry/registry-design.md`**
- Architecture: lookup backend is a local embedded SQLite index stored on the kiosk. Each kiosk validates and rebuilds its own index when a signed snapshot arrives; all validation/rebuilding stays inside the registry component. Certificate interface unchanged.
- Snapshot Import: signature verification with bundled public key, schema version rejection, serial uniqueness validation, prepare new snapshot without exposing partial records, activate only after success, failure leaves previous snapshot active.
- Index Build: on successful validation, build a new SQLite database in staging from NDJSON records. Table `equipment` with `serial TEXT PRIMARY KEY`, `calibration_date TEXT`, `due_date TEXT`, `description TEXT`, `snapshot_date TEXT`. Index on `serial`. Populate in a single transaction. On commit success, atomically replace active DB file and update snapshot date metadata. Previous DB remains available if build fails.
- Lookup Behavior: normalize surrounding whitespace and uppercase ASCII letters before lookup; serial punctuation significant; return snapshot date even on NotFound; lookup performed against local SQLite index with indexed `serial` column to meet 250 ms target on 4 GB RAM.
- Decisions & Alternatives:
  * Lookup backend — Chosen: Local embedded SQLite index. Alternatives: On-site HTTPS directory; Managed search service. Rationale: predictable lookups with no service to run; each kiosk validates/rebuilds its own index; keeps registry concerns inside component and satisfies no-network tenet.
  * Snapshot activation — Chosen: Staged build + atomic replace. Alternatives: In-place update. Rationale: ensures failed import leaves last valid snapshot available and avoids partial exposure.
- Open Questions & Future Decisions
  * Resolved: Lookup backend selected as local embedded SQLite index.
  * Deferred: Exact SQLite version and file location on kiosk filesystem; schema migration handling for future schema versions.

**LLD edge-case probe — gaps surfaced for triage**
- What happens when a lookup is in flight while a snapshot import/build is running? Need read stability guarantee.
- What happens if the SQLite build runs out of disk space mid-transaction?
- What happens if the active DB file becomes corrupted on disk?
- What happens if serial numbers contain Unicode that normalizes differently than ASCII uppercasing?
- What happens on duplicate serials after normalization vs. raw?
- What happens with concurrent snapshot imports from USB?

**EARS coverage check**
Current specs:
- REG-001 normalization before lookup
- REG-002 snapshot date included in result
- REG-003 reject invalid signature/schema/duplicate and retain active snapshot
- REG-004 activate valid replacement without partial exposure

Coverage is consistent with the SQLite choice. REG-004 covers atomic activation; the staged Index Build detail is design-level. A spec for “rebuild index from validated snapshot before exposing lookups” could be added in Phase 3 if you want that behavior explicitly tested.

Phase 2 stop: Please review the updated registry LLD above, the Decisions & Alternatives table, and the edge-case probe list. Confirm approval to proceed to Phase 3 — EARS spec draft/update with post-draft consistency verification — or provide numbered feedback to revise the LLD first.