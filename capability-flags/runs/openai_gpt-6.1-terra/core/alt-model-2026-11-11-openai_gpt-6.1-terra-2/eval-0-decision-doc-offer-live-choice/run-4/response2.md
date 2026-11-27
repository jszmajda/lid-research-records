I added `docs/decisions/board-change-delivery.md` and linked it from the HLD. Here is the decision for review:

---

# Decision: Board Change Delivery

## Context

MarketBoard has one authoritative board per event. Editors submit commands over HTTPS, and browsers need to see committed changes while events are running. The pilot targets up to 800 simultaneous browsers, bursts of 20 edits per second, and recovery after a browser disconnects for up to 20 minutes. Event revisions are retained for seven days.

All three delivery approaches can meet the goal of showing changes within 15 seconds under normal connectivity. Faster updates are useful, but subsecond delivery is not required. The choice affects the change store, delivery service, and browser sync design.

## Decision Elements

- **Update latency — major.** Favor shorter delays between a committed edit and its appearance in connected browsers, even though the 15-second goal permits slower delivery.
- **Realtime provider independence — major.** Favor an approach that does not tie board delivery to a hosted realtime provider.
- **Operational burden — moderate.** Account for the capacity, reliability, and recovery work the team must operate.
- **Recurring provider fees — moderate.** Account for a hosted realtime service's recurring fees. Self-hosting also has infrastructure and staffing costs; no total-cost comparison has been established.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes since a cursor over HTTPS. The server responds using queries against the change store. Delivery remains request/response, and browsers run a polling loop.

- **Update latency: partial.** Changes may wait several seconds for the next poll, plus request and processing time.
- **Realtime provider independence: strong.** Delivery uses the application's own HTTPS service rather than a hosted realtime provider.
- **Operational burden: strong.** Stateless request handling is simpler to operate than persistent connections, though repeated reads and cursor queries need capacity.
- **Recurring provider fees: strong.** There is no hosted realtime service fee; application infrastructure and read costs remain.

### Self-hosted WebSockets

The application operates persistent WebSocket connections to deliver committed changes to browsers. The change store provides replayable revisions and reliable publication; delivery manages sessions and connection capacity; browsers reconnect and catch up after interruptions.

- **Update latency: strong.** Connected browsers can receive changes promptly without waiting for a polling interval.
- **Realtime provider independence: strong.** The application owns the delivery service and its connections.
- **Operational burden: weak.** The team owns connection capacity, session reliability, publication, reconnect, and recovery work.
- **Recurring provider fees: strong.** There is no hosted realtime service fee; infrastructure and operational costs remain.

### Hosted realtime service

A provider manages realtime connections and delivers published changes to browser subscriptions. Application delivery wraps the provider, while the change store and publication path reconcile committed changes with provider delivery.

- **Update latency: strong.** Provider subscriptions can deliver changes promptly without a polling interval.
- **Realtime provider independence: weak.** Delivery and browser subscriptions depend on the provider's service and interfaces.
- **Operational burden: partial.** The provider manages connection infrastructure, but the application still owns publication reconciliation and recovery behavior.
- **Recurring provider fees: weak.** The provider introduces recurring service fees in addition to application costs.

## Selection

Use self-hosted WebSockets. Fast updates and independence from a realtime provider outweigh the additional connection and reconnect operations. Polling would be simpler to operate but adds repeated reads and several seconds of lag; hosted realtime would reduce connection operations but adds provider coupling and recurring fees.

The HLD permits both self-hosted and managed infrastructure; this selection applies the preference for fast, provider-independent board delivery rather than a general prohibition on managed services. It commits the three downstream nodes to designing replayable revisions and reliable publication, WebSocket session management, and browser reconnect and catch-up together. Specific mechanisms and failure handling belong in those node designs.

---

**Does this capture the tradeoff and the proposed criterion priorities accurately, and do you approve the revised HLD?** Also, should either lower latency over simpler operations or provider independence over reduced operational burden become a broader project tenet?

The access design still says delivery is undecided. May I correct that stale sentence when cascading?