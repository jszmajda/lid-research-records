I added `docs/decisions/change-delivery.md` and linked it from the HLD. Here is the decision document for review:

---

# Decision: Change Delivery

## Context

MarketBoard keeps one authoritative board per event. Editors submit commands over HTTPS, and connected browsers need to see committed changes. The pilot targets 800 simultaneous browsers, bursts of 20 edits per second, and delivery within 15 seconds under normal connectivity. Browsers must recover the latest board after disconnections of up to 20 minutes, and event revisions are retained for seven days.

All three approaches below can meet the freshness target. Subsecond updates are useful but not required. Each must preserve the authoritative event revision and make connectivity failures visible; those project tenets constrain the design regardless of transport.

## Decision Elements

- **Update latency — major.** Faster updates make the shared board more immediately useful, even though the target allows up to 15 seconds.
- **Independence from a realtime provider — major.** Avoid coupling delivery to a provider's service and subscription model.
- **Connection and recovery operations — moderate.** Consider the work of running delivery capacity and handling disconnected browsers.
- **Recurring realtime service fees — moderate.** Consider provider charges for delivery separately from the infrastructure and staff costs of running the system.

## Options in the Domain

### Five-second HTTPS polling

Each browser periodically requests changes since its last known revision over HTTPS. The store supplies cursor-based queries and the browser runs a polling loop and catches up after disconnecting.

- **Update latency: weak.** Changes can wait several seconds for the next poll.
- **Provider independence: strong.** Delivery uses the application's own request/response service.
- **Connection and recovery operations: strong.** Stateless requests avoid operating long-lived socket sessions, though browsers still need catch-up behavior.
- **Recurring realtime service fees: strong.** No dedicated realtime provider is required; repeated reads still consume infrastructure resources.

### Self-hosted WebSockets

Browsers maintain WebSocket connections to a MarketBoard delivery service, which sends committed changes. The change store provides replayable revisions and reliable publication; delivery manages sessions; browsers reconnect and catch up after interruptions.

- **Update latency: strong.** Changes can be pushed to connected browsers without waiting for a polling interval.
- **Provider independence: strong.** MarketBoard owns the delivery service and its connection model.
- **Connection and recovery operations: weak.** The project must provision and operate connection capacity and handle reconnects and catch-up.
- **Recurring realtime service fees: strong.** There is no dedicated realtime provider bill, though hosting and operations still cost money.

### Hosted realtime service

MarketBoard publishes committed changes to a managed realtime provider, and browsers use its subscription model. The store needs publication reconciliation, and the delivery component wraps the provider and manages its integration.

- **Update latency: strong.** The provider can push updates to subscribed browsers without a polling interval.
- **Provider independence: weak.** Delivery and browser subscriptions depend on the provider's service and interfaces.
- **Connection and recovery operations: strong.** The provider takes on much of the connection infrastructure, while the application still needs publication reconciliation and browser recovery.
- **Recurring realtime service fees: weak.** The provider adds recurring charges, although it reduces some self-hosted operational work.

## Selection

Use self-hosted WebSockets. Fast updates and independence from a realtime vendor outweigh the additional connection and reconnect operations. Polling is simpler but gives up immediacy; hosted realtime offers fast updates with less connection infrastructure to operate, but adds recurring fees and provider coupling. This choice does not assert that self-hosting has the lowest total cost.

The selection commits the change store, delivery, and browser sync designs to coordinate publication, session management, replay, and catch-up. It rules out polling and a hosted realtime service as the primary delivery approach; their tradeoffs remain relevant if the latency preference, operational capacity, or provider economics change. The authoritative-revision and visible-failure tenets apply to the selected design, but do not themselves select a transport.

---

1. Do the criteria and their relative importance capture your reasoning, or is there another consideration—particularly one that might favor polling or hosted delivery?
2. Do you approve this document and the updated HLD?
3. Should **lower latency over simpler operations** be a general project tenet, or was it specific to this decision?