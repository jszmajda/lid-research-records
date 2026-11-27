The HLD now carries the self-hosted WebSockets approach, updated in place:

- **Approach** — committed changes push over WebSockets from the board's own infrastructure: store records replayable revisions, delivery publishes to connected sessions, browsers replay newer revisions on reconnect. The trade you accepted (owning connection capacity, sessions, reconnect/catch-up) is stated as the cost; no vendor dependency.
- **Architecture** — the three unwritten nodes now have fixed scopes: change store owns replayable revision history and reliable publication; delivery owns WebSocket session management and publication; browser sync owns subscription/reconnect/catch-up over the socket.
- **Key Design Decisions** — added "Self-hosted WebSockets for change delivery," naming polling and hosted realtime as rejected alternatives with their tradeoffs (lag/repeated reads; recurring fees and provider coupling).

Three things need your ruling before I go on:

1. **Phase 1 review.** Please check the updated HLD above — especially the Approach paragraph and the node scopes, since the three designs will be sized around them.
2. **Decision doc?** This choice stays live for a cold reader — three credible options weighed on latency, ops burden, cost, and coupling, with three nodes about to be sized around it. Want me to record it as a full decision doc at `docs/decisions/` (re-runnable if circumstances change, e.g. connection capacity ever becomes a problem), or is the Key Design Decisions entry enough?
3. **Adjacent-segment cascade.** `docs/intent/access/access-design.md:10` still says authorization is independent of "the still-open change-delivery approach" — now stale. It's a one-line fix inside the access segment; may I make it, or leave it for when we touch access next?

On your approval (and answers above), we'll proceed to the three nodes — change store, delivery, and browser sync — one at a time.