Decision doc written at `docs/decisions/change-delivery-approach.md`, linked from the HLD's Key Design Decisions entry. Structure:

- **Context** — freshness floor, burst load, 20-minute recovery, and why the choice sizes the three downstream nodes (no conversation history; reads cold).
- **Decision Elements** — five weighted criteria: freshness latency (major), operating work owned by the project (major), cost/provider coupling (moderate), store read/write pressure (moderate), visibility of connectivity failure (moderate; tied to the existing tenet).
- **Options** — polling, self-hosted WebSockets, hosted service, each with a full description, a verdict-per-criterion analysis, and a one-line trade summary.
- **Selection** — self-hosted WebSockets: the only option strong on both latency and cost/coupling; the owned connection/reconnect work is the accepted cost; what it forecloses and what it obligates downstream is named.

Still open from the Phase 1 stop:

1. **HLD review** — approve the Approach/Architecture/Key Design Decisions changes, or give numbered feedback.
2. **Access cascade** — fix the now-stale "still-open change-delivery approach" phrase in `docs/intent/access/access-design.md`? (Cross-segment, so I'm waiting on you.)