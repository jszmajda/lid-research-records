That would be overkill—the **Decisions & Alternatives** row in `registry-design.md` is the right fit.

The test is whether a cold reader of the landed design would still see a live choice worth re-litigating, not how close the deliberation felt:

- **Inherited constraints settle it.** The HLD requires all lookups to complete from local kiosk files with no runtime network route (and excludes remote/cloud services during operation), which eliminates both the on-site HTTPS directory and the managed search service outright.
- **No other node depends on it.** `findBySerial` and its result types are fixed, and `certificates` never touches registry storage.

A standalone decision doc is for choices where credible options remain in tension and other design nodes are sized around the outcome. Here, the table row gives a future reader everything they need.

Whenever you're ready, let me know how you'd like to handle the LLD review and edge-case probe items (1–7) before we move to Phase 3 (`registry-specs.md`).