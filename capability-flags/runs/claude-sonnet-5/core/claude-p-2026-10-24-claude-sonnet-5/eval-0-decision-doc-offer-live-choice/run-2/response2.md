I wrote the decision doc at `docs/decisions/delivery-approach.md` and linked it from the HLD's Key Design Decisions row (now trimmed to a one-line pointer).

The doc lays out:
- **Context**: why the choice has to land before the change store, delivery, and browser-sync nodes can be written.
- **Decision Elements**: recurring cost, update latency, and operational ownership as major criteria; vendor coupling and implementation complexity as moderate.
- **Options in the Domain**: polling, self-hosted WebSockets, and hosted realtime, each with its strongest honest case and a fit verdict per criterion.
- **Selection**: WebSockets wins on cost and latency together; the real tradeoff is accepting weak fit on operational ownership in exchange for avoiding a recurring fee and vendor coupling — framed as exercising the "self-hosted and managed infrastructure are both permitted" tenet, not overriding it. Closes with what the choice forecloses and what it obligates the three downstream nodes to do.

Take a look and let me know if the framing or tradeoffs need adjustment. Once you're happy with it, I'll move to Phase 2 and draft the leaf LLDs for the three nodes — change store, delivery, and browser sync.