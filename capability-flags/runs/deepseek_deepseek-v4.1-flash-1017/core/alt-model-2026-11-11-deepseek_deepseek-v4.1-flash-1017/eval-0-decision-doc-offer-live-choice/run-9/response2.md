Written to `docs/decisions/websocket-delivery.md`, linked from the HLD's Key Design Decisions:

---

# Decision: Self-Hosted WebSockets for Board Delivery

## Context

Editors submit board changes over HTTPS to a server that assigns each committed edit one event revision; connected browsers display a revisioned view. The delivery mechanism decides how a committed revision reaches those browsers, and it shapes the store's read model, the delivery component's responsibilities, and the browser's recovery behavior. Delivery, change storage, and browser recovery are designed together, so this choice is made before the change-store, delivery, and browser-sync nodes are written.

Every candidate meets the 15-second freshness goal under normal connectivity. Subsecond updates are useful but not required. All candidates carry committed revisions only — editor commands stay on the HTTPS command boundary — and the HLD permits self-hosted and managed infrastructure alike, so hosting is not a gate on its own. The stakes are therefore not whether the board can be kept current, but what the project pays — in operating burden, recurring cost, coupling, and recovery complexity — to get there.

## Decision Elements

### Weighted Criteria

- **Vendor independence and recurring cost — major.** The project avoids a recurring realtime-service bill and a dependency on a provider's publication semantics. This is the criterion the decision turns on.
- **Update freshness — moderate.** Time from commit to display in a connected browser. Every candidate meets the 15-second goal; extra freshness has some value because coordinators act on opening-time bursts.
- **Connection and reconnect operations burden — moderate.** The work of holding, dropping, and re-establishing browser connections at up to 800 simultaneous browsers, and of catching a reconnecting browser up.
- **Read and publication load — moderate.** Repeated reads against the store, or publication work per committed revision. Bursts of 20 edits per second make this visible.
- **Recovery after a disconnect — moderate.** How easily a browser that was offline for up to 20 minutes returns to the latest board.
- **Connectivity failure visibility — moderate.** The HLD tenet that failures must be visible, not mistaken for an unchanged board. A mechanism that distinguishes "no change" from "not connected" fits better.
- **Implementation complexity — minor.** The amount of new machinery in store, delivery, and browser.

## Options in the Domain

### Five-second HTTPS polling

Browsers re-request the board or its changes on a five-second timer. The store answers with the revisions after a cursor the browser presents; delivery is a plain request/response endpoint. No long-lived connections exist, so there is no session state to hold or re-establish.

- **Vendor independence and recurring cost — strong fit.** No provider and no new recurring bill.
- **Update freshness — weak fit.** A commit can sit up to five seconds before a browser asks, and the timer drifts under load.
- **Connection and reconnect operations burden — strong fit.** No connections to manage; a failed request is retried by the next poll.
- **Read and publication load — weak fit.** Every browser reads on every interval whether or not anything changed; 800 browsers polling every five seconds is a steady read load independent of edit volume.
- **Recovery after a disconnect — strong fit.** The next successful poll returns the current board; catch-up is the normal path.
- **Connectivity failure visibility — partial fit.** An erroring request is visible, but a browser that silently stops receiving responses is easy to confuse with an unchanged board.
- **Implementation complexity — strong fit.** Cursor queries in the store and a polling loop in the browser; no publication or session machinery.

Summary: simplest to operate and recover, at the cost of lag and read load that grows with browser count rather than change volume.

### Self-hosted WebSockets

Browsers open a persistent socket to a server the project runs. When an edit commits, the server publishes the new revision to every subscribed session; browsers that reconnect present the last revision they saw and receive the retained revisions after it. The store must make revisions replayable, and delivery must hold sessions, publish reliably, and serve catch-up.

- **Vendor independence and recurring cost — strong fit.** No realtime vendor and no per-connection provider fee; cost is the project's own server capacity.
- **Update freshness — strong fit.** Publication follows commit directly, so connected browsers see changes at once.
- **Connection and reconnect operations burden — weak fit.** The project owns connection capacity for 800 browsers and the reconnect storms that follow a network event.
- **Read and publication load — strong fit.** Reads are only for catch-up; normal delivery publishes once per committed revision.
- **Recovery after a disconnect — partial fit.** Correct catch-up depends on replayable revisions and on the browser presenting its last revision; the project builds both.
- **Connectivity failure visibility — strong fit.** A dropped socket is an explicit, detectable state that the browser can surface.
- **Implementation complexity — weak fit.** Adds replayable retention, reliable publication, session management, and browser reconnect/catch-up logic.

Summary: fast, uncoupled updates in exchange for owning connection operations and reconnect correctness.

### Hosted realtime service

Browsers subscribe through a vendor's realtime product. Delivery wraps the provider's API, publishes committed revisions to it, and reconciles what the provider reports as published with the authoritative revisions in the store. Browsers use the provider's subscription model and reconnect behavior.

- **Vendor independence and recurring cost — weak fit.** Recurring fees scale with connections or traffic, and the board depends on the provider's publication and subscription semantics.
- **Update freshness — strong fit.** The provider delivers at low latency.
- **Connection and reconnect operations burden — strong fit.** The provider owns connection capacity and most reconnect handling.
- **Read and publication load — strong fit.** Delivery publishes once per committed revision.
- **Recovery after a disconnect — partial fit.** Catch-up follows the provider's model; the project still supplies replayable revisions or a snapshot path.
- **Connectivity failure visibility — strong fit.** The provider exposes connection state.
- **Implementation complexity — partial fit.** Less session code, but new publication reconciliation and provider credential handling.

Summary: least connection operations work and low latency, paid for with recurring fees and dependence on a provider.

## Selection

Self-hosted WebSockets is chosen.

The decision turns on **vendor independence and recurring cost**, the only major criterion. Self-hosting and polling both avoid a realtime provider; only self-hosting also delivers low-latency publication, so it dominates polling on freshness and read load while matching it on the major criterion. The hosted service wins on connection operations and implementation effort, but those are moderate or minor criteria, and it is the weakest option on the major one.

The accepted tradeoff is explicit: the project takes on connection capacity and reconnect correctness — the hosted service's chief advantage — to keep fast updates without a realtime vendor. The cost is bounded because the pilot audience is 800 simultaneous browsers at 40 weekend markets, and the failure modes are the ones the HLD already commits to surfacing: a dropped socket must read as disconnected, not as an unchanged board.

Committing this choice obligates the downstream nodes: the change store must retain replayable event revisions for catch-up; delivery must own socket sessions, connection capacity, publication of committed revisions, and replay support; browser sync must own subscription, reconnect, and catch-up. It forecloses a store designed only for cursor polling and forecloses relying on a provider's subscription model.

On tenets: the choice is permitted by *self-hosted and managed infrastructure are both permitted* — the tenet leaves hosting open, and vendor independence tips the major criterion. It supports *connectivity failures must be visible* through explicit socket disconnect state, and it preserves *a committed edit has one authoritative event revision regardless of its delivery route*: publication carries the store's revisions and never creates a second authority.

---

Phase 1 is still at your stop. Two items before we take the three nodes:

1. **Approve the HLD revision and this decision doc?** Numbered feedback, or approve.
2. **May I fix the stale Access sentence?** `docs/intent/access/access-design.md:10` still says authorization is "independent of the still-open change-delivery approach." Updating it crosses into the access segment, so I'm asking first.