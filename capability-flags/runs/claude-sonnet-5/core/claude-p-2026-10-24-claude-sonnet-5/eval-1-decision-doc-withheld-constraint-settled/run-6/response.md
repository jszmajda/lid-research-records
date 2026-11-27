I finished the registry design's Phase 2 update for the backend selection. Here's what changed and what needs your review before I touch EARS specs.

**Registry LLD (`docs/intent/registry/registry-design.md`)** — updated to reflect the SQLite choice:
- **Architecture**: lookup backend is now specified as a local embedded SQLite index, built and queried entirely on-kiosk; no shared/central index.
- **Snapshot Import**: index build is folded into the validation pipeline — an index-build failure is treated like any other validation failure, and snapshot + index activate together or not at all.
- **Lookup Behavior**: lookup queries the local index directly, no network hop.
- **Decisions & Alternatives** (new table): records the choice, the two alternatives you considered (HTTPS directory, managed search service), and the rationale — full local control and no network dependency, traded against each kiosk owning its own validate/rebuild cycle.

I didn't offer a standalone decision doc: all three options left the certificate interface unchanged and the backend is private to this node, so the choice doesn't size any other design node — it fits as a table row per the skill's own test for when a doc earns its place.

**HLD** — one line was stale after this decision (`docs/high-level-design.md`): "Its private lookup backend remains open" now reads "Its lookup backend is a local embedded SQLite index, private to this node."

**LLD-level edge-case probe** (delegated to a blind reader, given only the new LLD text): it surfaced gaps specific to the SQLite choice that this LLD doesn't currently answer —
1. Does serial uniqueness validation normalize case/whitespace before comparing, or could two records that normalize to the same key both pass?
2. Is there a post-build integrity check on the SQLite index, or is a failure only caught via the builder's return code?
3. Can activation be interrupted mid-swap, leaving a new snapshot paired with an old index (or vice versa)?
4. Can `findBySerial` observe a mid-swap state during an import?
5. Is a malformed/missing schema-version field a signature failure, a schema failure, or undefined?
6. Is there any record validation beyond signature, schema version, and serial uniqueness (e.g., a record missing a calibration date)?
7. Is an empty-after-normalization serial a `NotFound`, or a distinct error?
8. Do failed import attempts leave partial build artifacts to clean up?
9. What's served before any snapshot has ever been successfully imported — is "no active snapshot" representable?
10. Is the snapshot date returned always guaranteed to match the snapshot actually queried, under concurrent lookup + activation?

Per the workflow, this is a stop: which of these do you want fixed in the LLD now, and which should I defer as open questions? And does the LLD update above look right otherwise, before I move on to EARS specs?