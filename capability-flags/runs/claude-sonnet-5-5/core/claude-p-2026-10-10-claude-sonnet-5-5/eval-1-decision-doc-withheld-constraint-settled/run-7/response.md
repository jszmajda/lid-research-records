I've drafted the registry LLD around the local SQLite index, with two small edits, and I'm stopping at the Phase 2 review before touching specs.

**What changed**
- `docs/intent/registry/registry-design.md`:
  - Lookup is now served from a local SQLite index, private to the registry.
  - The new Local Index section says the kiosk builds the index itself from the signed records. The index is derived data and is never signed or copied between kiosks.
  - Import builds the index in a staging file and atomically switches the active pointer only after every check passes. A failed import discards the staging file and leaves the previous snapshot active.
  - Decisions & Alternatives has three rows: lookup backend, index provenance (rebuilt on each kiosk vs. shipped prebuilt), and activation (staging file vs. in-place transaction). The last two are my own choices and are open to change.
- `docs/high-level-design.md`: one line said the registry's backend "remains open", so I updated it to name the SQLite index. Please confirm that edit.
- The certificates design and specs are untouched, since the `findBySerial` interface is unchanged.

**On the choice**
The HLD tenets (lookup completes from kiosk files, no runtime network) already ruled out the HTTPS directory and the managed search service. I recorded SQLite as a Decisions row rather than a standalone decision doc, because an inherited constraint settles it. Tell me if you'd rather have a full doc.

**Edge-case probe: gaps in this LLD, for you to triage (fix now vs. defer)**
1. **Uniqueness vs. normalization.** Records `ab-1` and `AB-1` are unique as written but collide once normalized. Should the uniqueness check, and so REG-003, run on the normalized form?
2. **No active snapshot.** On first boot, before any import, `findBySerial` has no snapshot date to return. What should it do?
3. **Unreadable or corrupt active index.** A lookup can fail even though the signature passed at import. The result type has no error shape for this.
4. **Interrupted activation.** What happens on restart if there is a leftover staging file or the pointer switch was cut off?
5. **Older or same-date snapshot.** Should an import with a date at or before the active one be accepted, rejected, or warned about?
6. **Malformed records.** Bad JSON lines or missing fields aren't listed among REG-003's rejection reasons. Should they fail the import?
7. **Disk headroom.** A 150 MB snapshot plus its index plus the previous index must fit. Should import check free space first?
8. **Blank serial.** What does an input that is empty after normalization return?

Gaps 1 and 6 look like real forks in what the specs would say. Which of these do you want fixed in the LLD now, and which deferred as open questions? I'll hold the EARS specs until you approve the LLD.