**Phase 1 (HLD check) + Phase 2 (registry LLD draft) — review needed.** I folded the Phase 1 HLD review into this stop instead of stopping twice; say the word if you want them separated.

**Changed:** `docs/high-level-design.md` (registry now owns index maintenance; each kiosk keeps a local embedded index, lookups never leave the kiosk) and `docs/intent/registry/registry-design.md` (rewritten around the SQLite backend). EARS specs are untouched — that's Phase 3, after your review.

**The design (registry LLD)**
- Data dir: `index-<content-hash>.sqlite` + `active.pointer` (hash, snapshot date, schema version, record count).
- Import: verify signature → schema version → parse/validate records and normalized-serial uniqueness → build a new index in a temp file in batched transactions → write metadata → activate by atomically renaming a new pointer over `active.pointer` → delete superseded index files. Any failure before the pointer rename leaves the previous snapshot active and reports the cause.
- Schema: `records(serial_key PK, serial, description, calibration_date, due_date)` where `serial_key` is the normalized serial (trimmed, ASCII uppercased, punctuation significant); `snapshot_meta(key, value)`. Exact-match PK lookup over 90k records, no scan.
- Lookup: resolve pointer → query by normalized serial → `Found(record, snapshotDate)` / `NotFound(snapshotDate)`; snapshot date always returned. No active snapshot or a failed integrity check raises an error rather than returning a result.
- Decisions recorded as table rows (no decision doc — the HLD's no-network tenet already eliminates the HTTPS and managed-service options, so a cold reader wouldn't re-litigate it): local SQLite over HTTPS/managed service; full rebuild per snapshot over in-place update or a shipped prebuilt index; pointer-swap activation over in-place table swap; normalized serial as primary key; duplicate *normalized* serials fail the import.

**Edge-case probe (delegated, this LLD's own gaps) — needs your triage: fix now or defer**
1. The index file is never renamed/fsynced into its final name before the pointer swap — an implementer could activate a pointer to a missing file, losing the last valid snapshot.
2. What the "content hash" covers (records only vs whole snapshot) — records-only collides with the active file name when only the snapshot date differs.
3. Re-importing a snapshot whose hash equals the active one: rebuild, no-op, or overwrite the file being served?
4. Does the signature manifest cover the snapshot date and schema version, or only the records? (If records only, the date shown on certificates is unauthenticated.)
5. Signature scheme, key file/rotation, manifest format, and behavior on a missing/malformed manifest.
6. Pointer cache invalidation via mtime is unreliable (coarse granularity, clock changes) — a lookup could return the previous snapshot date.
7. Step 7 deletes non-active index files while the LLD promises in-flight lookups finish against their resolved index — is the file held open?
8. What "integrity check" means and when it runs (per-lookup `integrity_check` would blow the 250 ms budget).
9. What "raises an error" means at `findBySerial` — exception vs a third result variant, and which error kinds exist.
10. Normalization edges: which whitespace counts, non-ASCII letters, empty/whitespace-only serial → NotFound or error?
11. Exact record validation rules (required fields, unknown fields, accepted types, date formats, impossible dates).
12. Provenance and validation of the snapshot date.
13. `active.pointer` lifecycle: missing, empty, truncated, unknown hash, absent index file.
14. Concurrency: two imports at once, import during lookups, no locking stated.
15. Whether `record_count` is verified against rows actually inserted.

**Two decisions I need from you**
- **Older snapshots:** the draft accepts any valid snapshot (operator intent; date is shown on every result). Reject as regression instead?
- **Registry-unavailable path:** I drafted `findBySerial` as raising an error, which leaves the certificate component with no stated contract for that case — that crosses into the certificates segment, so I haven't touched those docs. Options: (a) keep the fixed `Found|NotFound` interface, raise a typed error, and add a certificate-side requirement to block export with a clear message (recommended); (b) add an `Unavailable(snapshotDate)` variant to the registry result type, changing the interface you said stays fixed. Confirm (a) and I'll carry the obligation into `docs/intent/certificates/` on your approval.