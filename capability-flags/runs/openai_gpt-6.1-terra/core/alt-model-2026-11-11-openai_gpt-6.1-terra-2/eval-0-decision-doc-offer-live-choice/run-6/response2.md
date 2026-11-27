I added `docs/decisions/change-delivery.md` and linked it from the HLD. The decision document reads:

# Decision: Delivery of committed board changes

## Context

MarketBoard keeps an authoritative board per event. Editors submit commands over HTTPS, and each committed edit receives an event revision. Connected staff browsers need to see changes within 15 seconds under normal connectivity and recover the latest board after disconnections of up to 20 minutes. The pilot must support 800 simultaneous browsers and bursts of 20 edits per second, retain revisions for seven days, and achieve 99.5 percent availability during published event hours.

The delivery approach affects how the change store exposes revisions, how the service delivers updates, and how browsers recover after interruptions. It also determines whether the team operates persistent connections or depends on a realtime provider.

## Decision Elements

- **Update latency — major.** Faster visibility is valuable even though all three options can meet the 15-second freshness goal under normal connectivity.
- **Realtime provider dependence and fees — major.** Avoiding a realtime vendor's recurring fees and coupling is valuable.
- **Operational burden — moderate.** Connection capacity, failure handling, and recovery require engineering and operational attention; reducing that burden is valuable.
- **Repeated read traffic — moderate.** Frequent checks by connected browsers consume store and service capacity even when nothing changes.

The authoritative revision, recovery, scale, retention, and availability goals apply to every option. Each would need its own design and verification to satisfy them.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes after their last known revision. The change store supports cursor queries; delivery remains request/response; browsers run a polling loop and catch up using the returned revisions.

- **Update latency: partial fit.** The polling interval adds up to roughly five seconds of waiting before a browser requests a newly committed change, plus request and processing time.
- **Realtime provider dependence and fees: strong fit.** It uses the application's HTTPS service without a realtime provider.
- **Operational burden: strong fit.** Request/response delivery avoids operating persistent WebSocket sessions, though polling and recovery still require implementation.
- **Repeated read traffic: weak fit.** Every connected browser makes regular requests, including when the board is unchanged.

### Self-hosted WebSockets

The application operates persistent WebSocket connections and pushes committed changes to browsers. The store provides replayable revisions and reliable publication; delivery manages sessions and capacity; browsers reconnect and catch up from authoritative revisions when a connection is interrupted.

- **Update latency: strong fit.** Connected browsers can receive changes without waiting for a polling interval.
- **Realtime provider dependence and fees: strong fit.** The application operates the delivery service without a realtime provider or its recurring service fees.
- **Operational burden: weak fit.** The team owns connection capacity, session failures, reliable publication, and reconnect recovery.
- **Repeated read traffic: strong fit.** Connected browsers do not need periodic change queries to discover ordinary updates; recovery still needs access to revisions.

### Hosted realtime service

A realtime provider manages browser subscriptions and connection delivery. The application wraps the provider in its delivery component, and the store supports publication reconciliation so committed revisions can be recovered when publication fails. Browsers use the provider's subscription model and recovery capabilities.

- **Update latency: strong fit.** Subscriptions can deliver changes without a polling interval.
- **Realtime provider dependence and fees: weak fit.** Delivery depends on the provider's service, subscription model, and recurring fees.
- **Operational burden: strong fit.** The provider handles connection operations, although the application still owns publication reconciliation and browser recovery behavior.
- **Repeated read traffic: strong fit.** Subscriptions avoid periodic change queries for ordinary updates; reconciliation and recovery still require access to revisions.

## Selection

Use self-hosted WebSockets. They favor fast updates and avoid a realtime vendor's fees and coupling. The team accepts the extra work of operating persistent connections and handling reconnection in exchange. Polling would reduce connection operations but adds repeated reads and seconds of lag; hosted delivery would reduce connection operations but introduces provider dependence and recurring fees.

This choice preserves the HLD's authoritative-revision and visible-connectivity-failure principles. It commits the change store, delivery, and browser sync designs to work together on replayable revisions, reliable publication, session management, reconnection, and catch-up. Their detailed protocols and failure handling remain to be designed and verified against the project's goals.

---

Do you approve this record and the updated HLD? In particular, are the proposed criterion weights right, and should the comparison give more weight to a critic’s concern such as total operating cost or the team’s ability to maintain availability?