Done — the decision doc is written at `docs/decisions/self-hosted-websockets-delivery.md`, linked from the HLD's Key Design Decisions row. Written cold, for a reader who wasn't in the conversation:

- **Context** — why the choice gates the three unwritten nodes, and that all three options clear the 15-second floor (so freshness doesn't separate them).
- **Decision Elements** — four weighted criteria: vendor independence (major), update latency (moderate), operations we own (moderate), server read load at 800 browsers (minor); notes that the "self-hosted and managed both permitted" tenet deliberately leaves the choice open.
- **Options** — each of the three given its strongest honest description plus a verdict-per-criterion analysis: polling (simplest, but lag and ~160 req/s of idle polling), self-hosted WebSockets (fast and vendor-free, but we run the connections), hosted realtime (fast with fewer connection ops, but fees and coupling).
- **Selection** — why WebSockets wins on the major criterion while matching hosted on latency, and what committing forecloses and obligates downstream (replayable revisions in the store, sessions in delivery, reconnect/catch-up in browser sync).

Two things still open from my last message:

1. Cascade the stale wording in `access-design.md` ("independent of the still-open change-delivery approach")?
2. HLD as shown — approved to start Phase 2 on the three nodes (change store, delivery, browser sync)?