The decision doc is written: `docs/decisions/change-delivery-approach.md`, linked from the HLD's Key Design Decisions entry. A newcomer reading it cold gets:

- **Context** — the three options, why none is eliminated by the 15-second floor / 20-minute recovery / 800-browser scale goals (all three can meet them), and that the board already runs on self-owned HTTPS infrastructure.
- **Decision elements** — latency below the floor (moderate; subsecond is headroom, not a requirement), operational burden, store read load at scale (~160 queries/sec for 800 polling browsers), recurring fees, provider coupling, and browser complexity — each weighted.
- **Options in the domain** — each option described at full strength and scored honestly against every element (polling wins on ops burden; hosted wins on connection operations; WebSockets wins on reads, fees, and coupling).
- **Selection** — the tradeoff stated plainly: polling rejected for its structural costs rather than its speed, hosted rejected on fees and coupling, and the owned connection/reconnect operations accepted deliberately as the cost of fast updates without a realtime vendor. Includes what committing forecloses (stateless delivery) and obligates downstream (replayable revisions, reliable publication, session management, reconnect/catch-up).

Still open from my last message before we move to the three nodes:

1. **Tenet** — keep "self-hosted and managed infrastructure are both permitted" as-is, or sharpen it to state the vendor-independence lean this decision took?
2. **Access drift** — may I fix the stale "still-open change-delivery approach" line in `access-design.md`, or leave it for when that node is next touched?
3. **HLD approval** — with the decision doc in place, approve the HLD changes so I can start the three nodes (change store, delivery, browser sync)?