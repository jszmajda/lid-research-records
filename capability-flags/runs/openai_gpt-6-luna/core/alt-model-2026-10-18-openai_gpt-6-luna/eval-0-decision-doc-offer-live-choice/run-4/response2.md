Created `docs/decisions/self-hosted-websocket-delivery.md` and linked it from the HLD’s Key Design Decisions. I weighted fast updates and avoiding realtime-provider dependency as major criteria, with recurring fees and operational burden as moderate criteria.

```markdown
---
node: high-level-design
---

# Decision: Self-Hosted WebSocket Delivery

## Context

MarketBoard serves revisioned event boards to as many as 800 simultaneous staff browsers. Editors submit commands over HTTPS, and committed changes need to reach connected browsers promptly. The system must also recover the latest board after a browser has been disconnected for up to 20 minutes and retain event revisions for seven days.

The delivery mechanism affects the change store, delivery service, and browser sync component. Polling calls for cursor-based reads and a browser polling loop. WebSockets call for replayable revisions and reliable publication, session management, and client reconnect and catch-up. A hosted realtime service adds a provider-specific publication and subscription path.

The choice balances update latency, recurring service cost and provider dependency, and the operational work of running delivery connections. The HLD's 15-second freshness goal applies to all options; the preference for faster updates favors event-driven delivery but does not establish a tighter numeric latency target.

## Decision Elements

- **Low-latency updates — major.** Connected browsers should receive committed changes without waiting for a periodic polling interval.
- **Avoid recurring realtime-service fees — moderate.** The delivery mechanism should avoid a recurring vendor charge dedicated to realtime updates.
- **Avoid realtime-provider dependency — major.** Board delivery should not depend on a vendor's connection, publication, or subscription model.
- **Limit self-operated connection and recovery work — moderate.** The design should avoid unnecessary responsibility for connection capacity, session lifecycle, replay, and reconnect behavior.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes over HTTPS, using a cursor to ask for revisions newer than the last one applied. The service remains request/response and holds no browser delivery sessions.

- **Low-latency updates — partial.** A change may wait for the next five-second poll before a browser sees it.
- **Avoid recurring realtime-service fees — strong.** Delivery uses the existing HTTPS service rather than a realtime vendor.
- **Avoid realtime-provider dependency — strong.** The client and service use the board's own HTTPS API and cursor contract.
- **Limit self-operated connection and recovery work — strong.** The service does not manage persistent browser sessions, though it must serve repeated reads and the browser must continue polling and resume from its cursor.

### Self-hosted WebSockets

The application operates WebSocket connections to browsers and publishes committed event revisions over those connections. The change store retains replayable revisions and supports reliable publication; delivery manages sessions; browsers reconnect and catch up from their last applied revision.

- **Low-latency updates — strong.** The server can deliver a committed change as it is published instead of waiting for a polling interval.
- **Avoid recurring realtime-service fees — strong.** The application operates delivery without a hosted realtime-service subscription.
- **Avoid realtime-provider dependency — strong.** Connection management, publication, and subscription behavior remain within the application rather than a vendor contract.
- **Limit self-operated connection and recovery work — weak.** The team operates connection capacity, session lifecycle, reliable publication, replay, and client reconnect and catch-up behavior.

### Hosted realtime service

The application reconciles committed revisions with a hosted realtime provider, which maintains browser subscriptions and delivers updates through its client model.

- **Low-latency updates — strong.** The provider delivers published changes without waiting for a polling interval.
- **Avoid recurring realtime-service fees — weak.** Realtime delivery incurs a recurring provider charge.
- **Avoid realtime-provider dependency — weak.** Publication, connection, or subscription behavior depends on the provider's service and client model.
- **Limit self-operated connection and recovery work — strong.** The provider operates the browser connection fleet, reducing the application's direct session and reconnect operations.

## Selection

Use self-hosted WebSockets for committed-change delivery. It meets the major priorities of fast updates and avoiding dependence on a realtime vendor, while avoiding a recurring realtime-service fee. Five-second polling avoids vendor dependency and minimizes connection management but introduces a polling delay; the hosted service offers low latency with less connection operations work but incurs fees and provider coupling. The project accepts the additional operational work of self-hosted connections and recovery in exchange for fast, vendor-independent delivery.

This choice preserves the HLD tenet that each committed edit has one authoritative event revision. It commits the change store, delivery service, and browser sync component to replayable revision publication, WebSocket session management, and reconnect and catch-up behavior, respectively. No numeric update-latency target tighter than the HLD's 15-second goal is set by this decision.
```

`git diff --check` passes. Please review the decision record and updated HLD link. Do you approve them as written? Once approved, I’ll proceed to the three design nodes.