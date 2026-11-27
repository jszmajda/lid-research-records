Wrote `docs/decisions/self-hosted-websocket-delivery.md` and linked it from the HLD's Key Design Decisions entry.

The doc records: the scale and freshness context; the criteria that separate the routes (perceived freshness, recurring cost, provider coupling, connection/reconnect operations, read load, recovery complexity, simplicity); all three options in domain prose with per-criterion verdicts; and the selection — WebSockets win on the two major criteria, cost and coupling, while accepting connection ownership and replay. It also names the downstream obligations for change store, delivery, and browser sync.

Two things still need you:

1. Approve the Phase 1 HLD update so I can move on to the three node LLDs?
2. You didn't answer the tenet question: add something like "prefer self-hosted infrastructure over vendor coupling where operational cost is acceptable," or leave the tenets unchanged?