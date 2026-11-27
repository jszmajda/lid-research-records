Added [`docs/decisions/change-delivery.md`](docs/decisions/change-delivery.md) and linked it from the HLD. The decision document for review:

# Decision: Delivery of Board Changes

## Context

MarketBoard maintains an authoritative board and revision history for each event. Editors submit changes over HTTPS, and staff browsers need to see committed changes promptly and recover after disconnection. The pilot must support 800 simultaneous browsers and opening-time bursts of 20 edits per second, recover after disconnections of up to 20 minutes, and retain seven days of event revisions. Its freshness target is 15 seconds under normal connectivity; subsecond delivery is useful but not required.

The delivery approach shapes the change store, the delivery service, and browser synchronization. The choice balances update latency and dependence on a realtime provider against the work of operating connections and recovery.

## Decision Elements

- **Major — Update latency.** Favor fast propagation of committed changes to connected browsers, even though all three options can meet the 15-second freshness target.
- **Major — Realtime provider dependence and fees.** Avoid coupling delivery to a realtime vendor and its recurring service fees.
- **Moderate — Operational burden.** Favor simpler operation, including connection capacity, publication reliability, and recovery from interruptions.

The pilot's capacity, recovery, retention, and availability goals remain constraints on the detailed design. The choice of transport alone does not establish that those goals are met.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes since a cursor over HTTPS. The change store supports cursor queries, delivery handles request/response reads, and each browser runs a polling loop and catches up from its cursor after interruptions.

- **Update latency: partial fit.** Changes can wait several seconds for the next poll, although this meets the stated freshness target under normal connectivity.
- **Realtime provider dependence and fees: strong fit.** Delivery does not require a realtime vendor or its subscription service.
- **Operational burden: strong fit.** Stateless requests avoid long-lived connection management, at the cost of repeated reads even when the board is unchanged.

### Self-hosted WebSockets

The application operates WebSocket connections to browsers and sends committed board changes over them. The change store supports replayable revisions and reliable publication; delivery manages socket sessions; browsers reconnect and catch up after interruptions.

- **Update latency: strong fit.** Connected browsers can receive changes promptly without waiting for a polling interval.
- **Realtime provider dependence and fees: strong fit.** Delivery does not depend on a hosted realtime service or its recurring fees.
- **Operational burden: partial fit.** The project owns connection capacity and reconnect behavior, as well as reliable publication and replay. Hosting and operating this infrastructure also has costs.

### Hosted realtime service

The application publishes changes to a provider, and browsers subscribe through that provider. The store supports publication reconciliation, delivery wraps the provider, and browser synchronization uses its subscription model and recovery capabilities.

- **Update latency: strong fit.** Connected subscribers can receive changes promptly without waiting for a polling interval.
- **Realtime provider dependence and fees: weak fit.** Delivery is coupled to the provider and incurs recurring service fees.
- **Operational burden: partial fit.** The provider handles connection infrastructure, but the application still needs publication reconciliation and recovery across interruptions.

## Selection

Use self-hosted WebSockets. Fast updates and independence from a realtime vendor outweigh the added work of operating connection capacity and reconnects. Polling would be simpler to operate but would introduce repeated reads and seconds of lag; hosted realtime would reduce connection operations but introduce provider coupling and recurring fees.

The store, delivery, and browser synchronization designs must jointly address replayable revisions, reliable publication, session capacity, reconnection, and catch-up. Their detailed mechanisms and their ability to meet the pilot's capacity and availability goals remain to be established in those designs.

---

Does this capture the tradeoff accurately, and do you approve it with the HLD? Is there another criterion—such as available operational staffing—that could change the choice?

Also, should avoiding provider coupling at the expense of operations work be a general project tenet, or is it specific to this decision?