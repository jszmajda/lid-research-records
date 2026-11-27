Phases 1–3 are drafted and need your review before anything goes further. Phase 4 (edge audit), tests, and code are not started.

## Phase 1: HLD check

The HLD still covers the registry. Choosing SQLite doesn't change the architecture, because the backend is private to the registry node. I made one edit to `docs/high-level-design.md`: "Its private lookup backend remains open" became "Its lookup backend is private to this node." The old wording would be stale now.

The on-site HTTPS directory and the managed search service both need network access at lookup time, which the HLD's no-runtime-network tenet forbids. SQLite is the only option left under that tenet. I recorded the choice as a Decisions row, not a decision doc, because an inherited constraint settles it. The cost you accepted (each kiosk rebuilds its own index) is noted in the LLD.

## Phase 2: LLD (`docs/intent/registry/registry-design.md`)

- **Architecture:** `findBySerial` is unchanged. Snapshot validation, index preparation, and lookup stay in the registry. The backend is a local SQLite file built from each snapshot.
- **Import, in order:** verify the signature with the bundled key, reject unsupported schema versions, write a staging index, run SQLite's integrity check, then activate by renaming the staging file over the active file. A failed step deletes the staging file and leaves the previous snapshot active. Staging and active files coexist during import, so import needs free disk space for a second index.
- **Lookup:** normalize whitespace and ASCII case, then do one keyed query on the normalized serial. Punctuation stays significant. The snapshot date is returned even on NotFound.
- **Decisions & Alternatives:** backend (SQLite vs. HTTPS directory and managed search, both eliminated by the tenet); activation (rename vs. in-place update, which can expose a partial import); index key (normalized, because lookup normalizes its input).

**Edge-case probe (delegated to a blind reader that saw only the docs).** Its findings:

1. Crash or power loss mid-import: no cleanup rule for a leftover staging file, and no rule for which file lookups open on restart.
2. Duplicate detection has no step in the import sequence. It's implied by the index key, but that's not stated.
3. The lookup result has no error variant for a missing, unreadable, or corrupt index.
4. The active file is not re-checked after activation.
5. In-flight lookups during the rename, and whether two imports can run at once.
6. No record-level validation: malformed lines, missing dates, empty serials, zero-record snapshots.
7. Disk-space check timing and failure reporting.
8. Whether activation counts as successful if removing the old file fails, and whether the old snapshot can be restored.
9. Which whitespace characters count, and whether import-time and lookup-time normalization are the same rule.
10. Missing or malformed manifest, and which error wins when a snapshot is both unsigned and on an unsupported schema.
11. Whether the 250 ms target covers cold cache, first lookup after start, or lookups during an import.

Items 1–11 above are the gap list, and I haven't resolved any of them.

## Phase 3: EARS specs (`docs/intent/registry/registry-specs.md`)

```
- [ ] **REG-001**: When a serial-number lookup is requested, the system SHALL normalize surrounding whitespace and ASCII letter case before returning a matching record or NotFound.
- [ ] **REG-002**: When a lookup completes, the system SHALL include the active snapshot date in the result.
- [ ] **REG-003**: When a snapshot has an invalid signature, an unsupported schema version, or duplicate serial numbers, the system SHALL reject the import and retain the active snapshot.
- [ ] **REG-004**: When a valid replacement snapshot is activated, the system SHALL expose all of its records together without exposing a partially imported snapshot.
- [ ] **REG-005**: When a serial-number lookup is requested, the system SHALL answer it from the active local index file without any network access.
- [ ] **REG-006**: When a serial-number lookup is requested against a 90,000-record snapshot on a kiosk with 4 GB of RAM, the system SHALL return the result within 250 ms.
```

REG-005 and REG-006 are new. They pin the no-network tenet and the 250 ms goal, which had no spec before.

**Consistency report:**
- **Coverage:** the LLD's behaviors each have a spec. Gap: nothing covers the no-snapshot state (see question 2 below).
- **Contradiction:** REG-003's "duplicate serial numbers" depends on whether the check is case- and whitespace-normalized. That's question 1.
- **Implicit scope:** REG-005 and REG-006 name their scope (local index, dataset size, hardware).
- **Context-free reading:** each line stands alone.

## Questions for you

These are forks, so I'm not picking a reading:

1. **Duplicate serials:** do serials that differ only in case or surrounding whitespace count as duplicates under REG-003? The index key is the normalized form, so a raw-form check and a normalized-form check give different results.
2. **Fresh kiosk with no snapshot:** what should `findBySerial` return? Both result types carry a snapshot date, and none exists yet.
3. **Older snapshot:** may an import activate a snapshot dated earlier than the active one?
4. **Signature coverage:** does the manifest cover the whole NDJSON file? Which bytes does it hash?

For the other gaps (items 1, 4–11 in the probe list), tell me which to fix in the LLD now and which to defer as open questions. My recommendation is to fix the crash-recovery rule (1), the error shape (3), and normalization identity (9) now, because the import and lookup behavior depends on them. Defer the rest.

Once you answer these and triage the gaps, I'll revise the LLD and specs, then move to the Phase 4 edge audit.