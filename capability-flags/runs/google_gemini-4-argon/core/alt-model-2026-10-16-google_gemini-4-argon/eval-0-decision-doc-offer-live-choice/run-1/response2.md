I've written the decision doc at `docs/decisions/change-delivery-transport.md` and linked it from `docs/high-level-design.md § Key Design Decisions`.

Here is `docs/decisions/change-delivery-transport.md` in full:

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Transport

## Context

MarketBoard keeps one authoritative board per event. Editors submit status-change commands over HTTPS (`docs/high-level-design.md § Key Design Decisions`), and up to 800 simultaneous staff browsers across 40 weekend markets display a revisioned view of the board. A busy market has 10–25 editors and averages two status changes per minute, with opening-time bursts reaching 20 edits per second.

Once the server commits an edit and assigns its authoritative event revision, the system must deliver that revision to connected browsers and allow browsers disconnecting for up to 20 minutes to recover the current board. The choice of delivery transport shapes three downstream subsystems together: how `change-store` indexes revisions and publishes commits, how `delivery` serves updates and manages sessions, and how `browser-sync` subscribes, detects connectivity loss, and catches up after a disconnect.

If this choice is wrong, MarketBoard either takes on unnecessary recurring vendor spend and third-party coupling on its critical live-board path, or incurs avoidable staleness and repeated read load during weekend market operations.

## Decision Elements

### Weighted Criteria

- **Update latency after commit (moderate)** — How quickly a committed revision reaches connected browsers. While the baseline goal is displaying committed changes within 15 seconds under normal connectivity, subsecond propagation prevents coordinators from acting on stale stall statuses during opening-time bursts of 20 edits per second.
- **Vendor independence and recurring cost control (major)** — Freedom from per-connection or per-message realtime vendor billing and proprietary subscription SDKs on the core board path. Derives from the tenet *Prefer self-hosted operational ownership over recurring vendor coupling when delivering low-latency updates* (while the tenet *Self-hosted and managed infrastructure are both permitted* leaves managed services passable rather than gate-eliminated).
- **Server connection and session operational simplicity (moderate)** — The operational burden of maintaining stateful socket capacity, heartbeats, load-balancer sticky/draining behavior, and reconnect storms across up to 800 concurrent browsers.
- **Disconnect visibility and catch-up determinism (moderate)** — How directly the transport lets the browser detect a lost connection and reconcile missed revisions against the single authoritative event revision log without mistaking a stalled transport for an unchanged board. Derives from the tenets *A committed edit has one authoritative event revision regardless of its delivery route* and *Connectivity failures must be visible, not mistaken for an unchanged board*.
- **Read-path efficiency under quiet and bursty traffic (minor)** — Avoiding redundant database or cache reads when boards are idle while handling 20-edit-per-second opening bursts without amplifying read load across 800 browsers.

## Options in the Domain

### Option 1: Five-Second HTTPS Polling

#### Description

Browsers run a periodic timer that issues an HTTPS `GET` request every five seconds with the event ID and the browser's last applied event revision (`?sinceRevision=N`). The delivery tier remains stateless request/response: it queries `change-store` for revisions greater than `N` (or returns a full snapshot if `N` is too old) and responds with the delta. No long-lived server connections or publication buses are maintained.

#### Demonstration

```text
GET /events/evt-42/changes?sinceRevision=108 HTTP/1.1
-> 200 OK { "currentRevision": 110, "changes": [rev 109, rev 110] }
```

#### Analysis

- **Update latency after commit (moderate): partial.** Meets the 15-second goal under normal connectivity, but introduces an average 2.5-second (up to 5-second plus RTT) lag on every edit even on healthy connections.
- **Vendor independence and recurring cost control (major): strong.** Uses standard stateless HTTPS endpoints with zero third-party realtime vendor fees or SDK coupling.
- **Server connection and session operational simplicity (moderate): strong.** Stateless request/response requires no connection-state tracking, WebSocket upgrade handling, or connection-draining coordination on deploy.
- **Disconnect visibility and catch-up determinism (moderate): partial.** Catch-up uses the same cursor query as normal operation, which is simple, but connectivity loss is only detected when a poll cycle times out or fails, delaying visible disconnect state by at least one polling interval.
- **Read-path efficiency under quiet and bursty traffic (minor): weak.** 800 simultaneous browsers polling every five seconds generate ~160 requests per second against the delivery and store tiers even when no edits are occurring.

#### Summary

Trades multi-second update lag and continuous idle read traffic for stateless server operation.

### Option 2: Self-Hosted WebSockets

#### Description

Browsers open a persistent WebSocket connection to MarketBoard's `delivery` service scoped to an event and starting from their known revision. When `change-store` commits an edit and assigns the authoritative event revision, it writes the revision to the replayable log and publishes it reliably to `delivery`, which broadcasts the revision frame to subscribed sessions for that event. Heartbeats detect dead connections; on reconnect, `browser-sync` requests missed revisions from its last contiguous revision (or loads a fresh snapshot if disconnected beyond the replay window).

#### Demonstration

```text
WS /events/evt-42/stream?sinceRevision=108
<- { "type": "revisions", "from": 109, "to": 110, "items": [...] }
<- { "type": "heartbeat", "serverTime": "2026-10-16T08:05:00Z" }
```

#### Analysis

- **Update latency after commit (moderate): strong.** Pushes committed revisions over open sockets immediately upon publication, achieving subsecond propagation during opening-time bursts.
- **Vendor independence and recurring cost control (major): strong.** Runs on self-hosted application infrastructure with no per-connection or per-message realtime vendor fees and no external provider coupling.
- **Server connection and session operational simplicity (moderate): weak.** Requires MarketBoard to own WebSocket session lifecycle, heartbeat timeouts, capacity for 800 concurrent connections, graceful deploy draining, and reconnect/catch-up coordination.
- **Disconnect visibility and catch-up determinism (moderate): strong.** Socket close events and missed heartbeats surface connectivity loss promptly, and replay queries against `change-store` reconcile the exact gap from the browser's last applied revision.
- **Read-path efficiency under quiet and bursty traffic (minor): strong.** Idle markets generate only lightweight heartbeats, and an opening-time burst of 20 edits per second is fanned out in memory to subscribed sockets rather than triggering hundreds of database cursor polls.

#### Summary

Delivers subsecond updates and efficient fan-out without vendor coupling, at the cost of owning connection management and reconnect replay in-house.

### Option 3: Hosted Realtime Service

#### Description

MarketBoard delegates live fan-out to a managed third-party realtime pub/sub provider. After `change-store` commits an event revision, `delivery` publishes the revision payload to the provider's API (using an outbox/reconciliation loop to handle provider API failures) and mints short-lived provider subscription tokens for authorized browsers. `browser-sync` embeds the provider's client SDK to subscribe to the event channel and receive live messages.

#### Demonstration

```text
POST /events/evt-42/subscription-token -> { "providerToken": "...", "channel": "evt-42" }
Browser SDK -> Provider Cloud (subscribe "evt-42")
Server -> Provider REST/Socket API (publish rev 109)
```

#### Analysis

- **Update latency after commit (moderate): strong.** Pushes updates to subscribed browsers in under a second once published to the provider.
- **Vendor independence and recurring cost control (major): weak.** Introduces recurring per-connection and per-message billing across 800 concurrent browsers and couples `delivery` and `browser-sync` to a proprietary subscription token flow and client SDK.
- **Server connection and session operational simplicity (moderate): partial.** Offloads holding 800 open socket connections from MarketBoard servers, but shifts operational work to provider credential management, outbox reconciliation when provider publishing fails after a local commit, and dual-path catch-up against `change-store`.
- **Disconnect visibility and catch-up determinism (moderate): partial.** Because the authoritative revision lives in MarketBoard's `change-store` rather than the provider's ephemeral channel buffer, `browser-sync` and `delivery` must reconcile provider connection state with `change-store` replay whenever a commit succeeds locally but lags or fails in provider publication.
- **Read-path efficiency under quiet and bursty traffic (minor): strong.** Fan-out is handled by the provider without idle polling against `change-store`.

#### Summary

Offloads socket connection hosting for low-latency fan-out, but adds recurring vendor cost, SDK coupling, and cross-system publication reconciliation.

## Selection

Choose **Option 2: Self-Hosted WebSockets**.

Self-hosted WebSockets give coordinators fast, subsecond updates during busy opening-time bursts without tying MarketBoard's core delivery path to a realtime vendor's recurring pricing or client SDK. It wins on **vendor independence and recurring cost control (major)** and **update latency after commit (moderate)** while keeping **disconnect visibility and catch-up determinism (moderate)** anchored directly to MarketBoard's single authoritative revision log. We explicitly accept the weaker score on **server connection and session operational simplicity (moderate)**: at MarketBoard's scale (up to 800 concurrent browsers, single-region pilot), operating WebSocket sessions, heartbeats, and replay catch-up is a bounded engineering cost we prefer to own rather than trading away latency (Option 1) or taking on vendor coupling and cross-system publication reconciliation (Option 3).

This decision turns on the tenets:
- *Prefer self-hosted operational ownership over recurring vendor coupling when delivering low-latency updates* — decisive in selecting Option 2 over Option 3 even though *Self-hosted and managed infrastructure are both permitted*.
- *A committed edit has one authoritative event revision regardless of its delivery route* — favors keeping live stream replay and snapshot recovery unified against `change-store` rather than split across an external pub/sub buffer.
- *Connectivity failures must be visible, not mistaken for an unchanged board* — favors explicit socket session heartbeats and immediate disconnect state transitions over polling intervals.

### Downstream Obligations

- **`change-store`** (`docs/intent/change-store/change-store-design.md`): Must assign contiguous per-event revisions, retain seven days of revision history, serve replay range queries from a caller's last seen revision (plus full board snapshots when a browser's revision precedes the 20-minute/replay window), and reliably publish newly committed revisions to `delivery` so no committed revision is silently dropped between commit and socket broadcast.
- **`delivery`** (`docs/intent/delivery/delivery-design.md`): Must authenticate and authorize WebSocket subscriptions per event, maintain active session registries for up to 800 simultaneous browsers, broadcast committed revisions in order, emit heartbeats to detect half-open connections, and support graceful connection draining.
- **`browser-sync`** (`docs/intent/browser-sync/browser-sync-design.md`): Must maintain the WebSocket subscription lifecycle, transition the UI into a visible disconnected state on socket close or missed heartbeat, reconnect with backoff, and reconcile missed revisions via replay catch-up (or full snapshot reload) before clearing the disconnected indicator.
```

Please let me know if you want any adjustments to `docs/decisions/change-delivery-transport.md` or `docs/high-level-design.md`, and whether you're ready to proceed to Phase 2 (starting with `change-store`, or whichever of the three nodes you prefer first).