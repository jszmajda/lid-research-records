I've drafted the registry LLD around the local SQLite index and run the gap probe. This is Phase 2 of the workflow, so I'm stopping here for your review before touching the specs.

## What changed

- **`docs/intent/registry/registry-design.md`**
  - Lookup is now served from a local embedded SQLite index, built on the kiosk at import.
  - Import runs in four steps: verify the signature, reject unsupported schema versions, build the index in a staging location (enforcing uniqueness), then activate it with one atomic switch.
  - Lookups keep using the old index until that switch, and any failure discards the staged index.
  - The "Decisions & Alternatives" table records the backend choice and the staged-then-switch activation.
- **`docs/high-level-design.md`**: one line. It said the backend "remains open"; it now names the local SQLite index.

## The other two options were already ruled out

The HLD tenets say lookup completes from files on the kiosk with no runtime network access, and that signed USB snapshots are the only update channel. That excludes the on-site HTTPS directory and the managed search service regardless of how close they looked. The Decisions table records it that way, so the choice should not need re-arguing. That is also why I didn't offer a separate decision doc: an inherited constraint settles it.

## Gaps for you to triage

Each one is either fixed in the LLD now or deferred as an open question.

1. **Uniqueness before or after normalization.** Do `ab-1` and `AB-1 ` count as duplicates? REG-003 and REG-001 don't say. This is a real fork, and it decides whether such a snapshot imports or is rejected.
2. **Staging space and cleanup.** Two index files coexist during import, and a crash can leave a stale staged file. Should the next start clean it up?
3. **Active index damaged at rest.** If the active index file is corrupt or missing at startup, should lookup report an error, or should the index be rebuilt from the retained snapshot? That depends on whether the snapshot file is kept.
4. **Which snapshot file is retained.** The design never says whether the NDJSON snapshot is kept after the index is built.
5. **Rebuild time.** For snapshots up to 150 MB there's no stated bound on import duration, and no statement about what the technician sees during it. The 250 ms goal covers lookup only.
6. **Lookup during import.** Is `findBySerial` allowed to run while an import is in progress? The design implies yes, but no spec says so.
7. **Atomic switch and power loss.** If power drops mid-switch, which index is active on the next boot?

I ran the probe in-context rather than through a subagent. The workflow lists no capability flags that apply to this model.

## Next

Tell me which of 1–7 to fix in the LLD and which to defer. Item 1 needs your decision, since it changes what REG-003 means. Once you approve, I'll move to Phase 3 and draft the EARS updates, with new specs for staged activation and uniqueness.