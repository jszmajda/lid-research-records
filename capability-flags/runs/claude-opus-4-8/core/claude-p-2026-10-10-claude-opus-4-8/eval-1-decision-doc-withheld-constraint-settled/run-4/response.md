Registry LLD drafted and the HLD's "backend remains open" note updated to match. Here's the Phase 2 output for your review.

## What changed

**`docs/intent/registry/registry-design.md`**
- **Architecture** — lookup is now served from a local embedded SQLite index on the kiosk. The signed snapshot stays the unit of distribution and trust; the SQLite index is a *derived* artifact each kiosk builds for itself from a snapshot it has already validated. The `findBySerial` interface and result types are unchanged, and the backend stays invisible to certificates.
- **Snapshot Import** — validation (signature, schema, uniqueness) now feeds an index build in a temp location, activated by atomic rename only after the build completes; any step failing leaves the prior snapshot and index in place.
- **Lookup Behavior** — normalize, then a single keyed-equality query, meeting the 250 ms / 90k-record budget.
- **Decisions & Alternatives** — a row recording SQLite over the HTTPS-directory and managed-search options, with the tradeoffs. I did *not* open a standalone decision doc: the choice lands entirely inside the registry node (the certificate interface is identical under all three), and it's partly settled by your existing no-runtime-network tenet — the networked options sit against it — so the row carries the reasoning a cold reader would want. Say if you'd rather have the fuller doc.

**`docs/high-level-design.md`** — the registry bullet's "lookup backend remains open" line now names the SQLite index. That's a one-line note staying current, not an architecture change; flagging it because it touches the root.

## Edge probe (Phase 2 — this LLD's own gaps)

A blind reader given only the draft surfaced these. They're for you to triage — fix in the LLD now, or defer as open questions:

1. **Normalization collision.** REG-003 checks "duplicate serial numbers," but if the uniqueness check runs on *normalized* keys, two distinct raw serials could collide into one key (and if it runs on raw serials, two could still collide at lookup). Which is authoritative, and is a post-normalization collision an import rejection?
2. **One normalization, defined once.** Index-build keying and lookup-time normalization must be the exact same operation or lookups miss. The LLD implies this but doesn't pin it as an invariant.
3. **Normalization scope.** Does "uppercase ASCII letters" deliberately leave non-ASCII letters untouched, and does "surrounding whitespace" mean interior whitespace is significant? Both readings exist in the text.
4. **Empty state / first boot.** What does `findBySerial` return before any snapshot has ever been validated, given every result must carry an active snapshot date? No state covers "no active index yet."
5. **Index recovery outside import** (already parked in Open Questions). A kiosk-built index can be lost or corrupted between snapshots — auto-rebuild from the retained snapshot, or treat as an import to re-run?
6. **Crash mid-build.** Is leftover temp index state cleaned up or reused after a failed/interrupted build?

I'd treat 1–4 as worth settling in the LLD before specs (they shape REG-001/003 and likely add a spec or two); 5 and 6 read as genuine defer candidates. A few of these (1, 3, 4) are spec forks — more than one reading — so they're yours to resolve, not mine to pick.

**Stopping here for your review.** Tell me which probe items to fix in the LLD vs. defer, how you want 1/3/4 resolved, and whether the draft otherwise reads right — then I'll cascade to the REG EARS specs (Phase 3).