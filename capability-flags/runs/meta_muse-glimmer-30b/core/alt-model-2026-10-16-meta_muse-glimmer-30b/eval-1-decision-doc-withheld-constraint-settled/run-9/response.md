Phase 2 — LLD updated for the Registry node.

Coherence pre-flight passed: HLD tenets, LLD, and EARS specs are mutually coherent for the change. No drift detected.

**Updated LLD: `docs/intent/registry/registry-design.md`**
- Architecture now states the lookup backend is a local embedded SQLite index built from each validated snapshot, rebuilt entirely inside the registry component with no runtime network access.
- Snapshot Import now builds a new SQLite index in a staging area and activates only after validation and build complete.
- Lookup Behavior now specifies lookups against the embedded SQLite index using a case-normalized serial column with an index for sub-250 ms resolution on 90,000 records.
- Decisions & Alternatives table records the choice:
  - Decision: Lookup backend
  - Chosen: Local embedded SQLite index
  - Alternatives Considered: On-site HTTPS directory; Managed search service
  - Rationale: Predictable offline lookups with no service to run; each kiosk validates and rebuilds its own index when a snapshot arrives, keeping all index maintenance inside the registry component. Meets tenet of no runtime network access and avoids recurring cost and external credentials.
- Open Questions & Future Decisions: Resolved lookup backend selection; Deferred index file size target and SQLite page size tuning for 150 MB snapshots.

**LLD-level edge-case probe**
What happens when...
1. Snapshot import fails mid-index build — staging build must be discarded, previous snapshot stays active. Covered by atomic activation; verify error path clears staging artifacts.
2. Two snapshots arrive concurrently — need serialization of import to avoid interleaved builds.
3. Lookup requested during index build — must continue serving previous index; no partial exposure.
4. SQLite file corrupts on disk — need detection on open and fallback to last valid snapshot with error reporting.
5. Serial contains non-ASCII characters — normalization is ASCII uppercase only; define behavior for non-ASCII.
6. Duplicate serial numbers after normalization — uniqueness check must use same normalization as lookup.
7. Disk space insufficient for staging index — import must fail cleanly and retain previous snapshot.
8. Schema version changes — validation rejects unsupported versions; no migration path defined.

Triage needed on items 2, 4, 5, 6, 7 before tests.

**EARS spec consistency**
`docs/intent/registry/registry-specs.md` unchanged and consistent with the updated LLD:
- REG-001 normalization
- REG-002 snapshot date in result
- REG-003 reject invalid signature/schema/duplicates, retain active snapshot
- REG-004 activate valid replacement without partial exposure

Coverage: No new observable behaviors introduced by the backend choice; specs remain implementation-agnostic. No contradictions or implicit scoping found.

STOP for user review. Please review the updated registry-design.md and the edge-case probe list. Confirm the LLD is acceptable and indicate which edge cases you want captured in the LLD vs deferred, so Phase 3 EARS drafting can proceed.
