The Phase 2 registry LLD is drafted in `docs/intent/registry/registry-design.md`. It now defines:

- Per-kiosk immutable SQLite indexes built from signed snapshot files.
- Streaming import with normalized serial numbers as unique keys.
- Staged database construction, integrity checking, and atomic generation activation.
- Startup validation, local index rebuilding, and fallback to the previous generation.
- Exact read-only lookup with record and snapshot date read from one generation.
- Decision rationale covering SQLite, generation switching, and normalized keys.

Before Phase 3 specifications, please review the design and triage these edge-case gaps:

1. Should registry unavailability extend `findBySerial` with an `Unavailable` result, or should it be raised as an operational error outside the result type?
2. Should imports reject snapshots older than the active snapshot? How should identical snapshots or the same date with different content be handled?
3. May a valid SQLite index remain usable if its retained signed source files are missing or corrupt, or must that generation become unusable?
4. Should import, recovery, activation, and cleanup be serialized under one registry-wide lock?
5. If a lookup encounters an SQLite or I/O failure after startup validation, should it trigger recovery, fall back to the previous generation, or immediately report unavailable?
6. If the active pointer is missing or damaged, may startup discover and select the newest valid retained generation, or must it report unavailable pending a new import?
7. Which record rules should be fixed now: required fields, date formats and ordering, maximum field lengths, Unicode policy, blank NDJSON lines, and unknown JSON fields?
8. `docs/high-level-design.md:13` still says the registry backend “remains open.” May I remove that now-stale phrase as a coherence correction?

Reply with numbered decisions and any other LLD changes. I’ll revise the design and stop again for approval before drafting EARS specifications.