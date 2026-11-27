Registry LLD is drafted. Here's the Phase 2 output and the probe findings.

## What landed

**`docs/intent/registry/registry-design.md`** — rewritten around the local SQLite index:

- **Index Layout** (new): one SQLite file per snapshot generation, `equipment(serial_key PRIMARY KEY, serial_raw, description, calibration_date, due_date)` plus a single-row `snapshot_meta(snapshot_date, schema_version, index_format)`. A pointer file names the active generation and is the only thing a lookup consults.
- **Snapshot Import**: staged build — verify signature and schema version before reading records, build into a staging path in one transaction (the primary key makes a duplicate serial a build-time conflict), confirm record count, then rename in and rewrite the pointer. The pointer rewrite is activation, so any earlier failure leaves the active generation untouched.
- **Lookup Behavior**: same normalization function at build time and query time; read-only open, primary-key probe, so a 150 MB snapshot never has to be resident on a 4 GB kiosk.
- **Decisions & Alternatives** (new): four rows — backend, index representation (vs. in-memory map / sorted flat file), activation via pointer file, and uniqueness enforced on the normalized key rather than the raw serial.

**`docs/high-level-design.md`** — one-line coherence fix: the Architecture bullet said the lookup backend "remains open," which is now false. I folded that into this pass rather than taking a separate Phase 1 stop for a single stale clause; say so if you'd rather I had paused there.

**Certificates**: no cascade. `findBySerial` and its result types are unchanged, and that node's "registry storage is invisible to me" stance still holds.

## On recording the choice

I recorded it as a Decisions row, not a decision doc — and the reason is worth your attention rather than mine. Two of the three options I sketched put a network dependency in the lookup path, which the HLD's own tenets flatly forbid ("no runtime network access is permitted"; "Kiosks have no network route during normal operation"). So the options weren't as close as they looked; I should have named the tenet when I sketched them, and you spent deliberation on a comparison that an inherited constraint had already settled. Once it lands, a cold reader holding those tenets reads a local file-based index as native, which is the bar for a row rather than a doc. If you think those tenets are themselves in play — that an on-site service is worth reopening them for — that's a different and larger conversation, and I'd rather have it than let the row quietly close it.

What a cold reader *would* question is SQLite over an in-memory map or a sorted flat file, so that got its own row.

## Edge-case probe

I delegated this to a subagent given only the design docs and specs, never this conversation. It returned 12 items; grouped and triaged, with my recommendation:

1. **The result type has no failure case.** `Found`/`NotFound` can't express "pointer missing," "database won't open," "corrupt index," or "`index_format` newer than this build." The readings fork: these surface as exceptions outside the documented interface, or collapse into `NotFound` — which tells a technician "no such gauge" when the truth is "index broken." **This crosses into certificates' territory**, since a third result case changes the interface that node consumes. Recommend fixing, but it needs your call before I touch anything on the certificates side.
2. **Activation crash window.** I called the pointer rewrite atomic without naming the mechanism, and nothing reclaims a fully built generation orphaned by a crash between rename and rewrite. Also unsaid: whether a lookup straddling activation can pair a record from one generation with a snapshot date from another. Recommend fixing both in the LLD.
3. **Import concurrency and generation identity.** How a generation ID is derived, and what happens on two concurrent imports or a re-import of the same snapshot, are unspecified. Recommend fixing.
4. **Disk space.** Each generation is a separate retained file at up to 150 MB, with no free-space precondition and no bound on garbage from repeatedly failed builds. Open Question 1 covers *superseded* generations, not *failed* ones. Recommend at least the failed-build cleanup now.
5. **Record-level validation.** Step 3 checks only count. Malformed lines, empty-after-normalization serials, missing `description`/`due_date` — all unsaid, as is the error shape REG-003 reports (does it name the conflicting serial?). Recommend fixing; it's mostly spec work in Phase 3.
6. **Normalization boundaries.** Empty or whitespace-only query; interior whitespace; non-ASCII letters, where my uniqueness argument silently doesn't apply since only ASCII case folds. Recommend fixing.
7. **`snapshot_meta` "exactly one row"** is asserted with no enforcement and no behavior when violated. Low stakes; fine to defer.

Already deferred in the LLD: retention policy, `index_format` upgrade remediation, and what `findBySerial` returns before any snapshot has ever been imported — the last one tensions with REG-002's "SHALL include the active snapshot date," and item 1's resolution probably decides it.

The probe pushed hardest on the activation sequence and on the fixed result type — it kept returning to the same gap from different angles. Happy to show you its raw output on either if you want to check my grouping.

**Which of 1–7 do you want fixed in the LLD now, and which deferred?** And on item 1: may I extend the result type into certificates' territory, or should that stay a registry-internal concern for now? Once you've ruled, I'll revise and move to Phase 3 (EARS) — I expect REG-003 to split along item 5, plus new specs for the failure result and the no-snapshot case.