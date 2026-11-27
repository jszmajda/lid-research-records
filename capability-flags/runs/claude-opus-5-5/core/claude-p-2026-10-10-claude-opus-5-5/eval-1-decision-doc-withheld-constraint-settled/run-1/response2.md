Overkill, I think. The row in the registry's Decisions table is enough.

A decision doc earns its place when a later reader would re-open the choice unless they could see the options weighed against each other. That isn't the case here, for three reasons:

- **The HLD's tenets settle it.** "No runtime network access is permitted" and "signed USB snapshots are the only registry update channel" rule out both the on-site HTTPS directory and the managed search service. Only SQLite passes, so there is nothing left to weigh.
- **It affects only the registry.** The certificates node sees the same `findBySerial` result under all three options, so no other design is sized around this choice.
- **One line of rationale answers "why SQLite?"** The existing row already names the two rejected options and the tenet that eliminates them.

The options looked close when you were weighing them, but that is a fact about the deliberation, not about the design as it now reads. Someone reading the HLD and the registry design cold will see the choice as close to forced.

A doc would become worthwhile if the no-network tenet were ever relaxed, say if kiosks gained a lab network route. Then the three options would be live again, and the trade-offs you weighed (central index maintenance versus per-kiosk rebuilds, recurring cost, timeout handling) would be worth writing down. That would be an HLD change first.

If you'd still like one for your own reasons, say so and I'll write it under `docs/intent/registry/decisions/` and link it from the row. Otherwise the design is still waiting on your answers to the numbered gaps from the last message.