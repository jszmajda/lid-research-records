Updated HLD to make the delivery trade-off explicit for a new reader.

**Approach**
Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered via self-hosted WebSockets, accepting ownership of connection capacity and reconnect handling to avoid realtime vendor fees and polling lag.

The store needs cursor queries for catch-up and replayable revisions; delivery manages sessions and reliable publication; browsers implement reconnect and catch-up logic.

**Key Design Decisions – Delivery via self-hosted WebSockets**
Chosen over five-second HTTPS polling and hosted realtime service.

* Five-second HTTPS polling is the simplest stateless operation, but adds repeated reads and a few seconds of lag; store needs cursor queries, delivery stays request/response, browsers run a polling loop.
* Hosted realtime service gives the quickest route to low-latency updates with less connection ops, but introduces recurring fees and provider coupling; store needs publication reconciliation, delivery wraps the provider, browsers use its subscription model.
* Self-hosted WebSockets give fast updates without a realtime vendor bill, accepting extra connection capacity and reconnect problem ownership. Store needs replayable revisions and cursor queries for catch-up, delivery manages sessions and reliable publication, browsers need reconnect/catch-up logic.

Trade-off accepted to avoid vendor coupling and achieve sub-15s freshness with low operational cost.

The HLD now reads context-free with the three options, downstream consequences, and the reason the trade-off was accepted.

STOP for review. Confirm this rationale is sufficient and I can proceed to Phase 2 — LLD check/draft for change-store, delivery, and browser-sync?