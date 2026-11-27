Created `docs/decisions/change-delivery.md` and linked it from the HLD’s Key Design Decisions. The decision record reads:

# Decision: Self-hosted WebSockets for Board Updates

## Context

MarketBoard distributes stall-status changes across forty weekend markets, serving up to 800 simultaneous staff browsers and opening-time bursts of 20 edits per second. Editors submit commands over HTTPS; the server commits each edit with one authoritative event revision.

The delivery approach shapes revision storage, delivery infrastructure, and browser recovery. The freshness goal is 15 seconds under normal connectivity. Subsecond updates are useful but not required, so polling, self-hosted WebSockets, and hosted realtime delivery are all credible approaches. Each must support recovery after a browser disconnects for up to 20 minutes, seven-day revision retention, and the 99.5 percent event-hours availability goal. These shared obligations are background, not reasons to prefer one transport.

## Decision Elements

The HLD tenet **“Prefer low-latency updates without realtime vendor coupling over minimizing connection and reconnect operations work”** establishes the following priorities:

- **Update latency — major.** Prefer prompt delivery of committed changes over waiting for a scheduled read, even where both satisfy the freshness goal.
- **Realtime vendor independence — major.** Prefer delivery that does not depend on a provider-specific subscription and publication model.
- **Recurring realtime-service fees — major.** Avoid a separate realtime-service bill. This does not establish a total-cost advantage: self-hosting still incurs infrastructure and engineering costs.
- **Operational burden — moderate.** Simpler connection capacity management, failure recovery, and deployment are valuable, but do not outweigh the preferences above. The tenet explicitly accepts this tradeoff.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request revisions after their last applied revision. Delivery remains stateless request/response; the store supports cursor queries and browsers own a polling loop. This uses familiar HTTPS infrastructure and avoids long-lived connection management, at the cost of repeated reads even when a board has not changed.

- **Latency: partial fit.** A committed change may wait several seconds for the next poll.
- **Vendor independence: strong fit.** No realtime provider is required.
- **Realtime-service fees: strong fit.** No separate realtime-service subscription is required, though repeated reads consume infrastructure resources.
- **Operational burden: strong fit.** Stateless requests simplify operation; polling failures still require visible connectivity state and recovery.

### Self-hosted WebSockets

MarketBoard operates persistent browser connections and pushes committed revisions through them. Durable revisions support catch-up, and reliable publication connects committed storage to delivery. Browsers manage reconnect and recovery rather than treating an open socket as proof of a complete board.

- **Latency: strong fit.** Committed changes can be pushed without waiting for a polling interval.
- **Vendor independence: strong fit.** Delivery uses a standard protocol under MarketBoard's control.
- **Realtime-service fees: strong fit.** No separate realtime-service subscription is required; hosting and engineering costs remain.
- **Operational burden: weak fit.** MarketBoard owns connection capacity, session failures, reliable publication, and reconnect/catch-up behavior.

### Hosted realtime service

A provider operates persistent subscriptions and connection infrastructure. MarketBoard publishes committed changes through the provider and reconciles publication with authoritative storage. Browsers use the provider's subscription model. This offers a quick route to low-latency delivery with less connection operations work.

- **Latency: strong fit.** Provider subscriptions support prompt updates.
- **Vendor independence: weak fit.** Publication and browser subscriptions depend on a provider's APIs and service behavior.
- **Realtime-service fees: weak fit.** Recurring service fees are part of the approach; no provider-specific estimate is established.
- **Operational burden: partial fit.** Connection operations are delegated, but publication reconciliation, credentials, and provider integration remain MarketBoard responsibilities.

## Selection

Use **self-hosted WebSockets** for committed board changes. This follows the HLD's low-latency/vendor-independence tenet: polling offers simpler operation but slower updates, while hosted delivery reduces connection work through recurring fees and provider coupling. The selected approach combines prompt delivery and realtime vendor independence by accepting the operational work directly.

The choice does not tighten the 15-second freshness goal into a subsecond guarantee or establish that self-hosting is cheapest overall. Its principal risk is whether the team can operate connections and recovery reliably within the availability goal. Evidence that this burden is unsustainable would justify revisiting the decision.

The downstream obligations are:

- **Change store:** replayable authoritative event revisions and reliable publication of committed changes.
- **Delivery:** WebSocket sessions, connection capacity, and delivery of committed revisions to subscribed browsers.
- **Browser sync:** revision application, visible connectivity state, and reconnect/catch-up from the last applied revision.

Editors continue to submit authorized commands over HTTPS. Detailed publication mechanisms, replay contracts, and recovery policies belong in the three nodes' designs; this decision does not select them.

---

`git diff --check` passed.

**Does this capture the tradeoff you want a new reader to understand, particularly the priority weights and the reason to revisit the choice?**