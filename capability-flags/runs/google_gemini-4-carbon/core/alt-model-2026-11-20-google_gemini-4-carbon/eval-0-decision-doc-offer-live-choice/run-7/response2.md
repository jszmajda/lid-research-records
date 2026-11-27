Wrote `docs/decisions/change-delivery.md` and linked it from `Key Design Decisions` in `docs/high-level-design.md`. Here is the decision doc in full for review:

```markdown
---
node: high-level-design
---

# Decision: Change Delivery to Browsers

## Context

MarketBoard keeps one authoritative board per event behind an HTTPS command boundary (`docs/high-level-design.md`, *Commands over HTTPS, one authoritative board per event*): editors submit commands over HTTPS, and the server assigns each committed edit a sequential event revision. Once an edit is committed, the system must deliver that revision to up to 800 simultaneous coordinator and staff browsers across active weekend markets, absorbing routine traffic of roughly two status changes per minute on a busy market and opening-time bursts of up to 20 edits per second.

The delivery mechanism cannot be chosen inside a single component because it couples the architecture of three sibling nodes:

- **Change store** (`change-store`) — whether storage optimizes for stateless cursor reads, a replayable revision log with reliable commit-to-delivery publication, or outbox reconciliation against an external provider.
- **Delivery** (`delivery`) — whether the server serves stateless HTTP responses, manages stateful long-lived socket sessions, or issues credentials and publishes to a third-party realtime service.
- **Browser sync** (`browser-sync`) — whether clients run a timer-driven fetch loop, maintain a socket state machine with revision catch-up, or embed a vendor subscription SDK.

Reversing this choice after implementation requires redesigning all three components together.

All three viable approaches satisfy the system's baseline constraints: each preserves a single authoritative event revision assigned at commit time, meets the 15-second freshness goal under normal connectivity, supports recovery after up to 20 minutes disconnected within the seven-day revision retention window, and is permitted under the infrastructure tenet (*Self-hosted and managed infrastructure are both permitted. Event updates contain stall IDs and operational statuses, not customer records*). Because no hard constraint eliminates an option up front, selection turns on how the options trade latency, operational complexity, connectivity fidelity, and vendor coupling.

## Decision Elements

No binary gate eliminates any option in contention; all elements driving selection are weighted criteria:

- **Vendor independence and predictable operating cost (major)** — Avoids coupling `delivery` and `browser-sync` to a proprietary realtime provider's SDK, subscription model, credential flow, and per-connection or per-message pricing across 800-browser weekend peaks. Although the infrastructure tenet permits managed services (*Self-hosted and managed infrastructure are both permitted*), keeping core board delivery independent of a realtime vendor avoids recurring peak-concurrency fees and provider lock-in.
- **Update immediacy during active coordination (major)** — Minimizes the delay between an editor committing a stall closure, late arrival, or power problem and connected browsers rendering the new revision, especially during 20-edit-per-second opening bursts when coordinators are triaging the market floor in real time.
- **Server-side connection and deployment operations (major)** — Minimizes stateful session management, memory and file-descriptor capacity planning for 800 concurrent connections, cross-instance fan-out coordination, and reconnect disruption during rolling deploys within published event hours (99.5 percent availability goal).
- **Connectivity visibility and single-authority delivery fidelity (moderate)** — Derives from *Connectivity failures must be visible, not mistaken for an unchanged board* and *A committed edit has one authoritative event revision regardless of its delivery route*. Favors mechanisms where transport failure is detected promptly in the browser and where live delivery and catch-up operate against the same authoritative store without a separate external broker whose health can diverge from commit health.
- **Tolerance of lossy field networks and HTTP intermediaries (minor)** — Handles mobile cellular handoffs, shared market Wi-Fi drops, NAT idle timeouts, and restrictive proxies common on outdoor weekend market grounds without brittle client failure modes.

## Options in the Domain

### Five-second HTTPS polling

**Description.** Browsers fetch board updates on a five-second timer over standard HTTPS `GET` requests carrying the event ID and the browser's last applied event revision (`?since=<revision>`). `delivery` executes stateless read requests against `change-store` cursor indexes and returns any newer revisions (or an empty response at head); cold loads and out-of-window recoveries request a full board snapshot. `change-store` requires only indexed revision-range queries over committed rows, with no push publication pipeline or outbox. `browser-sync` runs a timer loop with backoff on HTTP errors and marks the board disconnected when polls fail or time out.

**Analysis.**
- *Vendor independence and predictable operating cost*: **strong** — Uses plain HTTPS handlers on MarketBoard's own application servers with no external realtime vendor, SDK, or per-connection fees.
- *Update immediacy during active coordination*: **weak** — Introduces up to five seconds of polling lag (2.5 seconds average) plus HTTP round-trip latency on routine edits, and clumps opening-time bursts into five-second batches rather than streaming changes as they commit.
- *Server-side connection and deployment operations*: **strong** — `delivery` remains completely stateless; rolling deploys drain in-flight HTTP requests cleanly without severing subscriber sessions or triggering reconnect storms, at the cost of steady read load (~160 requests per second at 800 concurrent browsers).
- *Connectivity visibility and single-authority delivery fidelity*: **partial** — Every poll reads directly from the authoritative `change-store` revision sequence with no secondary broker to drift out of sync, but transport loss is noticed only after a poll interval and request timeout elapse.
- *Tolerance of lossy field networks and HTTP intermediaries*: **strong** — Short-lived HTTPS requests traverse restrictive proxies and cellular network switches cleanly; transient packet loss affects a single poll and self-heals on the next tick.

**Summary.** Lowest operational and protocol complexity, traded against multi-second update lag and continuous baseline read traffic.

### Self-hosted WebSockets

**Description.** Browsers open an authenticated WebSocket connection directly to MarketBoard's `delivery` service for their active event. When `change-store` commits a new event revision, a reliable publication path (such as a transactional outbox or store-backed notification stream paired with contiguous revision gap checks) delivers the committed revision to `delivery` instances, which fan it out over open event sockets. `delivery` owns socket authentication credentials, per-event session registries, bidirectional heartbeats, and bounded outbound buffers. On initial load or reconnect after a drop (up to the 20-minute recovery target), `browser-sync` presents its last applied revision and catches up via replayable revisions from `change-store` (or a snapshot when starting cold or beyond replay bounds) before resuming live stream application.

**Analysis.**
- *Vendor independence and predictable operating cost*: **strong** — Uses standard WebSocket protocols and open-source server libraries on self-managed or commodity compute, with zero per-connection or per-message vendor charges and no third-party SDK coupling.
- *Update immediacy during active coordination*: **strong** — Pushes committed revisions over established TLS/TCP connections immediately upon publication, delivering subsecond updates during both quiet periods and 20-edit-per-second opening bursts.
- *Server-side connection and deployment operations*: **weak** — `delivery` must manage up to 800 concurrent stateful sockets, heartbeat timers, slow-consumer backpressure, cross-instance fan-out if multiple `delivery` nodes run behind a load balancer, and graceful connection draining so deploys during event hours do not cause synchronized reconnect spikes.
- *Connectivity visibility and single-authority delivery fidelity*: **strong** — Socket close events and missed heartbeats let `browser-sync` flag broken connectivity promptly, while storage, live push, and reconnect replay remain inside one system boundary ordered strictly by `change-store` event revisions.
- *Tolerance of lossy field networks and HTTP intermediaries*: **partial** — Cellular handoffs, captive Wi-Fi blips, and intermediary idle timeouts drop long-lived sockets regularly on market grounds, requiring `browser-sync` to implement jittered reconnect backoff and gapless revision catch-up as routine execution paths rather than rare edge cases.

**Summary.** Subsecond updates and full vendor independence under one revision authority, traded against owning stateful socket capacity, deploy draining, and client reconnect engineering.

### Hosted realtime service

**Description.** MarketBoard delegates subscriber connection management and fan-out to a managed realtime pub/sub provider. `delivery` mints short-lived, event-scoped provider subscription tokens for authorized viewers and editors, and runs a publication worker that pushes committed revisions from a `change-store` outbox to the provider's event channels with retry and reconciliation. Browsers load an initial snapshot over HTTPS, connect to the provider via its client SDK, receive live revision messages on the event channel, and reconcile gaps against MarketBoard's HTTPS API if a sequence discontinuity or prolonged disconnect occurs.

**Analysis.**
- *Vendor independence and predictable operating cost*: **weak** — Couples `delivery` credential minting, outbox publishing, and `browser-sync` connection lifecycle to a vendor's proprietary SDK and API, while incurring recurring charges driven by peak weekend concurrency (up to 800 simultaneous connections) and burst fan-out message counts.
- *Update immediacy during active coordination*: **strong** — Delivers published revisions in subsecond latency over the provider's persistent edge connections.
- *Server-side connection and deployment operations*: **strong** — Offloads WebSocket termination, keepalives, horizontal connection scaling, and deploy-time session persistence to the vendor; MarketBoard's own servers stay stateless for subscriber connections and operate only the asynchronous outbox publisher.
- *Connectivity visibility and single-authority delivery fidelity*: **partial** — Vendor SDKs report client-to-vendor connection drops promptly, but splitting commit storage from an external message broker introduces a dual-system failure mode: a browser can hold a healthy socket to the vendor while MarketBoard's store-to-vendor publication is delayed or failing, silently stalling board updates unless MarketBoard builds independent staleness heartbeats.
- *Tolerance of lossy field networks and HTTP intermediaries*: **strong** — Commercial realtime SDKs include mature reconnect state machines and automatic HTTP streaming or long-polling fallbacks when networks block WebSocket upgrades.

**Summary.** Fast updates without operating stateful socket servers, traded against recurring vendor fees, SDK coupling, and cross-vendor publication reconciliation.

## Selection

MarketBoard selects **self-hosted WebSockets**.

Across the three major criteria, self-hosted WebSockets achieves **strong** fit on both *vendor independence and predictable operating cost* and *update immediacy during active coordination*, deliberately accepting **weak** fit on *server-side connection and deployment operations*. Five-second HTTPS polling avoids stateful server operations too, but sacrifices immediate floor coordination during opening-time bursts and generates constant read load across 800 browsers. A hosted realtime service matches WebSocket latency while offloading socket servers, but introduces ongoing peak-concurrency vendor costs, SDK lock-in across `delivery` and `browser-sync`, and a split availability boundary between MarketBoard's database and an external broker. At pilot scale (up to 800 concurrent connections and bursts of 20 edits per second in a single region), connection capacity fits comfortably on modest infrastructure; the real cost is engineering disciplined session management, deploy draining, and reconnect catch-up, which is a bounded one-time investment rather than a permanent vendor dependency.

In terms of project tenets:
- The choice turns positively on **A committed edit has one authoritative event revision regardless of its delivery route** and **Connectivity failures must be visible, not mistaken for an unchanged board**: keeping commit storage, live socket fan-out, and reconnect replay inside MarketBoard's own boundary ensures one revision sequence governs every path and avoids false "connected" indicators when an external publisher lags.
- The choice is made within, rather than compelled by, **Self-hosted and managed infrastructure are both permitted**: managed realtime infrastructure was eligible under project rules and rejected on cost and coupling grounds rather than data-sensitivity policy.

**What this forecloses:**
- Stateless-only `delivery` processes and zero-reconnect server restarts; rolling deploys during published event hours must drain connections gradually.
- Automatic HTTP long-polling fallback provided by a vendor SDK on networks that block WebSocket upgrades (if encountered in the field, fallback transport would have to be built explicitly).

**Downstream obligations on child design nodes:**
- **`change-store`**: Persist sequential per-event revisions, retain replayable revision history alongside board snapshots (covering both 20-minute browser disconnect recovery and seven-day operational retention), and guarantee reliable publication of every committed revision to `delivery` without silent drops.
- **`delivery`**: Issue and validate event-scoped WebSocket subscription credentials, manage up to 800 concurrent socket sessions with heartbeats and slow-client bounds during 20-edit-per-second bursts, serve revision replay on reconnect, and coordinate graceful connection draining across deploys to preserve 99.5 percent event-hour availability.
- **`browser-sync`**: Own the client WebSocket state machine, surface disconnected and catching-up states visibly so coordinators never mistake a stalled socket for a quiet board, reconnect with jittered backoff to prevent synchronized reconnect storms after network blips or server deploys, and reconcile missed revisions from the browser's last applied revision without gaps or duplicate effects.
```

Please let me know if `docs/high-level-design.md` and `docs/decisions/change-delivery.md` look ready to approve for Phase 1, and before I start Phase 2:

1. Should the vendor-coupling lean stay scoped to this delivery decision (leaving `Tenets` as-is), or should we add a project-level tie-breaker tenet for downstream choices in `change-store` and `delivery`?
2. Should I also update the stale "still-open change-delivery approach" wording in `docs/intent/access/access-design.md`, and which node (`change-store`, `delivery`, or `browser-sync`) would you like to tackle first?