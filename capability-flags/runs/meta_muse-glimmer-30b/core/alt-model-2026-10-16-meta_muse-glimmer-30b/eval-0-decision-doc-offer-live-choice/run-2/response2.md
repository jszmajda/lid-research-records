Updated the approach write-up so a new reader can reconstruct the tradeoff.

**HLD** `docs/high-level-design.md`
- Approach now states delivery uses self-hosted WebSockets for fast updates without a realtime vendor, and that the change store provides replayable revisions and reliable publication; delivery owns WebSocket sessions, connection capacity and reconnect handling; browsers implement reconnect and catch-up. Freshness target remains 15 seconds.
- Architecture bullets updated for WebSocket delivery.
- Key Design Decisions now references the decision doc:
  > **Self-hosted WebSockets for delivery.** Chosen over five-second HTTPS polling and a hosted realtime service to avoid vendor coupling and recurring fees. See `docs/decisions/delivery-approach-websockets.md` for criteria, options, and tradeoffs. ...

**Decision doc** `docs/decisions/delivery-approach-websockets.md`
Created with node: high-level-design.

Context, Decision Elements, Options in the Domain, and Selection are written fresh:
- Gates: 15s freshness, 20-min recovery, authoritative revision.
- Major criteria: low latency/read amplification, operational independence from realtime vendors.
- Options analyzed with strong/partial/weak fit:
  * Five-second HTTPS polling — simplest stateless, more repeated reads and a few seconds of lag; store needs cursor queries.
  * Self-hosted WebSockets — fast updates without vendor bill; store needs replayable revisions and reliable publication; delivery manages sessions; browsers need reconnect/catch-up.
  * Hosted realtime service — quickest low-latency with less connection ops; needs publication reconciliation and provider coupling; recurring fees.
- Selection: Self-hosted WebSockets wins on latency/read amplification and operational independence; connection/reconnect burden is explicitly accepted to avoid vendor coupling. Implications for store, delivery, and browser sync are recorded.

Phase 1 HLD check is now complete with the decision properly documented.

Confirm the HLD and decision doc capture your intent, or provide numbered feedback. On approval I will proceed to Phase 2 LLD check/draft for the three nodes: change-store, delivery, and browser-sync.