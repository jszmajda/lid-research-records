Done. I wrote the decision doc at `docs/decisions/websocket-delivery.md` (project-level, `node: high-level-design`, no EARS IDs) and linked it from the HLD's Key Design Decisions row. Here's the phase output for review:

**Context** — delivery fixes what the change store, delivery service, and browser sync must own; it rests on the "one authoritative event revision" decision. Baseline constraints (15s freshness, 800 browsers / 20 edits/s bursts, visible connectivity failures, both infra types permitted) are named as background that all three options satisfy.

**Decision Elements** — four weighted criteria, tenets named where importance derives from them:
- Propagation latency (moderate)
- Independence from a realtime vendor (major) — tenet *Self-hosted and managed infrastructure are both permitted* makes this a weighed preference, not a gate
- Recurring operating cost (moderate)
- Operational/design work owned by the project (moderate) — tenet *Connectivity failures must be visible…* sets the bar reconnect/catch-up must meet

**Options in the Domain** — each gets a full Description, a Demonstration, and verdict-led Analysis:

| Criterion | Polling | Hosted realtime | Self-hosted WS |
|---|---|---|---|
| Propagation latency | weak | strong | strong |
| Vendor independence | strong | weak | strong |
| Recurring cost | strong | weak | strong |
| Owned ops/design work | strong | strong | weak |

**Selection** — self-hosted WebSockets is the only option strong on latency, vendor independence, and cost. It explicitly states the tradeoff: the one weak criterion (owned connection/reconnect/replay/publication/catch-up work) is *accepted*, not avoided, in exchange for fast updates with no vendor dependency and no recurring fee; it names both tenets, states what the choice forecloses, and spells out the obligations it places on the three downstream nodes.

I'm still at the Phase 1 stop — I have not started the three nodes, changed the tenets, or touched the Access segment. Before I go further, these calls are yours:

1. **Latent-criteria probe:** is there a criterion a thoughtful critic would weigh that we haven't named, especially one cutting *against* self-hosted WebSockets (e.g. a constraint or cost I've left out)? If one survives, I'll fold it into the doc rather than quietly lock the current four.
2. **Approve the HLD, or give numbered edits?** Question #1 from the last stop is still open; I won't proceed to the three nodes (change store, delivery, browser sync) until you approve — each gets its own Phase 2 stop.
3. **Tenets — which way do you lean?** The Selection rests on a preference ("fast, vendor-independent updates even at the cost of owning more operations") that is not yet a recorded tenet. Should I add that one-line lean under `## Tenets`, and should the existing "both permitted" tenet stay as-is or be sharpened?
4. **Cross-segment cascade:** `docs/intent/access/access-design.md` still says "independent of the still-open change-delivery approach" — now stale. Want me to clean that wording as a cascade, or hold it until we do the three nodes?