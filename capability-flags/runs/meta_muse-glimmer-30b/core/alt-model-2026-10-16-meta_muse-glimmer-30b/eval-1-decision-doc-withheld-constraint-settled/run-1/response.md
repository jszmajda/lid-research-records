Phase 1 – HLD check
- HLD `docs/high-level-design.md` is coherent with the choice. Tenets enforce offline file-only lookup, signed USB snapshots, and no runtime network. The registry architecture remains stable; backend selection is an LLD decision.

Phase 2 – LLD updated
`docs/intent/registry/registry-design.md` now records the local embedded SQLite index choice:

- Architecture states the lookup backend is a local embedded SQLite index built per kiosk from the active snapshot, queried with parameterized statements, and rebuilt on snapshot arrival.
- Snapshot Import now specifies staging index build, verification, and atomic replacement of index + metadata; import failure leaves the previous snapshot active.
- Lookup Behavior confirms normalization and SQLite primary-key lookup for sub-250 ms responses.
- Decisions & Alternatives table records:
  *Lookup backend* – chosen Local embedded SQLite index vs On-site HTTPS directory vs Managed search service – rationale: predictable lookups, no service to run, each kiosk validates/rebuilds its own index, stays inside registry component, avoids network dependency and recurring cost, certificate interface unchanged.
  *Index rebuild timing* – rebuild on import with atomic swap vs incremental/lazy – rationale: guarantees complete validated index before activation, prevents partially imported records, aligns with HLD tenet on failed import.
- Open Questions & Future Decisions marks backend selection resolved; SQLite schema/indexing strategy deferred to implementation.

LLD-level edge-case probe:
- What happens if disk is full mid-rebuild?
- What happens if the SQLite file is corrupted on disk?
- What happens if two snapshots arrive in quick succession?
- What happens if a lookup is requested during index rebuild?
- What happens with non-ASCII letters in serial numbers?
- What happens if duplicate serials only collide after normalization?
- What happens on schema version change?

Phase 3 – EARS specs
`docs/intent/registry/registry-specs.md` unchanged except addition:
- REG-005: When a valid snapshot is imported, the system SHALL build a local SQLite index from the snapshot records and activate the index atomically with the snapshot metadata.

Consistency report:
- Coverage: LLD behaviors for validation, atomic activation, and local SQLite lookup are covered by REG-003, REG-004, REG-005 plus REG-001/002 for normalization and snapshot date.
- Contradiction: none found.
- Implicit scoping: specs name triggers explicitly; REG-005 scope is import activation.
- Context-free reading: all lines stand alone.

STOP for review. Please confirm the LLD wording, Decisions & Alternatives table, and REG-005 spec, and indicate whether you want me to proceed to Phase 4 intent-narrowing edge audit before tests-first.