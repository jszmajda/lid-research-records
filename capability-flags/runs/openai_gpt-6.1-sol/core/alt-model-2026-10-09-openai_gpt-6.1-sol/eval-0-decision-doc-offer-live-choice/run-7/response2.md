Created `docs/decisions/self-hosted-websocket-delivery.md` and linked it from the HLD’s Key Design Decisions. `git diff --check` passed.

Here is the decision document for review.

# Decision: Self-hosted WebSockets for board updates

## Context

MarketBoard serves forty weekend markets with up to 800 simultaneous staff browsers and opening-time bursts of 20 edits per second. Coordinators need a shared view of stall closures, late arrivals, and power problems. Editors submit commands over HTTPS; the server maintains one authoritative board and assigns event revisions to committed changes.

The high-level design requires connected browsers to show committed changes within 15 seconds under normal connectivity, recover the latest board after disconnections of up to 20 minutes, and retain seven days of revisions. Subsecond delivery is useful but is not a required service target. Five-second polling, self-hosted WebSockets, and hosted realtime delivery can all meet the freshness target; that target alone does not select the approach.

## Decision Elements

These are weighted criteria, not exclusion gates:

- **Update latency — major.** Prefer prompt delivery rather than waiting for a periodic read. This engages the tenet “Prefer fast updates without realtime-vendor dependence over minimizing connection and reconnect operations work.”
- **Realtime-vendor independence — major.** Prefer control of the delivery layer without provider-specific subscription APIs or a recurring realtime-service bill. This engages the same tenet; managed infrastructure elsewhere remains permitted.
- **Implementation and operational simplicity — moderate.** Consider initial engineering work, repeated reads, connection capacity, publication failures, reconnect behavior, and ongoing maintenance. Simplicity matters, but the stated tenet gives latency and realtime-vendor independence greater weight.

There is no quantified total-cost comparison. Avoiding a realtime-service bill does not eliminate infrastructure or staff costs, and self-hosting is not assumed to be cheaper overall.

## Options in the Domain

### Five-second HTTPS polling

Each browser periodically requests changes after its last applied event revision. Delivery remains request/response, and the change store supports cursor queries. This uses familiar stateless HTTP operations and avoids a persistent connection fleet.

- **Weak fit — update latency.** A committed edit waits for the next poll, introducing seconds of lag while still meeting the 15-second target under normal connectivity.
- **Strong fit — realtime-vendor independence.** Application-owned HTTP endpoints need no hosted realtime provider.
- **Strong fit — implementation and operational simplicity.** Stateless requests simplify deployment and recovery, though browsers need polling loops and the store handles repeated reads even when boards are unchanged.

### Self-hosted WebSockets

Browsers maintain connections to application-operated delivery servers. Committed revisions are published to connected sessions, and interrupted browsers reconnect and catch up from stored revisions. The application operates both the live connection path and recovery behavior.

- **Strong fit — update latency.** Publication can reach connected browsers promptly without waiting for a polling interval.
- **Strong fit — realtime-vendor independence.** The application controls delivery and its browser protocol without a hosted realtime-service dependency or bill.
- **Weak fit — implementation and operational simplicity.** The team owns connection capacity, interrupted publication, deployment-related disconnects, reconnect load, and replay coordination. Reliable revision storage is still necessary; a socket connection alone does not guarantee recovery.

### Hosted realtime service

The application publishes committed changes through a provider, and browsers use that provider’s subscription model. The provider operates persistent connections; the application wraps its API and reconciles publication with authoritative revisions.

- **Strong fit — update latency.** Provider subscriptions offer prompt push delivery without polling intervals.
- **Weak fit — realtime-vendor independence.** Subscription APIs and publication behavior create provider coupling, with recurring service fees.
- **Strong fit — implementation and operational simplicity.** The provider absorbs connection operations and can shorten delivery implementation. Application-side publication reconciliation, credentials, and browser recovery still require design and maintenance.

## Selection

Use self-hosted WebSockets for committed board changes. The tenet favoring fast updates without realtime-vendor dependence outweighs the simpler operations of polling and the reduced connection burden of a hosted service. This accepts additional engineering and ongoing operations work; the choice is not compelled by the 15-second freshness requirement or by a proven total-cost saving.

The decision creates obligations for three design nodes:

- **Change store:** persist replayable committed event revisions and provide reliable publication to delivery.
- **Delivery:** operate WebSocket sessions and connection capacity, and coordinate live delivery, replay, and recovery from interrupted publication.
- **Browser sync:** apply revisions, expose connection failures, reconnect, and catch up from the last applied revision to the latest board.

HTTPS remains the command boundary. The node designs determine publication mechanisms, connection limits, reconnect policy, and catch-up contracts within the HLD’s freshness, recovery, retention, and availability goals.

---

**Does this capture the tradeoff you accepted—particularly giving latency and vendor independence greater weight than implementation and operational simplicity?**