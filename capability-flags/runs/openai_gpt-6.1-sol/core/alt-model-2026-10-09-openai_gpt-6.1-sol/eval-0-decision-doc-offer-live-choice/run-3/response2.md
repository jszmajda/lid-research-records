Created `docs/decisions/change-delivery.md` and linked it from the HLD’s Key Design Decisions. `git diff --check` passed.

Here is the decision document for review:

# Decision: Self-hosted WebSockets for board changes

## Context

MarketBoard serves forty weekend markets with up to 800 simultaneous staff browsers. Coordinators need a shared view of stall closures, late arrivals, and power problems. Busy markets average two status changes per minute, with opening-time bursts of up to 20 edits per second.

Editors submit commands over HTTPS. The server commits changes to one authoritative board per event and assigns event revisions. This decision concerns how committed changes reach browsers, not how commands are authorized or committed.

The required freshness bound is 15 seconds under normal connectivity. Subsecond updates are useful but are not a separate guarantee. Five-second polling, self-hosted WebSockets, and hosted realtime delivery can each meet the freshness requirement if appropriately implemented and provisioned. They differ in delivery latency, provider dependence, and operational burden.

Every option must also support recovery of the latest board after disconnections of up to 20 minutes, seven days of revision retention, and 99.5 percent availability during published event hours. These are shared design obligations rather than criteria that eliminate an option. Event updates contain stall IDs and operational statuses, not customer records; managed infrastructure is permitted.

## Decision Elements

- **Fast updates — major.** Favor prompt delivery after a change commits, even though several seconds of lag would satisfy the required freshness bound. This engages the HLD tenet: “Prefer fast, vendor-independent delivery over minimizing connection and reconnect operations.”
- **Realtime vendor independence — major.** Favor delivery without a realtime provider’s subscription model, service dependency, or recurring provider fees. This engages the same tenet. It does not prohibit managed infrastructure elsewhere in MarketBoard.
- **Operational simplicity — moderate.** Connection capacity, reconnect behavior, failure recovery, and recurring operating work matter, especially during opening-time bursts. This criterion cuts against self-hosted sockets, but is secondary to fast, vendor-independent delivery under the HLD tenet.

No delivery option is eliminated solely for satisfying these criteria less strongly. There is no established total-cost estimate; avoiding a realtime vendor bill is not evidence that self-hosting has the lowest total operating cost.

## Options in the Domain

### Five-second HTTPS polling

Each browser periodically requests changes after its last applied revision. Delivery stays request/response; the store supports cursor queries; browsers run a polling loop and resume reads after connectivity returns.

- **Fast updates: partial fit.** A connected browser normally waits until its next poll to discover a committed change, adding up to about five seconds before request and processing time. This can satisfy the 15-second target but does not provide prompt push delivery.
- **Realtime vendor independence: strong fit.** Ordinary HTTPS requests need no realtime provider or provider subscription model.
- **Operational simplicity: strong fit.** Delivery is stateless request/response rather than long-lived socket management. At 800 browsers polling every five seconds, the baseline is about 160 requests per second even when boards are unchanged; the service must provision those repeated reads and handle synchronized retries.

### Self-hosted WebSockets

MarketBoard maintains browser connections and pushes committed changes through its own delivery service. The store provides replayable revisions and reliable publication; delivery owns socket sessions; browsers reconnect and catch up after interruptions.

- **Fast updates: strong fit.** Connected browsers receive changes without waiting for a polling interval, making low-latency updates possible.
- **Realtime vendor independence: strong fit.** MarketBoard owns the delivery implementation and has no realtime provider subscription model or bill.
- **Operational simplicity: weak fit.** MarketBoard must provision and operate connection capacity, detect failed connections, and handle reconnect surges. Reliable publication and coordination of replay with live updates add design and recovery work beyond polling.

### Hosted realtime service

MarketBoard publishes committed changes through a provider and browsers use its subscription model. Delivery wraps the provider; the store reconciles committed revisions with publication so that failed publication does not silently lose updates.

- **Fast updates: strong fit.** Provider-managed subscriptions enable low-latency push delivery without a browser polling interval.
- **Realtime vendor independence: weak fit.** Delivery depends on provider APIs and subscription semantics, with recurring provider fees and migration work if the provider changes.
- **Operational simplicity: strong fit.** The provider operates connection infrastructure and much of the subscription lifecycle. MarketBoard still owns credentials, publication reconciliation, browser recovery, and handling provider outages.

## Selection

Use self-hosted WebSockets for delivery of committed board changes. This option combines fast push updates with realtime vendor independence. The HLD tenet “Prefer fast, vendor-independent delivery over minimizing connection and reconnect operations” gives those two criteria priority over operational simplicity.

Polling remains a credible simpler option that meets the freshness bound, but accepts several seconds of delivery lag and repeated reads. Hosted realtime remains a credible way to obtain fast updates with less connection operations work, but accepts provider coupling and recurring fees. Self-hosted WebSockets accepts the connection and reconnect work instead. It does not establish a subsecond service guarantee or a total-cost saving.

The decision creates obligations for three design nodes:

- **Change store:** define replayable committed revisions and reliable publication. Choose the persistence, replay, and publication mechanisms in its design.
- **Delivery:** define socket session management, capacity for 800 browsers and opening-time bursts, and coordination of catch-up with live delivery.
- **Browser sync:** define connection lifecycle, reconnect and revision catch-up, and visible connectivity state.

The transport choice does not by itself guarantee recovery or availability. The three nodes must make those behaviors explicit and compatible with the shared event revision boundary. Server-side HTTPS command authorization remains the access component’s responsibility.

---

Does this capture why you accepted the tradeoff? If approved, shall we start with the change-store design?