Coherence pre-flight passed: HLD → LLD → EARS trace clean, no drift detected.

**Phase 2 — LLD updated: docs/intent/registry/registry-design.md**

Architecture now specifies a local embedded SQLite database built from the active snapshot, read-only in normal operation, with no network service for lookups.

Snapshot Import now builds the SQLite index in a temporary database file and activates by atomically replacing the active database file and updating the stored snapshot date.

Lookup Behavior now queries the embedded SQLite index with a parameterized statement against the normalized serial value.

Decisions & Alternatives table added:
- Lookup backend → Chosen: Local embedded SQLite index; Alternatives: On-site HTTPS directory; Managed search service; Rationale records predictable offline lookups and per-kiosk validation/rebuild inside the registry component.

Open Questions & Future Decisions updated: backend resolved; SQLite schema definition and snapshot rollback retention deferred.

**LLD-level edge-case probe — triage needed**
- What happens if SQLite build runs out of disk space mid-build?
- What happens if power is lost during the atomic file replacement?
- What happens if two snapshots arrive in quick succession?
- What happens if a lookup is requested during the index swap?
- What happens if serial numbers contain Unicode beyond ASCII after normalization?
- What happens if snapshot contains duplicate serial numbers only after normalization?
- What happens if the SQLite database becomes corrupted?

**Phase 3 — EARS specs updated: docs/intent/registry/registry-specs.md**

Added:
- [ ] **REG-005**: When a valid snapshot is activated, the system SHALL build a local SQLite index from the snapshot records and atomically replace the active index for subsequent lookups.

Existing REG-001 to REG-004 unchanged and trace to LLD.

Post-draft consistency:
- Coverage: normalization, snapshot date, signature/schema/duplicate rejection, atomic activation, and SQLite build are covered. Lookup 250 ms goal remains a HLD goal, not a spec.
- Contradiction: none found.
- Scope: specs are context-free.

Stop for review. Please confirm the LLD wording and Decisions & Alternatives table, and triage which edge-case probes should be resolved in the LLD now vs deferred. On explicit approval I will proceed to Phase 4 Intent-narrowing edge audit.