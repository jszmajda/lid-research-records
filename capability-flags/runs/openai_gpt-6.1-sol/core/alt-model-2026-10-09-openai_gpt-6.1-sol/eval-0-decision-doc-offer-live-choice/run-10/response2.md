Created `docs/decisions/change-delivery.md` and linked it from the HLD. The decision document reads:

# Decision: Self-hosted WebSockets for change delivery

## Context

MarketBoard coordinates stall closures, late arrivals, and power problems across 40 weekend markets. Up to 800 simultaneous staff browsers need a revisioned view of committed edits, including opening-time bursts of 20 edits per second. Editors submit commands over HTTPS to one authoritative board per event; this decision concerns how committed changes reach browsers.

The freshness requirement is 15 seconds under normal connectivity. Subsecond updates are useful but are not a separate guarantee. Browsers must recover the latest board after disconnections of up to 20 minutes, revisions are retained for seven days, and event-hours availability is targeted at 99.5 percent. These are shared obligations, not reasons to eliminate any of the three delivery approaches.

## Decision Elements

- **Update latency — major.** Favor prompt delivery of committed changes rather than waiting for the next scheduled read. The HLD tenet “Prefer fast, vendor-independent updates over minimizing connection and reconnect operations work” supplies this priority.
- **Realtime vendor independence — major.** Favor delivery that does not depend on a realtime provider's subscription model or recurring realtime service fees. This follows the same HLD tenet; it does not exclude ordinary hosting costs.
- **Operational simplicity — moderate.** Favor fewer connection-capacity, publication, and recovery responsibilities. This matters for event-hours availability, but is subordinate to fast, vendor-independent updates. Self-hosting transfers work to the project; it does not establish a lower total cost.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes after their last applied revision. Stateless request/response delivery uses familiar HTTP infrastructure and avoids maintaining long-lived connections. The change store supports cursor queries, and browsers operate a polling loop and recover missed revisions.

- **Update latency: partial fit.** A five-second interval meets the freshness target under normal conditions but introduces seconds of lag between a commit and its next read.
- **Realtime vendor independence: strong fit.** Delivery requires no realtime provider or realtime service subscription.
- **Operational simplicity: strong fit.** Stateless requests simplify connection operations, at the cost of repeated reads even when boards have not changed.

### Self-hosted WebSockets

Browsers maintain connections to project-operated delivery servers, which push committed event revisions. The change store supplies replayable revisions and reliable publication; delivery manages sessions; browsers reconnect and catch up after interruption.

- **Update latency: strong fit.** Push delivery avoids the scheduled polling delay; actual latency still depends on publication and delivery capacity.
- **Realtime vendor independence: strong fit.** The project owns delivery without a realtime provider's fees or subscription model.
- **Operational simplicity: weak fit.** The project owns connection capacity, connection failures, reconnect load, and coordination between replay and live delivery.

### Hosted realtime service

A provider operates realtime connections and delivers published changes through its subscription model. The change store needs publication reconciliation, delivery wraps the provider, and browsers use its subscription and recovery interfaces.

- **Update latency: strong fit.** Provider-managed push delivery avoids a scheduled polling delay and offers a quick route to low-latency updates.
- **Realtime vendor independence: weak fit.** Delivery acquires recurring service fees and coupling to provider interfaces.
- **Operational simplicity: strong fit.** The provider handles connection operations, while the project still owns publication reconciliation and browser recovery integration.

## Selection

Select self-hosted WebSockets. Polling offers independence and simpler operation, but adds avoidable delay. Hosted realtime offers fast updates with less connection work, but introduces provider coupling and recurring fees. Self-hosted WebSockets combine the two major priorities, accepting weaker operational simplicity in accordance with the HLD tenet.

This selection makes connection capacity and reconnect operations project responsibilities. Capacity planning must account for simultaneous browsers, opening-time edit bursts, and reconnect load. The availability target remains in force; accepting operations work does not relax it. Hosting, engineering effort, and incident response remain costs even without a realtime vendor bill.

The downstream designs carry distinct obligations:

- **Change store:** replayable event revisions and reliable publication of committed changes.
- **Delivery:** self-hosted WebSocket sessions, connection capacity, and server-side reconnect/catch-up coordination.
- **Browser sync:** subscription, reconnect, and catch-up from the last applied event revision, with visible connectivity failures.

The delivery architecture does not depend on a hosted realtime subscription model or a five-second polling loop. Exact publication, replay, and reconnect mechanisms belong in the three node designs; this decision does not select those mechanisms.

---

The document is consistent with the HLD, and `git diff --check` passes.

**Does this capture your rationale and priority ordering—fast updates and vendor independence ahead of operational simplicity—before we move to the three node designs?**