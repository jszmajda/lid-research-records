Created `docs/decisions/change-delivery.md` and linked it from the HLD’s **Key Design Decisions**. `git diff --check` passed.

## Decision: Self-hosted WebSockets for board updates

### Context

MarketBoard serves forty weekend markets, about 120 coordinators, and up to 800 simultaneous staff browsers. A busy market has 10–25 editors and averages two status changes per minute, with opening-time bursts of up to 20 edits per second. Coordinators need shared visibility of stall closures, late arrivals, and power problems.

Editors submit commands over HTTPS. The server maintains one authoritative board per event and assigns each committed edit an event revision. This command and authority boundary is independent of how changes reach browsers.

The delivery approach must support the HLD’s goals: changes visible within 15 seconds under normal connectivity, recovery after browser disconnections of up to 20 minutes, seven days of retained event revisions, and 99.5 percent availability during published event hours. These are shared obligations, not reasons to eliminate any of the three delivery options. Subsecond updates are useful but are not a required service guarantee.

The choice spans change storage, delivery, and browser sync, so it belongs to the high-level design. A persistent transport does not itself guarantee that every committed revision reaches a browser; publication and catch-up remain design obligations.

### Decision Elements

- **Update latency — major.** Prefer prompt visibility of edits over using the full 15-second freshness allowance. During opening-time activity, coordinators benefit from seeing changes without waiting for a periodic read.
- **Realtime-vendor independence — major.** Prefer control of the delivery service over dependency on a realtime provider’s subscription model, commercial terms, and recurring service fees. This follows the HLD tenet: “Prefer fast, realtime-vendor-independent updates over minimizing connection and reconnect operations work.” It does not prohibit managed infrastructure elsewhere in the system.
- **Operational simplicity — moderate.** Fewer long-lived connections, connection-capacity concerns, and reconnect failure modes reduce the work of keeping the service available. This consideration favors the alternatives to self-hosted sockets, but is subordinate to the two major criteria under the same tenet.

Operator time, reconnect storms, and recovery during service interruptions are costs even without a realtime vendor bill. No comparative total-cost estimate or capacity benchmark is established by this decision. The selection accepts those obligations; it does not establish that self-hosting is cheaper overall or already meets the availability and capacity goals.

### Options in the Domain

#### Five-second HTTPS polling

Browsers periodically request committed changes after their last applied event revision. The server answers ordinary HTTPS requests rather than retaining a live delivery session. The change store supports cursor queries, delivery provides request/response reads, and browser sync owns the polling loop and recovery cursor.

- **Update latency: partial fit.** A five-second interval can meet the 15-second target under normal connectivity, but edits may wait several seconds for the next request.
- **Realtime-vendor independence: strong fit.** Ordinary HTTPS delivery does not require a realtime provider or its client subscription model.
- **Operational simplicity: strong fit.** Delivery is stateless request/response and avoids socket-session capacity and reconnect management. Repeated reads still consume infrastructure resources, including when no board changes have occurred.

Polling provides straightforward operation and adequate required freshness at the cost of update lag and repeated reads.

#### Self-hosted WebSockets

Browsers establish secure WebSocket sessions with MarketBoard’s delivery service. The service pushes committed event revisions to subscribed browsers. The change store supplies replayable revisions and reliable publication; delivery owns sessions and catch-up delivery; browser sync owns reconnect and recovery from its last applied revision.

- **Update latency: strong fit.** Live connections allow committed changes to be pushed without waiting for the next polling interval. Actual latency still depends on publication and delivery performance.
- **Realtime-vendor independence: strong fit.** MarketBoard operates the delivery service and controls its browser-facing protocol without a realtime vendor subscription or provider-specific client model.
- **Operational simplicity: weak fit.** MarketBoard owns connection capacity, interrupted sessions, reconnect bursts, and service recovery. Reliable publication and replay must bridge failures rather than assuming socket sends are durable.

Self-hosted sockets combine prompt updates with vendor independence, while placing connection and recovery operations on MarketBoard.

#### Hosted realtime service

MarketBoard publishes committed changes through a realtime provider. A delivery adapter wraps the provider, and browsers use its subscription model. The change store supports publication reconciliation so database commits and provider delivery can be recovered when they diverge. The provider operates the live connection infrastructure.

- **Update latency: strong fit.** Provider-managed subscriptions enable prompt push delivery and offer a quick route to low-latency updates.
- **Realtime-vendor independence: weak fit.** Delivery depends on the provider’s APIs, subscription semantics, commercial terms, and recurring fees. An adapter can limit coupling but cannot remove those dependencies.
- **Operational simplicity: partial fit.** The provider reduces connection operations work, but MarketBoard still owns publication reconciliation, credentials, browser recovery, and handling provider interruptions.

A hosted service reduces connection-management effort in exchange for recurring fees and provider coupling.

### Selection

Use **self-hosted secure WebSockets** for committed board-change delivery. It combines strong fit on update latency and realtime-vendor independence. Five-second polling offers simpler operation and satisfies required freshness, but does not offer the same immediacy. Hosted realtime offers prompt updates and less connection operations work, but introduces the provider dependency and recurring service fees this approach seeks to avoid.

The HLD tenet favoring fast, realtime-vendor-independent updates over minimizing connection and reconnect operations work resolves the tradeoff. Operational simplicity has real value; its weaker fit is an accepted cost of this selection, not an absent concern.

The decision creates these downstream obligations:

- **Change store:** retain authoritative, replayable event revisions and establish reliable publication and publication recovery for committed changes.
- **Delivery:** operate secure WebSocket sessions, support the connection and edit-burst goals, and coordinate catch-up with live delivery across interruptions.
- **Browser sync:** track the applied revision, reconnect and recover missed changes, and surface connectivity failures rather than displaying a stale board as current.

The three node designs must establish a coherent recovery path without gaps between catch-up and live updates. The decision does not select a publication mechanism, deployment topology, or detailed reconnect protocol; those choices require their own node-level design and review.

HTTPS remains the command boundary. The 15-second freshness target remains the service requirement; subsecond delivery is a benefit rather than a new guarantee. Five-second polling and hosted realtime are not the selected delivery architecture. A materially different priority for operator effort, an unacceptable capacity or availability result, or a change in tolerance for provider coupling would justify revisiting this choice against the same criteria.

---

**Does this capture why you accepted the tradeoff, including the relative priorities, so we can proceed to the change-store node first?**