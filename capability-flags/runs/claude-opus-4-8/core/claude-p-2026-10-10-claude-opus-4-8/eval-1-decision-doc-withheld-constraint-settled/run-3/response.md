I've finished the registry LLD around the local SQLite index. This is the Phase 2 (LLD) stop — here's what changed and what I need from you before cascading to the EARS specs.

## `registry-design.md`
- **Architecture** now names the backend: lookup resolves against a private, on-kiosk SQLite index each kiosk builds from the active snapshot. The `findBySerial` interface and result types are unchanged, so certificates are untouched.
- **Snapshot Import** now folds index-building into the import transaction: build the index in staging, activate only after signature + schema + uniqueness + build all succeed, and a build failure is an import failure that retains the previous snapshot (honoring the "failed import leaves the last valid snapshot" tenet).
- **Lookup Behavior** pins normalization to run identically at build time and query time, so a lookup is one indexed match.
- Added a **Decisions & Alternatives** row and an **Open Questions** list (see below).

## `high-level-design.md` (please confirm — this touches the root)
The HLD line said the registry's backend "remains open," which is now stale. I changed it to point at the registry node for the recorded choice. It's a one-line coherence fix, but it's upstream of the registry segment, so I'm flagging it rather than treating it as free cascade — say the word if you'd rather I revert it.

## How I recorded the decision — and one thing worth your eye
I recorded this as a **Decisions & Alternatives row, not a full decision doc.** Here's why, and it's the part I'd most like you to check: the two alternatives you weighed against SQLite both require network access *at lookup time* — the HTTPS directory over the lab network, the managed service over external connectivity. The HLD tenets ("no runtime network access," "no network route during normal operation") and the "no cloud services during kiosk operation" non-goal rule both of those out as gates, not just score them lower. So under the project's current tenets, SQLite is the only option that clears the bar — an inherited-constraint-settles case, which the skill says gets a row, not a doc.

That may be exactly what you intended, but it's worth naming: the three options felt close on maintenance/cost/extensibility, yet the no-network tenet makes them not actually interchangeable. **Did you intend those tenets to stand (making SQLite effectively forced), or were you contemplating relaxing them?** If they stand, the row as written is right; if you were open to revisiting them, this reopens as a genuine HLD-level choice.

## Edge probe — gaps I want you to triage before specs
The LLD lists these under Open Questions; the first one needs a decision before I can write specs cleanly:

1. **Uniqueness under normalization (needs your call).** REG-003 rejects duplicate serials, but two records whose serials differ only in surrounding whitespace or ASCII case collapse to one normalized key. Is uniqueness enforced on **raw** serials (both import, then compete for one key at lookup — nondeterministic) or on **normalized** serials (the collision is rejected at import)? This changes both import validation and lookup determinism, and it likely needs a spec line.
2. **Activation crash recovery** — exact mechanism guaranteeing one complete active index after a crash mid-swap.
3. **Disk headroom / old-index cleanup** — a kiosk briefly holds both indexes during import.
4. **Build memory bound** — streaming the build to stay within 4 GB RAM for 150 MB snapshots.

Items 2–4 I think can ride as deferred implementation constraints unless you want any promoted to specs now.

The existing REG-001–004 specs are backend-agnostic and need no change from choosing SQLite — the one likely spec addition is whatever you decide for #1. **Approve the LLD (and the HLD line), and tell me your call on the uniqueness question, and I'll cascade to the EARS specs.**