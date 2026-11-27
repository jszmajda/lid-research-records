It would be overkill. Under LID's **earns-its-place heuristic**, the test is applied from the *landed* state looking forward—not from how long the deliberation took: *would a cold reader of the landed design find the choice non-obvious and be tempted to re-litigate it without a full breakdown of options and criteria?*

A standalone decision doc is only warranted when a choice stays genuinely live—where credible options trade off against multiple criteria and sibling design nodes are sized around the outcome. It is explicitly not needed when:

1. **An inherited constraint eliminates the alternatives:** The HLD's Tenets and Non-Goals already forbid runtime network access, live synchronization, and cloud services on the kiosks. That standing gate eliminates both the on-site HTTPS directory and the managed search service outright.
2. **One option clearly dominates once constraints apply:** For 90,000 read-only records on an offline 4 GB kiosk with a 250 ms lookup target and atomic snapshot replacement, an embedded SQLite index is a natural fit.
3. **The choice stays local to its own node:** The `findBySerial(serial)` contract and result types exposed to the `certificates` node are completely unchanged.

A single line of rationale in `registry-design.md`'s `Decisions & Alternatives` table is all a cold reader needs to see why SQLite was chosen and why networked backends are out of bounds.

If you're happy keeping it as the table row, let me know how you'd like to handle the 6 edge-case probe items from above so we can finalize the LLD and move to Phase 3 (EARS specs).