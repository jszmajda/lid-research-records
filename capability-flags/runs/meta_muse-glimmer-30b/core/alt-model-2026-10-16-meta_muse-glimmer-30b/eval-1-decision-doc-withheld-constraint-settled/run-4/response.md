Registry design is updated for the local embedded SQLite index choice. Per linked-intent-dev stops, here is the current state for review before tests/code.

**Phase 1 — HLD check**
docs/high-level-design.md is unchanged and coherent. HLD tenets — no runtime network, offline lookup, atomic snapshot import, certificate component isolation — are satisfied by the local SQLite option. No HLD revision needed.

**Phase 2 — LLD update**
docs/intent/registry/registry-design.md updated:
* Architecture now states: lookup backend is a local embedded SQLite index. Each kiosk validates and rebuilds its own index on snapshot arrival; index lives in registry private storage and requires no network service at lookup time.
* Lookup Behavior now specifies execution against the embedded SQLite index with normalized serial query and an index on normalized serial.
* Decisions & Alternatives table added:
  * Lookup backend — Chosen: Local embedded SQLite index. Alternatives: On-site HTTPS directory; managed search service. Rationale: predictable lookups, no service to run, index maintenance stays inside registry, meets no-runtime-network tenet.
  * Snapshot activation — Chosen: Atomic swap after full validation. Alternatives: Incremental update; lazy rebuild. Rationale: failed import must leave last valid snapshot available.
* Open Questions & Future Decisions: Lookup backend resolved; index rebuild performance budget and progress reporting for 150 MB snapshots deferred.

LLD-level edge-case probe for triage:
* What happens when snapshot import is interrupted mid-rebuild, e.g., power loss?
* What happens when normalized serials collide for distinct original serials differing only in ASCII case?
* What happens if the SQLite index file becomes corrupted?
* What happens when two snapshots arrive in quick succession?
* How are non-ASCII characters in serial numbers handled by normalization and indexing?
* What happens if index rebuild exceeds the kiosk memory budget?

**Phase 3 — EARS specs**
docs/intent/registry/registry-specs.md now:
- [ ] **REG-001**: When a serial-number lookup is requested, the system SHALL normalize surrounding whitespace and ASCII letter case before returning a matching record or NotFound.
- [ ] **REG-002**: When a lookup completes, the system SHALL include the active snapshot date in the result.
- [ ] **REG-003**: When a snapshot has an invalid signature, an unsupported schema version, or duplicate serial numbers, the system SHALL reject the import and retain the active snapshot.
- [ ] **REG-004**: When a valid replacement snapshot is activated, the system SHALL expose all of its records together without exposing a partially imported snapshot.
- [ ] **REG-005**: When a valid snapshot is activated, the system SHALL rebuild the embedded SQLite index from that snapshot before the new snapshot becomes active for lookups, and lookups SHALL complete without network access.

Consistency report:
* Coverage: normalization, snapshot date, validation/rejection, atomic activation, and SQLite rebuild without network are now covered.
* Contradiction: none found.
* Implicit scoping: REG-005 explicitly scopes to embedded SQLite index and no-network lookups.
* Context-free reading: specs stand alone.

**Phase 4 — Intent-narrowing edge audit**
* REG-001 normalization vs REG-005 index rebuild: must clarify whether the index stores normalized serials and queries use normalized input, or normalization happens only at query time. Current LLD says query after normalization with index on normalized column — consistent, but needs confirmation.
* REG-004 atomic exposure vs REG-005 rebuild ordering: REG-005 requires rebuild before activation, which satisfies REG-004. Ensure the spec pair does not allow activation before rebuild completes.
* Snapshot date visibility: REG-002 requires date in every lookup result, including NotFound. Ensure the active snapshot date is the one after atomic swap.

Please review the LLD updates, the edge-case probe list, and the new REG-005 spec. Confirm whether you want the normalization/index storage detail clarified in the LLD, and approve to proceed to Phase 5 tests-first.