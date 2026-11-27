I've updated `docs/high-level-design.md` for self-hosted WebSockets and stopped there for your review; nothing is committed, and the three nodes are untouched.

## What changed

**Approach** (replaced):

> Keep one authoritative board per event. Editors submit commands over HTTPS, and the server assigns each committed edit one event revision. Committed revisions reach browsers over WebSocket connections that MarketBoard hosts itself: every open board holds a socket to the delivery component, which pushes each revision as it commits.
>
> Hosting the sockets means MarketBoard owns connection capacity and reconnect behavior instead of buying them from a provider. Three components carry that work and are designed together, with the event revision as their shared contract:
>
> - The change store keeps a replayable revision history and reliably publishes every committed revision to delivery.
> - Delivery manages socket sessions and pushes published revisions to the browsers viewing that event.
> - Browser sync detects a lost connection, reconnects, and catches up from the last revision it applied.

**Architecture** (the four entries no longer say "depends on the approach"):

> - Access: […] Authorizes HTTPS commands; sits below the command boundary and does not depend on how changes are delivered.
> - Change store: […] Not written yet. Owns revision assignment, the replayable revision history, and reliable publication of committed revisions to delivery.
> - Delivery: […] Not written yet. Owns socket sessions, connection capacity, and pushing published revisions to connected browsers.
> - Browser sync: […] Not written yet. Owns the browser's socket lifecycle: connecting, showing connectivity loss, reconnecting, and catching up.

**Key Design Decisions** (new entry):

> **Self-hosted WebSockets deliver committed changes.** MarketBoard runs its own socket endpoint and pushes each revision to connected browsers as it commits. All three candidates meet the 15-second freshness goal, so the choice turns on what is paid for updates faster than the goal requires. Five-second HTTPS polling was rejected: it is the simplest to operate and stateless, but it leaves a few seconds of lag on every change and repeats reads from up to 800 browsers whether or not anything changed. A hosted realtime service was rejected: it gives low latency with the least connection operations work, but adds a recurring fee and couples the board to one provider's subscription model. Self-hosting gets the fast updates without that dependency; the accepted cost is owning connection capacity, reconnect handling, and replay.

Problem, Tenets, Goals and Non-Goals are unchanged.

## Questions for you

1. **Freshness goal.** The goal still reads "within 15 seconds", and the decision entry says sockets were chosen for updates faster than the goal requires. Should the goal tighten (to what figure?), or stay at 15 seconds as the floor with speed as a bonus? The delivery and browser-sync nodes will be sized against this number.
2. **Vendor independence as a tenet.** The fourth tenet still says self-hosted and managed infrastructure are both permitted. I recorded your reasoning as specific to realtime delivery, not as a general lean. Do you want a tenet such as "prefer owning a capability over coupling the board to a vendor, even at operational cost", or does it stop at this one decision?
3. **Decision doc.** This choice had three credible options traded on latency, operations burden, cost and coupling, and three nodes are about to be built on it. Do you want a full decision doc at `docs/decisions/` with the options and criteria laid out, or is the Key Design Decisions entry enough?
4. **Access node is stale.** `docs/intent/access/access-design.md` still says the delivery approach is "still-open". It also says subscription credentials "will belong to the delivery node", so authorizing a socket connection lands in delivery. I left it alone because it is a separate segment. May I fix that wording, and is delivery the right owner for socket authorization?

Once you approve the HLD (or send numbered changes), I'll start on the change store, delivery and browser-sync nodes.