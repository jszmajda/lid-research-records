Wrote `docs/decisions/self-hosted-websockets.md` and linked it from the HLD's Key Design Decisions entry.

The doc lays out:
- **Context** — why delivery is load-bearing: it shapes the change store, delivery, and browser-sync designs.
- **Decision Elements** — no eliminating gate (all three meet freshness; both infra kinds are permitted), then weighted criteria: latency, recurring cost, connection operations, vendor coupling, failure visibility (tied to the visible-failure tenet), and downstream design burden.
- **Options** — each of the three described at its strongest, then verdict-per-criterion.
- **Selection** — sockets win on recurring cost and vendor coupling, accepting connection/reconnect operations; names the tenet engagement and the three downstream obligations.

Still open from before: `docs/intent/access/access-design.md:10` says the authorization decision is "independent of the still-open change-delivery approach," which is now stale. May I fix that one line, or leave it until we work the nodes?

Does the decision doc read the way you wanted?