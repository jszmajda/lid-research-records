I have written `docs/decisions/change-delivery.md` and linked it from `Key Design Decisions` in `docs/high-level-design.md`.

### `docs/decisions/change-delivery.md`

````markdown
---
node: high-level-design
---

# Decision: Change Delivery Approach

## Context

This decision builds on MarketBoard's authoritative command model (`docs/high-level-design.md`): editors submit commands over HTTPS, and the server assigns each committed edit a single authoritative event revision.

Forty weekend markets rely on MarketBoard to coordinate stall closures, late arrivals, and power problems across roughly 120 coordinators and up to 800 simultaneous staff browsers. A busy market has 10–25 editors averaging two status changes per minute, with opening-time bursts of up to 20 edits per second. During published event hours, the system targets 99.5 percent availability, committed changes visible in connected browsers within 15 seconds under normal connectivity, full board recovery after up to 20 minutes disconnected, and seven-day revision retention.

All three viable delivery approaches—five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service—satisfy the 15-second freshness bound and 20-minute disconnect recovery goal. Under the HLD tenet *Self-hosted and managed infrastructure are both permitted*, event updates carry stall IDs and operational statuses rather than customer records, so neither self-hosted nor third-party infrastructure is ruled out on data-governance grounds.

Selecting the delivery approach determines the architecture of three downstream components together—`change-store`, `delivery`, and `browser-sync`—and fixes MarketBoard's trade between live responsiveness, vendor coupling, and connection operations.

## Decision Elements

No binary gates apply: every option in contention respects the single-revision HTTPS command boundary, clears the 15-second freshness ceiling, recovers across 20-minute disconnects, and is permitted under the HLD's infrastructure tenet. Selection turns on five weighted criteria:

- **Vendor independence and predictable operating cost (major)** — Freedom from coupling `delivery` and `browser-sync` to a proprietary realtime provider's SDK, subscription model, and external credentials, and from recurring per-connection or per-message fan-out fees across 40 weekend markets and up to 800 concurrent browsers.
- **Low-latency update propagation (major)** — How quickly committed revisions reach connected browsers during routine coordination and 20-edit-per-second opening-time bursts, beyond clearing the 15-second freshness ceiling.
- **Connection and reconnect operational simplicity (moderate)** — The engineering and operational work required to manage client transport, idle-timeout heartbeats across market Wi-Fi and cellular networks, reconnect backoff, and 20-minute catch-up transitions.
- **Deploy, failover, and multi-instance resilience during event hours (moderate)** — How easily the service maintains 99.5 percent event-hours availability across rolling deploys, process restarts, and horizontal scaling without dropping active browsers into simultaneous reconnect storms or requiring cross-instance fan-out.
- **End-to-end failure visibility and single-authority consistency (moderate)** — How directly the delivery path preserves authoritative revision ordering and detects broken delivery rather than displaying an apparently healthy but stale board. Derives from two HLD tenets: *A committed edit has one authoritative event revision regardless of its delivery route* and *Connectivity failures must be visible, not mistaken for an unchanged board*.

## Options in the Domain

### Five-Second HTTPS Polling

Browsers load an initial board snapshot with its current event revision, then send stateless `GET` requests every five seconds passing their last applied revision cursor. `change-store` indexes revisions by `(event_id, revision)` for cursor range reads; `delivery` serves stateless HTTP responses containing any newer revisions (or a full snapshot if the cursor predates the replay window); `browser-sync` runs a periodic polling timer, advances its local revision cursor, and marks connectivity degraded when polls fail or time out.

Demonstration:

```text
GET /events/evt_12/changes?since=142
-> 200 OK { "revisions": [143, 144], "headRevision": 144 }
```

Analysis:

- **Vendor independence and predictable operating cost**: **strong** — Uses standard HTTPS endpoints on MarketBoard's own servers with no third-party realtime provider, proprietary SDK, external credentials, or message/connection billing.
- **Low-latency update propagation**: **weak** — Adds an average 2.5-second polling delay plus HTTP round-trip latency (up to five-plus seconds between ticks), grouping rapid opening-time edits into periodic batch updates rather than immediate push.
- **Connection and reconnect operational simplicity**: **strong** — Servers hold no per-browser connection state, and recovering from a brief drop or a 20-minute disconnect uses the exact same cursor query as steady-state operation, at the cost of roughly 160 read requests per second at 800 concurrent browsers even when no edits occur.
- **Deploy, failover, and multi-instance resilience during event hours**: **strong** — Stateless HTTP handlers run behind any standard load balancer, and rolling deploys or instance restarts complete between poll intervals without dropping sessions or triggering reconnect bursts.
- **End-to-end failure visibility and single-authority consistency**: **strong** — Every poll reads committed revisions directly from MarketBoard's authoritative store with no secondary publication hop, and failed or timed-out polls surface lost reachability within one poll cycle.

Summary: Simplest stateless operation and zero-disruption deploys, traded against multi-second update lag and continuous baseline read traffic across idle boards.

### Self-Hosted WebSockets

Browsers establish an event-scoped WebSocket connection directly to MarketBoard's `delivery` service. `change-store` persists replayable event revisions and reliably publishes committed revisions (via a committed-revision tail or outbox) to `delivery`; `delivery` validates subscription credentials, maintains open WebSocket sessions, runs periodic heartbeats, and pushes new revisions immediately to subscribed browsers; `browser-sync` manages the socket lifecycle, surfaces connectivity loss on close or missed heartbeats, reconnects with jittered backoff, and replays missed revisions from its last applied cursor before resuming live frames.

Demonstration:

```text
WS /events/evt_12/stream?since=142
<- { "type": "replay", "revisions": [143, 144] }
<- { "type": "revision", "revision": 145, "stallId": "B-14", "status": "power_issue" }
<-> periodic ping / pong frames
```

Analysis:

- **Vendor independence and predictable operating cost**: **strong** — Runs over standard WebSockets on MarketBoard's own infrastructure with no realtime vendor dependency, proprietary client protocol, or per-connection/message fees.
- **Low-latency update propagation**: **strong** — Pushes committed revisions over open connections immediately upon publication, delivering subsecond updates during both quiet periods and 20-edit-per-second opening bursts without idle read polling.
- **Connection and reconnect operational simplicity**: **weak** — MarketBoard owns stateful session tracking for up to 800 concurrent browsers, heartbeat tuning across NATs and spotty venue cellular/Wi-Fi networks, jittered client reconnect backoff, and gap-free handoff between stored revision replay and live socket frames.
- **Deploy, failover, and multi-instance resilience during event hours**: **weak** — Recycling or losing a `delivery` instance drops its open sockets, requiring graceful connection draining and jittered reconnects to avoid 800-browser catch-up spikes, plus cross-instance fan-out whenever multiple `delivery` instances run for 99.5 percent event-hours availability.
- **End-to-end failure visibility and single-authority consistency**: **partial** — Socket liveness and heartbeats directly reflect reachability of MarketBoard rather than a third-party edge, surfacing transport drops quickly, while decoupling commit persistence from asynchronous socket push requires reliable internal publication and client revision-gap checks so no committed edit is silently missed.

Summary: Subsecond push updates and full independence from realtime vendors, traded against owning stateful socket capacity, deploy draining, and reconnect catch-up.

### Hosted Realtime Service

MarketBoard delegates persistent browser connections to a managed realtime provider. When an edit commits, `change-store` records the authoritative revision and queues an outbound publication record; `delivery` mints short-lived, event-scoped provider subscription tokens and publishes committed revisions to the provider's API with reconciliation retries; `browser-sync` uses the provider's client SDK to subscribe to the event channel, rely on managed reconnects and keepalives, and fetch missed revisions from MarketBoard when a disconnect or gap exceeds the provider's replay buffer.

Demonstration:

```text
POST /events/evt_12/subscription-token -> { "token": "..." }
Browser SDK subscribes channel "event:evt_12"
Server outbox publishes revision 145 -> Provider edge fans out to subscribers
```

Analysis:

- **Vendor independence and predictable operating cost**: **weak** — Couples `delivery` credential/publication logic and `browser-sync` subscriptions to a vendor SDK and API, and incurs recurring connection-minute and fan-out message charges (up to 16,000 outbound messages per second across 800 browsers during 20-edit-per-second opening bursts).
- **Low-latency update propagation**: **strong** — Pushes revisions over persistent vendor-managed edge connections with subsecond delivery once published upstream.
- **Connection and reconnect operational simplicity**: **strong** — Offloads socket termination, idle keepalives, network-transition handling, and transport fallbacks to the provider's edge and SDK, leaving MarketBoard to own token issuance and extended-disconnect catch-up.
- **Deploy, failover, and multi-instance resilience during event hours**: **strong** — Browsers remain connected to the provider's edge while MarketBoard servers deploy, restart, or scale horizontally behind stateless HTTP boundaries.
- **End-to-end failure visibility and single-authority consistency**: **weak** — Splits authority and connectivity across two systems: a browser can hold a healthy socket to the vendor edge while MarketBoard-to-vendor publication lags or fails, risking a silently stale board unless MarketBoard builds outbox reconciliation and end-to-end upstream liveness heartbeats.

Summary: Low-latency push without operating socket servers or deploy drains, traded against recurring vendor fees, SDK coupling, and split-boundary publication reconciliation.

## Selection

MarketBoard selects **Self-hosted WebSockets**.

Self-hosted WebSockets is the only option with **strong** fit on both **major** criteria—delivering subsecond push updates during busy opening-time coordination while keeping the board free of realtime vendor coupling and burst fan-out billing. Although five-second HTTPS polling scores **strong** across all three **moderate** operational criteria, its multi-second lag leaves coordinators looking at slightly behind-the-play state during rapid opening reassignments and generates continuous read polling across up to 800 browsers. A hosted realtime service matches WebSockets on latency and offloads socket and deploy management, but fails the **major** vendor-independence criterion and introduces a split failure boundary between MarketBoard's store and the vendor's edge. At MarketBoard's pilot scale—800 simultaneous browsers and peak bursts of 20 edits per second—owning WebSocket session capacity, deploy draining, and reconnect catch-up is a bounded engineering cost worth accepting.

Committing to self-hosted WebSockets forecloses purely stateless HTTP-only `delivery` servers and offloaded edge connection termination. Downstream, it obligates:

- **`change-store`**: sequential per-event revisions retained for seven days, indexed range reads to serve catch-up after disconnects of up to 20 minutes, and reliable publication of every committed revision so `delivery` never silently drops an update.
- **`delivery`**: self-hosted WebSocket session management for up to 800 concurrent browsers, event-scoped subscription credentials, periodic liveness heartbeats, graceful connection draining on deploy, and cross-instance revision fan-out when running multiple `delivery` instances for 99.5 percent event-hours availability.
- **`browser-sync`**: WebSocket connection management, immediate visual indication when heartbeats time out or sockets close, jittered reconnect backoff to prevent post-deploy catch-up storms, and ordered revision catch-up from the browser's last applied revision (with snapshot fallback if disconnected beyond the replay window).

This selection turns directly on two HLD tenets—*A committed edit has one authoritative event revision regardless of its delivery route* and *Connectivity failures must be visible, not mistaken for an unchanged board*—by keeping revision storage and socket termination inside one operational boundary while requiring reliable internal store-to-socket publication and heartbeat-driven disconnect UI. While *Self-hosted and managed infrastructure are both permitted* left hosted services eligible on data-classification grounds, avoiding external vendor coupling and recurring fan-out fees outweighed offloading socket operations.
````

And in `docs/high-level-design.md`, the `Key Design Decisions` entry now ends with `See [docs/decisions/change-delivery.md](decisions/change-delivery.md).`

---

Does this decision doc and the updated HLD look good to approve for Phase 1? Once you confirm (and let me know if I should also update the stale *"still-open change-delivery approach"* phrase in `docs/intent/access/access-design.md`), we can start Phase 2 with the first of the three nodes (`change-store`).