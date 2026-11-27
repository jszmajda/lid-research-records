Completed the registry LLD in `docs/intent/registry/registry-design.md` and removed the stale “backend remains open” wording from `docs/high-level-design.md`.

The design now specifies:

- A per-kiosk embedded SQLite index built from each signed snapshot.
- Streaming import with normalized-serial uniqueness enforcement.
- Integrity checking and durable staging before activation.
- Versioned databases activated through an atomic pointer swap.
- Snapshot-consistent read-only lookups.
- Failure isolation that preserves the active snapshot.
- SQLite storage layout and component boundaries.
- A Decisions & Alternatives entry covering SQLite, on-site HTTPS, and managed search.

The network-backed alternatives were not actually equivalent under the existing HLD: both conflict with the tenets requiring local-only lookup and prohibiting runtime network access. SQLite is the only proposed option consistent with those constraints, so the choice is recorded in the LLD rather than a standalone decision document.

The delegated LLD edge-case probe found no direct HLD contradiction, but identified these design questions:

1. What should `findBySerial` return before the first snapshot is activated, or when the active database cannot be opened? The fixed `Found`/`NotFound` interface cannot represent registry unavailability.
2. Should a kiosk accept a snapshot older than the active snapshot for intentional rollback?
3. Should concurrent imports be rejected or serialized, and which import wins?
4. What exact crash-recovery invariant applies if power fails while the active pointer is being replaced or flushed?
5. How should the registry determine that no lookup can still reference an old version before deleting it?
6. Which fields, date formats, encodings, blank lines, unknown fields, and empty snapshots count as malformed input?
7. What error categories and diagnostic details should import failures expose?
8. How many inactive versions should be retained, and how should abandoned or colliding version files be handled?

Please review the LLD and reply with numbered resolutions for these questions, or approve specific items for deferral. I have stopped before updating the EARS specifications, as required at the Phase 2 boundary.