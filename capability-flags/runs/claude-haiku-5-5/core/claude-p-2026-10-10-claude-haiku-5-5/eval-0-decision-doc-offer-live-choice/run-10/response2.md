I wrote the decision doc at `docs/decisions/change-delivery-approach.md`, and the HLD entry now links to it. Nothing is committed.

The doc records:
- **Context:** the 15-second freshness goal, the 800-browser and 20-edits-per-second load, and the 20-minute recovery requirement. It also explains why the choice is hard to reverse: it sets what the change store must replay.
- **Criteria:** operational burden and vendor coupling are the major criteria. Recurring cost and latency headroom are moderate. Request load is minor. The two gates (the freshness goal and one authoritative revision per edit) are passed by every option.
- **Options:** polling, self-hosted WebSockets, and a hosted realtime service, each described as its advocates would describe it, with fit ratings against each criterion.
- **Selection:** self-hosted WebSockets. Its weak point is operational burden, which the decision accepts. The doc also lists what the choice forecloses and what it obligates the change-store, delivery, and browser-sync nodes to do.

The doc does not record your tenet question. Vendor independence is named as a project priority, not a tenet, because you have not decided whether it should become one. The stale "still open" wording in `docs/intent/access/access-design.md` is also unchanged.