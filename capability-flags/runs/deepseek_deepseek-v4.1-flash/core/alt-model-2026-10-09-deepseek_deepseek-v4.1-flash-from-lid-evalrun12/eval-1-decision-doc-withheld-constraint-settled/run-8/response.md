Registry design — Phase 2 (LLD) draft, at the review stop.

**Phase 1 (HLD) coherence fix:** `docs/high-level-design.md:13` said the registry's "private lookup backend remains open." That note is now stale, so I removed it; the architecture (offline, USB snapshots, fixed `findBySerial` interface) is unchanged. No cascade into certificates — the interface is untouched.

**One thing to flag first.** The two rejected options conflict with the HLD's own tenets — "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted" and "Kiosks have no network route during normal operation." An on-site HTTPS directory and a managed search service both require runtime network access, so the offline tenet already eliminated them; they were never actually live choices. Local SQLite is the only candidate consistent with the HLD. I've recorded it that way. If you intended to revisit the offline tenet, say so; otherwise I'll treat the choice as settled by it (which is also why I'm not proposing a standalone decision doc — a Decisions row covers it).

**Updated `docs/intent/registry/registry-design.md`:**

```markdown
---
parent: high-level-design
prefix: REG
---

# Registry Design

## Context

Technicians enter an equipment serial number and need its calibration date, due date, and equipment description. A signed snapshot contains newline-delimited JSON records, a schema version, a snapshot date, and a signature manifest. Snapshots arrive on approved USB media, and a kiosk has no network route during normal operation, so every lookup is served from a local index built from the active snapshot.

## Architecture

Expose `findBySerial(serial)` returning either `Found(record, snapshotDate)` or `NotFound(snapshotDate)`. Record fields and result types are fixed regardless of the lookup backend. The certificates node uses only this interface.

Snapshot validation, index preparation, and lookup all belong to this node. The lookup backend is a local embedded SQLite index: each kiosk builds its own index from a validated snapshot and keeps it in a kiosk-local file owned by this node. No service process, port, or network dependency is involved.

## Snapshot Import

Import is a two-phase operation: validate the incoming snapshot, then build and activate an index from it.

Validation runs before any index work. Verify the signature over the raw snapshot bytes using the bundled public key, reject an unsupported schema version, and reject any serial number that collides with another after lookup normalization. A snapshot that fails any check is discarded and the active index is untouched.

Index build reads the validated snapshot into a new SQLite database file: one row per record keyed by the normalized serial, plus a metadata row carrying the snapshot date. The build writes to a temporary path, never the active path. Activation renames the completed database over the active one in a single filesystem operation, so a lookup observes either the whole previous index or the whole new one and never a partially imported snapshot. A failure before activation leaves the previous index active and reports a useful error.

## Lookup Behavior

Normalize the query by trimming surrounding whitespace and uppercasing ASCII letters; serial-number punctuation remains significant. Look the normalized serial up in the active SQLite index by primary key. Return the matching record as `Found` with the active snapshot date, or `NotFound` with the active snapshot date when no record matches. Return the snapshot date even when no matching record exists.

A lookup is a single indexed query against the active database and does not read the raw snapshot.

## Decisions & Alternatives

| Decision | Chosen | Alternatives Considered | Rationale |
|---|---|---|---|
| Lookup backend | Local embedded SQLite index | On-site HTTPS directory; managed search service | The HLD tenet that every lookup completes from on-kiosk files with no runtime network access precludes both network-backed alternatives. SQLite gives predictable indexed lookups with no service to run, at the cost of each kiosk rebuilding its own index when a snapshot arrives. |
| Index activation | Build a new database file and rename it over the active one | In-place table swap inside one database; import rows into the active file within a transaction | A file rename is a single atomic filesystem operation, so a concurrent lookup sees a complete index and a failed build never disturbs the active one. |

## Open Questions & Future Decisions

### Deferred

1. Behavior when no snapshot has ever been imported (no active snapshot date to return).
2. Free-disk-space precondition for holding a temporary index alongside the active one.
```

**LLD-level edge-case probe** (delegated to a blind reader; gap list for your triage — fix now in the LLD, or defer):

1. What does `findBySerial` return when the active index is missing, corrupt, or unreadable, given the result type only admits `Found`/`NotFound`?
2. What is the error shape of import failure (validation vs. build vs. activation), and is the reason distinguishable to the caller?
3. Which snapshot date is authoritative — manifest field, metadata row, or local clock — and in what format/timezone?
4. Is the snapshot date derived from signed bytes, or from an unsigned field/local clock?
5. Does activation assume an OS where rename over an open database succeeds (Windows file-handle semantics)?
6. Does the active index use SQLite journal/WAL sidecar files, and if so how is a single-file rename still atomic for them?
7. Is the temporary path guaranteed to be on the same filesystem as the active path (cross-filesystem rename is not atomic)?
8. What happens if a second import starts while one is in progress — serialized, rejected, or interleaved?
9. Is collision-detection normalization identical to lookup-key and index-key normalization?
10. Disposition of a validly signed snapshot with malformed NDJSON, a partial trailing line, or records missing required fields?
11. Is the schema version inside the signed bytes, and is it checked before or after signature verification?
12. Is an empty (zero-record) snapshot valid, and what index/date results?
13. Where is the snapshot read from during build, and what if USB media is removed mid-import (copy-then-process vs. read-in-place)?
14. Is the activation rename durable across power loss (directory fsync), or can a crash leave no active index?
15. For distinct serials that normalization collapses, which record is kept, and is that decided before or during index build?

I've tentatively deferred #1 and #12 to the Open Questions section above; the rest are open for your call.

**Review gate:** approve this LLD (with any numbered fixes and your triage of the gaps), or tell me what to change. On approval I'll move to Phase 3 — the `REG-*` EARS updates for the index build, activation, and no-active-snapshot behavior — and stop there for review.