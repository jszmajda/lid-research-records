Created `docs/decisions/self-hosted-websockets.md` and linked it from the HLD’s Key Design Decisions. The HLD now also states the supporting tenet: for realtime delivery, prefer operational ownership over recurring vendor fees and provider coupling.

---

# Decision: Self-hosted WebSockets for change delivery

## Context

MarketBoard keeps one authoritative, revisioned board per event. Editors submit changes over HTTPS, and staff browsers need committed changes delivered promptly. The board must support 800 simultaneous browsers and opening-time bursts of 20 edits per second, show connected browsers committed changes within 15 seconds under normal connectivity, and recover the latest board after disconnections lasting up to 20 minutes.

Five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service can all meet the baseline freshness target. The decision therefore concerns the quality of updates and the operating model around that baseline, not whether the board can function. It determines the responsibilities of the change store, delivery service, and browser synchronization design.

## Decision Elements

### Baseline constraints

The options are assessed against the existing requirements for 800 simultaneous browsers, 20 edits per second during opening-time bursts, 15-second delivery under normal connectivity, and recovery after disconnections lasting up to 20 minutes. All three options have a credible design that meets these constraints, so they are background rather than gates that eliminate an option.

### Weighted criteria

- **Update responsiveness — major.** Prefer prompt delivery of committed revisions rather than merely satisfying the 15-second ceiling.
- **Operational ownership — major.** Prefer a manageable operational burden for connection capacity, reconnect handling, delivery infrastructure, and provider availability.
- **Cost and vendor independence — major.** Prefer avoiding recurring realtime-service fees and coupling the board's delivery behavior to an external provider.
- **Implementation and recovery complexity — moderate.** Prefer simple storage, delivery, and browser recovery mechanisms with fewer failure modes to design and test.

The cost-and-independence criterion follows the HLD tenet: for realtime delivery, prefer operational ownership over recurring vendor fees and provider coupling.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes over HTTPS using a cursor that identifies the last revision they received. Delivery remains request/response and does not require persistent server-side browser sessions. The change store supports cursor queries, and browsers run a polling loop.

#### Analysis

- **Update responsiveness — weak.** A committed change waits for the next polling request before delivery begins. The approach can meet the 15-second requirement but does not provide the promptness of push delivery.
- **Operational ownership — strong.** The service does not own persistent socket capacity or socket-session reconnect behavior. Repeated reads are the principal additional load.
- **Cost and vendor independence — strong.** Delivery requires no realtime provider, recurring provider fee, or provider-specific browser subscription model.
- **Implementation and recovery complexity — strong.** Cursor queries and a browser polling loop are comparatively simple, with no socket publication or reconnect protocol to build.

### Self-hosted WebSockets

MarketBoard operates its own WebSocket delivery service. The change store retains replayable event revisions and reliably hands committed changes to delivery. Delivery manages socket sessions and publishes revisions to connected browsers; browsers reconnect and catch up from replayable revisions after interruptions.

#### Analysis

- **Update responsiveness — strong.** Connected browsers receive published revisions without waiting for a polling interval.
- **Operational ownership — weak.** MarketBoard owns connection capacity, socket lifecycle, reconnect behavior, and the operational failure modes of persistent connections.
- **Cost and vendor independence — strong.** MarketBoard avoids recurring realtime-service fees and provider coupling while continuing to pay for and operate its own infrastructure.
- **Implementation and recovery complexity — weak.** The design needs replayable revisions, reliable publication, session management, and browser reconnect and catch-up behavior.

### Hosted realtime service

An external provider operates the realtime connection infrastructure. MarketBoard publishes committed changes to the provider, wraps provider integration in its delivery component, and uses the provider's subscription model in browsers. Publication reconciliation keeps the authoritative store and provider delivery state aligned.

#### Analysis

- **Update responsiveness — strong.** The provider can push committed changes to subscribed browsers without polling delays.
- **Operational ownership — partial.** The provider absorbs much of the connection-capacity and reconnect burden, but MarketBoard still owns integration health, publication reconciliation, provider credentials, and responses to provider failures.
- **Cost and vendor independence — weak.** The service introduces recurring fees and couples delivery and browser behavior to provider interfaces and operating characteristics.
- **Implementation and recovery complexity — partial.** Provider subscriptions offer a quick route to low-latency delivery, but the provider wrapper, publication reconciliation, and recovery behavior remain MarketBoard responsibilities.

## Selection

Choose self-hosted WebSockets. They combine strong update responsiveness with strong cost and vendor independence. HTTPS polling also avoids a realtime vendor, but its polling delay makes it weaker on the major responsiveness criterion. A hosted service offers comparable responsiveness with less connection operations work, but its recurring fees and provider coupling conflict with the HLD's realtime-infrastructure tenet.

This selection deliberately accepts weak fits on operational ownership and implementation complexity. MarketBoard will own connection capacity and reconnect operations rather than purchase that work through a realtime vendor or avoid it through slower polling.

The choice forecloses a polling-only, stateless delivery design and rules out a hosted realtime provider for board updates. It obligates the change store to provide replayable revisions and reliable publication, delivery to manage WebSocket sessions and publish committed revisions, and browser synchronization to reconnect and catch up after interrupted connections.

---

Please review the decision document. Once approved, I’ll begin the change-store LLD and stop there for review before moving to delivery and browser sync.