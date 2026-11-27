Overkill — the row in `docs/intent/registry/registry-design.md`'s **Decisions & Alternatives** table is the right level here.

The test is from the landed state, not how close the deliberation felt: would a cold reader question the choice or try to re-litigate it without a full options-and-criteria breakdown? Here, no:

- **Inherited constraints settle it:** The HLD already mandates offline-only kiosks with no runtime network route and USB snapshots as the only update channel, which rules out both the on-site HTTPS directory and the managed search service.
- **Contained to one node:** The lookup backend is private to `registry`; `certificates` depends only on `findBySerial(serial)`, so no other node is being sized around this choice.
- **One row answers "why this?":** A cold reader can reconstruct the decision immediately from the table row without a standalone doc.

Whenever you're ready, let me know how you'd like to triage items 1–9 from the Phase 2 probe (or if you want to approve the LLD as-is and move to Phase 3).