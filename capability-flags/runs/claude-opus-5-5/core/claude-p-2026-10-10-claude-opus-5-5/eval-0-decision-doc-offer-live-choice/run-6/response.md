`docs/high-level-design.md` now commits to self-hosted WebSockets. I changed nothing else and haven't committed; the change-store, delivery and browser-sync nodes wait on your review of this.

## What changed

**Approach** (replaced in full):

> Keep one authoritative board per event. Editors submit commands over HTTPS; the server commits each one as an event revision and pushes it to connected browsers over WebSocket connections that MarketBoard hosts itself. Browsers display a revisioned view of the board and, after a dropped connection, reconnect and catch up from the last revision they hold.
>
> Self-hosted sockets deliver changes quickly without coupling the board to a realtime vendor. The cost is operational and is accepted: MarketBoard owns connection capacity for its simultaneous browsers and owns the reconnect behavior that a hosted service would otherwise provide.
>
> Change storage, delivery, and browser recovery are designed together around this. The change store keeps replayable revisions and publishes each committed revision reliably; delivery manages socket sessions; browsers carry the reconnect and catch-up logic.

**Architecture** (the three unwritten nodes now state what they own; Access is unchanged):

> - Change store: … Not written yet. Owns revision history that can be replayed to a reconnecting browser, and reliable publication of each committed revision to delivery.
> - Delivery: … Not written yet. Owns WebSocket sessions: accepting connections, pushing published revisions to them, and connection capacity.
> - Browser sync: … Not written yet. Owns the browser's socket subscription, reconnect, and catch-up from its last held revision.

**Key Design Decisions** (new entry):

> - **Self-hosted WebSockets for delivering committed changes.** The server pushes each committed revision to browsers over sockets MarketBoard runs itself, accepting connection-capacity and reconnect work in exchange for fast updates with no dependence on a realtime vendor. Five-second HTTPS polling was rejected: it is the simplest to operate and stateless, but it repeats reads and lags every change by a few seconds. A hosted realtime service was rejected: it reaches low latency soonest with the least connection operations, but brings recurring fees and couples the board to its provider.

Tenets, Goals and Non-Goals are untouched.

## Questions for you

1. **Decision doc or just the entry above?** I'd write a full decision doc at `docs/decisions/` and link it from that entry. All three options meet the 15-second goal, so a later reader could reasonably reopen the choice, and three nodes are about to be sized around it. The alternative is to leave the one-paragraph entry as the whole record.

2. **Does the freshness goal tighten?** Goals still says "within 15 seconds", and the old line that subsecond updates are "useful, but not required" is gone with the old Approach. If fast updates are now a requirement, give me a number, because the delivery node will be sized to it. Otherwise 15 seconds stays the only commitment.

3. **Is vendor independence a standing lean or a one-off?** The fourth tenet still reads "Self-hosted and managed infrastructure are both permitted." If avoiding vendor coupling should tip future choices as well, I'd reword that tenet to say so. If it applies only to realtime delivery, the tenet stands as written.

4. **May I fix two stale lines in the Access design?** `docs/intent/access/access-design.md` calls the delivery approach "still-open" and refers to "delivery-specific subscription credentials". Both are wording-only changes with no effect on the Access specs, but they are in another node, so I'm asking first.

Once you approve the HLD or send changes, I'll start on the change-store node.