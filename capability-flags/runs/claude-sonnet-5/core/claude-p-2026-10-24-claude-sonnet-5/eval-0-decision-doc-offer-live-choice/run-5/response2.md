I wrote the decision doc at `docs/decisions/delivery-approach.md` and linked it from the HLD's Key Design Decisions row (which now carries a one-line summary instead of the full rationale).

The doc covers:
- **Context** — why delivery is a cross-cutting choice (shapes change store, delivery, browser sync) and the load figures driving it.
- **Decision Elements** — the 15-second freshness gate (all three options pass it), and four weighted criteria: update speed, vendor independence, operational burden (all major), and store/browser complexity (moderate).
- **Options in the Domain** — polling, self-hosted WebSockets, and the hosted service, each with its own strongest-honest-case description and a verdict per element.
- **Selection** — self-hosted WebSockets, chosen for scoring strong on both update speed and vendor independence, explicitly taken *against* the operational-burden criterion, naming the HLD tenet it turns on (self-hosted and managed infrastructure are both permitted), and spelling out what it forecloses and obligates downstream for the three LLDs.

This closes out Phase 1 for the delivery-approach change. Ready to move to Phase 2 — LLD drafts for the three nodes (change store, delivery, browser sync)?