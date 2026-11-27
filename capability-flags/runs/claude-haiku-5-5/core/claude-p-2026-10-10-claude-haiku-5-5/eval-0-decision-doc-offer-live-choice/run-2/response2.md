The write-up is in `docs/decisions/delivery-approach.md`, and the HLD's Key Design Decisions entry now links to it. Nothing is committed yet.

The decision doc is at project level, not under one node, because the choice shapes the change store, delivery, and browser sync together. It covers:

- **Context:** the 15-second freshness goal, 800 browsers, bursts of about 20 edits per second, and why the delivery route also determines how revisions are stored and how browsers recover.
- **Criteria:** vendor independence and update latency are weighted major; operational burden is major; recurring cost and recovery complexity are moderate. The doc also lists the criteria that count against the choice, namely operational burden and recovery complexity. No gates are listed, because every option passes the constraints that apply to all three.
- **The three options:** each has its strongest case, its ratings against the criteria, and a summary line.
- **Selection:** why WebSockets wins on the criteria the project weighted most, what it costs, and what it commits the three nodes to. It also states that no HLD tenet is overridden.

One change from the earlier HLD edit: the doc says the project accepts operational cost "for the chosen option" rather than in a way that reads as narration.

Still open from my last message:
- **Access node:** `docs/intent/access/access-design.md` line 10 still calls the delivery approach "still-open." I left it alone because it's a sibling segment. Should I update it?
- **Tenet:** "Self-hosted and managed infrastructure are both permitted" still doesn't say which way to lean. Do you want a tenet that leans toward self-hosting, or leave it?
- **Missing HLD sections:** Full LID expects Target Users, System Design, and Success Metrics. These were already missing and I didn't add them.

The HLD still needs your review before the three nodes start. Tell me what to change, or approve it and I'll begin the change-store, delivery, and browser-sync docs.