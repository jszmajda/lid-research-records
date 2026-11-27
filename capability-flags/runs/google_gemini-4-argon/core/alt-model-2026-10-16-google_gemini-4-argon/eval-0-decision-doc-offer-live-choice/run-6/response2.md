I have written `docs/decisions/change-delivery.md` and linked it from `docs/high-level-design.md` under **Key Design Decisions**. Here is the decision doc in full:

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Mechanism

## Context

MarketBoard keeps one authoritative board per weekend market event. Up to 120 coordinators maintain boards viewed by up to 800 simultaneous staff browsers across 40 markets, with busy events seeing 10–25 active editors, an average of two status changes per minute, and opening-time bursts of up to 20 edits per second.

Editors submit commands over HTTPS (`docs/high-level-design.md` § Key Design Decisions), and the server assigns each committed edit a single authoritative event revision. The system must deliver those committed revisions to connected browsers within 15 seconds under normal connectivity, recover the latest board after a browser has been disconnected for up to 20 minutes, and surface connectivity failures visibly rather than letting a disconnected browser appear up to date.

The change-delivery mechanism sits at the boundary between three components—`change-store`, `delivery`, and `browser-sync`—and shapes what each component must own: how revisions are indexed and published in the store, whether the delivery tier is stateless or manages long-lived sessions, and how browsers subscribe, detect disconnects, and catch up after an outage.

## Decision Elements

### Weighted Criteria

- **Update latency during active coordination (major)** — How quickly a committed stall status change reaches connected staff browsers after the HTTPS command succeeds. All options meet the 15-second goal ceiling, but subsecond delivery prevents coordinators in the same market from acting on stale stall state during opening-time bursts.
- **Provider independence and recurring cost control (major)** — Whether core board delivery depends on an external realtime vendor's SDK, availability, and per-connection or per-message pricing across 40 weekend markets and up to 800 simultaneous browsers. Related tenet: *Self-hosted and managed infrastructure are both permitted.*
- **Server and client operational simplicity (major)** — The engineering and operational surface required to run delivery in production: stateful connection capacity, load-balancer session affinity or fan-out, reconnect storm handling, and publication reconciliation between the store and delivery tier.
- **Disconnect visibility and 20-minute catch-up fidelity (moderate)** — How directly the transport exposes connection loss to the browser and how cleanly a reconnecting browser reconciles missed revisions up to the 20-minute recovery window without violating the tenet *Connectivity failures must be visible, not mistaken for an unchanged board* or *A committed edit has one authoritative event revision regardless of its delivery route*.
- **Idle-period read efficiency (minor)** — Server and database load when boards are open in 800 browsers but edits are sparse (two changes per minute on average outside opening bursts).

## Options in the Domain

### Option 1: Five-Second HTTPS Polling

#### Description

Browsers run a periodic timer that issues an HTTPS `GET` request every five seconds passing the event ID and the browser's last applied event revision cursor (`sinceRevision`). The delivery tier is stateless request/response: it queries the change store for committed revisions newer than the cursor (or returns a full board snapshot if the cursor is too old) and responds with the delta and current revision number. No persistent connections or push channels exist.

#### Demonstration

`GET /events/{eventId}/changes?sinceRevision=1042` → `200 OK { "currentRevision": 1044, "changes": [...] }`

#### Analysis

- **Update latency during active coordination**: **weak** fit. Committed edits wait up to five seconds plus request RTT to appear on staff screens, which lags behind rapid multi-editor bursts at market opening.
- **Provider independence and recurring cost control**: **strong** fit. Uses standard HTTPS infrastructure with zero third-party realtime vendor dependency or per-message fees.
- **Server and client operational simplicity**: **strong** fit. The delivery tier is completely stateless; load balancing, deployments, and Horizontal scaling require no connection draining or session management.
- **Disconnect visibility and 20-minute catch-up fidelity**: **partial** fit. Catch-up after a disconnect uses the exact same `sinceRevision` query as normal operation, but connectivity loss is only detected when the next poll times out or fails rather than immediately upon transport drop.
- **Idle-period read efficiency**: **weak** fit. 800 connected browsers generate ~160 requests per second even when no stall statuses are changing, requiring read indexing or caching to absorb repeated empty cursor queries.

#### Summary

Maximizes operational simplicity and avoids vendor coupling at the cost of multi-second update lag and continuous baseline read traffic.

### Option 2: Self-Hosted WebSockets

#### Description

Browsers open a persistent WebSocket connection to MarketBoard's own `delivery` service, authenticating the session and subscribing to an event starting from their last known revision. When an HTTPS command commits in `change-store`, the store appends the revision to a replayable log and publishes it to `delivery`, which fans the revision out over active WebSocket sessions for that event. On disconnect, the browser immediately marks connectivity degraded, reconnects with backoff, and requests replay from its last applied revision (falling back to a full snapshot if disconnected beyond the replay window).

#### Demonstration

Browser sends `{"type": "subscribe", "eventId": "mkt-12", "sinceRevision": 1042}`; server replays revisions `1043..1044` and streams subsequent committed revisions as they occur.

#### Analysis

- **Update latency during active coordination**: **strong** fit. Committed revisions are pushed immediately upon publication, delivering subsecond updates during opening-time bursts.
- **Provider independence and recurring cost control**: **strong** fit. Runs on self-hosted compute with no external realtime provider SDK, credential management, or per-connection/per-message vendor billing.
- **Server and client operational simplicity**: **weak** fit. MarketBoard owns stateful WebSocket capacity for up to 800 concurrent connections, heartbeat/keepalive timeouts, rolling-deploy connection draining, and reconnect/catch-up coordination across `change-store`, `delivery`, and `browser-sync`.
- **Disconnect visibility and 20-minute catch-up fidelity**: **strong** fit. Socket closure and missed heartbeats surface connectivity loss promptly, and reconnecting with `sinceRevision` against the store's replayable revision log reconciles missed updates cleanly under the single authoritative revision stream.
- **Idle-period read efficiency**: **strong** fit. Quiet periods require only lightweight socket heartbeats; store reads happen only on commit and on reconnect replay.

#### Summary

Delivers subsecond updates and full vendor independence while shifting stateful connection management and reconnect/replay mechanics onto the MarketBoard team.

### Option 3: Hosted Realtime Service

#### Description

Browsers subscribe to event channels using a managed third-party realtime pub/sub provider (such as Pusher, Ably, or AWS IoT/AppSync). Editors still submit commands to MarketBoard over HTTPS. When `change-store` commits a revision, `delivery` publishes the revision payload to the hosted provider's API via a transactional outbox and reconciliation worker. The provider manages WebSocket termination, connection scaling, and fan-out to the 800 browsers.

#### Demonstration

`change-store` records revision `1045` + outbox entry → `delivery` publishes to `provider.channels.trigger("event-mkt-12", "revision", { rev: 1045, ... })`.

#### Analysis

- **Update latency during active coordination**: **strong** fit. Push delivery over the provider's managed sockets achieves subsecond fan-out once the outbox publishes.
- **Provider independence and recurring cost control**: **weak** fit. Couples `delivery` and `browser-sync` to a proprietary subscription model and incurs ongoing connection-minute and message-fan-out charges across 40 weekend markets.
- **Server and client operational simplicity**: **partial** fit. Offloads socket termination and 800-connection scaling to the vendor, but requires MarketBoard to operate a publication outbox, retry/reconciliation loop, and short-lived provider token issuance so committed store revisions and external channel state never diverge.
- **Disconnect visibility and 20-minute catch-up fidelity**: **partial** fit. The provider's client SDK handles socket state and brief history replay, but reconciling a 20-minute disconnect still requires falling back to MarketBoard's authoritative store if the provider's channel retention or ordering guarantees differ from MarketBoard's revision log.
- **Idle-period read efficiency**: **strong** fit. MarketBoard servers handle zero idle polling traffic; idle connections sit on the provider's infrastructure.

#### Summary

Offloads WebSocket connection scaling for fast updates, but introduces recurring vendor fees, provider coupling, and outbox reconciliation between the authoritative store and external channels.

## Selection

**Chosen: Option 2 — Self-Hosted WebSockets.**

Self-hosted WebSockets win because they deliver subsecond updates during high-activity opening windows (**Update latency**, major) without coupling MarketBoard's delivery and browser clients to a third-party realtime vendor or incurring per-connection/per-message fees (**Provider independence and recurring cost control**, major). While the tenet *Self-hosted and managed infrastructure are both permitted* allows a hosted service, Option 3 does not eliminate server-side complexity: because *A committed edit has one authoritative event revision regardless of its delivery route*, a hosted service still forces MarketBoard to build outbox reconciliation and snapshot fallback while adding vendor lock-in. Option 1 (Five-second HTTPS polling) wins on **Server and client operational simplicity** (major), but sacrifices subsecond responsiveness and generates continuous idle read load across 800 browsers.

We explicitly trade **Server and client operational simplicity** against **Update latency** and **Provider independence**: we accept owning connection capacity (800 concurrent sockets), heartbeats, and reconnect/catch-up coordination in order to get fast push updates on our own infrastructure.

### Downstream Obligations

- **`change-store` (`docs/intent/change-store/`)**: Must maintain a contiguous, replayable per-event revision log covering at least the 20-minute recovery window (and seven-day retention goal) and provide reliable publication notifications to `delivery` when a revision commits.
- **`delivery` (`docs/intent/delivery/`)**: Must manage authenticated WebSocket sessions for up to 800 concurrent browsers, track event subscriptions, fan out newly committed revisions, and serve revision replay (or trigger snapshot fallback) when a session subscribes with a prior revision cursor.
- **`browser-sync` (`docs/intent/browser-sync/`)**: Must maintain the WebSocket lifecycle, surface disconnect/reconnecting states immediately per the visibility tenet, and execute reconnect with `sinceRevision` catch-up so the board recovers cleanly after outages up to 20 minutes.
```

Does this HLD and decision doc capture what you want for Phase 1, and if approved, would you also like me to clean up the `"still-open change-delivery approach"` wording in `docs/intent/access/access-design.md` before we start Phase 2 on `change-store`, `delivery`, and `browser-sync`?