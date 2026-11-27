I wrote the decision up as `docs/decisions/committed-change-delivery.md` and linked it from the WebSocket entry in the HLD's Key Design Decisions.

The doc covers the context, the freshness and load gate, the weighted criteria, all three options with their trade-offs, and the selection. It also lists what the choice obligates each node to do: the change store must replay revisions and publish without loss, delivery owns sockets and capacity, and browser sync owns reconnect and replay. Polling and hosted delivery are both recorded with their reasons for rejection.

Two things to check when you read it:

- **No tenet decides this.** The vendor-coupling priority that drives the choice is not in the HLD's Tenets list. Should it become one? If so, I'd add it as a one-line lean, for example "avoid tying the board's delivery to one realtime vendor's client or publication model."
- **The two open questions are still open.** I haven't resolved how revoked access and session expiry apply to open sockets. The doc doesn't settle them either. They'll need answers before the Access and Delivery specs are written.

Once you've reviewed the doc and answered those questions, I'll draft the three node LLDs and their EARS specs, one stop at each.