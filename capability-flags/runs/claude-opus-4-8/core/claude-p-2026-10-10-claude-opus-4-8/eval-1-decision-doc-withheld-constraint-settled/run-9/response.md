Phase 2 is drafted. Here's where the registry LLD stands and what needs your call before I touch EARS.

## What I finished

**`docs/intent/registry/registry-design.md`** — committed the lookup backend to the local embedded SQLite index:
- **Architecture**: the index is now described as a *derived, on-kiosk artifact* — built from a validated snapshot's records, never transferred between kiosks. The signed snapshot stays the only authoritative input and update channel; `findBySerial` and its result types are unchanged.
- **Snapshot Import**: rewrote as a fixed 6-step order (verify signature → reject bad schema → validate uniqueness → **build index into a temporary DB** → **verify built index against the snapshot** → **atomic swap**), so any failure — including a failed build or verification — keeps the previous snapshot/index active and discards the temp index. This preserves the two offline tenets (last valid snapshot survives; no partial exposure).
- **Lookup Behavior**: normalized serial resolved as an exact-match single-record query through the index.
- **Decisions & Alternatives**: recorded the backend choice as a table row with both rejected alternatives and why. I did *not* open a full decision doc: once it lands, the offline tenets ("no runtime network access," "kiosks have no network route") make an on-kiosk backend the native choice and rule out both networked alternatives, so a cold reader wouldn't re-litigate it — a row carries it. Say the word if you'd rather have the standalone doc.

**`docs/high-level-design.md`** — the registry bullet said "lookup backend remains open," which is now stale, so I changed that one clause to note the backend is on-kiosk and internal to the node. The decision's substance stays in the registry segment; this is just a coherence touch to the root.

## Edge-probe gaps to triage (Phase 2)

A blind probe against the LLD's own internals surfaced these. Tell me which to pin down in the LLD now vs. defer as open questions:

1. **Raw vs. normalized uniqueness** *(already recorded as open; flagging as the one that most needs your call)* — step 3 validates uniqueness on raw serials, but lookup uppercases. `abc` and `ABC` are both unique raw yet collide in the index. This changes what REG-003 means, so it should be settled before I revise specs.
2. **No snapshot ever imported** — what does `findBySerial` return before any successful import? There may be no snapshot date to return, yet REG-002 says every result includes one.
3. **Crash mid-swap (step 6)** — if the process dies during the atomic swap, what's the restart state? (Related to the recorded corrupted-index open item, but about swap ordering specifically.)
4. **Empty but valid snapshot** — zero records passes the count check (0 == 0) and activates an index that answers every lookup NotFound. Intended, or reject?
5. **Older/equal snapshot re-imported** — since snapshots arrive by USB, is activating an older-dated snapshot allowed, or rejected?
6. **Malformed record** — where in the order does NDJSON parsing / required-field validation sit, and what happens to a bad line?
7. **Error shape** — "reports a useful error" is unspecified; should import distinguish bad-signature vs. bad-schema vs. duplicate vs. build-failure?

(Lower-priority ones I can also fold in: concurrent imports on one kiosk, supported-schema-version boundary, whitespace-only query, temp-file cleanup after a crash.)

**This is the Phase 2 stop.** Once you've reviewed the LLD and told me how to resolve #1 (and which others to fix now), I'll move to Phase 3 and update the REG specs. Nothing cascades to specs, tests, or code yet.