The approach is settled and the HLD is updated. Here is the revised `docs/high-level-design.md` — Phase 1, presented for your review.

**Approach** (replaces the open-approach text):

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are pushed to browsers over WebSocket connections the project operates itself: the server assigns each committed edit an event revision, publishes it to connected sockets, and replays revision history so a reconnecting browser catches up from where it left off.
>
> Delivery, change storage, and browser recovery are designed together around this model. The change store provides replayable revisions and a reliable publication path; delivery manages socket sessions and connection capacity; browser sync handles reconnect and catch-up from the last received revision. This route takes on in-house connection and reconnect operations in exchange for low-latency updates without a realtime vendor.

**Architecture** — the three not-yet-written nodes now carry their socket-model obligations (change store: replayable revisions + ordered outbox; delivery: session management for 800 simultaneous browsers, per-event subscribe, publication; browser sync: reconnect/catch-up from last received revision, visible connection loss). Access is unchanged.

**Key Design Decisions** — added:

> **Self-hosted WebSockets for change delivery.** Committed revisions are pushed over WebSocket connections the project operates; the change store keeps revisions replayable with a reliable publication path, delivery manages socket sessions, and browsers reconnect and catch up from their last received revision. Five-second HTTPS polling was rejected: simplest stateless route, but repeated store reads and a few seconds of lag, with cursor queries still needed. A hosted realtime service was rejected: recurring fees and provider coupling for a board whose event updates carry only stall IDs and operational statuses. The cost accepted is in-house connection capacity and reconnect operations.

Two things for you:

1. **Adjacent-segment flag:** `docs/intent/access/access-design.md` line 10 still says authorization is "independent of the still-open change-delivery approach" — now stale. It's a one-line touch-up in that segment; may I update it, or leave it for when access is next worked on?
2. **Decision doc offer:** this choice stays live for a cold reader (three credible routes, criteria trading latency vs. ops vs. cost vs. coupling, and three nodes about to be sized around it). Want me to record it as a full decision doc at `docs/decisions/` and link it from the Key Design Decisions entry? The entry as written is the alternative if not.

On your approval of the HLD, we'll proceed to the three nodes — Phase 2, one LLD at a time.