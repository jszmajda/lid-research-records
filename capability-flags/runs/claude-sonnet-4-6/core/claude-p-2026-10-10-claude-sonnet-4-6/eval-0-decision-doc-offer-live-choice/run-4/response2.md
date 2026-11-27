Done. The decision doc lives at `docs/decisions/delivery-mechanism.md` and the HLD's KDD entry now links it.

The doc covers:
- **Context** — why the choice exists and what it shapes downstream
- **Decision elements** — one gate (15-second freshness) and four criteria: latency and operational ownership as major, recurring cost and provider coupling as moderate, browser complexity as minor; latency ties back to the *connectivity failures must be visible* tenet
- **Options** — all three from the prior sketch, each given its strongest honest representation with per-criterion analysis
- **Selection** — explains why WebSockets wins on the two major criteria, names the operational cost that's accepted and why, and lists the three downstream obligations it creates

Ready to move on to the three nodes whenever you are.