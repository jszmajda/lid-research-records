Phase 2 complete — here's where it stands, then I'll stop for your review before touching the specs.

**Coherence pre-flight (resuming):** clean. No code or tests exist yet; REG-001–004 are backend-agnostic and still trace to the LLD. The only drift the selection created was the "backend remains open" wording, now fixed.

**What I changed**
1. `registry-design.md` — closed the backend selection on the local SQLite index. New *Lookup Index* and rewritten *Snapshot Import* / *Lookup Behavior* sections specify: one active SQLite file per kiosk, a unique index on a **normalized lookup key**, a metadata row carrying the snapshot date (so `NotFound` can still return it), and import as a **per-kiosk build-to-staging + single swap** so lookups only ever see a whole snapshot. The `findBySerial` interface and record/result types are untouched, so the certificates node is unaffected (no cascade across that boundary).
2. `high-level-design.md` — dropped the stale "lookup backend remains open" clause, keeping the backend private to the registry. This is a one-clause staleness fix on the root doc with no architecture change; flagging it since it edits the HLD.

**Decision recording:** I recorded the choice as a **Decisions & Alternatives row**, not a full decision doc. The no-runtime-network tenet eliminates both networked options for *lookup*, so once landed the choice reads as largely settled by an inherited constraint rather than genuinely live — that's below the bar for a standalone decision doc. Say the word if you'd rather have the full doc anyway.

**Edge-case probe — three gaps I need you to triage** (I left these as Open Questions rather than deciding them):

1. **Normalized-key collisions (please resolve before I write specs).** Uniqueness is validated on *raw* serials, but two distinct raw serials can collide on the normalized key — e.g. `abc-1` and `ABC-1` both normalize to `ABC-1`. Should such a snapshot be **rejected at import** as a duplicate (tightening REG-003's meaning of "duplicate serial numbers" to normalized-key duplicates), or **accepted with a defined tie-break** at lookup? This changes REG-003's wording either way, so I'd like your read before Phase 3.
2. **Active-index corruption at open time.** The import rules preserve the last valid snapshot across *import* failure, but behavior when an already-active index is found unreadable at *lookup* time (power loss mid-swap, media fault) isn't specified. Specify a behavior, or defer?
3. **Staging cleanup after an interrupted import.** Whether a leftover staged index is cleaned up on next import or at startup is unspecified. Specify, or defer?

Once you've settled #1 (and said how you want #2/#3 handled), I'll cascade into the EARS specs (Phase 3) and stop again there.