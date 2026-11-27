Created `docs/decisions/change-delivery.md` and linked it from the HLD’s **Key Design Decisions**. It records the tradeoff at the project level, where all three component designs can reference it. `git diff --check` passed.

Here is the decision document for review.

# Decision: Self-hosted WebSockets for board changes

## Context

MarketBoard serves 40 weekend markets and up to 800 simultaneous staff browsers, with opening-time bursts of 20 edits per second. Editors submit commands over HTTPS; the server assigns each committed edit one authoritative event revision. This decision concerns how committed changes reach browsers, not how edits are authorized or committed.

The freshness target is 15 seconds under normal connectivity. Subsecond updates are useful, not mandatory. Browsers must recover the latest board after disconnections of up to 20 minutes, and the system targets 99.5 percent availability during published event hours. All three delivery approaches can meet the freshness target; no approach removes the need for recovery or visible connectivity failures.

Self-hosted and managed infrastructure are both permitted. Provider independence is a preference, not a prohibition on managed infrastructure.

## Decision Elements

- **Fast updates — major.** Favor delivery soon after commitment rather than waiting for a scheduled read. This reflects the HLD tenet favoring fast board updates over minimizing connection-management operations.
- **Realtime-provider independence — major.** Favor control of the delivery contract without a provider-specific subscription model. This reflects the same HLD tenet.
- **Recurring realtime service fees — moderate.** Favor avoiding a separate realtime vendor bill. This is not a claim that self-hosting has lower total cost: infrastructure and operator time still cost money.
- **Operational simplicity — moderate.** Favor less connection-capacity, reconnect, and service-management work. Operational burden matters to the availability goal, even though it is not the overriding preference.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes after their latest event revision. Delivery remains request/response, and the change store supports cursor queries. Stateless requests use familiar HTTPS infrastructure and avoid persistent connection management.

- **Fast updates: partial fit.** Normal polling adds up to roughly one polling interval before a change is requested, plus request time; it can meet the 15-second target but introduces seconds of lag.
- **Realtime-provider independence: strong fit.** The application owns the HTTPS delivery contract.
- **Recurring realtime service fees: strong fit.** No realtime vendor subscription is needed; repeated reads still consume infrastructure resources.
- **Operational simplicity: strong fit.** Stateless requests avoid persistent sessions, though browsers still need polling, error handling, and catch-up.

### Self-hosted WebSockets

The application operates persistent browser connections and pushes committed revisions. The change store supports replayable revisions and reliable publication; delivery manages sessions; browsers reconnect and catch up after interruptions.

- **Fast updates: strong fit.** Push avoids the scheduled polling wait; actual latency still depends on publication and connection health.
- **Realtime-provider independence: strong fit.** The application owns its socket protocol and delivery infrastructure.
- **Recurring realtime service fees: strong fit.** No realtime vendor subscription is needed; hosting and operator costs remain.
- **Operational simplicity: weak fit.** MarketBoard owns connection capacity, session lifecycle, reliable publication, and reconnect operations.

### Hosted realtime service

A provider operates persistent connections and exposes a subscription model. Delivery wraps the provider, the store reconciles committed changes with publication, and browsers use the provider’s subscription and recovery mechanisms.

- **Fast updates: strong fit.** Provider push avoids the polling wait, subject to publication and provider health.
- **Realtime-provider independence: weak fit.** Delivery and browser recovery depend on the provider’s interfaces and semantics.
- **Recurring realtime service fees: weak fit.** The service introduces an ongoing vendor bill; its amount depends on provider pricing and usage.
- **Operational simplicity: strong fit.** The provider operates connection infrastructure, while MarketBoard still owns integration, publication reconciliation, and recovery correctness.

## Selection

Use self-hosted WebSockets. They combine fast updates with realtime-provider independence and avoid a separate realtime vendor bill. Polling is operationally simpler but adds delivery lag; hosted realtime reduces connection operations but introduces provider coupling and recurring fees. The HLD tenet favoring fast updates and provider independence outweighs the operational-simplicity advantage of those alternatives.

This choice accepts responsibility for connection capacity and reconnect operations; it does not promise lower total cost or subsecond delivery. Its downstream obligations are:

- **Change store:** authoritative board state, replayable event revisions, and reliable publication of committed changes.
- **Delivery:** self-hosted socket sessions, connection capacity, and coordination with revision replay for recovery.
- **Browser sync:** subscription, reconnect, revision-based catch-up, and visible connectivity state.

The three component designs define publication guarantees, replay contracts, and recovery details. WebSockets are the selected live delivery route; polling and hosted subscriptions are not parallel delivery modes. The 15-second freshness target, 20-minute recovery window, seven-day revision retention, and event-hours availability goal remain constraints on those designs.

---

**Does this capture the rationale accurately—particularly the relative importance assigned to speed, provider independence, service fees, and operational simplicity?**