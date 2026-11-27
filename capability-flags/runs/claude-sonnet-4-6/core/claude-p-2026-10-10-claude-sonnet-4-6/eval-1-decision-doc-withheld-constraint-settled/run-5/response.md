Both files are updated. Here is the Phase 2 output — the updated registry LLD — for your review.

---

## Phase 2 — Registry LLD (updated)

**HLD change**: removed "Its private lookup backend remains open"; now reads "Owns snapshot validation, SQLite index management, and lookup."

**Registry LLD** (`docs/intent/registry/registry-design.md`) — rewritten with SQLite design:

- **Architecture**: `findBySerial` now returns three variants: `Found`, `NotFound`, and `NotReady` (no snapshot imported yet).
- **SQLite schema**: `records` table with `serial` as PRIMARY KEY (enforces uniqueness, provides lookup index); `meta` table for `schema_version` and `snapshot_date`; ISO 8601 TEXT for dates.
- **File locations**: `<data-dir>/registry.db` (active) and `<data-dir>/registry.db.staging` (import staging); both on the same local filesystem.
- **Import**: builds staging file completely before touching the active file; activates via a single within-directory rename (atomic on ext4/APFS/NTFS); any failure leaves the active file unchanged.
- **Lookup**: per-call read-only open, normalize serial, SELECT, close. Connection-per-call avoids coordination with activation.
- **Decisions & Alternatives table** records: backend choice (SQLite vs. the two network-dependent alternatives, both excluded by the HLD tenet); rename vs. in-place overwrite; per-call vs. persistent connection; `NotReady` vs. sentinel date; ISO 8601 text dates.

**Decisions & Alternatives note**: the SQLite choice is constrained by the HLD tenet ("all lookup SHALL complete using files on the kiosk; no runtime network access"). Both alternatives require network access at lookup time and fail that tenet. Because the tenet settles it, I did not offer a decision doc — the Decisions table row carries sufficient rationale.

---

## LLD edge-case probe

Questions pointed at gaps within this LLD:

1. **Corrupt active database** — `registry.db` exists but is not a valid SQLite file (truncated write, FS corruption). The LLD returns `NotReady` only when the file is absent; a corrupt file would produce an unhandled DB error. Is that a distinct result type, or should it collapse into `NotReady`?

2. **Concurrent imports** — two import calls run in parallel and both try to write `registry.db.staging`. The LLD doesn't say imports are serialized. Should the registry serialize imports internally, or is this the caller's responsibility?

3. **Snapshot JSON field names** — the LLD defines the DB columns (`serial`, `description`, `cal_date`, `due_date`) but not the JSON field names in the snapshot records that map to them. This needs to be stated somewhere (here, or in a snapshot format reference).

4. **Pre-existing staging file delete fails** — step 3 says "delete any pre-existing `registry.db.staging`"; if that delete fails (permissions, locked file), the import would continue writing to a file it didn't fully clear, or the open in step 4 would fail. No error path is specified for this case.

Which of these should be resolved in the LLD now, and which can stay deferred?