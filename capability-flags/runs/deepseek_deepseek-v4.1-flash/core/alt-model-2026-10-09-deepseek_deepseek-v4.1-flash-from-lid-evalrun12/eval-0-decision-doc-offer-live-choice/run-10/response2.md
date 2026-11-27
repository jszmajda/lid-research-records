Wrote the decision doc to `docs/decisions/change-delivery-approach.md` and linked it from the HLD's Key Design Decisions entry. It lays out, for a cold reader:

- **Context** — why delivery was the open question and why the answer is load-bearing for change store, delivery, and browser sync.
- **Decision elements** — weighted criteria (vendor coupling, connection/reconnect burden, failure visibility per the tenet, freshness, integration effort), with freshness noted as not by itself decisive since all options meet the 15-second goal.
- **Options in the domain** — polling, self-hosted WebSockets, and hosted realtime, each described strongly and scored per criterion.
- **Selection** — sockets wins as the only option strong on both no-vendor-coupling and on-commit freshness; it names the accepted costs (connection capacity, reconnect ops, and heartbeat detection so a half-open socket isn't mistaken for an unchanged board) and the downstream obligations on the three nodes.

Two things still open:

1. **Approve the HLD update + this doc?** On your go I'll start the three nodes (change-store → delivery → browser-sync), one at a time with their own stops.
2. **Access cascade:** `access-design.md` still says authorization is independent of "the still-open change-delivery approach" — now stale. It's a different segment, so I've left it alone; want me to fix that wording when I proceed?