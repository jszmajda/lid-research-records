Here's the updated registry design with the SQLite decision and implementation details. I also ran an LLD-level edge-case probe — here are the gaps found:

**LLD Edge-Case Gaps**

1. Signature verification failure mid-import — temp file cleanup and exact error shape?
2. Unsupported schema version — distinct error code? Previous snapshot stays active?
3. Duplicate serials in snapshot — which record wins? Per-duplicate or batch error?
4. Temp SQLite write failure (disk full, perms) — rollback guarantee? Error propagation?
5. Atomic rename succeeds but metadata update fails — inconsistent state?
6. In-flight `findBySerial` during rename — old, new, or mixed state?
7. Missing/corrupt `registry.db` on first run — structured error or panic?
8. Missing/corrupt metadata table or `snapshot_date` key — what does lookup return?
9. SQLite error during lookup (corruption, lock, schema mismatch) — defined error shape?
10. Non-ASCII serial normalization — Unicode case-folding or only ASCII?
11. Empty/whitespace-only serial — rejected early or passed to SQLite?
12. Record count validation failure after index build — temp file deleted? Previous stays active?
13. Stale `registry.new.db` from crashed import — overwritten or import aborted?
14. Equipment table pre-existing data (migration) — truncated or merged?
15. `snapshot_date` monotonicity invariant — can newer snapshot have older date?
16. `schema_version` invariants — can it change? Backward compatibility?
17. Old `registry.db` retention/cleanup policy?
18. Concurrent import + lookup — read-only access guaranteed safe during rename?
19. Distinct error types for `findBySerial` — `NotFound` vs `CorruptIndex` vs `MissingMetadata` vs `IOError`?
20. Invalid ISO 8601 dates in snapshot — validated before index build?

**STOP for your review.** Please triage which gaps to fix in the LLD now vs. defer as open questions. The design document is at `docs/intent/registry/registry-design.md`.