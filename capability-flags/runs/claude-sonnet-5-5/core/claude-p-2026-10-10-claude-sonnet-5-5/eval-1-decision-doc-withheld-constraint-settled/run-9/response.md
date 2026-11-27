The registry LLD now commits to the local SQLite index (`docs/intent/registry/registry-design.md`). I stopped at the LLD phase; specs, tests and code have not been touched.

**What changed**
- **Architecture:** lookup runs against an embedded SQLite index on the kiosk. The index is private to the registry, and certificates still sees only `findBySerial`.
- **Snapshot Import:** each kiosk builds its own index into a staging file and stores the snapshot date in it. Activation is a single atomic rename after all validation and index construction succeed. A failed import discards the staging file and leaves the previous index active.
- **Lookup Behavior:** serials are stored normalized under a unique index, so a lookup is one indexed equality query reading only local files.
- **Decisions & Alternatives:** I added two rows, one for the backend and one for staged-build-plus-rename activation.

**One thing you might not expect:** the options were closer in your head than in the HLD. The HLD tenets (no runtime network access, no network route on kiosks) and its non-goals rule out the HTTPS directory and the managed service. I recorded that as the rationale. Because an inherited constraint settles the choice, I did not offer a full decision doc.

**Edge-case probe: gaps in this LLD**
1. **Duplicates after normalization.** REG-003 says "duplicate serial numbers", and lookup uppercases and trims. Should `ab-1` and `AB-1` in one snapshot count as duplicates and be rejected? If not, the unique index on the normalized serial cannot hold both. This is a real fork, so I need your ruling before specs.
2. **Corrupt or missing active index at startup.** The active index could be damaged, or absent on first run. Should `findBySerial` return an error distinct from `NotFound`, and what does the technician see before any snapshot is imported?
3. **Crash mid-import.** An interrupted import leaves a stale staging file. Should the next import or startup clean it up?
4. **Insufficient disk for the staging index.** Should the import check free space first and fail with a clear error?
5. **Activation while a lookup is in flight.** The design implies an in-flight lookup finishes against whichever index it opened. Is that acceptable?
6. **Index build time.** A 150 MB snapshot at 90,000 records builds on the kiosk. Do you want a time or progress expectation for imports, or is the 250 ms goal for lookups only?
7. **Re-importing the same or an older snapshot date.** Should it be accepted, rejected, or warned about?

Which of these should I fix in the LLD now, and which should stay in an Open Questions section? Item 1 needs an answer before Phase 3 (EARS specs). Once you approve the LLD, I'll move on to the specs.