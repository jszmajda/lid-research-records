Created `docs/decisions/change-delivery.md` and linked it from the HLD’s **Key Design Decisions**. The document reads as follows.

---

# Decision: Self-Hosted WebSocket Change Delivery

## Context

MarketBoard serves 40 weekend markets with up to 800 simultaneous staff browsers and opening-time bursts of 20 edits per second. Editors submit commands over HTTPS to one authoritative board per event. Connected browsers need committed changes within 15 seconds under normal connectivity; subsecond updates are useful but are not a separate guarantee.

Delivery spans the change store, delivery, and browser sync nodes, so its choice belongs to the high-level design. Every option preserves server-side command authorization and authoritative event revisions. Browser recovery after a disconnect of up to 20 minutes, seven-day revision retention, and 99.5 percent availability during event hours remain shared goals.

## Decision Elements

No inherited constraint eliminates any of the three options. Selection turns on these weighted criteria:

- **Update latency — major.** Prefer prompt delivery of committed changes over routinely waiting several seconds, even though all three options can meet the 15-second target.
- **Realtime vendor independence and fees — major.** Prefer delivery without a realtime provider’s subscription model, credentials, or recurring service bill. This and update latency express the tenet: “Prefer vendor-independent, low-latency updates over minimizing connection and reconnect operations work.”
- **Operational simplicity — moderate.** Fewer connection-management and recovery responsibilities make the service easier to operate. This criterion favors polling and hosted delivery and counts against self-hosted sockets.

Avoiding a realtime vendor bill does not establish the lowest total cost: self-hosting still consumes infrastructure and engineering effort. No provider quote or total-cost estimate settles this choice.

## Options in the Domain

### Five-Second HTTPS Polling

Browsers periodically request committed revisions after their last applied event revision. Request/response delivery is stateless and uses familiar HTTPS infrastructure; the change store supports cursor queries and browsers run a polling loop.

- **Update latency: partial fit.** A change waits for the next polling request, adding up to roughly five seconds of scheduling delay before request processing and network time.
- **Realtime vendor independence and fees: strong fit.** No realtime provider is required, though repeated reads consume application and store capacity. At 800 active browsers, five-second polling schedules roughly 160 requests per second even without changes.
- **Operational simplicity: strong fit.** The server does not maintain persistent browser connections. Failed requests and catch-up still need handling.

### Self-Hosted WebSockets

Browsers maintain connections to MarketBoard’s delivery service, which pushes committed event revisions. The change store supports replay and reliable publication; browsers reconnect and catch up after interruptions.

- **Update latency: strong fit.** Push delivery avoids the routine polling interval, though network and service conditions still affect latency.
- **Realtime vendor independence and fees: strong fit.** MarketBoard owns delivery without a realtime provider’s API or service bill; hosting and engineering costs remain.
- **Operational simplicity: weak fit.** MarketBoard operates connection capacity, failed connections, and reconnect recovery. Reliable publication and replay must prevent interruptions from leaving browsers permanently behind.

### Hosted Realtime Service

MarketBoard publishes committed changes through a realtime provider; browsers use the provider’s subscription model. The delivery node wraps that integration and the change store supports publication reconciliation.

- **Update latency: strong fit.** Provider subscriptions offer push updates without a routine polling delay.
- **Realtime vendor independence and fees: weak fit.** Delivery depends on provider contracts, credentials, subscription behavior, and recurring fees.
- **Operational simplicity: strong fit.** The provider operates browser connection capacity. MarketBoard still owns publication reconciliation, integration failures, and browser recovery.

## Selection

Use **self-hosted WebSockets** for committed-change delivery. Polling offers the simplest stateless operation and hosted realtime reduces connection operations work, but WebSockets combine the two major preferences: prompt updates and realtime vendor independence. The HLD’s vendor-independent, low-latency tenet outweighs operational simplicity for this decision.

This accepts responsibility for connection capacity and reconnect operations rather than assuming those costs disappear. It selects neither polling as the primary delivery mechanism nor a hosted realtime subscription model. It does not tighten the freshness guarantee or relax the availability and recovery goals.

The downstream obligations are:

- **Change store:** replayable authoritative event revisions and reliable publication of committed changes.
- **Delivery:** self-hosted WebSocket sessions, connection capacity, and delivery of committed revisions to subscribed browsers.
- **Browser sync:** subscription, visible connectivity state, reconnect, and revision-based catch-up.

The three node designs must settle publication mechanics and the replay/subscription handoff, and show how capacity and recovery support the HLD goals. This decision does not prescribe an outbox, broker, hosting topology, or reconnect timing.

---

`git diff --check` passed.

**Does this capture the tradeoff accurately enough to approve the HLD and decision document before we begin the three node designs?**