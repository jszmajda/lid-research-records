Phase 1 – HLD check
The project is LID-configured Full Mode 1.4.0. `docs/high-level-design.md` exists and covers the registry domain. Tenets require no runtime network, signed USB snapshots only, failed import leaves last valid snapshot, and certificates must not read registry storage directly. Local embedded SQLite satisfies those tenets and does not require an HLD change.

Phase 2 – LLD updated
`docs/intent/registry/registry-design.md` has been rewritten as a fresh author document.

Key changes:
* Context and Design Philosophy now states the fixed `findBySerial` interface and registry ownership.
* Snapshot Import describes staging validation, signature/schema/duplicate checks, temporary SQLite build, and atomic activation. Import failure leaves previous snapshot active.
* Lookup states normalization of surrounding whitespace and ASCII case, punctuation significant, snapshot date returned always, and that lookups query the embedded SQLite index rebuilt on activation.
* Decisions & Alternatives table records:
  * Lookup backend – Chosen: Local embedded SQLite index. Alternatives: On-site HTTPS directory; Managed search service. Rationale: predictable lookups with no service to run; each kiosk validates and rebuilds its own index on snapshot arrival, keeping maintenance inside the registry component; satisfies no-network tenet; certificate interface unchanged.
  * Index rebuild strategy – Chosen: Full rebuild on snapshot activation. Alternatives: Incremental delta updates. Rationale: simpler correctness with whole signed snapshots.
* Open Questions & Future Decisions updated: Lookup backend resolved; deferred: SQLite file location/backup rotation; performance validation for 90k records / 250 ms on 4 GB RAM.

LLD reads context-free and the Decisions & Alternatives table now contains the rejected alternatives and why.

LLD-level edge-case probe – gaps for you to triage:
* What happens when snapshot import fails mid-rebuild due to disk full or I/O error? Is rollback explicit?
* What happens when two snapshots arrive concurrently on a kiosk?
* What happens if the active SQLite file is corrupted on boot? Fallback behaviour?
* REG-003 duplicate serial numbers – should uniqueness be checked on raw serial or after the normalization applied at lookup?
* Normalization is defined for lookup only. Should import validation also normalize before duplicate detection?
* Lookup during index swap – is a read lock or atomic file replace sufficient to guarantee no partial reads?
* Snapshot date validation – should future-dated or very old snapshots be rejected?
* Memory usage during rebuild of a 150 MB snapshot on 4 GB RAM kiosks.
* Non-ASCII serial characters – normalization only mentions ASCII letters.

Phase 3 – EARS consistency
Specs unchanged:
- REG-001 normalize whitespace/ASCIi case before lookup
- REG-002 include active snapshot date in result
- REG-003 reject import on invalid signature/unsupported schema/duplicate serials and retain active snapshot
- REG-004 activate valid replacement snapshot atomically, no partial exposure

Consistency report:
* Coverage: LLD behaviours for atomic activation, full rebuild, normalization and snapshot-date return are covered by REG-004, REG-001, REG-002. Validation is covered by REG-003.
* Contradiction: none found.
* Implicit scoping: REG-003 duplicate serial numbers is ambiguous about normalization; scope is not explicit.
* Context-free reading: specs stand alone.

Stop for your review. Please confirm:
1. The LLD update and Decisions & Alternatives table as written.
2. Which of the edge-case probe items you want fixed in the LLD now vs deferred to Open Questions.
3. Whether REG-003 duplicate check should be clarified to specify normalized serials.

Approval to proceed to Phase 4 Intent-narrowing edge audit?