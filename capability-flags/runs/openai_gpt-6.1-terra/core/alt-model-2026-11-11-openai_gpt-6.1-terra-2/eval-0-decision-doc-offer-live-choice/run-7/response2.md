Added [`docs/decisions/change-delivery.md`](docs/decisions/change-delivery.md) and linked it from the HLD.

# Decision: Change Delivery

## Context

MarketBoard maintains one authoritative board per event. Editors submit commands over HTTPS, and connected staff browsers need to see committed changes. The pilot must support 800 simultaneous browsers, opening-time bursts of 20 edits per second, and recovery after disconnections of up to 20 minutes. Its normal-connectivity freshness goal is 15 seconds; updates in less than a second would be useful but are not required. All three approaches considered can meet the freshness goal.

The delivery choice shapes revision storage, publication, and browser recovery as well as the work required to operate the system.

## Decision Elements

- **Major — update latency:** Favor getting committed changes to connected browsers quickly, including where this improves on the required freshness target.
- **Major — realtime provider independence:** Avoid coupling delivery to a realtime provider and its recurring service fees.
- **Moderate — operational simplicity:** Reduce the connection-management and recovery work the team must own.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes since a cursor over HTTPS. The server responds with committed changes, and browsers advance their cursors. The change store supports cursor queries; delivery remains request/response and browsers run a polling loop.

- **Update latency — partial:** A connected browser normally waits until its next poll, adding up to several seconds of lag.
- **Realtime provider independence — strong:** Delivery uses the application's own HTTPS infrastructure without a realtime service.
- **Operational simplicity — strong:** Stateless requests avoid managing long-lived connections, though repeated reads and requests add load.

### Self-hosted WebSockets

Browsers maintain WebSocket connections to application-operated delivery infrastructure. Committed changes are published to connected browsers; replayable revisions support catch-up after interruption. The change store needs reliable publication, delivery manages sessions and connection capacity, and browsers reconnect and catch up.

- **Update latency — strong:** Changes can be pushed to connected browsers promptly without waiting for a polling interval.
- **Realtime provider independence — strong:** The application operates delivery without a realtime vendor or its service bill. Infrastructure and operational work still have costs.
- **Operational simplicity — weak:** The team owns connection capacity, session management, reconnect behavior, and reliable publication and recovery.

### Hosted realtime service

The application publishes committed changes through a provider, and browsers subscribe using the provider's model. The change store needs publication reconciliation, delivery wraps the provider, and browsers integrate its subscription and recovery mechanisms.

- **Update latency — strong:** Provider-managed subscriptions support prompt push delivery.
- **Realtime provider independence — weak:** Delivery depends on a provider's service and incurs recurring fees.
- **Operational simplicity — strong:** The provider handles much of the connection infrastructure, though the application still owns publication reconciliation and browser integration.

## Selection

Use self-hosted WebSockets. They favor fast updates and avoid a realtime vendor dependency and service bill, while accepting the operational burden of connections and recovery. Polling is simpler to operate but adds repeated reads and several seconds of lag; a hosted service offers low latency with less connection operations work but introduces provider coupling and recurring fees.

This choice commits the design to replayable event revisions and reliable publication, self-hosted session and capacity management, and browser reconnect and catch-up. The change-store, delivery, and browser-sync designs must work together to preserve the authoritative event revision and make connectivity failures visible. The detailed contracts and recovery mechanisms belong in those nodes.

---

Before moving to the three nodes:

1. Do you approve the HLD and this decision record? The existing access design still calls delivery “open”; that cross-node wording needs a later cascade.
2. Do the criterion weights reflect your priorities? In particular, would the cost or staffing needed to operate WebSockets change the decision?
3. Should the preference for fast updates and provider independence become a general tenet, or is it specific to this choice?