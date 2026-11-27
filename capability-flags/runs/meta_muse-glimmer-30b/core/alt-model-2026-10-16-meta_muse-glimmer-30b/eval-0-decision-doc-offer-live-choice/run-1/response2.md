Updated the HLD to make the tradeoff explicit and readable for a new reader.

**Approach** now states the choice and the trade:
> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Delivery of committed changes uses self-hosted WebSockets.
>
> Self-hosted WebSockets provide fast updates without a realtime vendor dependency. The change store must keep replayable revisions and a reliable publication outbox. Delivery owns WebSocket sessions, connection capacity, and reconnect handling. Browsers implement reconnect and catch-up to recover the latest board after disconnection.
>
> This trades extra connection and reconnect operational work for lower latency and avoidance of recurring vendor fees and provider coupling. Five-second HTTPS polling was rejected because it adds repeated reads and a few seconds of lag. A hosted realtime service was rejected because it would introduce recurring fees and provider coupling.

**Key Design Decisions — Delivery via self-hosted WebSockets** now includes:
- *Rationale.* WebSockets give sub-second update latency without recurring vendor fees or provider coupling. The team accepts the operational cost of managing connection capacity and reconnect logic to retain that latency and independence.
- *Alternatives considered.*
  - Five-second HTTPS polling: simplest stateless operation; store needs cursor queries; delivery stays request/response; browsers run a polling loop. Rejected for repeated reads and a few seconds of lag.
  - Hosted realtime service: quickest route to low-latency updates with less connection ops; store needs publication reconciliation; delivery wraps the provider; browsers use its subscription model. Rejected for recurring fees and provider coupling.
- *Consequences.* The change store must provide replayable revisions and reliable publication. Delivery must manage sessions, reliable publication from store to sockets, and reconnect handling. Browsers must implement reconnect and catch-up logic.

`docs/high-level-design.md` is updated accordingly. Confirm this wording is acceptable and I will proceed to Phase 2 — LLD check/draft for change-store, delivery, and browser-sync.