Updated `docs/intent/registry/registry-design.md` to finish the registry LLD now that the backend choice is made (Phase 2):

- **Architecture / Snapshot Import / Lookup Behavior** now state the concrete backend: a local embedded SQLite index, rebuilt per kiosk into a new file on snapshot arrival and atomically switched in with the snapshot only once signature, schema, uniqueness, and index-build validation all succeed — otherwise the previous snapshot+index stay active.
- Added a **Decisions & Alternatives** row recording the choice and the two rejected alternatives. I didn't offer a standalone decision doc: the HLD's existing "no runtime network access" tenet already dominates this choice — the other two options depend on the lab network or an external service during normal operation, so a cold reader wouldn't find it live once that tenet is applied, even though it took you a few passes to see it that way.
- No changes were needed to `certificates-design.md` or the registry's EARS IDs — the HLD already scoped this decision as invisible outside the registry node, and that held.

Ran the Phase 2 edge-case probe for this LLD's own gaps (not cross-component — that's Phase 4) and logged four under **Open Questions & Future Decisions**:

1. Does a partial index file from a power loss mid-rebuild get reliably distinguished from a valid one on restart?
2. Is a corrupted active index (disk fault between imports) detected at lookup time, or does it fail silently?
3. Is there disk headroom to hold the new index alongside the still-active one during rebuild, given snapshots up to 150 MB?
4. Should the index carry its own format/version tag, separate from the snapshot schema version, for future index-format changes?

Which of these do you want folded into the LLD now versus left deferred, and does the LLD update otherwise look right to move on to Phase 3 (EARS)?