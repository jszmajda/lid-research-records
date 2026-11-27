**Phase 1 — HLD updated for the self-hosted WebSockets choice.** Changed sections of `docs/high-level-design.md`:

> **## Approach**
>
> Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes reach browsers over self-hosted WebSockets: the application holds one socket per connected browser and pushes each new revision as soon as it is assigned, so an edit appears in open browsers well inside the freshness target with no realtime service in the path. Subsecond updates would be useful, but are not required.
>
> Sockets fail more often than requests, so the design treats reconnection as routine. The change store retains a replayable revision history and publishes committed revisions reliably; delivery owns socket sessions and publication to connected browsers; each browser reconnects and catches up from the last revision it rendered. Change storage, delivery, and browser recovery are specified in the nodes below and must stay coherent with one another.

> **## Architecture**
> - Change store: … Not written yet. Retains the replayable revision history, read indexes, and reliable publication of committed revisions.
> - Delivery: … Not written yet. Owns WebSocket sessions and the push of each committed revision to connected browsers.
> - Browser sync: … Not written yet. Owns the browser's connection, its reconnect after a drop, and catch-up from the last revision it rendered.
> (Access bullet unchanged; Tenets, Goals, Non-Goals unchanged.)

> **## Key Design Decisions**
> - **Self-hosted WebSockets for change delivery.** Alternatives considered: five-second HTTPS polling — stateless and simple, but seconds of lag, a polling loop in every browser, and repeated reads from the store; and a hosted realtime service — the quickest route to low-latency updates with little connection operations, but recurring fees and provider coupling. Sockets were chosen because fast updates matter more here than minimizing connection operations, and the board should not depend on a realtime vendor. The cost of the choice is owning connection capacity, session management, and reconnect handling in the application.

Three things for you:

1. **Approve or revise the HLD above.**
2. **One stale line in the Access segment** (cross-segment cascade — I did not touch it): `docs/intent/access/access-design.md:10` still says *"Authorization for HTTPS edit commands is independent of the still-open change-delivery approach."* — "still-open" is now false. Fix to *"…independent of the change-delivery approach."* Apply it?
3. **Decision doc offer (once):** this choice trades three credible options against more than one criterion and the three pending nodes are about to be sized around it, so it clears the bar for a full decision doc at `docs/decisions/change-delivery-approach.md`. The alternative is the single Key Design Decisions entry above. Want the doc, or just the entry?

Say the word and I'll proceed to the three nodes (change store, delivery, browser sync).