Created `docs/decisions/self-hosted-websockets.md` and linked it from `docs/high-level-design.md`. I treated your reply as acceptance of the WebSockets tradeoff and a request to record its rationale. The decision record is:

# Decision: Self-Hosted WebSockets for Live Updates

## Context

MarketBoard serves a revisioned board to staff browsers during weekend markets. Editors submit changes through HTTPS commands, and the server assigns a revision to each committed edit. Connected browsers need to learn about new revisions; browsers that disconnect also need to recover the changes they missed.

The project targets delivery of committed changes to connected browsers within 15 seconds under normal connectivity and recovery after disconnects of up to 20 minutes. Five-second polling, self-hosted WebSockets, and a hosted realtime service can meet the freshness target. Lower latency is desirable, but it is not a separate numeric service-level target.

The delivery choice shapes storage, publication, and browser recovery. Polling favors cursor-based reads. WebSockets require connection and publication management plus reconnect and catch-up behavior. A hosted service reduces connection operations but introduces provider dependence and recurring fees.

## Decision Elements

- **Major — Low-latency updates for connected browsers.** The board should reflect committed changes promptly rather than waiting for a periodic poll.
- **Major — Avoid realtime-vendor dependence and recurring service fees.** Live delivery should not depend on a dedicated provider's subscription model or pricing.
- **Moderate — Limit connection and recovery operations.** The delivery path should avoid unnecessary operational burden, though this consideration may be traded for the two higher-priority criteria.

These criteria express the priorities for this delivery decision; no existing project tenet selects a delivery option.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request revisions newer than their last observed revision. The store serves the request from a cursor query, and each response completes the delivery interaction without maintaining a server-side browser session.

- **Low-latency updates — partial.** A committed change may wait nearly one polling interval before a connected browser requests it.
- **Avoid realtime-vendor dependence and recurring service fees — strong.** Delivery uses the application's HTTPS interface and does not require a hosted realtime provider.
- **Limit connection and recovery operations — strong.** The service does not manage persistent browser connections; browsers can resume by requesting revisions after their last observed cursor. The tradeoff is repeated read traffic from polling.

Summary: stateless and operationally simple, with repeated reads and polling-interval lag.

### Self-hosted WebSockets

The application maintains WebSocket sessions with connected browsers and sends committed revisions over those sessions. The change store retains revisions for replay and supports reliable publication. Delivery manages connection sessions, and browsers reconnect and catch up from their last observed revision after interruptions.

- **Low-latency updates — strong.** Revisions can be sent to connected browsers as they are published rather than waiting for a polling interval.
- **Avoid realtime-vendor dependence and recurring service fees — strong.** The application owns the realtime delivery path instead of relying on a dedicated hosted realtime provider.
- **Limit connection and recovery operations — weak.** The application must manage connection capacity and reliable publication, while browser behavior must cover reconnect and catch-up.

Summary: low-latency delivery without a realtime vendor, at the cost of owning connection and recovery operations.

### Hosted realtime service

The application publishes committed revisions to a realtime provider, which manages browser subscriptions and persistent delivery connections. The application must reconcile committed revisions with publication, and the browser follows the provider's subscription and recovery model.

- **Low-latency updates — strong.** The provider delivers changes through its realtime subscription mechanism.
- **Avoid realtime-vendor dependence and recurring service fees — weak.** The design relies on provider APIs, credentials, and pricing.
- **Limit connection and recovery operations — strong.** The provider manages connection infrastructure, reducing the application's direct session and reconnect work; publication reconciliation and provider integration remain application responsibilities.

Summary: low-latency delivery with less connection infrastructure to operate, in exchange for recurring fees and provider coupling.

## Selection

Choose self-hosted WebSockets. This provides the desired low-latency updates while avoiding a dedicated realtime vendor and its recurring fees. The project accepts the additional operational work because connection-capacity management and reconnect recovery are preferable to introducing provider dependence for this capability. The choice is local to live-update delivery; it does not prohibit managed infrastructure for other parts of the system.

The decision requires the change store to retain replayable event revisions and support reliable publication of committed changes. The delivery component owns WebSocket session management and delivery to connected browsers. Browser sync owns reconnect and catch-up from the last observed revision. These responsibilities must preserve the existing 15-second freshness goal and 20-minute disconnect-recovery goal; implementation details and guarantees belong in the respective design nodes.

The HLD now links to this decision record. I also found that `docs/intent/access/access-design.md` still calls the delivery approach “still-open.” Its access boundary remains valid, but that wording is stale. I left it unchanged because updating it crosses into the ACCESS segment.

Please review the decision record and confirm it captures the rationale. Also, should I update that sentence in the Access design during the cascade?