I've updated the registry design (Phase 2) for the local SQLite index and stopped there. Specs, tests, and code are untouched.

## One thing to know about the choice

The three options weren't as close as they looked. The HLD tenets say "All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted" and list "remote access, or cloud services during kiosk operation" as a non-goal. The on-site HTTPS directory and the managed search service both break that. SQLite was the only option the existing intent allowed. I recorded it that way, so the choice is a Decisions row rather than a standalone decision doc.

## What changed

**`docs/intent/registry/registry-design.md`**
- **Backend:** lookup is served from a private local SQLite index on the kiosk, and no other node opens it.
- **Import:** each kiosk builds the new snapshot's index in a staging location. It activates with a single atomic switch only after signature, schema, uniqueness, and index build all succeed. This realizes REG-003 and REG-004 and the tenet that a failed import leaves the last valid snapshot available.
- **Lookup:** an exact-match query on the serial key of the active index, opened read-only.
- **Decisions & Alternatives:** a new row with the chosen backend, the two rejected options, and the rationale above.

**`docs/high-level-design.md`**: one line changed, from "private lookup backend remains open" to "a local SQLite index on the kiosk". Please confirm this is acceptable.

The certificates node is unaffected, since its interface is unchanged.

## Gaps in this design (edge-case probe)

Which of these should be fixed in the design now, and which deferred as open questions?

1. **Normalization at import vs. lookup.** Lookup trims whitespace and uppercases ASCII, but nothing says whether snapshot serials are normalized the same way. If a record is stored as `ab-12` and a lookup normalizes to `AB-12`, the record is unreachable. This is a spec fork, and it also affects the uniqueness check: are `ab-12` and `AB-12` duplicates?
2. **Interrupted import or power loss mid-switch.** What does the kiosk see on restart: the old index, or a leftover staging index? Should leftover staging data be cleaned up?
3. **Corrupt or missing active index at startup.** Does the registry report an error, or fall back to the previous index, and does it keep one?
4. **Disk space.** Snapshots can reach 150 MB, and the active and staged indexes coexist during import. Should insufficient space be a reported import failure that leaves the active snapshot untouched?
5. **Import during lookup.** Lookups running while an import builds, or at the moment of the switch, should see exactly one whole snapshot.
6. **Non-ASCII or empty serials.** Empty or whitespace-only input, and non-ASCII letters (which are not case-folded), are unspecified. Does an empty serial return NotFound?
7. **Latency and import time.** The 250 ms lookup goal is not tied to the index design. Is a time or size bound on import worth stating?
8. **Re-importing the active snapshot.** Does it do nothing, or rebuild?

## Please check

I can't tell whether you want to settle the normalization question (gap 1) as part of the design or leave it open, so it's yours to rule on. It is the one that changes what the specs say.

Once you've triaged the gaps and approved the design, I'll move to Phase 3 and draft the EARS spec updates for the registry.