Added `docs/decisions/self-hosted-websockets.md` and linked it from the HLD’s Key Design Decisions. The decision record is self-contained so a new reader can reconstruct the trade-off:

```markdown
---
node: high-level-design
---

# Decision: Self-hosted WebSockets for Board Updates

## Context

MarketBoard keeps one authoritative, revisioned board per event. Editors submit changes over HTTPS, and staff browsers need committed changes within 15 seconds under normal connectivity. The service must support 800 simultaneous browsers, opening-time bursts of 20 edits per second, and recovery after disconnections lasting up to 20 minutes.

The delivery mechanism determines more than network latency. It shapes the change store's read and publication model, the delivery component's operating responsibilities, and the browser's recovery behavior. The choice therefore trades update responsiveness and read efficiency against service cost, provider independence, and operational complexity.

## Decision Elements

- **Update responsiveness and read efficiency — major.** Prefer prompt delivery without repeatedly reading unchanged board state. The 15-second freshness goal is a minimum; faster updates remain valuable.
- **Avoiding realtime-service fees and provider coupling — major.** Prefer a delivery mechanism that does not add a recurring realtime vendor bill or make board recovery depend on a provider's subscription model.
- **Operational and implementation simplicity — moderate.** Prefer fewer stateful connections, recovery mechanisms, and moving parts, but accept additional work when it buys substantially better responsiveness and independence.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes after their last received revision. The change store provides cursor queries, delivery remains request/response, and each browser runs a polling loop.

#### Analysis

- **Update responsiveness and read efficiency: weak.** Polling meets the 15-second freshness goal but introduces several seconds of lag and repeatedly reads for changes even when the board is unchanged.
- **Avoiding realtime-service fees and provider coupling: strong.** HTTPS polling uses the existing command transport style and requires no realtime provider or provider-specific credentials.
- **Operational and implementation simplicity: strong.** Stateless requests avoid socket capacity management, persistent sessions, and socket-specific reconnect handling. Cursor-based catch-up is still required.

### Self-hosted WebSockets

The service operates persistent WebSocket connections and pushes committed event revisions to subscribed browsers. The change store provides replayable revisions and reliable publication; delivery manages sessions and connection capacity; browsers reconnect and catch up from their last received revision.

#### Analysis

- **Update responsiveness and read efficiency: strong.** Committed changes can be pushed as soon as they are published, without waiting for a polling interval or repeatedly querying unchanged boards.
- **Avoiding realtime-service fees and provider coupling: strong.** The service uses infrastructure it operates itself, with no recurring realtime-service fee or dependency on a vendor's subscription protocol.
- **Operational and implementation simplicity: weak.** The team owns connection capacity, socket lifecycle, reconnect behavior, reliable publication, and replay-based recovery. These responsibilities span all three delivery-related components.

### Hosted realtime service

A realtime provider carries subscriptions and pushes committed changes to browsers. The change store reconciles publication with the provider, delivery wraps the provider API, and browsers use the provider's subscription and recovery model.

#### Analysis

- **Update responsiveness and read efficiency: strong.** Provider-managed subscriptions deliver changes promptly without board polling.
- **Avoiding realtime-service fees and provider coupling: weak.** The service incurs recurring fees and depends on provider credentials, APIs, subscription semantics, and availability.
- **Operational and implementation simplicity: partial.** The provider absorbs much of the connection-capacity and reconnect burden, but publication reconciliation, provider integration, and vendor-specific browser behavior remain.

## Selection

Use self-hosted WebSockets. They provide the strongest fit for both major criteria: prompt, read-efficient updates without recurring realtime-service fees or provider coupling. Their additional connection and reconnect work is an accepted cost rather than an overlooked one.

This selection applies the tenet to prefer self-hosted realtime delivery over provider coupling when its connection operations are affordable. Polling remains the simplest transport but gives up responsiveness and read efficiency; hosted delivery removes substantial connection operations but gives up provider independence and adds recurring fees.

The change-store, delivery, and browser-sync designs must jointly preserve the recovery guarantee: revisions must be replayable, publication must be reliable, socket sessions must be operated within capacity, and browsers must reconnect and catch up without treating a connectivity failure as an unchanged board. The detailed publication, session, and recovery protocols belong to those three component designs.
```

Please review this decision record. Once approved, I can begin the three node designs with the change-store LLD.