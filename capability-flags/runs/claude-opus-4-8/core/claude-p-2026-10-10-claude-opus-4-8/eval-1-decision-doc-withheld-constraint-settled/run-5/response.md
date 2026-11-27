I've drafted the updated registry LLD around the local SQLite index (Phase 2). This is the Phase 2 stop — please review before I cascade into the EARS specs.

## What changed in `registry-design.md`

- **Architecture** now names the backend: a local embedded SQLite index file, built and queried in-process on the kiosk, kept private behind `findBySerial`. The result type stays fixed, so certificates are untouched.
- **Snapshot Import** folds index-building into validation as a fourth step and makes activation an atomic swap; any failure (including a failed index build, e.g. disk full) aborts and leaves the previous index active. It states plainly that each kiosk validates and rebuilds its own index.
- **Lookup Behavior** resolves the normalized serial against the active index, with normalization applied identically at build time so keys match.
- **Decisions & Alternatives** records the backend choice with both rejected options and why.

## One thing I need you to weigh (tenet/goal conflict)

While recording the alternatives I noticed the three options weren't actually as close as they felt. Two of them break HLD tenets:

- The **on-site HTTPS directory** and the **managed search service** both require a runtime network route for registry lookups. The HLD tenets say *"no runtime network access is permitted"* and *"Kiosks have no network route during normal operation"*, and the managed service also hits the *"no cloud services during kiosk operation"* non-goal.

So the local SQLite index isn't just the one you preferred — it's the only one of the three that's eligible under the current HLD. That's worth flagging because it changes how I'd record the decision: since an inherited constraint (the tenet) eliminates the alternatives rather than a close judgment call, **a Decisions & Alternatives row is the right weight — not a standalone decision doc.** I've written it as a row. If you actually intend the kiosks to gain a network route (which would reopen the other two options), that's an HLD change and we should start there instead.

## Also needs your call

1. **Stale HLD phrase.** The HLD architecture line still says the registry's *"private lookup backend remains open."* With the backend chosen, a fresh author would drop "remains open" and just call it private/internal. That's a one-phrase edit to the root HLD — may I make it?
2. **Edge-probe gaps** (Phase 2, this LLD's own gaps — triage which to pin down now vs. defer):
   - **Validation ordering** — I put signature → schema → uniqueness → index build. Is that the order you want (cheapest/most-security-relevant check first)?
   - **Concurrent lookup during import** — the design assumes a single-user kiosk so a lookup can't race the atomic swap. Is that assumption safe to bake in?
   - **Index storage location / previous-index retention** — I deferred this as an implementation detail under the atomic-swap guarantee. OK to leave deferred?

Once you've signed off on the LLD (and the items above), I'll cascade to the EARS specs — I expect REG-003/REG-004 to stay as-is but want to check whether "failed index build is an import failure" deserves its own spec line rather than riding inside REG-003.