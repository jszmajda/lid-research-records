I've written `docs/decisions/change-delivery.md` and linked it from `docs/high-level-design.md § Key Design Decisions`. Here is the decision doc in full for review:

```markdown
---
node: high-level-design
---

# Decision: Board Change Delivery

## Context

MarketBoard keeps one authoritative board per event, with edit commands submitted over HTTPS and assigned ordered event revisions on the server (see `docs/high-level-design.md § Key Design Decisions`). Once an edit commits, connected staff browsers must learn about the new revision and disconnected browsers must recover missed changes when they return.

Across 40 weekend markets, about 120 coordinators maintain boards viewed by up to 800 simultaneous staff browsers. A busy market has 10–25 active editors averaging two status changes per minute, with opening-time bursts up to 20 edits per second. The system must surface committed changes within 15 seconds under normal connectivity, recover the latest board after disconnects up to 20 minutes, retain seven days of revisions for operational investigation, and hold 99.5 percent availability during published event hours.

All three viable delivery models—periodic HTTPS polling, self-hosted WebSockets, and a hosted realtime service—satisfy the 15-second freshness bound, preserve server-assigned revision authority, and comply with MarketBoard's infrastructure boundary (updates carry stall IDs and operational statuses rather than customer records, so both self-hosted and managed services are permitted). What is at stake is where complexity and coupling land across three components: `change-store` (cursor queries vs. replayable revisions with reliable publication vs. vendor publication reconciliation), `delivery` (stateless responses vs. stateful socket sessions vs. provider credentials and wrappers), and `browser-sync` (polling timers vs. socket lifecycle and catch-up vs. vendor SDK subscriptions).

## Decision Elements

- **Vendor independence and recurring cost** (**major**) — Avoids coupling `delivery` and `browser-sync` subscription protocols, credentials, and event-hour availability to a third-party realtime provider, and avoids recurring per-connection or per-message vendor billing across 800 simultaneous browsers. While the tenet *Self-hosted and managed infrastructure are both permitted* allows managed infrastructure on data-sensitivity grounds, binding core board delivery to a provider's subscription model creates cross-component switching cost.
- **Update propagation latency** (**major**) — Delivers committed stall closures, power problems, and late arrivals to connected browsers with subsecond-to-low-second latency during active coordination and 20-edit/second opening bursts, reducing the window in which coordinators act on stale board state even though the outer goal permits up to 15 seconds.
- **Connection and deploy operational simplicity** (**major**) — Minimizes stateful connection capacity planning, rolling-deploy connection-drain herds during 99.5%-availability event hours, cross-instance fan-out plumbing, and transport sensitivity on spotty outdoor market mobile networks.
- **Authoritative revision continuity and recovery simplicity** (**moderate**) — Derives from the tenet *A committed edit has one authoritative event revision regardless of its delivery route*. Measures how directly `change-store`, `delivery`, and `browser-sync` preserve gap-free, ordered revision state across both steady-state updates and catch-up after disconnects up to 20 minutes, without losing committed edits between storage and fan-out.
- **Connectivity-failure visibility** (**moderate**) — Derives from the tenet *Connectivity failures must be visible, not mistaken for an unchanged board*. Measures how reliably a quiet board (averaging two edits per minute, with multi-minute idle stretches) distinguishes an intact end-to-end path from a dropped or stalled connection.
- **Idle traffic and read-path efficiency** (**minor**) — Avoids continuous read traffic and request overhead from 800 browsers when event boards have no new edits.

## Options in the Domain

### Five-Second HTTPS Polling

Browsers run a periodic five-second timer that sends an authenticated `GET` request carrying the event ID and the highest event revision already applied (`since_revision`). `delivery` stays a stateless request/response handler backed by an indexed revision-range query (or short-lived in-memory revision cache) in `change-store`. Initial load, steady-state updates, and recovery from disconnects up to 20 minutes all execute the same cursor request path; if a browser falls behind a compaction boundary or loads fresh, the response supplies a current board snapshot with its authoritative revision.

```text
Browser ── GET /events/{id}/changes?since=42 (every 5s) ──► Delivery ──► Change Store
        ◄── 200 { headRevision: 44, changes: [43, 44] } ──┘
```

- **Vendor independence and recurring cost**: **strong** — Uses standard HTTPS handlers and MarketBoard's own store with no third-party realtime SDK, external credentials, or per-connection fees.
- **Update propagation latency**: **weak** — Introduces an average 2.5-second and worst-case 5-second timer wait plus HTTP round-trip latency before a committed edit appears, meeting the 15-second goal but lagging during active bursts.
- **Connection and deploy operational simplicity**: **strong** — Stateless requests survive rolling server deploys without connection draining or reconnect storms and tolerate transient cellular drops and restrictive proxies without session teardown.
- **Authoritative revision continuity and recovery simplicity**: **strong** — Steady-state delivery and 20-minute disconnect catch-up share a single cursor query directly against `change-store`, requiring neither a separate publication channel nor stream-to-snapshot splice logic.
- **Connectivity-failure visibility**: **strong** — Every five-second poll actively verifies end-to-end reachability to the origin even when no edits occur; failed or timed-out requests surface connectivity loss within seconds without separate heartbeat frames.
- **Idle traffic and read-path efficiency**: **weak** — 800 simultaneous browsers generate roughly 160 requests per second (~9,600 per minute) even when all 40 boards are idle, though small board state makes this cacheable.

**Summary**: Trades multi-second update lag and continuous polling requests for stateless operations and a single cursor-based recovery path.

### Self-Hosted WebSockets

Browsers establish an authenticated WebSocket session to `delivery` scoped to an event. When a command commits in `change-store`, the store persists the ordered event revision and reliably publishes it to `delivery`, which pushes the revision frame to subscribed sessions for that event. `delivery` owns connection capacity, per-event session registries, subscription credentials, and application-level heartbeats; `browser-sync` tracks the local head revision, surfaces socket and heartbeat failures, reconnects with backoff after drops, and runs revision catch-up from `change-store` (or snapshot fallback) to bridge any gap between its last applied revision and the live stream.

```text
Command ──► Change Store (commit rev 43 + publish) ──► Delivery ── WS push rev 43 ──► Browsers
Reconnect: Browser (at rev 40) ── connect / catch-up since 40 ──► Delivery / Change Store
```

- **Vendor independence and recurring cost**: **strong** — Runs on standard WebSocket infrastructure under MarketBoard's control with no realtime vendor lock-in or per-connection/per-message vendor billing.
- **Update propagation latency**: **strong** — Pushes committed revisions over open sockets immediately upon publication, delivering subsecond updates under normal connectivity even during 20-edit/second opening bursts.
- **Connection and deploy operational simplicity**: **weak** — MarketBoard owns stateful capacity for 800 concurrent sockets, graceful connection draining and reconnect-herd smoothing during event-hour deploys, heartbeat tuning on flaky mobile networks, and cross-instance pub/sub fan-out whenever `delivery` runs more than one server instance.
- **Authoritative revision continuity and recovery simplicity**: **partial** — Keeps commit and delivery inside MarketBoard's server boundary, but requires reliable store-to-delivery publication (so committed revisions cannot vanish silently after commit) and deterministic deduplication/gap bridging in `browser-sync` when transitioning from catch-up replay to live frames.
- **Connectivity-failure visibility**: **partial** — Clean socket closes surface immediately, but half-open connections on quiet boards look identical to an unchanged board unless `delivery` and `browser-sync` enforce periodic ping/pong heartbeats and client staleness timeouts.
- **Idle traffic and read-path efficiency**: **strong** — Steady-state work scales with committed edits, lightweight heartbeats, and reconnects rather than continuous full-fleet read polling.

**Summary**: Delivers immediate updates without external vendor coupling or fees in exchange for owning stateful socket operations, heartbeats, reliable internal publication, and client catch-up coordination.

### Hosted Realtime Service

MarketBoard delegates live fan-out and long-lived browser connections to a managed realtime provider. `delivery` mints short-lived, event-scoped provider subscription tokens and publishes committed revisions from `change-store` to the provider's API; `browser-sync` embeds the provider's client SDK to subscribe to event channels and receive updates. Because commit in `change-store` and publication to the external provider cross a network and vendor boundary, `change-store` and `delivery` maintain an outbox and reconciliation loop, and reconnecting browsers still reconcile against authoritative revisions when provider history windows or transient publish delays occur.

```text
Command ──► Change Store (commit + outbox) ──► Delivery ── HTTPS publish ──► Realtime Vendor ──► Browser SDK
```

- **Vendor independence and recurring cost**: **weak** — Incurs ongoing connection and message fees across 800 browsers and couples `delivery` token issuance, `browser-sync` subscriptions, and event-hour availability to a vendor's API and operational SLA.
- **Update propagation latency**: **strong** — Pushes published revisions over the provider's persistent connections in well under a second once the outbox worker forwards the commit.
- **Connection and deploy operational simplicity**: **partial** — Offloads socket termination, keepalives, and fan-out scaling from MarketBoard servers (allowing stateless origin deploys), while leaving MarketBoard to operate provider credentials, outbox retries, and vendor-outage diagnostics.
- **Authoritative revision continuity and recovery simplicity**: **weak** — Splits commit and delivery across two independent systems, requiring transactional outbox persistence, idempotent publication reconciliation, and authoritative catch-up fallback whenever provider replay retention is shorter than MarketBoard's 20-minute recovery window.
- **Connectivity-failure visibility**: **partial** — The provider SDK detects browser-to-vendor disconnects via built-in heartbeats, but a healthy vendor socket does not prove MarketBoard's outbox publisher is healthy without additional end-to-end staleness signaling.
- **Idle traffic and read-path efficiency**: **strong** — Origin servers handle writes, token minting, and reconnect catch-up while the provider absorbs idle connection maintenance and message fan-out.

**Summary**: Offloads socket-holding infrastructure for fast updates, at the cost of recurring vendor fees, provider coupling across `delivery` and `browser-sync`, and cross-system publication reconciliation.

## Selection

MarketBoard selects **Self-Hosted WebSockets**.

The decision turns on accepting a **weak** fit on **Connection and deploy operational simplicity** (**major**) in order to secure **strong** fits on the other two **major** criteria—**Vendor independence and recurring cost** and **Update propagation latency**—while keeping authoritative revision handling inside MarketBoard's own boundary. Although the tenet *Self-hosted and managed infrastructure are both permitted* leaves a hosted realtime service eligible on data-classification grounds, coupling three components to a realtime vendor's SDK, token model, and recurring connection pricing is rejected when 800 concurrent sockets and 20-edit/second peaks fit comfortably within self-hosted capacity. Conversely, although **Five-Second HTTPS Polling** dominates on operational and recovery simplicity and still meets the 15-second freshness bound, subsecond push during busy opening-time coordination is worth owning stateful socket plumbing.

To uphold the project's tenets where self-hosted WebSockets score **partial**, committing to this option forecloses a stateless-only `delivery` tier and obligates the three downstream nodes as follows:

- **Change store (`change-store`)** — Must persist ordered, replayable event revisions covering both 20-minute browser catch-up and seven-day operational retention, and must pair commits with reliable publication to `delivery` so no committed revision is silently missed on live streams (*A committed edit has one authoritative event revision regardless of its delivery route*).
- **Delivery (`delivery`)** — Must manage authenticated per-event WebSocket sessions for up to 800 simultaneous browsers, issue/validate subscription credentials, send periodic liveness heartbeats, and drain connections predictably during deploys so event-hour availability stays at or above 99.5 percent.
- **Browser sync (`browser-sync`)** — Must maintain the WebSocket lifecycle, enforce heartbeat/staleness timeouts so silent half-open drops surface visibly (*Connectivity failures must be visible, not mistaken for an unchanged board*), reconnect with jittered backoff to avoid reconnect herds, and bridge revision gaps cleanly between catch-up replay and live socket frames.
```

Please review `docs/high-level-design.md` and `docs/decisions/change-delivery.md` for Phase 1 approval:

1. Any edits to the HLD or the decision doc (including whether you want to add a vendor-independence tenet or leave `## Tenets` and `## Goals` as-is)?
2. Once approved, which node should we draft first in Phase 2 (`change-store`, `delivery`, or `browser-sync`), and should we also clean up the `"still-open change-delivery approach"` wording in `docs/intent/access/access-design.md`?