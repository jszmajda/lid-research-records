Decision doc written: `docs/decisions/self-hosted-socket-delivery.md`, linked from the HLD's decisions row. It's project-level (owned by the HLD) since the choice spans all three downstream nodes.

The doc reads cold — no narration of our discussion, just the landed judgment:

- **Decision Elements**: two gates (freshness floor incl. 20-minute catch-up; stall-IDs-and-statuses-only payload) and five weighted criteria — update latency and vendor coupling as **major** (both tenet-driven), operational burden and recurring cost **moderate**, implementation simplicity **minor**.
- **Options in the domain**: polling, self-hosted WebSockets, and hosted realtime, each described as its advocate would and analyzed bullet-by-bullet against the elements. Polling: stateless and vendor-free but weak latency and reads scaling with audience; hosted: fastest to low latency but weak on coupling and recurring cost; self-hosted: strong on both majors, weak on owned connection ops.
- **Selection**: self-hosted wins as the only option strong on both major criteria; the price (owned connection/reconnect ops) is accepted, and the doc names what it obligates downstream — replayable revisions in the change store, session management and reliable publication in delivery, reconnect/catch-up in browser sync. Those obligations stay downstream design work, not settled here.

STOP for your review. When you approve, the next step is the three nodes in order (change store → delivery → browser sync); I'll start with the change-store LLD and stop for your review of it.