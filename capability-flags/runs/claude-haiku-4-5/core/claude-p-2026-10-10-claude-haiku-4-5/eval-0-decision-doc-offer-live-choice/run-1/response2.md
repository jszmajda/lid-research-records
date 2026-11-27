Decision doc created at `docs/decisions/delivery-approach.md`. It lays out the three options (polling, self-hosted WebSockets, hosted service), the weighted criteria that mattered (vendor independence as major, operational simplicity and performance as moderate), and why the choice forecloses simplicity-through-outsourcing but wins on independence and latency.

The HLD now links to it from the Key Design Decisions entry. A cold reader who sees "self-hosted WebSockets" in the architecture can now understand the tradeoffs that justified it.

**HLD is ready for Phase 1 review.** Does this capture the right reasoning, and are you ready to move into Phase 2 (the three LLDs: change-store, delivery, and browser-sync)?