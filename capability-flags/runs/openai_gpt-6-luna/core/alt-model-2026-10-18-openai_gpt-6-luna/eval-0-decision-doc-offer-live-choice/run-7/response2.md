Created `docs/decisions/self-hosted-websocket-delivery.md` and linked it from the HLD’s Key Design Decisions section. It compares all three options, explains the criteria and accepted operational tradeoff, and records the downstream responsibilities for the change store, delivery service, and browser sync. `git diff --check` passed.

## Decision: Self-Hosted WebSocket Delivery

```markdown
---
node: high-level-design
---

# Decision: Self-Hosted WebSocket Delivery

## Context

MarketBoard has one authoritative board per event. Editors submit commands over HTTPS, and the server assigns revisions to committed changes. Staff browsers need to see those changes while an event is running, including after temporary connectivity interruptions. The project targets 800 simultaneous browsers and recovery after disconnections of up to 20 minutes.

The delivery mechanism affects update latency, repeated reads, recurring service fees, and who owns connection and recovery behavior. The board needs updates faster than a five-second polling interval while avoiding dependence on a hosted realtime provider. This decision selects the delivery model; the change-store, delivery, and browser-sync designs define its detailed contracts and implementation.

## Decision Elements

- **Fast delivery of committed changes — major.** All three approaches can meet the 15-second freshness goal, but a push model can make committed changes visible sooner than five-second polling.
- **Avoid dependence on a hosted realtime provider — major.** The delivery path should not require a provider's service, credentials, or subscription model.
- **Limit recurring realtime-service fees — moderate.** A dedicated hosted realtime service adds an ongoing provider cost; self-hosting avoids that fee but still consumes application infrastructure.
- **Limit connection and recovery operations owned by MarketBoard — moderate.** Persistent connections require capacity management, publication reliability, reconnection, and catch-up behavior; polling avoids most of this session-management work.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically issue HTTPS requests asking for revisions newer than their last-seen cursor. The server responds with changes or an unchanged result, and each browser repeats the request on a timer. The store needs cursor queries, while clients need a polling loop. This keeps delivery request/response and avoids persistent client sessions.

- **Fast delivery — weak.** A change can wait for the next five-second poll before a connected browser sees it.
- **Provider independence — strong.** Delivery uses MarketBoard's HTTPS API without a hosted realtime provider.
- **Recurring realtime-service fees — strong.** No dedicated realtime service is required, though repeated reads use application resources.
- **MarketBoard-owned connection and recovery operations — strong.** There are no persistent browser sessions to manage; browsers resume by querying from their cursor.

### Self-hosted WebSockets

MarketBoard's delivery service maintains browser WebSocket sessions and publishes committed revisions over those connections. The change store retains replayable revisions and supports reliable publication. Browsers reconnect after interruptions and catch up from their last received revision. MarketBoard owns connection capacity, session lifecycle, publication reliability, and the client recovery path.

- **Fast delivery — strong.** The service can push committed changes to connected browsers without waiting for a polling interval.
- **Provider independence — strong.** The board's delivery behavior is implemented and operated as part of MarketBoard rather than delegated to a realtime provider.
- **Recurring realtime-service fees — strong.** No dedicated realtime provider is required, although persistent connections have infrastructure and operational costs.
- **MarketBoard-owned connection and recovery operations — weak.** The project must handle session capacity, publication, reconnect behavior, and revision catch-up.

### Hosted realtime service

MarketBoard reconciles committed revisions with a hosted realtime provider, and its delivery layer wraps the provider's publication and subscription model. The provider manages much of the connection infrastructure, while the application must integrate provider credentials and reconcile publication with the authoritative change store.

- **Fast delivery — strong.** A realtime provider can distribute changes with low latency.
- **Provider independence — weak.** Delivery depends on the provider's service, credentials, and subscription model.
- **Recurring realtime-service fees — weak.** The provider charges recurring fees for realtime delivery.
- **MarketBoard-owned connection and recovery operations — strong.** The provider manages connection sessions, reducing the connection-capacity and reconnect machinery operated by MarketBoard.

## Selection

Choose self-hosted WebSockets. Fast updates and independence from a hosted realtime provider are major criteria; self-hosted WebSockets satisfy both. They also avoid a dedicated realtime-service fee. This is worth the additional connection-capacity, publication-reliability, reconnect, and catch-up work owned by MarketBoard. Five-second polling would be simpler to operate, but its repeated reads and update delay are a worse fit for fast status visibility. A hosted realtime service would provide fast delivery with less connection work, but its recurring fees and provider coupling conflict with the selected direction.

This choice puts the authoritative-revision tenet into the delivery path: WebSockets distribute server-assigned revisions rather than making browser state authoritative. It also requires the visible-connectivity-failure tenet to be reflected in browser recovery behavior. The change store must support revision replay and reliable publication; delivery owns WebSocket sessions; browsers reconnect and catch up from their last received revision. The choice does not prescribe the detailed publication guarantee, session-capacity strategy, or catch-up protocol; those belong in the respective component designs.
```

Please review this decision record. Once you approve it, we can proceed to the three component nodes.