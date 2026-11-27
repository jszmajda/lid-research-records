I've updated the registry LLD (`docs/intent/registry/registry-design.md`) for the local SQLite index. This is the Phase 2 stop. I haven't touched EARS specs, tests, or code.

## What changed in the LLD
- **Architecture:** Lookup now uses a local embedded SQLite index on each kiosk. The index is private to the registry, and certificates still sees only `findBySerial`.
- **Snapshot Import:** The new snapshot's index is built in a staging file. It is activated by one atomic switch, and only after validation and the build both succeed. A failed import leaves the active index untouched.
- **Local Index (new section):**
  - Each kiosk builds its own index from the signed snapshot.
  - Rows are keyed by the normalized serial, with snapshot date and schema version stored alongside.
  - Lookup is a single read-only keyed read with no network access.
  - The staging build is verified by row count before activation.
  - The old index is deleted only after the new one is active.
- **Decisions & Alternatives:** I added a row for the backend choice and a row for staging-then-switch activation.
- **Alternatives:** The HTTPS directory and managed search service are recorded as alternatives. Both would need runtime network access, which the HLD tenets rule out.

I did not offer a separate decision doc. The no-network tenet settles the choice, so the Decisions row is enough.

## Edge-case probe: gaps in this LLD
Please triage each as fix now in the LLD, or defer:

1. **No snapshot yet:** What does `findBySerial` return on a fresh kiosk with no imported snapshot? `NotFound` needs a snapshot date, and there isn't one.
2. **Corrupt active index:** What happens if the active index file is unreadable or fails an integrity check? Does the kiosk refuse lookups, or fall back to the previous index? The previous index is deleted after activation.
3. **Previous index retention:** Should the previous index be kept after activation as a fallback? That would cost disk space but give a recovery path.
4. **Uniqueness definition (spec fork):** Is uniqueness checked on the raw serial or the normalized serial? Under the normalized check, `ab-1` and `AB-1` collide. Under the raw check, they would both import, and the index keyed on the normalized serial would have a conflict. REG-003 doesn't say which, so I need your ruling.
5. **Disk space:** The staging and active indexes coexist during import, at snapshots up to 150 MB. What happens if there isn't room? Should this be a checked import failure with a clear message?
6. **Interrupted import:** If power is lost mid-build, is the staging file discarded on the next start? Is it ever mistaken for the active index?
7. **Concurrent lookup during activation:** A lookup in flight during the switch should see either the old index or the new one, never a mix.
8. **Normalization vs. stored serials:** Are stored serials normalized at import, or only the query? The LLD currently implies the index key is normalized at import.
9. **Lookup latency:** The 250 ms goal on a 4 GB kiosk with 90,000 records should hold for a keyed read, but there is no spec or test that pins it.

Items 1, 2, 5 and 8 are already in the LLD's Deferred list, plus item 4 as "uniqueness basis". Tell me which gaps to resolve in the LLD, and I'll then move to Phase 3 (EARS updates).

**Note on capability flags:** `references/capability-flags.md` lists no flagged configurations, so there is nothing to raise there.