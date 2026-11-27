Phase 2 — registry LLD updated for the local SQLite index, and the LLD-level edge probe is back for your triage.

**What I wrote into `docs/intent/registry/registry-design.md`**

- Lookup is served by a local embedded SQLite index file on kiosk storage, built per kiosk from the snapshot it imports, opened read-only, resolved by exact match on an indexed column.
- The index also holds the snapshot metadata (snapshot date, snapshot schema version, index layout version), so a lookup reads the record and the date from one file and the two can't disagree across an import.
- Import builds into a new file beside the active one and swaps only after the build and all validation succeed — the previous index serves lookups for the whole build.
- Serial uniqueness is enforced by a unique constraint on the serial column, so a duplicate fails the build rather than needing a separate validation pass.
- Normalization has one implementation used twice: the index stores normalized serials, a lookup normalizes its argument. That's what keeps exact-match lookup inside the 250 ms goal at 90,000 records.
- Decisions & Alternatives now carries four rows: index activation, normalized-serial storage, metadata location, duplicate detection.

**One thing worth naming about the choice itself.** Two of the three options were already closed by the HLD: *"All serial-number lookup SHALL complete using files on the kiosk; no runtime network access is permitted"* and *"Kiosks have no network route during normal operation."* The on-site HTTPS directory and the managed search service both need a runtime network route for registry lookups, so they contradict those tenets rather than trading against them. That's likely part of why the three felt close and the deliberation dragged — the sketch presented them as peers. If you do want a network-backed backend on the table, that's an HLD-level tenet change first, not a registry decision. Otherwise the backend choice reads as settled by inherited constraint, so I recorded no decision doc and no row for "why SQLite" — the rows I added are for the sub-decisions SQLite actually forces.

**HLD coherence — needs your nod.** `docs/high-level-design.md:13` still says *"Its private lookup backend remains open."* That line is now stale, but it's the root node, so I left it alone. Want me to drop that sentence (the rest of the line stands)?

**Edge probe — triage these: fix in the LLD now, or defer as open questions?**

1. **No result state for "no index yet."** `findBySerial` returns only `Found(record, snapshotDate)` or `NotFound(snapshotDate)`, both carrying a date. A freshly provisioned kiosk that has never imported a snapshot has no date to return, and the design names no third state.
2. **Duplicate detection sits on the normalized column, REG-003 says "duplicate serial numbers."** Two records whose raw serials differ but normalize identically (`ab-1`, `AB-1`) — rejected as duplicates, or is uniqueness meant to apply to raw serials, in which case the normalized column has to tolerate collisions? This one changes what REG-003 means, so it's the gap I'd most want settled before Phase 3.
3. **"Reports a useful error" has no shape.** Five failure causes are named with no error set, and nothing distinguishes "re-request the snapshot from the inventory team" from "free disk space."
4. **Swap semantics are unstated** — atomic rename over a fixed path, a pointer file, or a directory switch? And what happens to a lookup already holding the old index open when the swap lands. The "one file, can't disagree" invariant leans on this.
5. **Snapshot-date monotonicity.** Importing a validly signed but *older* snapshot than the active one passes every stated check. Legitimate rollback, or blocked?
6. **Partial-index lifecycle.** A failed build leaves a file "unusable to lookup" without saying what makes it unusable or who deletes it — so the next import may find the new-file path occupied.
7. **Concurrent or re-entrant imports.** The design assumes a single build slot; a second import started mid-build, or an import begun before an interrupted file is reclaimed, is unaddressed.
8. **Degenerate lookup input** — empty normalized string, interior whitespace, non-ASCII characters: `NotFound`, or an input-validation error?

Minor: whether normalization *semantics* drift is covered by the index layout version (it rides the same field), and an invariant that exactly one non-empty snapshot-metadata set exists in a readable index (REG-002 needs a date on every result).

Already captured as open questions in the LLD, not re-litigated here: snapshot retention / unreadable active index, free-space preflight, layout-version mismatch, lookups during import.

Tell me which of 1–8 to fold into the LLD and which to defer, plus your call on the HLD line, and I'll revise before moving to Phase 3 (EARS).