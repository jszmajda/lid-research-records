`docs/decisions/change-delivery.md` is written and linked from `docs/high-level-design.md` (`## Key Design Decisions`). Here is the full decision doc for review:

````markdown
---
node: high-level-design
---

# Decision: Change Delivery to Connected Browsers

## Context

This decision builds on MarketBoard's HTTPS command model (`docs/high-level-design.md` § Key Design Decisions): editors submit commands over HTTPS, and the server commits each accepted edit at the next ordered event revision on a single authoritative board per event. Once an edit commits, MarketBoard must deliver that revision to connected staff browsers and bring temporarily disconnected browsers back up to date.

MarketBoard serves 40 weekend markets, about 120 coordinators, and up to 800 simultaneous staff browsers. A busy market has 10–25 active editors averaging two status changes per minute, with opening-time bursts of up to 20 edits per second as stall closures, late arrivals, and power issues arrive together. Staff frequently view boards over outdoor Wi-Fi and mobile networks, so browsers must recover cleanly after disconnects of up to 20 minutes while sustaining 99.5 percent availability during published event hours in a single-region pilot.

Three delivery models—five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service—all satisfy the 15-second freshness ceiling, preserve server-assigned event revisions, and comply with MarketBoard's data boundary (updates contain stall IDs and operational statuses rather than customer records, so both self-hosted and managed infrastructure are permitted). Because no binary constraint eliminates any of the three contenders—and because five-second polling already clears the 15-second freshness goal with stateless servers—the choice turns on how MarketBoard weighs subsecond push responsiveness, vendor coupling, revision continuity, and connection operations across `change-store`, `delivery`, and `browser-sync`.

## Decision Elements

All three options pass MarketBoard's hard architectural boundaries, so selection is driven by five weighted criteria:

- **Low-latency push and idle-read efficiency** (**major**) — How quickly committed revisions reach browsers during active triage (including 20-edit-per-second opening bursts) and how much unproductive read traffic 800 connected browsers generate during quiet periods averaging two edits per minute.
- **Vendor independence and predictable operating cost** (**major**) — Whether board synchronization uses standard web protocols and portable components rather than coupling `delivery` and `browser-sync` to a third-party realtime SDK, external availability domain, and peak-connection or per-message vendor pricing. *(While the tenet "Self-hosted and managed infrastructure are both permitted" leaves third-party services eligible, coupling the core board-delivery protocol to a realtime vendor remains a major architectural and cost consideration.)*
- **Authoritative revision continuity and disconnect visibility** (**major**; derives from the tenets *A committed edit has one authoritative event revision regardless of its delivery route* and *Connectivity failures must be visible, not mistaken for an unchanged board*) — How directly the architecture preserves one gapless revision sequence across live delivery and 20-minute disconnects, and how reliably browsers surface lost connectivity rather than displaying a frozen board.
- **Stateless operational and deployment simplicity** (**moderate**) — How little connection-capacity management, rolling-deploy connection draining, reconnect-storm mitigation, and cross-instance fan-out work are needed to maintain 99.5 percent availability during published weekend event hours for up to 800 single-region browsers.
- **Server-controlled subscription revocation** (**minor**; derives from the tenet *Commands use server-side authorization; browser state is not evidence of permission*) — How directly server-side session expiry and event-assignment revocations cut off active board update streams without waiting on external token lifetimes.

## Options in the Domain

### Five-Second HTTPS Polling

**Description**: Browsers load an initial board snapshot at revision `R` and run a five-second HTTPS timer requesting committed revisions after their highest applied revision. `delivery` stays a stateless request/response handler backed by an indexed `(event_id, revision)` range query in `change-store`. Steady-state updates and reconnect catch-up up to 20 minutes share the same cursor endpoint; if a cursor falls outside the replay window, the server instructs the browser to load a fresh snapshot.

**Demonstration**:

```text
GET /events/{eventId}/revisions?after=142
-> 200 OK { "revisions": [143, 144], "headRevision": 144 }
```

**Analysis**:

- **Low-latency push and idle-read efficiency**: **Weak fit** — Adds ~2.5 seconds of average lag (up to 5 seconds plus request round-trip time) on every edit, and 800 open browsers issue roughly 160 HTTPS read requests per second continuously even when boards average two edits per minute.
- **Vendor independence and predictable operating cost**: **Strong fit** — Uses standard HTTPS endpoints and database reads with no third-party realtime SDK, external credential exchange, or per-connection vendor billing.
- **Authoritative revision continuity and disconnect visibility**: **Strong fit** — Reads directly from committed revision storage through a single cursor path for both live polling and 20-minute recovery without a separate push channel to reconcile; failed or timed-out polls surface connectivity loss within one poll-and-timeout cycle.
- **Stateless operational and deployment simplicity**: **Strong fit** — Holds no long-lived per-browser server state, allowing ordinary load balancing, horizontal scaling, and rolling deployments during event hours without connection draining or reconnect storms.
- **Server-controlled subscription revocation**: **Strong fit** — Checks session validity and current event assignment against server state on every five-second poll request.

**Summary**: Minimizes server state and recovery complexity while meeting the 15-second ceiling, at the cost of multi-second update lag and continuous idle read load.

### Self-Hosted WebSockets

**Description**: Browsers authenticate a WebSocket session directly with MarketBoard's `delivery` service, subscribing to an event from their last known revision `R`. `change-store` persists ordered event revisions and reliably publishes committed revisions (for example, via a transactional outbox or ordered commit log tail) to `delivery`. `delivery` replays any committed revisions after `R` before transitioning the session into live fan-out, runs bidirectional heartbeats to detect silent network drops, and coordinates cross-instance fan-out when multiple delivery nodes run. On disconnect, `browser-sync` marks connectivity degraded immediately, reconnects with jittered backoff, and resumes from its highest applied revision.

**Demonstration**:

```text
WS /events/{eventId}/stream?after=142
<- { "type": "replay", "revisions": [143, 144] }
<- { "type": "live",   "revision": 145, "stallId": "B-12", "status": "power_issue" }
```

**Analysis**:

- **Low-latency push and idle-read efficiency**: **Strong fit** — Pushes committed revisions over open sockets in subsecond time during 20-edit-per-second bursts while eliminating repetitive empty reads during quiet stretches.
- **Vendor independence and predictable operating cost**: **Strong fit** — Relies on the browser's built-in `WebSocket` API and MarketBoard-operated servers, avoiding third-party realtime SDK coupling, external provider outages, and recurring peak-concurrency fees.
- **Authoritative revision continuity and disconnect visibility**: **Partial fit** — Keeps revision numbering, replay, and socket liveness end-to-end inside MarketBoard's boundary, but requires reliable store-to-delivery publication, explicit heartbeat timeouts for half-open mobile connections, and deduplicated handoff between replayed history and live frames.
- **Stateless operational and deployment simplicity**: **Weak fit** — Requires `delivery` to manage up to 800 concurrent stateful sockets, coordinate pub/sub across server instances, drain connections gracefully during weekend deploys, and absorb synchronized reconnect bursts.
- **Server-controlled subscription revocation**: **Strong fit** — Keeps socket sessions on MarketBoard servers so session expiry or assignment revocation can terminate active streams directly.

**Summary**: Delivers subsecond updates without third-party realtime coupling or idle poll traffic, in exchange for owning stateful socket capacity, heartbeats, and replay handoff.

### Hosted Realtime Service

**Description**: MarketBoard delegates persistent browser connections and fan-out to a managed realtime provider. Browsers obtain short-lived signed channel tokens from `delivery` and subscribe through the provider's client SDK. When `change-store` commits a revision, an outbox publisher pushes the revision payload to the provider's publish API. Because provider channel history is bounded and separate from MarketBoard's authoritative revision log, browsers reconnecting after longer drops reconcile missed revisions against a MarketBoard HTTPS catch-up or snapshot endpoint.

**Demonstration**:

```text
POST /events/{eventId}/realtime-token -> { "token": "...", "channel": "event:42" }
ChangeStore outbox -> Provider.publish("event:42", { "revision": 145, ... }) -> Browser SDK
```

**Analysis**:

- **Low-latency push and idle-read efficiency**: **Strong fit** — Delivers subsecond push updates to 800 simultaneous browsers without steady-state polling load on MarketBoard servers.
- **Vendor independence and predictable operating cost**: **Weak fit** — Couples `delivery` and `browser-sync` to a proprietary SDK, token model, external weekend availability, and recurring connection/message billing tiers shaped by weekend concurrency peaks.
- **Authoritative revision continuity and disconnect visibility**: **Weak fit** — Splits commit authority (`change-store`) from message transport (the external provider), requiring outbox reconciliation for failed publishes plus a second MarketBoard-hosted catch-up path to guarantee gapless recovery across 20-minute disconnects.
- **Stateless operational and deployment simplicity**: **Strong fit** — Offloads persistent socket fleets, TLS connection scaling, and deploy-time connection continuity to the provider while keeping MarketBoard's own servers stateless.
- **Server-controlled subscription revocation**: **Partial fit** — Relies on short-lived provider tokens for channel access, so revoking an active viewer mid-session either waits for token expiration or requires provider-specific revocation calls.

**Summary**: Offloads socket fleet operations while keeping subsecond push, at the cost of recurring vendor fees, SDK lock-in, and split commit-versus-publish reconciliation.

## Selection

MarketBoard selects **Self-Hosted WebSockets**.

Five-second HTTPS polling is the strongest stateless baseline—it meets the 15-second freshness goal and keeps revision continuity trivial—while a hosted realtime service removes socket fleet management. Self-hosted WebSockets win because MarketBoard prioritizes **low-latency push and idle-read efficiency** during active market coordination together with **vendor independence and predictable operating cost**, and keeps **authoritative revision continuity** inside a single system boundary rather than reconciling commits against an external broker. The weak fit on **stateless operational and deployment simplicity** is deliberately accepted because pilot scale is bounded: 800 simultaneous browsers in a single region during scheduled weekend event hours is modest enough to operate directly without paying ongoing vendor concurrency costs or enduring continuous polling load.

This choice turns on three HLD tenets while clarifying the fourth:

- *A committed edit has one authoritative event revision regardless of its delivery route*: keeping storage, replay, and live socket delivery under MarketBoard's control avoids cross-vendor split authority, provided store-to-delivery publication and replay-to-live handoff are gapless.
- *Connectivity failures must be visible, not mistaken for an unchanged board*: WebSockets cannot rely on passive TCP close alone over mobile networks, obligating explicit heartbeats and immediate degraded/disconnected indicators in the browser.
- *Commands use server-side authorization; browser state is not evidence of permission*: server-owned socket sessions allow MarketBoard to enforce session expiry and assignment changes on subscriptions without waiting on third-party token lifetimes.
- *Self-hosted and managed infrastructure are both permitted*: rejecting a hosted realtime service reflects a coupling and cost trade-off on the client synchronization protocol, not a prohibition on managed backing infrastructure elsewhere.

Committing to self-hosted WebSockets forecloses purely stateless `delivery` deployments and obligates three coordinated downstream designs:

- **`change-store`**: Persist ordered, replayable event revisions retained for seven days, serve efficient revision-range catch-up reads across 20-minute disconnects, and guarantee reliable publication of every committed revision to `delivery`.
- **`delivery`**: Authenticate WebSocket subscriptions, enforce session expiry and revocations, maintain heartbeats and capacity for 800 concurrent sockets and 20-edit-per-second bursts, coordinate ordered replay-to-live handoff (and multi-instance fan-out if horizontally scaled), and drain connections cleanly during deploys.
- **`browser-sync`**: Manage WebSocket connection state, apply jittered reconnect backoff, catch up from the last applied revision without gaps or duplicate application (falling back to a full snapshot when required), and surface disconnected or reconnecting state immediately whenever liveness fails.
````

To wrap up Phase 1 before we move into Phase 2:

1. Do `docs/decisions/change-delivery.md` and `docs/high-level-design.md` look ready to approve, or would you like any adjustments to the criteria or trade-offs?
2. Should `## Tenets` stay as-is (treating vendor avoidance as local to this delivery decision while managed backing services remain fine), or would you like a general tie-breaker tenet added?
3. When we step into Phase 2, should I also update the stale *"still-open change-delivery approach"* phrasing in `docs/intent/access/access-design.md`, and which of `change-store`, `delivery`, or `browser-sync` would you like to draft first?