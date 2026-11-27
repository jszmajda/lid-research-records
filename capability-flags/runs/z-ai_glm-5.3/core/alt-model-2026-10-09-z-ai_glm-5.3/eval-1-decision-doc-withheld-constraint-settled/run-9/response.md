**Phase 2 — Registry LLD finished around the local SQLite index.** Files changed:

- `docs/intent/registry/registry-design.md` — the open backend language is gone. The design now specifies: signature and schema-version checks before any records are read; import builds a staging SQLite database in a single transaction, with serials normalized into an indexed `normalized_serial` key (uniqueness enforced on the *normalized* key, since lookup normalizes — two raw serials collapsing to one key would make a result ambiguous); activation is an atomic rename of staging over the active file only after the full build validates; failed imports delete staging and leave the previous snapshot active. Lookup runs one indexed point query against the read-only active database; missing/corrupt/never-imported states report an explicit no-snapshot error. A Decisions & Alternatives table records the backend choice and the duplicate-key choice.
- `docs/high-level-design.md` — one line: "Its private lookup backend remains open" → "Its lookup backend is a local embedded SQLite database, private to the node."

Two things worth your attention:

1. **Why the decision is a table row, not a decision doc:** the HLD's tenets (lookups complete using files on the kiosk; no runtime network access) already exclude the HTTPS directory and managed service options — your pick aligns with the inherited constraint, so the row's rationale cites the tenets and that's the full record.

2. **Edge-case probe** (fresh reader, docs only). Triage these — which do I fix in the LLD now, which stay open questions, which need your call:

   1. The no-snapshot error is a third outcome, but `findBySerial` is typed as `Found | NotFound` — exception? third variant? Does the certificates-facing interface acknowledge it?
   2. If activation renames staging *over* the active file, what "replaced file" is deleted afterward? And are SQLite WAL/journal sidecar files accounted for across the rename?
   3. "Lookups in flight complete against the previous snapshot" — what mechanism guarantees this (per-lookup open vs. held handle)? What defines "in flight"?
   4. Kiosk loses power mid-import: is the staging filename fixed, and does the orphaned file collide with or get overwritten by the next import?
   5. When/how is a "corrupt" active database detected — at every lookup open, at import time, or never proactively?
   6. Are metadata (schema version, snapshot date) and records written in one transaction, so a staging database can't have them disagree?
   7. Serials with non-ASCII letters or internal whitespace — left as-is, matched literally, or rejected at import? Could two distinct raw serials collide through them?

My suggestions: #2, #4, and #6 are mechanical — I'd fix them in the LLD now. #1 and #3 need your intent on the interface shape. #5 and #7 could be fixed or deferred.

Once you've triaged, I'll fold the fixes in and move to Phase 3 (EARS update — e.g., whether the no-snapshot error becomes a spec alongside REG-001..004).