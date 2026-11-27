Created `docs/decisions/self-hosted-websockets.md`, linked it from the HLD’s Key Design Decisions, and removed the stale “still-open” wording from the Access design.

The decision record reads:

# Decision: Self-hosted WebSockets for Board Updates

## Context

MarketBoard keeps one authoritative, revisioned board per event. Editors submit changes over HTTPS, but staff browsers also need a way to learn about committed changes without repeatedly reloading the board. That delivery choice shapes three other components: the change store's read and revision model, the delivery service's connection responsibilities, and the browser's recovery behavior.

The board must support up to 800 simultaneous browsers and opening-time bursts of 20 edits per second. Committed changes must reach connected browsers within 15 seconds under normal connectivity, and a browser must recover the latest board after a disconnection lasting up to 20 minutes. Event revisions are retained for seven days. Subsecond updates would be useful during coordinated opening work, but are not required.

HTTPS polling, self-hosted WebSockets, and a hosted realtime service can all meet the stated freshness target. The decision therefore does not turn on basic feasibility. It turns on how much delivery latency and repeated reading MarketBoard is willing to accept, how much connection infrastructure it wants to operate, and whether recurring provider cost and coupling are acceptable. The result deliberately accepts operational work in exchange for prompt updates without a realtime vendor dependency.

## Decision Elements

All options must preserve one authoritative event-revision sequence, make connectivity failures visible, and meet the scale, recovery, retention, and availability goals in the High-Level Design. Those shared obligations are background rather than discriminators.

### Update freshness and read efficiency — major

Prefer delivering committed changes promptly without having every browser repeatedly ask whether anything changed. The 15-second target is a limit, not a reason to ignore the operational value of faster updates during busy periods.

### Operational burden and failure ownership — major

Weigh the work required to run the delivery path and meet 99.5 percent availability during event hours. This includes request or connection capacity, session lifecycle, reconnect behavior, publication reliability, monitoring, and recovery from failures.

### Recurring external service cost — major

Prefer avoiding a recurring realtime-service bill. This criterion concerns vendor fees specifically; it does not assume that self-hosting has no infrastructure or staffing cost.

### Provider independence — major

Prefer keeping the board's delivery protocol and availability from becoming coupled to a particular realtime provider's SDK, subscription model, credentials, and service behavior.

## Options in the Domain

### Five-Second HTTPS Polling

**Description.** Each browser asks for changes every five seconds. The change store supports cursor-based queries so a browser can request revisions after the last one it received. Delivery remains ordinary request/response HTTPS, with no persistent browser sessions on the server.

This is the simplest operational model. Existing HTTP deployment, scaling, and monitoring practices apply, and a failed request does not require restoring a persistent connection. Browser recovery can use the same cursor mechanism as normal polling.

**Analysis.**

- **Update freshness and read efficiency: partial.** Polling meets the 15-second requirement, but introduces several seconds of ordinary lag. Browsers also repeat reads while nothing has changed, with request volume rising alongside the number of connected browsers.
- **Operational burden and failure ownership: strong.** The server remains stateless with respect to browser delivery. There is no socket-capacity management, persistent-session lifecycle, or reconnect-storm handling.
- **Recurring external service cost: strong.** There is no realtime-vendor bill, although repeated queries still consume infrastructure capacity.
- **Provider independence: strong.** The delivery path uses MarketBoard's own HTTPS API and does not depend on a realtime provider's client or subscription model.

**Summary.** Polling minimizes delivery operations at the cost of repeated reads and slower updates.

### Self-Hosted WebSockets

**Description.** MarketBoard operates its own WebSocket endpoints and pushes committed revisions to connected browsers. The change store provides replayable revisions and reliable publication to the delivery service. Delivery manages socket capacity and sessions, while browsers reconnect and catch up from their last received revision.

This option keeps the delivery path under MarketBoard's control while providing prompt updates. It also makes MarketBoard responsible for the failure modes that a managed realtime provider would otherwise absorb.

**Analysis.**

- **Update freshness and read efficiency: strong.** Committed changes can be pushed as they are published rather than waiting for each browser's next poll, and idle browsers do not generate repeated change queries.
- **Operational burden and failure ownership: weak.** MarketBoard owns connection capacity, socket lifecycle, reliable publication, reconnect behavior, and the associated monitoring and failure recovery. Reconnecting browsers also need a dependable catch-up path.
- **Recurring external service cost: strong.** There is no realtime-provider subscription fee. MarketBoard still pays for and operates its own serving capacity.
- **Provider independence: strong.** The board uses MarketBoard-controlled endpoints and WebSocket protocols rather than a vendor-specific subscription service.

**Summary.** Self-hosted WebSockets provide fast, independent delivery in exchange for substantial connection and recovery operations.

### Hosted Realtime Service

**Description.** A hosted provider accepts and fans out realtime updates to browsers. MarketBoard's delivery component wraps the provider's publication API, and browsers use the provider's subscription model. The change store still needs publication reconciliation so a committed board change is not silently lost when provider publication fails or its outcome is uncertain.

The provider removes much of the persistent-connection capacity work, but MarketBoard remains responsible for correct publication, credentials, provider-aware failure handling, and browser recovery around the service.

**Analysis.**

- **Update freshness and read efficiency: strong.** The provider can push updates promptly without browser polling.
- **Operational burden and failure ownership: strong.** MarketBoard avoids most socket-capacity and connection-lifecycle operations, although it still owns publication reconciliation, credentials, integration monitoring, and provider-failure handling.
- **Recurring external service cost: weak.** Usage creates an ongoing vendor bill that can grow with connections or traffic.
- **Provider independence: weak.** Delivery and browser code depend on the provider's APIs, SDK or subscription semantics, credentials, limits, and availability.

**Summary.** Hosted realtime provides prompt updates with less connection-management work while adding recurring fees and provider coupling.

## Selection

MarketBoard uses **self-hosted WebSockets** for committed-change delivery.

This is the only option that combines prompt push delivery with both no recurring realtime-vendor fee and no realtime-provider coupling. Polling is operationally simpler and remains capable of meeting the formal freshness target, but its repeated reads and several-second lag give up benefits that matter during active coordination. A hosted service provides similar prompt delivery with less connection-management work, but its recurring fees and provider-specific integration are the trade MarketBoard chooses not to make.

The selection is not a claim that self-hosting minimizes total cost or staffing effort. It explicitly accepts ownership of connection capacity, reconnect problems, reliable publication, and catch-up behavior in exchange for delivery independence and fast updates. The choice turns on the HLD tenet that both self-hosted and managed infrastructure are permitted: managed delivery is allowed, but it is not preferred strongly enough here to outweigh vendor cost and coupling. The selected path must still uphold the tenets requiring one authoritative event revision and visible connectivity failures.

The decision creates the following downstream obligations:

- **Change store:** maintain replayable event revisions and provide reliable publication to delivery, while retaining revision history for seven days and supporting browser catch-up.
- **Delivery:** manage WebSocket sessions and capacity for the target browser population, publish committed revisions promptly, and operate the connection failure and recovery path within the event-hours availability goal.
- **Browser sync:** maintain the subscription, reconnect after interruption, catch up from the last received revision, and show connectivity loss rather than presenting a stale board as current.

HTTPS remains the command path. Specific socket protocols, publication mechanics, capacity limits, and reconnect policies belong to the three component designs rather than this project-level decision.

---

Please review the decision record. If it captures the trade-off accurately, approve it and I’ll move to the **Change Store** LLD.