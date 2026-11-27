Added `docs/decisions/change-delivery.md` and linked it from the HLD:

---

# Decision: Delivery of Committed Board Changes

## Context

MarketBoard has one authoritative board per event. Editors submit commands over HTTPS, and connected browsers need to see committed changes. The pilot must support 800 simultaneous browsers and bursts of 20 edits per second, show changes within 15 seconds under normal connectivity, and recover the latest board after a disconnection of up to 20 minutes. Subsecond updates are useful but are not required. All three delivery approaches can meet the freshness target; their capacity, recovery, and availability still need to be designed and verified against the pilot goals.

The choice affects the change store, delivery, and browser sync designs. The board's authoritative revisions remain independent of the delivery route, and connectivity failures must be visible rather than appearing as an unchanged board.

## Decision Elements

- **Major — Update latency:** Deliver changes promptly to connected browsers, beyond merely meeting the 15-second freshness target.
- **Major — Realtime provider independence:** Avoid tying delivery to a hosted realtime provider and its subscription model.
- **Moderate — Operational burden:** Minimize the connection management and recovery work the team must operate.
- **Moderate — Recurring delivery costs:** Limit recurring realtime-service fees while accounting for the infrastructure and operational costs of self-hosting.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes after their last known revision. The store supports cursor queries, delivery remains request/response, and browsers run a polling loop. The normal delivery lag includes up to a polling interval, plus request and processing time.

- **Update latency: partial fit.** A five-second interval meets the stated freshness target but adds seconds of delay and repeated reads.
- **Realtime provider independence: strong fit.** Delivery uses the application's HTTPS service without a realtime provider.
- **Operational burden: strong fit.** Stateless requests avoid managing long-lived delivery sessions, though polling and recovery still need implementation.
- **Recurring delivery costs: partial fit.** There is no realtime-service fee, but repeated requests and reads consume infrastructure capacity.

### Self-hosted WebSockets

The application maintains WebSocket sessions and sends committed changes to connected browsers. The store supports replayable revisions and reliable publication; delivery manages sessions and connection capacity; browsers reconnect and catch up after interruptions.

- **Update latency: strong fit.** An established connection can deliver changes promptly without waiting for the next poll.
- **Realtime provider independence: strong fit.** The application operates delivery without a hosted realtime provider.
- **Operational burden: weak fit.** The team owns connection capacity, session management, reconnects, and the reliability of publication and recovery.
- **Recurring delivery costs: partial fit.** There is no realtime-service fee, but hosting connections and operating the service incur costs.

### Hosted realtime service

The application publishes committed changes through a provider, and browsers subscribe using the provider's model. The store supports publication reconciliation, and delivery wraps the provider and manages the necessary credentials. Browser recovery must account for interruptions and missed changes.

- **Update latency: strong fit.** Subscriptions can deliver changes promptly without waiting for the next poll.
- **Realtime provider independence: weak fit.** Delivery and browser subscriptions depend on the provider's service and interfaces.
- **Operational burden: partial fit.** The provider handles connection infrastructure, while the application still owns publication reconciliation, credentials, and recovery integration.
- **Recurring delivery costs: weak fit.** The provider charges recurring fees in addition to the application's own infrastructure costs.

## Selection

Use **self-hosted WebSockets**. Prompt updates and independence from a realtime provider outweigh the additional work of operating connections and reconnects. Polling is operationally simpler but introduces repeated reads and seconds of lag; a hosted service reduces connection operations but adds provider coupling and recurring fees. This choice builds on the tenet that each committed edit has one authoritative event revision: WebSocket delivery carries changes from that authority rather than creating a separate one.

The change store must support replayable revisions and reliable publication. Delivery must manage sessions and capacity, and browser sync must reconnect and catch up. Those nodes must define how these responsibilities meet the freshness, recovery, capacity, and availability goals; the transport choice alone does not establish that they do.

---

For review:

1. Do the **criterion weights** reflect your reasoning? Is there another consideration—especially one weighing against self-hosting—that should be included?
2. Do you approve the HLD and decision record before we start the three nodes?
3. Should low latency and provider independence over simpler operations be a **general tenet**, or just this decision?
4. The access design still calls delivery “open.” May I update that stale wording when we cascade?