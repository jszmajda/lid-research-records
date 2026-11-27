Created `docs/decisions/realtime-delivery.md` and linked it from the HLD’s Key Design Decisions section. The record explains the criteria, compares the three options, and describes the operational work accepted with self-hosted WebSockets. `git diff --check` passes.

```markdown
---
node: high-level-design
---

# Decision: Realtime Board Delivery

## Context

MarketBoard keeps one authoritative revision sequence for each event and needs to show committed changes in staff browsers within 15 seconds under normal connectivity. The system is expected to support up to 800 simultaneous browsers, recover the latest board after a browser has been disconnected for up to 20 minutes, and retain seven days of event revisions.

The delivery approach determines how quickly connected browsers see a change and what the project must operate or depend on. The main alternatives are periodic HTTPS polling, a self-hosted WebSocket service, and a hosted realtime service. Each can meet the freshness target, but they place different demands on the change store, delivery layer, and browser recovery behavior.

## Decision Elements

These criteria are specific to realtime board delivery; no project-wide tenet currently resolves this tradeoff.

- **Fast updates — major.** Connected staff should see committed changes promptly. Subsecond updates are useful but are not a requirement; the stated target is 15 seconds under normal connectivity.
- **Realtime-vendor independence and recurring service cost — major.** Avoid making board delivery depend on a realtime provider's API, credentials, availability, or recurring service fees.
- **Operational burden — moderate.** Account for the work and capacity needed to operate delivery, including connection lifecycle, recovery after disconnection, and publication reliability.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically issue HTTPS requests asking for event revisions newer than a cursor. The server responds with the changes available at that cursor; the browser repeats the request after five seconds. This retains request/response delivery and does not require long-lived connections.

- **Fast updates — partial.** A committed change may wait for the next polling interval before a browser requests it, adding several seconds of delivery lag.
- **Realtime-vendor independence and recurring service cost — strong.** Delivery uses the project's HTTPS service without a realtime provider.
- **Operational burden — strong.** The service avoids managing persistent browser sessions, though the store needs cursor queries and repeated reads add request load.

Summary: simplest connection operations, with periodic read load and polling-interval latency.

### Self-hosted WebSockets

The project operates a WebSocket service that keeps browser connections open and sends committed revision notifications over them. The change store retains replayable revisions and supports reliable publication. Delivery manages connection sessions, and browsers reconnect and catch up from their last applied revision after interruption.

- **Fast updates — strong.** The server can publish a committed revision to an open connection without waiting for a polling interval.
- **Realtime-vendor independence and recurring service cost — strong.** The project operates the delivery service itself and does not depend on a hosted realtime provider or its recurring service fees.
- **Operational burden — weak.** The project owns connection capacity, session lifecycle, reliable publication, reconnect behavior, and replay-based catch-up.

Summary: fast, provider-independent delivery in exchange for owning connection and recovery operations.

### Hosted realtime service

The application publishes committed changes to a realtime provider, which manages browser subscriptions and persistent connections. The application integrates with the provider's credentials, API, and subscription model, and reconciles publication with committed revisions.

- **Fast updates — strong.** The provider delivers changes to subscribed browsers without a polling interval.
- **Realtime-vendor independence and recurring service cost — weak.** Delivery depends on provider-specific integration and incurs recurring service fees.
- **Operational burden — strong.** The provider operates connection capacity and much of session recovery, while the application still owns publication reconciliation and provider integration.

Summary: low connection-operations burden and fast updates, with recurring fees and provider coupling.

## Selection

Use self-hosted WebSockets to deliver committed event revisions to connected browsers. This satisfies the need for fast updates while avoiding a realtime-vendor dependency and its recurring service fees. Five-second polling avoids provider coupling and is simpler to operate, but introduces periodic read load and several seconds of update lag. A hosted realtime service also provides fast updates and lowers connection-operations work, but requires accepting provider coupling and recurring fees.

The choice favors fast, vendor-independent delivery over minimizing connection and recovery operations. The project accepts responsibility for operating capacity for up to 800 simultaneous browsers, managing connection sessions, publishing committed revisions reliably, and supporting browser reconnect and catch-up. The change store, delivery, and browser-sync design nodes must define the details of those responsibilities while preserving the 15-second freshness target, 20-minute browser recovery, and seven-day revision retention goals.
```

Please review and approve this decision record before I proceed to the three design nodes. I kept vendor independence specific to this delivery decision rather than making it a project-wide HLD tenet—is that right?