I've drafted the registry LLD with the local SQLite index chosen. Phase 2 stops here; no specs, tests, or code have been touched.

**What changed in `docs/intent/registry/registry-design.md`**
- **Architecture:** lookup is served from a local embedded SQLite index built on the kiosk from each imported snapshot. The index is private to the registry and the certificates node never sees it.
- **Snapshot Import:** the index is built in a separate staging file and checked against the snapshot (record count and snapshot date) before activation. Any failure, including index construction, leaves the previous snapshot and index active.
- **Lookup Behavior:** normalize the serial, query the active index, and return the snapshot date from the same snapshot that answered.
- **Decisions & Alternatives (new):**
  - **Lookup backend:** the rationale cites the HLD tenets and non-goals, which already exclude both network options. The "close at first" comparison you went through is therefore not what the table rests on.
  - **Index activation:** staging file plus activation after validation.
  - **No standalone decision doc:** the HLD settles the backend choice, so I recorded a table row only.

**HLD cascade for you to approve**
`docs/high-level-design.md` still says the registry's "private lookup backend remains open." I haven't edited it because it sits above the registry segment. I propose changing that clause to "Its private lookup backend is a local SQLite index built on the kiosk from each snapshot." Say yes and I'll make the edit.

**LLD edge-case probe: gaps for you to triage (fix in LLD now, or defer)**
1. **Uniqueness vs. normalization (spec fork):** is a duplicate serial judged on the raw value or the normalized value? If the snapshot has `ab-1` and `AB-1` as separate records, they would be distinct raw but collide at lookup. Raw comparison would make lookup ambiguous; normalized comparison would reject the snapshot. I think normalized is the safer reading, but this is your call.
2. **Lookup during import:** do lookups continue against the active index while a new one is being built? That is my assumption, and the 250 ms goal depends on it.
3. **Activation atomicity:** what makes the switch to the new index all-or-nothing, so a crash mid-switch never leaves no active snapshot?
4. **Interrupted import at startup:** what happens to a leftover staging file after power loss? (Already listed under Deferred.)
5. **Corrupt active index:** at lookup time, should this return an error rather than NotFound? A NotFound would let certificates block export wrongly. (Already listed under Deferred.)
6. **Retained previous index:** keep it after activation or delete it? (Already listed under Deferred.)
7. **Index size and import time:** snapshots can reach 150 MB. Is there a limit on staging disk space or on import duration, and what is reported to the technician during a long rebuild?
8. **Empty snapshot:** is a valid, signed snapshot with zero records acceptable?

Please reply with numbered feedback, including your ruling on item 1, and say whether to apply the HLD edit. Once you approve the LLD, I'll move on to the EARS specs.