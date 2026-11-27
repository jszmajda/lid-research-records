The registry design is finished around your choice, and the local SQLite index is recorded as the selected backend.

**What changed**

- `docs/intent/registry/registry-design.md` — rewritten as a complete design: `findBySerial` interface unchanged; embedded SQLite index private to the registry node; each kiosk validates snapshots and rebuilds its own index (stages: verify signature → check schema version → check serial uniqueness → build fresh index file while lookups keep serving from the active one → activate by atomic rename). Any stage failure, including a build failure after validation, leaves the previous snapshot active. Records are keyed by normalized serial with a unique index; the snapshot date lives in index metadata. The backend decision is recorded in the Decisions & Alternatives table: the HLD's no-network tenets rule out the HTTPS directory and managed search service, with the accepted cost that every kiosk rebuilds its own index; the certificate interface is identical either way.
- `docs/high-level-design.md` — the Architecture line no longer says the lookup backend "remains open"; it now notes the registry owns its private local lookup index.

The certificates node and the existing REG-001–004 specs are untouched — they're backend-neutral, and the interface they rely on didn't move. EARS updates for anything the finished design adds (e.g., rebuild-failure handling, availability during rebuild) come next, after you approve this LLD.

**Phase 2 edge-case probe — please triage**

A blind subagent read the LLD and raised these gaps. For each: fix in the LLD, or defer as an open question?

1. SQLite `-wal`/`-shm` sidecar files — does the stage-5 atomic rename move them, and what about sidecars on the old active index? (Most likely place for an implementer to corrupt the index.)
2. What does an in-flight lookup observe at the moment of the stage-5 rename — old snapshotDate, block, or fail?
3. Active index corrupted on disk at startup — detect, report, refuse to serve?
4. Power loss between build and activation — is a fully built but unactivated index detected and discarded at next startup?
5. Is stage-3 uniqueness checked on raw or normalized serials (is `ab-12` vs `AB-12` a duplicate?), and does build-time normalization exactly match lookup-time normalization?
6. Malformed JSON lines in the snapshot — which stage rejects them?
7. Concrete import error shape (stage code, message, retryability) — one shared type or distinct per stage?
8. Disk exhaustion during the stage-4 rebuild — must the build stream records, or may it hold the 150 MB snapshot in memory?
9. Which schema versions are "supported," and are record fields beyond the fixed shape rejected, ignored, or failed later?
10. Snapshot date that's missing, malformed, or implausible (e.g., in the future) — validated anywhere?

**Stop for your review:** Please review the rewritten LLD and tell me which probe gaps to fold into the design versus defer. Once you approve, I'll cascade to the EARS specs.