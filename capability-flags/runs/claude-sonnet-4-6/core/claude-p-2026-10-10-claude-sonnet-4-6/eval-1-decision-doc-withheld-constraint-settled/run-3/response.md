Now I'll present the Phase 2 output with the edge-case probe.

---

## Phase 2 — Registry LLD: SQLite backend, complete draft

**What changed from the previous draft:**

- `registry-design.md` fully specifies the SQLite index: table schema, two-file staging layout, import sequence (7 steps), lookup query, and normalization scope.
- The Decisions & Alternatives table records the backend choice and three implementation choices (activation mechanism, index type, normalization scope).
- The HLD Architecture line was updated to remove "Its private lookup backend remains open."

The interface (`findBySerial`, `Found`/`NotFound`, fixed result type) is unchanged; the certificates node is unaffected.

---

**LLD edge-case probe** — gaps in this LLD's own internals:

1. **Field validity beyond uniqueness.** The schema uses `NOT NULL` on description, calibration_date, and due_date. If a snapshot record is present but has an empty string for one of those fields, the INSERT succeeds. The LLD doesn't say whether empty-string field values are accepted or treated as a validation failure.

2. **Staging file location.** `rename(2)` is atomic only within the same filesystem. If `staging.db` is created somewhere other than the same directory as `active.db` (e.g., a system temp dir on a different mount), the rename would fail with EXDEV. The LLD says both files live in "the registry data directory" but doesn't lock that down explicitly; the implementation assumption should be stated.

3. **Zero-record snapshot.** The LLD rejects duplicates and invalid signatures but doesn't say whether a snapshot with zero equipment records is accepted or rejected. A zero-record activation would answer every lookup with NotFound.

4. **WAL siblings on rename.** Currently deferred, but worth flagging now: if WAL mode is ever enabled on `active.db`, SQLite creates `active.db-wal` and `active.db-shm` alongside it. Renaming `active.db` alone leaves those orphaned and will corrupt the next open. The deferred question should note this specific hazard so it isn't forgotten.

5. **Internal whitespace in serial numbers.** The spec (REG-001) and LLD both normalize *surrounding* whitespace. A serial like `AB 12345` with an internal space passes through unchanged. This is probably correct — punctuation and internal spacing are significant — but it's worth confirming that the catalog genuinely doesn't include serials where internal spaces are insignificant.

---

Which of these should I resolve in the LLD now versus leave as open questions? Items 2 (staging file location) and 4 (WAL rename hazard note) are low-effort to specify and prevent future confusion. Items 1, 3, and 5 need your call on what the catalog data actually looks like.