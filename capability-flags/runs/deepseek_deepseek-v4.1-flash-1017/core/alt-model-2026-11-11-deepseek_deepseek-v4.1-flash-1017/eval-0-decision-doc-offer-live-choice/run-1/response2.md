Wrote `docs/decisions/websocket-delivery.md` (node: `high-level-design`) and linked it from the HLD's Key Design Decisions entry.

**Context** — pins the delivery choice to the numbers and the three nodes it sizes: 15-second freshness, 20-minute recovery, seven-day retention, 800 browsers, 20 edits/sec bursts, 99.5% availability.

**Decision elements**
- Gate: delivery must not depend on a realtime vendor account (doc-local boundary, not a project-wide prohibition — the managed-infrastructure tenet still holds elsewhere).
- Major: freshness headroom, operating burden, vendor independence.
- Moderate: change-store read load, browser recovery complexity.

**Options and verdicts**

| | Polling | Self-hosted WS | Hosted service |
|---|---|---|---|
| Vendor gate | passes | passes | eliminated |
| Freshness | partial | strong | strong |
| Operating burden | strong | weak | strong |
| Store read load | weak (~160 reads/s idle) | strong | strong |
| Browser recovery | strong | partial | partial |

Each option is written as its advocate would argue it, with the analysis stating facts rather than editorializing.

**Selection** — self-hosted WebSockets: clears the gate, best freshness, no idle reads. The doc names the accepted weakness plainly (capacity, heartbeats, deploy draining, reconnect storms, dead sockets surfaced as failures) and the connectivity-visibility tenet it turns on. Downstream obligations are spelled out per node; it forecloses cursor polling as the primary path and provider-managed capacity, while keeping HTTPS for snapshots and catch-up.

Two questions:

1. Does the decision doc read right — anything a new reader would still be missing, or any verdict you'd disagree with?
2. Shall I move on to Phase 2 now — the three nodes, change store first? I'll draft one LLD at a time and stop after each.

Still open from before: `docs/intent/access/access-design.md:10` says "the still-open change-delivery approach" — want me to refresh that phrase while I'm in the docs?