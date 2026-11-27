The decision doc is written and linked from the HLD. Here it is in full for your review — `docs/decisions/change-delivery-approach.md`:

> ---
> node: high-level-design
> ---
>
> # Decision: Self-hosted WebSockets for change delivery
>
> ## Context
>
> MarketBoard delivers committed edits to as many as 800 simultaneous staff browsers, and must show a committed change within 15 seconds under normal connectivity, recover after a browser has been disconnected for up to 20 minutes, and hold 99.5 percent availability during published event hours. Editors' commands commit over HTTPS, and every committed edit carries one authoritative event revision regardless of how it reaches a browser (a project tenet). Delivery, change storage, and browser recovery are designed together, so this decision sizes three downstream components: the change store's publication machinery, the delivery service's session management, and the browser's reconnect and catch-up behavior.
>
> Three delivery mechanisms can each meet every hard goal — five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service all satisfy the freshness, capacity, recovery, and availability targets. No option is eliminated on requirements, and the tenet permitting both self-hosted and managed infrastructure keeps all three in contention. The choice is therefore a weighed trade among operational postures, not a requirement-driven elimination.
>
> ## Decision Elements
>
> All elements are weighted criteria; none is a gate, since no option fails a hard requirement.
>
> - **Update latency (major)** — time from a committed edit to its display in a connected browser. Better-than-required responsiveness was wanted even though only 15 seconds is required.
> - **Vendor independence in the delivery path (major)** — whether the board's core update behavior depends on an outside provider's fees, credentials, and uptime.
> - **Operations we own (major)** — connection capacity management, reconnect failure handling, and on-call responsibility during event hours.
> - **Store load and machinery (moderate)** — read amplification against the store, and what publication machinery (cursor queries, replay, outbox, reconciliation) the store must provide.
> - **Browser client complexity (moderate)** — what the browser must implement to stay current.
> - **Burst absorption (moderate)** — where opening-time edit bursts and mass reconnects (a network blip at 800-browser scale) concentrate load, and who absorbs them.
> - **Cost shape (minor)** — recurring per-usage fees versus owned capacity that sits idle outside event hours.
>
> ## Options in the Domain
>
> ### Five-second HTTPS polling
>
> Browsers request cursor-based deltas over plain HTTPS every five seconds. Nothing holds state between requests: no persistent connections, no sessions, no subscription registry. Each poll is idempotent, degrades gracefully through caches and proxies, and can be debugged with any HTTP client. A disconnected browser resumes with a single catch-up query against its stored cursor.
>
> - Update latency (major): **weak** — changes appear up to five seconds late; acceptable against the 15-second target, but no better than required.
> - Vendor independence (major): **strong** — plain HTTPS, no outside provider.
> - Operations we own (major): **strong** — stateless; nothing to hold open and nothing to fail between requests.
> - Store load and machinery (moderate): **weak** — 800 browsers polling every five seconds is a standing ~160 reads/second against the store even when nothing changes, and every poll repeats cursor-query work.
> - Browser client complexity (moderate): **strong** — a polling loop is the simplest possible client.
> - Burst absorption (moderate): **partial** — polls spread load evenly by construction, but the standing load is constant and rejoining browsers trickle in one poll at a time.
> - Cost shape (minor): **strong** — cheap to serve.
>
> Summary: the simplest and most robust operation, paying with lag and constant repeated reads.
>
> ### Hosted realtime service
>
> A third-party realtime provider owns the fan-out. The board publishes each committed revision to the provider; browsers subscribe through the provider's client library, which handles edge reconnects. Connection capacity, socket operations, and scaling become the vendor's, typically under an SLA.
>
> - Update latency (major): **strong** — subsecond push.
> - Vendor independence (major): **weak** — recurring fees, credentials, and SDK coupling sit on the board's core update path; a provider outage or pricing change touches every connected browser.
> - Operations we own (major): **strong** — the vendor runs connections and absorbs reconnect storms.
> - Store load and machinery (moderate): **partial** — no poll load, but the store must reconcile publication: what the provider delivered versus what actually committed, and repair the gap.
> - Browser client complexity (moderate): **partial** — the vendor library covers reconnect, at the cost of provider-specific subscription code.
> - Burst absorption (moderate): **strong** — the vendor's capacity absorbs opening bursts and mass reconnects.
> - Cost shape (minor): **weak** — fees recur and scale with connections and messages as markets grow.
>
> Summary: the fastest route to low-latency push, paying with money and coupling.
>
> ### Self-hosted WebSockets
>
> The board runs its own socket layer. A delivery service owns sessions and connection capacity; the change store publishes committed revisions through a reliable publication mechanism with replayable revisions; browsers hold a socket subscription and, on reconnect, catch up from the last revision they received.
>
> - Update latency (major): **strong** — subsecond push.
> - Vendor independence (major): **strong** — no outside provider in the delivery path.
> - Operations we own (major): **weak** — connection capacity, reconnect failures, and event-hours on-call are ours; opening bursts and mass reconnects land on infrastructure we size ourselves.
> - Store load and machinery (moderate): **partial** — no poll amplification, but the store must provide replayable revisions and reliable publication (a committed edit must eventually reach every live socket and every reconnecting browser).
> - Browser client complexity (moderate): **weak** — reconnect with backoff, duplicate suppression by revision, and catch-up queries are all client-side obligations.
> - Burst absorption (moderate): **weak** — reconnect storms at 800-browser scale concentrate on our own capacity.
> - Cost shape (minor): **partial** — no per-usage fees, but provisioned capacity idles outside event hours.
>
> Summary: fast, vendor-free push, paying with operational work we own.
>
> ## Selection
>
> **Self-hosted WebSockets.** It is the only option strong on both major criteria other than the operations it trades away: polling concedes latency, the hosted service concedes vendor independence, and self-hosted sockets concede operations we own — a price accepted deliberately for fast updates with no realtime vendor in the delivery path. The tenet permitting both self-hosted and managed infrastructure kept the hosted option legitimate; this decision leans to the self-hosted side of that permission for the board's core update behavior, where provider coupling would be hardest to unwind.
>
> The decision is bounded by the authoritative-revision tenet: because delivery routes are interchangeable behind revisioned storage, moving later to a hosted service or to polling touches the delivery and browser-sync designs, not the store's revision semantics. Reversibility is real, though not free.
>
> Committing to this option obligates the downstream designs:
>
> - The change store must provide replayable revisions and reliable publication.
> - Delivery must own socket sessions and size connection capacity for opening bursts and reconnect storms.
> - Browser sync must own reconnect handling and catch-up from the browser's last received revision.
>
> It forecloses the hosted route's turnkey connection operations for the pilot, and with them the vendor's absorption of burst load.

Notes on the write-up: it's cold-readable (no reference to our conversation), each option gets its strongest honest case, and two criteria that cut *against* the choice — burst absorption and cost shape — are recorded rather than buried, since a new reader weighing "why not just pay a vendor?" deserves the full picture.

Still open from my last stop:

1. This doc and the linked HLD entry — approve, or any changes?
2. The tenet candidate: "Prefer self-hosted infrastructure where the operations burden is bounded; avoid coupling core board behavior to a vendor." Add it, or leave the tenets as they are?
3. The stale phrase in access-design.md ("still-open change-delivery approach") — fix that one phrase now, or leave it for a later pass?
4. On approval I'll start the three nodes — change-store, delivery, browser-sync LLDs. Any order preference, or shall I walk them dependency-first (change-store → delivery → browser-sync)?