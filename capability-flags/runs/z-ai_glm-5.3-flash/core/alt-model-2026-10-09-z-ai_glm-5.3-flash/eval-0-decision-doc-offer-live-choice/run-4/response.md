The HLD is updated for the self-hosted WebSockets approach:

- **Approach** (docs/high-level-design.md:9-13): now states the committed-change delivery route as self-hosted WebSockets, with the reasons the other two options were rejected and the downstream consequence each node inherits — replayable revisions in the store, session ownership in delivery, reconnect/catch-up in browser sync. The 15-second freshness target is unchanged; subsecond delivery is recorded as a benefit of the route, not a new goal.
- **Architecture**: the change-store, delivery, and browser-sync bullets now describe their fixed roles instead of "depends on the approach."
- **Key Design Decisions**: added a row for the delivery choice, including why polling and a hosted realtime service were rejected.

Not yet touched: the three downstream design nodes (change-store, delivery, browser-sync), which you've said come next. Nothing in access needed to change — its authorization boundary is independent of delivery.

Two things before we proceed to the three nodes:

1. **Decision doc offer** — this choice clears the bar for one: two credible options were traded against cost, coupling, latency, and ops burden, and all three downstream nodes are being sized around the result. I've recorded it as an HLD Key Design Decisions row, which may be enough. Want a full decision doc under `docs/decisions/` instead, or is the row sufficient?
2. **Review the HLD edits** above — any corrections before I draft the change-store, delivery, and browser-sync designs?