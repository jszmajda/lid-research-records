**Phase 1 (HLD check): done. Stopping here for your review, per the workflow's phase stops.**

You chose the local SQLite index. I checked the HLD against that choice. It doesn't change the architecture, but one line was stale. The HLD said the registry's backend "remains open," so I changed it in `docs/high-level-design.md` to:

> Owns snapshot validation and lookup. Its lookup index is private to this node and is built on each kiosk from the accepted snapshot.

I kept SQLite out of the HLD on purpose. The backend is a registry-internal detail, so the name belongs in the registry LLD. The HLD tenets and goals still hold under SQLite: lookups read local files, the 250 ms and 90,000-record goals are well within reach, and the certificate interface is unchanged.

I did not offer a decision doc. The choice affects only the registry node, so I'll record it as a row in the registry LLD's Decisions & Alternatives table (the section doesn't exist yet). `docs/intent/registry/registry-design.md` still says the index is "open pending the user's choice," and I'll fix that in Phase 2.

**One spec fork needs your decision before the LLD:**

REG-003 rejects a snapshot with duplicate serial numbers, but lookup normalizes whitespace and case (REG-001). So a snapshot containing `AB-12` and `ab-12` has two distinct records that collide on lookup. Which rule should apply?

- **(a) Uniqueness on the normalized form.** Such a snapshot is rejected at import. The kiosk never holds an ambiguous serial.
- **(b) Uniqueness as written.** Both records import, and a lookup for `AB-12` has no single answer. This would need a further rule (for example, return NotFound or an error).

I'd recommend (a), since it keeps the lookup deterministic and the central inventory team can fix the duplicate at source. Your call.

**Next, once you approve Phase 1 and pick (a) or (b):**
- Phase 2: draft the registry LLD around SQLite. It covers the import sequence (build a staging database, validate, then atomically swap it in so the last valid snapshot survives a failed import), how the snapshot date is stored, and cleanup of a staging file left by a crash. It also adds the Decisions row. Then I'll run the LLD edge probe.
- Phase 3 and later: EARS updates, then the stops for Phases 4–6.