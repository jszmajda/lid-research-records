I've written `docs/decisions/change-delivery.md` and linked it from `docs/high-level-design.md` under `## Key Design Decisions`. Here is the decision doc in full for review:

```markdown
---
node: high-level-design
---

# Decision: Board Change Delivery

## Context

MarketBoard processes edit commands over HTTPS against one authoritative board per event (see [docs/high-level-design.md](../high-level-design.md) § Key Design Decisions), requiring a server-to-browser delivery mechanism to propagate committed event revisions to staff browsers.

Forty weekend markets operate boards maintained by roughly 120 coordinators and viewed by up to 800 simultaneous staff browsers. A busy event has 10–25 active editors averaging two status changes per minute, with opening-time bursts up to 20 edits per second. Across all viable delivery mechanisms, committed edits must appear in connected browsers within 15 seconds under normal connectivity, browsers must recover the latest board after disconnects up to 20 minutes, revision history must be retained for seven days, and the board must sustain 99.5 percent availability during published event hours. Event updates carry stall IDs and operational statuses rather than customer records.

This choice shapes three coupled components — `change-store`, `delivery`, and `browser-sync` — and sets the architectural trade between propagation latency, stateful connection operations, and third-party vendor coupling.

## Decision Elements

### Weighted Criteria

- **Vendor independence and predictable operating cost (major)** — Freedom from proprietary realtime provider coupling across `delivery` and `browser-sync`, and from recurring per-connection or per-message vendor fees as concurrent staff browsers or market count grow. While the tenet *"Self-hosted and managed infrastructure are both permitted"* leaves managed services eligible on data-classification grounds, coupling live board delivery to a realtime vendor binds both server publication and browser client code to external pricing and SDK lifecycles.
- **Update latency during active coordination (major)** — Subsecond propagation of committed stall closures, late arrivals, and power problems to connected browsers, especially during 20-edit/second opening-time bursts. While 15 seconds is the outer freshness requirement, coordinators triaging opening-time issues benefit when edits appear across staff screens immediately upon commit rather than behind a multi-second polling cadence.
- **Stateful connection and deploy operations (major)** — Operational simplicity of sustaining 99.5 percent availability during published event hours across up to 800 simultaneous browsers. Covers persistent socket memory and connection limits, load-balancer timeout configuration, heartbeat tuning, and reconnect/catch-up blast radius when server instances restart or roll during active events.
- **End-to-end connectivity failure visibility (moderate)** — Derived from the tenet *"Connectivity failures must be visible, not mistaken for an unchanged board."* How quickly and unambiguously a browser can detect degradation anywhere along the delivery path from MarketBoard's server to the client, avoiding silent staleness.
- **Authoritative revision and publication simplicity (moderate)** — Derived from the tenet *"A committed edit has one authoritative event revision regardless of its delivery route."* How little cross-component machinery (cursor reads vs. internal pub/sub and gap replay vs. external outbox reconciliation) is needed across `change-store`, `delivery`, and `browser-sync` so every browser converges on the store's single revision sequence across live traffic and 20-minute disconnect recovery.
- **Server-side access and revocation alignment (minor)** — Derived from the tenet *"Commands use server-side authorization; browser state is not evidence of permission."* How directly read/subscription admission, eight-hour session expiry, and event-assignment revocation integrate with MarketBoard's server-side session model without maintaining parallel third-party token lifecycles.

## Options in the Domain

### Five-Second HTTPS Polling

**Description**

Browsers load an initial board snapshot with its current `eventRevision` over HTTPS and then poll an HTTPS endpoint every five seconds with `sinceRevision=<n>`. `change-store` indexes event revisions by `(eventId, revision)` so cursor queries return ordered deltas cheaply (falling back to a full snapshot if a cursor is older than the replay window). `delivery` remains a stateless request/response HTTP handler with no persistent session state or internal push bus. `browser-sync` runs a timer loop, applies returned revisions in order, and marks connectivity degraded when poll requests fail or time out. After a disconnect up to 20 minutes, the next successful poll catches up via the same cursor endpoint.

**Demonstration**

```text
Browser -> GET /events/{id}/changes?since=104 (every 5s)
Delivery -> ChangeStore.readSince(eventId, 104) -> [rev 105, rev 106]
Browser applies rev 105..106; advances local cursor to 106
```

**Analysis**

- **Vendor independence and predictable operating cost**: **strong** — Uses standard HTTPS handlers and database reads with no external realtime provider, SDK, or per-connection billing.
- **Update latency during active coordination**: **weak** — Committed edits wait up to five seconds plus HTTP round-trip latency (roughly 2.5 seconds on average under healthy links) before browsers observe them.
- **Stateful connection and deploy operations**: **strong** — Delivery servers remain stateless across rolling deploys and instance restarts, trading connection management for roughly 160 steady read requests per second at 800 simultaneous browsers.
- **End-to-end connectivity failure visibility**: **partial** — Failed polls prove the path to MarketBoard is broken, but outage detection lags by up to one five-second poll interval plus request timeout before degraded UI appears.
- **Authoritative revision and publication simplicity**: **strong** — Browsers read committed revisions directly from the authoritative store path with no separate publication pipeline, fan-out bus, or dual-channel ordering logic.
- **Server-side access and revocation alignment**: **strong** — Every poll is an ordinary HTTPS request validated directly against current server-side session expiry and event assignment state.

**Summary**

Maximizes server statelessness and architectural simplicity at the cost of multi-second update lag and continuous repeated read polling across all open browsers.

### Self-Hosted WebSockets

**Description**

Browsers establish a persistent WebSocket connection to MarketBoard's `delivery` service after loading or reconciling board state. When an HTTPS command commits a new revision, `change-store` persists the ordered revision and reliably publishes it (for example via an outbox or ordered internal notification stream paired with store reads) to `delivery`. `delivery` authenticates subscription admission, maintains active per-event socket registries, runs protocol heartbeats, and broadcasts committed revisions to connected browsers. `browser-sync` tracks its highest contiguous `eventRevision`, surfaces degraded connectivity immediately upon socket close or missed heartbeats, reconnects with jittered backoff, and replays missed revisions from `change-store` (or reloads a snapshot when needed) to recover from gaps and disconnects up to 20 minutes.

**Demonstration**

```text
Editor -> POST /events/{id}/commands -> commits rev 105 in ChangeStore
ChangeStore -> reliably publishes rev 105 -> Delivery broadcasts rev 105 over WebSockets
Disconnected browser reconnects at rev 98 -> replays rev 99..105 (or snapshot) -> resumes live stream
```

**Analysis**

- **Vendor independence and predictable operating cost**: **strong** — Uses standard WebSocket protocols on self-hosted compute with no third-party realtime vendor lock-in or per-connection/message fees.
- **Update latency during active coordination**: **strong** — Pushes committed revisions over open sockets in subsecond time, keeping coordinator and staff boards tightly synchronized during opening-time bursts.
- **Stateful connection and deploy operations**: **weak** — MarketBoard owns concurrent socket capacity for up to 800 browsers, load-balancer long-lived connection settings, heartbeat management, and coordinated reconnect/replay load during rolling deploys or node failures.
- **End-to-end connectivity failure visibility**: **strong** — Socket close frames and application heartbeats operate directly between MarketBoard and the browser, enabling immediate detection when the end-to-end update path breaks.
- **Authoritative revision and publication simplicity**: **partial** — Requires reliable internal publication from `change-store` to `delivery` plus gap detection and replay reconciliation in `browser-sync`, though all state remains inside MarketBoard's boundary under one revision sequence.
- **Server-side access and revocation alignment**: **partial** — `delivery` checks server-side session and event assignments directly on connection admission, but enforcing mid-session expiry or revocation requires tracking and terminating open sockets.

**Summary**

Delivers subsecond updates and direct end-to-end connection visibility without vendor coupling, at the cost of owning stateful WebSocket session operations and reconnect/replay mechanics.

### Hosted Realtime Service

**Description**

MarketBoard delegates persistent browser fan-out to a managed realtime provider. Browsers authenticate against MarketBoard's `delivery` component to obtain short-lived, event-scoped provider capability tokens, then open subscriptions directly to the provider's edge infrastructure using its client SDK. When an HTTPS edit commits in `change-store`, an outbox worker in `delivery` publishes the committed revision to the provider's REST/publish API, reconciling transient publish failures so no revision is lost. `browser-sync` wraps the provider SDK's subscription and connection-state callbacks, deduplicates or orders incoming messages by `eventRevision`, and fetches missed revisions or a board snapshot from MarketBoard when reconnecting after gaps up to 20 minutes.

**Demonstration**

```text
Browser -> POST /events/{id}/realtime-token -> subscribes to provider channel event:{id}
ChangeStore commits rev 105 -> Delivery outbox publishes rev 105 to Provider API -> Provider fans out
Browser detects revision gap or >provider history -> fetches missed revisions from MarketBoard HTTPS
```

**Analysis**

- **Vendor independence and predictable operating cost**: **weak** — Couples `delivery` publication and `browser-sync` subscription logic to a proprietary vendor API/SDK and incurs recurring connection and message charges.
- **Update latency during active coordination**: **strong** — Pushes committed updates through persistent provider sockets with subsecond latency under normal operation.
- **Stateful connection and deploy operations**: **strong** — Offloads socket connection capacity, keepalives, and deploy-time connection persistence from MarketBoard's servers, which remain stateless HTTP and background worker processes.
- **End-to-end connectivity failure visibility**: **partial** — Provider SDKs promptly report browser-to-provider socket drops, but a healthy provider socket can mask failures in MarketBoard's server-to-provider publication pipeline unless supplemented by end-to-end heartbeats.
- **Authoritative revision and publication simplicity**: **weak** — Splits commit and fan-out across an external network boundary, requiring transactional outbox retries, idempotent revision deduplication, and fallback MarketBoard catch-up reads when disconnects exceed provider buffer windows.
- **Server-side access and revocation alignment**: **weak** — Requires minting signed third-party capability tokens and relying on short token TTLs or provider-specific revocation calls to enforce MarketBoard session expiry and assignment changes.

**Summary**

Achieves low-latency updates without MarketBoard operating WebSocket infrastructure, at the cost of recurring vendor fees, provider coupling, and cross-vendor publication and auth reconciliation.

## Selection

MarketBoard selects **Self-Hosted WebSockets**.

Across the **major** criteria, self-hosted WebSockets is the only option that achieves both subsecond update propagation during active market coordination and full independence from a third-party realtime vendor's pricing and SDK surface. Five-second HTTPS polling avoids stateful server operations (**Stateful connection and deploy operations**), but sacrifices immediate propagation during opening-time bursts (**Update latency during active coordination**) and introduces a multi-second blind spot before outages surface. A hosted realtime service matches WebSockets on latency while keeping MarketBoard's servers stateless, but scores poorly on **Vendor independence and predictable operating cost** as well as cross-boundary publication and authorization alignment. At MarketBoard's scale — up to 800 simultaneous browsers and bursts of 20 edits per second in a single-region pilot — owning WebSocket session management is a bounded engineering and operational cost rather than a multi-region infrastructure problem, making the trade on **Stateful connection and deploy operations** worthwhile.

This decision turns on the project's tenets as follows:

- While *"Self-hosted and managed infrastructure are both permitted"* leaves hosted providers eligible on data-sensitivity grounds, self-hosted WebSockets avoids binding core board synchronization to an external vendor while keeping the full delivery path under MarketBoard's control.
- It directly supports *"Connectivity failures must be visible, not mistaken for an unchanged board"* by giving `delivery` and `browser-sync` direct end-to-end socket close and heartbeat signals with no intermediate vendor hop.
- It preserves *"A committed edit has one authoritative event revision regardless of its delivery route"* and *"Commands use server-side authorization; browser state is not evidence of permission"*, provided downstream nodes uphold reliable internal publication, revision-ordered catch-up, and server-enforced session lifecycles.

Committing to self-hosted WebSockets forecloses purely stateless delivery deploys (server rolls will disconnect active sockets and must be absorbed cleanly) and sets concrete obligations for the three downstream nodes:

- **`change-store`**: Persist strictly ordered per-event revisions, retain seven days of history, serve board snapshots and bounded revision replay queries covering at least the 20-minute disconnect window, and guarantee reliable publication of every committed edit to `delivery`.
- **`delivery`**: Manage concurrent WebSocket connections for up to 800 browsers and 20-edit/second bursts, enforce server-side subscription admission and session/assignment revocation, run connection heartbeats, and drain sockets gracefully on deploy.
- **`browser-sync`**: Maintain WebSocket subscriptions, track the contiguous applied `eventRevision`, display degraded connectivity immediately on disconnect or heartbeat timeout, reconnect with jittered backoff to avoid reconnect storms, and reconcile missed revisions (or reload a snapshot) before clearing degraded status.
```

Does this decision doc (and the updated HLD) look good to approve so we can start Phase 2 with `change-store`?