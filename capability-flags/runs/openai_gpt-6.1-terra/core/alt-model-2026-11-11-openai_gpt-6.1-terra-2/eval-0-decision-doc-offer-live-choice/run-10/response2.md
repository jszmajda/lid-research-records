I added `docs/decisions/change-delivery.md` and linked it from the HLD. Here is the decision record for review:

---

# Decision: Committed Change Delivery

## Context

MarketBoard maintains one authoritative board per event. Editors submit commands over HTTPS, and browsers need to show the resulting committed revisions. The pilot must support 800 simultaneous browsers, opening-time bursts of 20 edits per second, and recovery after disconnections of up to 20 minutes. Under normal connectivity, changes must appear within 15 seconds; faster updates would be useful, but subsecond delivery is not required.

The delivery approach shapes the change store, the delivery service, and browser recovery. It also determines how much connection management the project operates itself and how much it depends on a realtime provider. All options incur infrastructure or service costs, but no comparative cost estimate is established for the expected traffic. The board retains seven days of revisions for investigation regardless of delivery approach.

## Decision Elements

- **Update latency — major.** Favor prompt delivery of committed changes, even though all three approaches can meet the 15-second target.
- **Realtime-provider independence — major.** Avoid reliance on a realtime vendor and its subscription model.
- **Operational burden — moderate.** Favor fewer connections, failure modes, and recovery mechanisms for the team to operate; weigh this against the value of faster, provider-independent updates.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes since a cursor over HTTPS. The change store supports cursor queries, delivery remains request/response, and browsers run a polling loop and catch up through subsequent requests. Repeated requests and reads consume infrastructure even when few changes occur.

- **Update latency: partial fit.** Changes normally wait up to a polling interval before the next request; five seconds fits the stated freshness target but is slower than push delivery.
- **Realtime-provider independence: strong fit.** Delivery uses the application's own HTTPS service without a realtime provider.
- **Operational burden: strong fit.** Stateless requests avoid operating long-lived socket sessions and their reconnect lifecycle, although polling and catch-up still need handling.

### Self-hosted WebSockets

Browsers maintain WebSocket connections to application-operated delivery infrastructure. The store provides replayable revisions and reliable publication of committed changes; delivery manages socket sessions and capacity; browsers reconnect and catch up after interruptions. Hosting and operating the connection infrastructure incurs costs even without a realtime-provider subscription.

- **Update latency: strong fit.** Committed changes can be pushed promptly to connected browsers without waiting for a polling interval.
- **Realtime-provider independence: strong fit.** The application operates delivery rather than depending on a realtime vendor.
- **Operational burden: weak fit.** The team owns connection capacity, publication reliability, reconnects, and recovery under disconnects and bursts. Meeting the availability and recovery goals depends on designing and operating these mechanisms.

### Hosted realtime service

The application publishes committed changes to a managed realtime provider, and browsers subscribe using the provider's model. Delivery wraps the provider; the store and publication path reconcile committed changes with what has been published. Provider fees add a recurring charge alongside application infrastructure.

- **Update latency: strong fit.** A managed push service can deliver changes promptly without a polling interval.
- **Realtime-provider independence: weak fit.** The delivery path and browser subscription model depend on the provider.
- **Operational burden: partial fit.** The provider handles connection infrastructure, but the application still owns publication reconciliation, credentials, and recovery integration.

## Selection

Use self-hosted WebSockets. Fast updates and independence from a realtime vendor outweigh the additional connection and reconnect operations. Polling would reduce operational complexity but introduce repeated reads and several seconds of lag; hosted delivery would reduce connection operations but introduce provider coupling and recurring fees.

This choice does not relax the 15-second freshness target or make subsecond delivery a requirement. It commits the change store, delivery, and browser sync designs to address replayable revisions, reliable publication, session capacity, reconnection, and catch-up together. The existing tenets of one authoritative revision and visible connectivity failures remain constraints on those designs. The specific mechanisms, capacity plan, and cost estimates belong in the downstream designs.

---

1. Does this capture your reasoning and the relative importance of the criteria? Is there another consideration that could change the choice?
2. Do you approve the HLD and decision record? May I correct the access design’s stale statement that delivery is still open when we cascade?
3. Should **“Prefer faster updates over lower operational burden”** be a general tenet, or was that preference specific to this choice?