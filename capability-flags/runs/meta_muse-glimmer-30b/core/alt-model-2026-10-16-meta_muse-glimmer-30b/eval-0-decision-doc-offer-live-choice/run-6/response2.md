Updated `docs/high-level-design.md` with a context-free write-up of the delivery tradeoff.

**Approach — alternatives now explicit**

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered to browsers over self-hosted WebSockets for fast updates without tying the board to a realtime vendor.

Delivery, change store, and browser recovery are designed together around WebSocket sessions. The store maintains replayable revisions and a publication outbox for catch-up. Delivery manages sessions, reliable publication, and connection capacity. Browsers implement reconnect and catch-up logic to recover after disconnections.

Alternatives considered:

Five-second HTTPS polling: simplest stateless operation, but more repeated reads and a few seconds of lag. The store needs cursor queries, delivery stays request/response, and browsers run a polling loop.

Hosted realtime service: quickest route to low-latency updates with less connection operations, but recurring fees and provider coupling. The store needs publication reconciliation, delivery wraps the provider, and browsers use its subscription model.

Self-hosted WebSockets were chosen to achieve fast updates without a realtime vendor bill. The tradeoff is owning connection capacity and reconnect problems: the store needs replayable revisions and reliable publication, delivery manages sessions, and browsers need reconnect/catch-up logic.

**Key Design Decisions — rationale made readable**

- **Self-hosted WebSockets for change delivery.** Browsers receive committed changes via persistent WebSocket connections to the MarketBoard service. The store provides replayable revisions and reliable publication, delivery manages sessions and connection capacity, and browsers implement reconnect and catch-up.

Rejected alternatives:
- Five-second HTTPS polling: simplest stateless operation, but more repeated reads and a few seconds of lag. Store needs cursor queries, delivery stays request/response, browsers run polling loop.
- Hosted realtime service: quickest route to low-latency updates with less connection operations, but recurring fees and provider coupling. Store needs publication reconciliation, delivery wraps provider, browsers use subscription model.

Self-hosted WebSockets were chosen to avoid vendor coupling and recurring fees while achieving fast updates, accepting ownership of connection capacity and reconnect problems.

File: `docs/high-level-design.md`

STOP — does this write-up make the tradeoff clear for a new reader? If approved, I’ll proceed to Phase 2 LLD check/draft for change-store, delivery, and browser-sync.