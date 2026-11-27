I've recorded SQLite as the registry's lookup backend and stopped at the Phase 2 review. The registry EARS specs (Phase 3) are not drafted yet.

**What changed**
- **`docs/intent/registry/registry-design.md`**
  - Architecture now says lookup is served from a local embedded SQLite index that each kiosk builds from the snapshot it imports.
  - Snapshot Import builds the index in a separate staging file and activates it only after signature, schema, uniqueness, and index build all succeed. A failure discards the staging file and keeps the previous index active.
  - Lookup Behavior is an exact match of the normalized serial against the active index.
  - New Decisions & Alternatives row for the backend choice, naming the two rejected options and why.
- **`docs/high-level-design.md`**: I changed one line, because "backend remains open" had gone stale. The Registry bullet now names the SQLite index. This is the only edit outside the registry segment. Certificates is untouched, since its interface doesn't change.

**On the decision record**
The tenets already settle this choice. "No runtime network access" and "no network route during normal operation" rule out the HTTPS directory and the managed service, so the options were closer on cost than on fit. That is why it's a table row and not a full decision doc.

**Gaps from the LLD edge-case probe**
Please triage each as fix in the LLD or defer.

1. **Normalization collisions (needs your call).** REG-003 rejects duplicate serials. Do `ab-1` and `AB-1` count as duplicates?
   - If yes, the import rejects the snapshot.
   - If no, one lookup could match two records.
   - I would reject, since lookup normalizes both sides, but you should decide.
2. **Disk space.** The staging index needs room beside the active one, on top of a snapshot of up to 150 MB. What should happen when there isn't enough, and should the import check up front?
3. **Interrupted import.** If power is lost mid-build or mid-activation, should the kiosk start on the previous snapshot and clean up the stale staging file?
4. **Corrupt or missing active index at startup.** Possible options:
   - Return a distinct lookup error.
   - Rebuild from the retained snapshot, if one is kept.
   - Require a re-import.
5. **First run.** No snapshot is active yet. Does `findBySerial` return an error or `NotFound`? `NotFound` can't work, since it needs a snapshot date.
6. **Activation during a lookup.** Should an in-flight lookup finish against the old index, with new lookups seeing the new one?
7. **Index build time.** The 250 ms goal covers lookup only. Should there be an import-duration expectation for a 90,000-record or 150 MB snapshot on kiosk hardware?
8. **Which snapshot is "previous".** Is the previous index kept only until the next activation, or is the old snapshot file retained as well?

Capability flags: the flags file lists none, so nothing applies here.

Reply with numbered feedback on these gaps (especially 1) or approve the LLD, and I'll move on to the EARS specs.