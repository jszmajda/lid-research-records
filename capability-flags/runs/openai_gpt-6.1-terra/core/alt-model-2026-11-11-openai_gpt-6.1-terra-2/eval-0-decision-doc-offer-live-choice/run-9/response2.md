Added `docs/decisions/change-delivery.md` and linked it from the HLD. Here is the decision document for review:

# Decision: Delivery of Committed Changes

## Context

MarketBoard has one authoritative board per event. Editors send commands over HTTPS, and staff browsers need to see committed revisions. The pilot must support 800 simultaneous browsers and bursts of 20 edits per second, show changes within 15 seconds under normal connectivity, and recover the latest board after a disconnection of up to 20 minutes. Event revisions are retained for seven days. The availability target is 99.5 percent during published event hours.

Each delivery approach must preserve the authoritative event revision and make connectivity failures visible. All three options can meet the freshness goal; subsecond updates are useful but not required. The choice affects the change store, delivery service, and browser sync design.

## Decision Elements

- **Low-latency updates — major.** Faster updates improve the shared board even though the goal permits up to 15 seconds.
- **Independence from a realtime provider — major.** Avoiding a provider's subscription model, coupling, and recurring realtime-service fees leaves the board's delivery under the project's control.
- **Connection and recovery operations — moderate.** Simpler operation reduces the work of supporting connections and recovering from interruptions, but additional work is acceptable for fast, provider-independent delivery.
- **Repeated read and infrastructure load — moderate.** The mechanisms differ in request frequency and connection capacity, both of which affect operating work and cost. Actual costs depend on deployment and usage.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes after a cursor. The server responds to each request, and the change store supports cursor queries. Browsers run the polling loop and use the returned changes to update their views.

- **Low-latency updates: partial.** Changes can wait several seconds for the next poll, although the approach can meet the 15-second goal.
- **Independence from a realtime provider: strong.** Ordinary HTTPS requests do not require a realtime subscription provider.
- **Connection and recovery operations: strong.** Stateless request/response avoids operating persistent WebSocket sessions; browsers still need polling and catch-up behavior.
- **Repeated read and infrastructure load: weak.** Frequent polls create repeated reads and requests even when no changes occur.

### Self-hosted WebSockets

The project operates WebSocket connections to browsers and delivers committed changes over those connections. The change store provides replayable revisions and reliable publication to delivery; delivery manages sessions; browsers reconnect and catch up after interruptions.

- **Low-latency updates: strong.** Connected browsers can receive changes as they are delivered, without waiting for a polling interval.
- **Independence from a realtime provider: strong.** The project operates delivery without a realtime vendor's subscription model or recurring service fee.
- **Connection and recovery operations: weak.** The project owns connection capacity, session operation, publication reliability, and reconnect and catch-up behavior.
- **Repeated read and infrastructure load: partial.** Persistent connections avoid periodic polling reads but require capacity for concurrent connections and their recovery.

### Hosted realtime service

Delivery wraps a provider's realtime service, and browsers subscribe using its model. The change store and delivery design must reconcile publication with committed revisions. The provider operates the realtime connection infrastructure.

- **Low-latency updates: strong.** Subscriptions can deliver changes quickly without a browser polling loop.
- **Independence from a realtime provider: weak.** Delivery depends on the provider's service and subscription model and incurs recurring fees.
- **Connection and recovery operations: partial.** The provider reduces connection infrastructure work, while the application still needs publication reconciliation and recovery appropriate to the provider.
- **Repeated read and infrastructure load: partial.** Subscriptions avoid periodic polling reads and shift realtime connection capacity to the provider, in exchange for service fees.

## Selection

Use **self-hosted WebSockets**. Fast updates and independence from a realtime provider outweigh the extra work of operating connections and recovery. Polling offers simpler stateless operation but introduces repeated reads and several seconds of lag; hosted realtime reduces connection operations but adds provider coupling and recurring fees.

The change store, delivery, and browser sync nodes must be designed together around replayable revisions, reliable publication, WebSocket sessions, and browser reconnect and catch-up. Their detailed contracts and operational mechanisms remain to be designed against the board's freshness, recovery, capacity, and availability goals.

---

For the HLD review:

1. Does this capture the tradeoff and the relative importance of the criteria? Is there another consideration—such as staffing or availability risk—that could change the choice?
2. Do you approve the HLD and decision document?
3. Should provider independence be a broader tenet, or apply only to this decision?
4. May I correct the access design’s stale statement that delivery is still open?