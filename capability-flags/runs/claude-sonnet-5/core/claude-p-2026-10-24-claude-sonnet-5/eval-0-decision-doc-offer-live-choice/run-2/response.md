I've updated `docs/high-level-design.md` to resolve the Approach and Architecture sections around self-hosted WebSockets, and added a Key Design Decisions row:

**Approach** now reads: browsers hold a self-hosted WebSocket connection and receive published revisions directly; rationale given is fast updates without a realtime vendor fee, in exchange for owning connection capacity and reconnect handling.

**Architecture** bullets for the three not-yet-written nodes now name WebSocket-specific obligations: change store owns replayable revisions and reliable publication; delivery owns WebSocket session lifecycle (accept, authenticate, push); browser sync owns the client-side connection, reconnect, and catch-up logic.

**Key Design Decisions** gained a row: *"Self-hosted WebSockets for delivery"* — polling rejected for staleness/read load, hosted realtime rejected for recurring fees and vendor coupling.

Before we move on: this tradeoff (latency vs. ops burden vs. recurring cost, with the three downstream nodes about to be sized around it) is the kind that can stay genuinely live for a future reader. Want me to expand that row into a full decision doc at `docs/decisions/delivery-approach.md` instead, or is the row enough?

Once you're happy with the HLD update (or the decision-doc question is settled), I'll move to Phase 2 and draft the leaf LLDs for the three nodes — change store, delivery, and browser sync.