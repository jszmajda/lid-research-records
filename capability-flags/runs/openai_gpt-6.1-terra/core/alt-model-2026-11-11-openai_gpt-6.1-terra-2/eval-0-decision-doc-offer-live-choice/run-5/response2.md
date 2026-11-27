Added `docs/decisions/change-delivery.md` and linked it from the HLD. Here is the decision document for review:

# Decision: Delivery of committed board changes

## Context

MarketBoard maintains one authoritative, revisioned board per event. Editors send commands over HTTPS, and staff browsers need to see committed changes while a market is operating. The board must support up to 800 simultaneous browsers and bursts of 20 edits per second, recover after a browser has been disconnected for up to 20 minutes, and show committed changes within 15 seconds under normal connectivity. Subsecond updates are useful but not required.

The delivery approach shapes the change store, the delivery service, and browser recovery. All three options can meet the freshness target; they differ in latency, dependence on a realtime provider, operating responsibilities, and recurring costs.

## Decision Elements

- **Major — update latency.** Faster delivery makes the board more useful during active market operations, even though the 15-second goal does not require subsecond delivery.
- **Major — realtime-provider independence.** Avoid tying the board's update delivery to a realtime vendor and its subscription model.
- **Moderate — operational responsibility.** Limit the work of running delivery infrastructure, including managing connections and recovery.
- **Moderate — recurring delivery costs.** Limit repeated read traffic and recurring provider fees; actual costs depend on deployment and usage.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes since a cursor. The server responds with committed revisions, and the browser applies them to its board. The store needs cursor queries, delivery remains request/response, and browsers run a polling loop and catch up after interruptions.

- **Latency: weak fit.** A change may wait several seconds for the next poll, although the approach can meet the 15-second goal.
- **Provider independence: strong fit.** Delivery does not require a realtime provider.
- **Operational responsibility: strong fit.** Stateless requests avoid operating a fleet of persistent browser connections.
- **Recurring delivery costs: partial fit.** There is no realtime-provider subscription, but polling generates repeated reads even when few changes occur.

### Self-hosted WebSockets

The service maintains WebSocket sessions to push committed changes to connected browsers. The store needs replayable revisions and reliable publication; delivery manages sessions and connection capacity; browsers reconnect and catch up after interruptions.

- **Latency: strong fit.** Changes can be pushed promptly rather than waiting for the next poll.
- **Provider independence: strong fit.** The project operates its own delivery service without a realtime vendor.
- **Operational responsibility: weak fit.** The project owns connection capacity, session management, and reconnect and recovery problems.
- **Recurring delivery costs: partial fit.** There is no realtime-vendor subscription, but the project pays for and operates the infrastructure that holds connections and delivers updates.

### Hosted realtime service

A hosted provider maintains subscriptions and distributes updates to browsers. The store and publication path need reconciliation so committed changes reach the provider; the delivery component wraps the provider, and browsers use its subscription model.

- **Latency: strong fit.** Subscriptions can deliver changes promptly without waiting for a polling interval.
- **Provider independence: weak fit.** Delivery and browser subscriptions depend on the provider's service and interfaces.
- **Operational responsibility: strong fit.** The provider takes on much of the connection infrastructure, though publication and recovery still need attention.
- **Recurring delivery costs: weak fit.** Provider fees recur alongside the application's own infrastructure costs.

## Selection

Use self-hosted WebSockets. Fast updates and independence from a realtime provider outweigh the additional work of operating connections and handling reconnects. Polling is simpler but trades away prompt updates; a hosted service reduces connection operations but adds fees and provider coupling. This selection accepts the operational burden rather than claiming that the 15-second goal requires WebSockets.

The change store must support replayable revisions and reliable publication, delivery must manage WebSocket sessions, and browser sync must reconnect and catch up. These responsibilities must be designed together so that a committed edit keeps its authoritative event revision and connectivity failures remain visible, as required by the HLD's tenets. The detailed publication, session, and recovery mechanisms belong in the respective design nodes.

---

Does this capture the tradeoff and the relative importance of the criteria correctly? Do you approve the HLD and decision document for the cascade into the three nodes?

Also, should provider independence be a general project tenet, or is it specific to realtime delivery? The access design still calls the delivery approach open; I’ll need your approval to update that downstream node too.