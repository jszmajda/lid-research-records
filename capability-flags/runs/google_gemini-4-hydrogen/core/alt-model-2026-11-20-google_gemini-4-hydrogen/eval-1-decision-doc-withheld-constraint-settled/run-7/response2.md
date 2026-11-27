It would be **overkill**—the **Decisions & Alternatives** table row in `docs/intent/registry/registry-design.md` is the right fit here.

By LID's decision-doc bar, a standalone doc is only warranted when a choice stays genuinely live for a cold reader and shapes other nodes around it. Here:
1. **An inherited constraint settles it:** The HLD's offline/no-network tenets already rule out the on-site HTTPS directory and managed search service.
2. **It affects only its own node:** Storage and indexing stay private to `registry`; `certificates` uses the exact same `findBySerial` contract either way.

A cold reader of the landed docs won't need to re-litigate this, so a table row captures all the rationale needed. If you'd like to stick with the table row, let me know your triage on the Phase 2 edge-case questions above (and whether Phase 2 is approved) so we can move to Phase 3 (`registry-specs.md`).