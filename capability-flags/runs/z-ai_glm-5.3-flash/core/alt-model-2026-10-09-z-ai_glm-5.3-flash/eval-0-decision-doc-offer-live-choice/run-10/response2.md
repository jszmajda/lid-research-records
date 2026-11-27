Done. `docs/decisions/self-hosted-websocket-delivery.md` now records the full tradeoff — the three options each in their strongest form, five weighted criteria, and the selection logic — written to be read cold by someone new:

- **Context**: why the route was chosen once, up front, given the 15-second floor with subsecond updates genuinely useful and no single criterion overriding.
- **Decision Elements**: latency (major), recurring cost, vendor coupling, owned operational burden (moderate), reuse of committed machinery (minor — the replay path sockets need is already owed to the 20-minute recovery goal).
- **Options**: polling (stateless simplicity, seconds of lag), self-hosted sockets (low latency + no vendor bill, owned connection ops), hosted service (fastest to low latency, fees + provider coupling).
- **Selection**: names the accepted tradeoff explicitly — burden taken on to stay off a realtime vendor — and what it obligates downstream.

The HLD's Key Design Decisions row now links to it.

Two open items for you:

1. The doc's rationale — "keep the board off a realtime vendor" — leans decisions the three nodes haven't reached yet, but no existing HLD tenet backs it. Add a tenet like *Own the live data path rather than vendor-couple it*? Or leave the reasoning resident in this decision doc only?
2. Still pending from before: `access-design.md` says authorization is independent of the "*still-open*" delivery approach — fix that stale phrase now, or when we next touch the access node?