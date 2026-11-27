The registry design is drafted with the local SQLite index as the backend. I've stopped at the Phase 2 review. The EARS specs and tests come after you approve this.

**Phase 1: HLD check**

- The HLD already rules out the other two options. Both need a network route during kiosk operation, which the HLD tenets prohibit ("no runtime network access"). The SQLite choice is consistent with the HLD.
- One edit to `docs/high-level-design.md`: the registry line said its backend "remains open." It now says the backend is a local SQLite index built on each kiosk, and no other node sees it.
- I did not offer a decision doc. The choice affects only the registry node, and the alternatives were excluded by the HLD, so a row in the LLD's Decisions table is enough.

**Phase 2: LLD draft (`docs/intent/registry/registry-design.md`)**

- **Architecture:** `findBySerial` is unchanged. Lookups read a SQLite file on the kiosk, and the index, query syntax, and storage path stay internal to the node.
- **Snapshot import:** verify the signature, reject unsupported schema versions, write records to a staging SQLite file in the same directory as the active index, store each normalized serial as a unique key, store the snapshot date in a metadata table, run an integrity check, then activate with a single rename. Any failure leaves the active index in place.
- **Lookup:** normalize the request, then run an equality query on the unique key. The snapshot date is returned for `NotFound` too. Stored serials are normalized the same way, and each record keeps its original serial text.
- **Decisions table:** the backend choice, with both alternatives and the HLD tenet that rules them out. Also the rename-based activation, which satisfies REG-004.

**LLD edge probe (gaps for you to triage)**

1. Power loss or a full disk during staging leaves a partial staging file. The draft does not say whether startup deletes it.
2. Two imports started from different USB media at once. The draft does not say whether one is refused.
3. A snapshot with zero records. The draft does not say whether it is accepted.
4. Serials that differ only by case. The draft treats them as duplicates, which rejects the import. Please confirm.
5. A rename that fails because the staging file is on another volume. The draft puts staging in the active file's directory, which should prevent this, but it isn't stated as a rule.

**Deferred open questions (in the doc)**

- What the manifest signature covers: the record bytes, the built index, or both.
- How much disk the two index files need, and what happens when space is short.
- Whether a kiosk-side index build needs a time bound.

**Not yet done**

- `registry-specs.md` is unchanged. The current REG-001 to REG-004 still match this draft. Phase 3 will add specs for the import steps, the staging and rename behavior, and the duplicate rule.

Please reply with your decisions on the probe gaps (especially item 4) and the deferred questions. You can also send numbered edits to the LLD. Once you approve, I'll move to Phase 3.