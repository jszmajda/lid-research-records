Phase 2 (LLD) is drafted against your choice. Here's what changed and what I need from you before it goes further.

## What I did

**`registry-design.md` — backend now selected and specified.**
- *Architecture*: lookups resolve against "a local embedded SQLite index that each kiosk builds from the active snapshot; no service or network path is involved." The `findBySerial` interface and `Found`/`NotFound` result types are unchanged and stay private to this node.
- *Snapshot Import*: import now builds a fresh SQLite index in a staging location (keyed by the normalized serial), activates only after the build **and** all validation succeed, and counts a failed index build as an import failure that retains the previously active index.
- *Lookup Behavior*: queries the active index on its normalized-serial key — which lines up with the REG-001 normalization rule (whitespace + ASCII case).
- Added a **Decisions & Alternatives** row recording SQLite over the two networked alternatives, with the rationale that it's the only option that sits inside the HLD's no-runtime-network tenets.

**`high-level-design.md` — one coherence fix.** The Registry line read "Its private lookup backend remains open," which is now stale; I changed it to "Its lookup backend is private to this node." No architecture change.

**On recording the decision:** I recorded it as a Decisions row, not a full decision doc. Even though you went back and forth, the choice affects only the registry node (the certificate interface is identical across all three options) and the HLD's no-network tenets effectively settle it for a cold reader — so a row carries the "why" without a standalone doc. Say the word if you'd rather have the fuller decision doc.

## Phase 2 edge probe — for your triage

A blind probe of the updated LLD (given only the doc text) surfaced these internal gaps. Tell me which to fix in the LLD now vs. defer as Open Questions — I'm not resolving any of them for you:

1. **First-ever lookup** — `findBySerial` before any snapshot has imported: what's returned, and what `snapshotDate` rides along with that `NotFound`? (Same gap underlies "no previous index to fall back to" on a failed first import.)
2. **Uniqueness vs. normalization** — is uniqueness checked on the raw serial or the normalized key? Two raw serials that differ only by whitespace/case would collide on the index key — import failure, or allowed?
3. **Malformed individual record** — a record that passes signature/schema but is bad JSON or missing a required field: import failure, skipped record, or unspecified?
4. **Schema-version check** — does "unsupported" cover missing/empty/unparseable version fields, or only known-bad versions?
5. **Activation atomicity** — if a lookup arrives mid-swap or the process crashes during activation, can a half-activated or absent index be observed?
6. **Runtime query failure** — a corrupt/unreadable active index at lookup time: the fixed result types are only `Found`/`NotFound`; is there any error shape, or is that out of scope?
7. **Staging cleanup** — are partial staging artifacts from a failed build guaranteed cleaned up so they can't affect a later import?
8. **Zero-record snapshot** — valid snapshot with no records: successful import? What does lookup/`snapshotDate` do against it?
9. **Serial normalization edges** — embedded (non-surrounding) whitespace, empty/whitespace-only input after normalization, and non-ASCII/Unicode letters (uppercasing is ASCII-only) — verbatim or unspecified, and must the stored key use the same rule?

Several of these (3, 4, 5, 7) likely map to existing specs REG-003/REG-004 once resolved; others (1, 6, 8, 9) look like genuinely new behavior that would need their own spec lines in Phase 3.

**Stopping here for your review** (Phase 2 boundary). Once you've okayed the LLD and triaged the probe list, I'll cascade into the EARS specs (Phase 3) — that's the next phase and its own stop.