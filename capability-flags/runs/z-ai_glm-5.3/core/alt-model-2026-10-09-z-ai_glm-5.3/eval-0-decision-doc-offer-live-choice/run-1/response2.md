The decision doc is written.

- **`docs/decisions/delivery-approach.md`** — "Deliver committed board changes over self-hosted WebSockets." It's written for a cold reader: context (why delivery shape drives the whole architecture, weekend-only usage, the standing targets as background), five weighted criteria (update latency, operated complexity, recurring cost and provider coupling, burst fan-out ~16k msg/s at peak, idle-time cost profile), each option presented at its strongest honest representation with per-criterion verdicts, and a selection that names the decisive trade (latency over stateless simplicity, with polling and sockets tied on cost/coupling), why hosted lost (the one major criterion it differs on), what the choice forecloses, and the four downstream obligations it locks in.
- **HLD** — the Key Design Decisions entry now links the doc: "Full tradeoff analysis: `docs/decisions/delivery-approach.md`."

Note: the preference for owning the delivery path did its work as a criterion inside this decision rather than as a tenet — that's flagged in the Selection. If you'd rather it guide unforeseen future choices as a one-line tenet, say so and I'll add it; otherwise the doc is the record.

Ready to start the three nodes on your go — change store, delivery, browser sync, one LLD at a time.