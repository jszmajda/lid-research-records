The self-hosted WebSockets choice is recorded and the HLD is updated (docs/high-level-design.md). Here is the Phase 1 output for your review — the three changed sections in full; Problem, Tenets, Goals, and Non-Goals are unchanged.

**Approach** (now reads):

> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are pushed to browsers over self-hosted WebSockets: the board operates its own socket infrastructure rather than depending on a realtime vendor, taking on connection-capacity and reconnect operations in exchange for fast updates with no recurring provider fees. Socket pushes are normally subsecond, well inside the required freshness target.
>
> Delivery, change storage, and browser recovery are designed together around the socket approach. The change store provides replayable revisions and reliable publication so a browser can catch up on changes missed while disconnected. Delivery owns socket sessions and connection capacity. Browser sync owns reconnect and catch-up behavior.

**Architecture** (three "not written yet" nodes now say what each will own under the socket approach):

> - Change store: ... Revision history, read indexes, and the publication outbox are sized for socket delivery: replayable revisions and reliable publication.
> - Delivery: ... Owns socket sessions, connection capacity, and publication of committed revisions to connected browsers.
> - Browser sync: ... Owns socket subscription, reconnect handling, and catch-up from the browser's last received revision.

**Key Design Decisions** (new entry alongside the HTTPS-command decision):

> **Self-hosted WebSockets for change delivery.** Committed revisions are pushed to browsers over sockets the board operates itself. Five-second HTTPS polling was rejected: simplest stateless operation, but a few seconds of lag and repeated reads across up to 800 browsers. A hosted realtime service was rejected: least connection operations, but recurring fees and provider coupling around a core board behavior. Owning connection capacity and reconnect operations is the accepted cost of fast, vendor-free updates.

Questions before I proceed to the three nodes:

1. **Approval of the HLD as updated** — or any wording changes you want.
2. **Decision doc?** This choice stays live for a cold reader (three credible options, latency/ops/cost/coupling criteria, three nodes sized around it). I've recorded it as a Key Design Decisions entry; I can expand it into a full decision doc at `docs/decisions/` if you'd rather — otherwise the entry stands.
3. **Tenet candidate:** your rationale — vendor independence — could govern the node designs ahead (socket library, pub/sub middleware, managed database all come up). Should I add a tenet like "Prefer self-hosted infrastructure where the operations burden is bounded; avoid coupling core board behavior to a vendor"? Its reverse (prefer managed to reduce ops) is defensible, so it's a real lean, not a platitude. The existing "self-hosted and managed are both permitted" tenet would stay.
4. **Cross-segment staleness:** access-design.md says authorization is "independent of the *still-open* change-delivery approach." That phrase is now stale. The Access segment is outside this pass — may I update that one phrase, or leave it for a later pass?

On your approval I'll start the three nodes — change-store, delivery, and browser-sync LLDs. Any preference for order, or shall I walk them in dependency order (change-store → delivery → browser-sync)?