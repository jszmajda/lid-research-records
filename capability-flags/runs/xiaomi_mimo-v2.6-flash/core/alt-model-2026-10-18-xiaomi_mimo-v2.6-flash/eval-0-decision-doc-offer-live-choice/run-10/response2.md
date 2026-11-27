Decision doc written: `docs/decisions/change-delivery-approach.md` (project-level, `node: high-level-design`), and the HLD's delivery entry now links to it.

What it contains:

- **Context** — the three delivery shapes, why all three clear the HLD's hard requirements, and that the three pending nodes are sized around this choice.
- **Decision Elements** — six weighted criteria, no gates: update latency (major), operational burden owned by the team (major), failure visibility (major, importance named from the visibility tenet), vendor coupling (major), recurring cost at pilot scale (moderate), client implementation surface (moderate).
- **Options in the Domain** — one section each for polling, self-hosted WebSockets, and the hosted service, each with a strongest-honest description, a per-criterion verdict with factual basis, and a one-line trade summary.
- **Selection** — sockets win latency and vendor coupling, lose operational burden by the widest margin; the willingness trade is stated plainly as the price rather than an oversight. Names the two tenets the decision turns on and lists the five downstream obligations it commits the change-store, delivery, and browser-sync nodes to — including that liveness reporting must reach the browser UI because visibility is the tenet sockets satisfy least naturally.

Two items still open from the Phase 1 stop:

1. **The HLD text itself** (Approach, Architecture, Key Design Decisions) — approve or revise?
2. **The stale line** in `docs/intent/access/access-design.md:10` — *"…independent of the still-open change-delivery approach"* → *"…independent of the change-delivery approach."* Apply it?

Then I'll start the three nodes.