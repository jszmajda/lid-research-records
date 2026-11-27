**Phase 1 — HLD updated.** The changed sections in full:

**Approach**

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach connected browsers over self-hosted WebSockets. Subsecond delivery comes naturally from that channel, though the design only needs to meet the 15-second freshness goal.
>
> Change storage, delivery, and browser recovery are designed around that channel: the change store keeps replayable revisions and a reliable publication path, delivery owns WebSocket sessions and reconnect handling, and browsers catch up from replay after gaps in their connection.

**Architecture** (node bullets for change-store, delivery, browser-sync now name the WebSockets obligations — replayable revisions + publication path, sessions/subscriptions/publication, reconnect + catch-up — instead of "depending on the approach").

**Key Design Decisions** (new entry)

> **Self-hosted WebSockets deliver committed changes.** Alternatives considered: five-second HTTPS polling — the simplest stateless operation, but repeated reads and seconds of lag; the store would need cursor queries, delivery would stay request/response, and browsers would run a polling loop. A hosted realtime service — the quickest route to low-latency updates with less connection operations, but recurring fees and provider coupling; the store would need publication reconciliation, delivery would wrap the provider, and browsers would use its subscription model. Self-hosted WebSockets were chosen to get fast updates without tying the board to a realtime vendor; the accepted cost is owning connection capacity and reconnect problems in delivery, replayable revisions and reliable publication in the store, and reconnect and catch-up logic in browsers.

Tenets, Goals, Non-Goals unchanged — the existing tenets still hold and the choice belongs to Key Design Decisions, not a tenet.

Two questions before I stop for your review:

1. **Decision doc offer.** This choice cleared the bar for one: three options traded against multiple criteria (latency, ops burden, vendor fees/coupling), and the three nodes are about to be sized around it — a cold reader could be tempted to re-litigate "why not just poll?" Record it as a full decision doc at `docs/decisions/self-hosted-websockets-delivery.md`, or keep just the Key Design Decisions entry above? (I write the doc only if you say yes.)

2. **Cross-segment cascade into access.** `access-design.md` says "Authorization for HTTPS edit commands is independent of the still-open change-delivery approach." The substance still holds, but "still-open" is now stale. ACCESS is a separate segment, so I'm asking rather than editing: want me to update that line?

Reply with your review of the HLD changes plus answers to 1 and 2, and I'll proceed to the three nodes.