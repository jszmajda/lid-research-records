Written up at `docs/decisions/change-delivery-mechanism.md`, with the HLD's Key Design Decisions row now linking to it.

**What the doc contains** — Context (why the mechanism choice is project-level and shapes the three adjacent nodes); Decision Elements (two gates, both passing; seven weighted criteria — latency, cost at board scale, vendor coupling, recovery, operational burden, browser-side complexity, read amplification); the three options with honest descriptions and per-criterion verdicts; and a Selection that rules out polling on latency/read-amplification/cost and the hosted service on recurring fee and provider-guarantee dependence, naming operational burden as the deliberate, bounded cost of the chosen path and closing on what it obliges the change store, delivery, and browser sync to own.

I also fixed two "as we discussed" residues in it (the deliberation framing of the criteria section and the gated-sounding "eliminated" wording for options that were ruled out by tradeoffs, not gates).

Two items from my last message are still open, and I need your call on them before Phase 2:

1. **Tenet** — leave "Self-hosted and managed infrastructure are both permitted" as-is, or add a forward-looking lean toward self-hosting when operational burden is acceptable?
2. **Freshness goal** — keep "within 15 seconds" (WebSockets meet it comfortably), or tighten it now that sub-second delivery is achievable?

Also: is the HLD revision approved as it stands, so I can move on to the three nodes (change store, delivery, browser sync) in Phase 2?