The decision doc is written at `docs/decisions/delivery-approach.md` and linked from the HLD's Key Design Decisions entry. It reads standalone for someone new:

> # Decision: Self-hosted WebSockets for change delivery
>
> ## Context
>
> MarketBoard boards must show committed status changes in up to 800 simultaneous staff browsers within 15 seconds under normal connectivity, absorb opening-time bursts of 20 edits per second, and let a browser recover after being disconnected for up to 20 minutes. Commands already arrive over HTTPS and commit as single authoritative event revisions; the open question was how committed revisions travel from server to browsers. Three mechanisms can meet the freshness target — interval HTTPS polling, self-hosted WebSockets, or a hosted realtime service — and the choice sizes three design nodes at once: the change store's publication surface, the delivery component's session model, and the browsers' recovery behavior. No overriding criterion was fixed in advance between operating burden and running cost, so the tradeoff is weighed explicitly below.
>
> Foundational invariants every option respects, and therefore background rather than decision elements: one authoritative revision per committed edit regardless of delivery route; connectivity failures visible rather than mistaken for an unchanged board; server-side authorization independent of delivery.
>
> ## Decision Elements
>
> No gates eliminate any option: all three meet the 15-second freshness target and the 800-browser concurrency requirement, and the project's infrastructure tenet explicitly permits both self-hosted and managed infrastructure. The choice is decided on weighted criteria:
>
> - **Update latency** (major): how quickly a committed change appears in a connected browser.
> - **Operating burden** (major): connection capacity, session lifecycle, and reconnect work the team runs day to day, including burst fan-out to ~800 concurrent sessions.
> - **Recurring cost** (major): continuing fees or usage charges beyond self-hosted compute.
> - **Vendor independence** (major): whether the update path can be re-implemented without depending on a single provider's service, SDK, and pricing.
> - **Read amplification** (moderate): store reads the mechanism generates at steady state — 800 browsers, roughly two edits per minute, bursts of 20 per second.
> - **Browser-side complexity** (moderate): how much reconnect and catch-up logic the browser must implement.
>
> ## Options in the Domain
>
> ### Five-second HTTPS polling
> ... (strongest case: stateless requests, no session lifecycle, standard HTTP infra works unmodified; delivery stays request/response, browsers run a polling loop)
> - Update latency: **weak** — a committed change waits out the interval; seconds of lag.
> - Operating burden: **strong** — no connections to manage; stateless requests.
> - Recurring cost / Vendor independence: **strong**.
> - Read amplification: **weak** — ~9,600 store reads per minute against ~2 changes.
> - Browser-side complexity: **strong** — a loop and a cursor.
>
> ### Self-hosted WebSockets
> ... (server holds sessions open and pushes each committed revision; store publishes replayable revisions; browsers catch up by replay from their last received revision)
> - Update latency: **strong** — push; subsecond under normal connectivity.
> - Operating burden: **weak** — we own ~800 concurrent sessions, burst fan-out ≈16,000 messages/second, session lifecycle, reconnect behavior.
> - Recurring cost / Vendor independence: **strong**.
> - Read amplification: **strong** — read per change, not per interval.
> - Browser-side complexity: **weak** — reconnect and catch-up logic beyond a plain polling loop.
>
> ### Hosted realtime service
> ... (third-party provider carries updates; server publishes to it, browsers subscribe via its SDK; store needs publication reconciliation, delivery wraps the provider)
> - Update latency: **strong** — provider push.
> - Operating burden: **partial** — provider handles capacity; we manage account, credentials, publication reconciliation.
> - Recurring cost: **weak** — recurring fees, typically scaling with connections or messages.
> - Vendor independence: **weak** — coupled to one provider's service, SDK, and subscription model.
> - Read amplification: **strong**.
> - Browser-side complexity: **partial** — provider SDK reconnect, but its model must be reconciled with board recovery after long disconnects.
>
> ## Selection
>
> **Self-hosted WebSockets.** It matches the hosted option's strong latency while keeping polling's strong cost and independence profile; what it gives up is the strong operating-burden position. The team accepted owning connection capacity and reconnect handling to get fast updates without tying the board to a realtime vendor. The decision turns on the infrastructure tenet that both self-hosted and managed infrastructure are permitted: vendor coupling was weighed as a cost, not forbidden, and found not worth the operations it would offload at the pilot's single-region scale. Committing obligates the downstream nodes: the change store must publish replayable revisions with reliable publication; delivery must manage sessions and fan-out sized for ~800 concurrent connections and 16,000 messages per second at burst; browser sync must make disconnects visible (per the connectivity-failure tenet) and catch up by replaying from the last received revision. It forecloses stateless request/response delivery and vendor-managed connection operations.

The full file carries complete per-option descriptions; the abridged view above is faithful to it. Phase 1 is complete: HLD updated, decision recorded and linked.

Ready to move on to the three nodes — change store, delivery, and browser sync — whenever you are. I'll draft their LLDs one at a time (change store first, since delivery and browser sync both lean on its replayable revisions), with a stop for your review after each. Shall I start there?