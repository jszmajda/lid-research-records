Phase 2 (registry LLD) is now finalized around the local embedded SQLite index. The choice reads as settled rather than live — the HLD already pins lookups to files on the kiosk with no runtime network route, which rules out the on-site HTTPS directory and the managed search service — so I recorded it as a Decisions & Alternatives row rather than opening a decision doc. I also refreshed the HLD architecture line, which still said the backend "remains open."

**Registry design, as written to `docs/intent/registry/registry-design.md`:**

- **Architecture** — `findBySerial(serial)` still returns `Found(record, snapshotDate)` or `NotFound(snapshotDate)`; the certificates node still sees only this interface. Lookup is served by a local embedded SQLite index built from the active snapshot. The index is derived data; the validated snapshot stays the source of truth and can rebuild it.
- **Snapshot import** — verify signature, reject unsupported schema versions, validate serial uniqueness. Build the new index in a staging location, activate only once the whole build is done; a failure leaves the previous snapshot active, discards the staged index, and reports a useful error.
- **Index build and activation** — one SQLite DB in the registry data directory: a records table keyed by normalized serial (with display serial, description, calibration date, due date) plus a metadata row for the snapshot date. Build runs in one transaction; activation replaces the active index so lookups see old-index/old-date or new-index/new-date, never a mixture.
- **Lookup behavior** — normalize surrounding whitespace and uppercase ASCII on both build and query sides; punctuation stays significant. The snapshot date comes from the active index metadata, so it is returned even on `NotFound`.

**Phase 2 edge-case probe** — gaps I found in this LLD's own state/transition/error/ordering assumptions. None are decided; I've provisionally listed the first three as Deferred in the doc:

1. **Duplicate uniqueness basis** — does "unique serial" apply to the raw or the normalized serial? Two raw serials differing only by case/whitespace currently collapse to one index key.
2. **Unreadable/corrupt active index** — should lookup surface a distinct error rather than `NotFound`? `NotFound` otherwise means "no such record."
3. **Crash mid-build** — orphaned staged index; what cleans it up on next start?
4. **Activation on Windows** — an atomic replace can fail if a lookup holds the DB open; is a versioned-file-plus-pointer needed instead of replace?
5. **Zero-record snapshot** — valid empty index, or rejected?
6. **Disk space / build failure** — confirm prior index stays active and staging is removed.
7. **Date-field validation scope** — are calibration/due date formats validated at import, or stored as-is?
8. **Snapshot-date semantics** — timezone/format bounds unstated.

I've stopped here. Please (a) approve the registry LLD or give numbered edits, and (b) triage the gaps — tell me which to settle in the LLD now versus leave Deferred. Once you approve, I'll move to Phase 3 (the `REG-*` EARS updates).