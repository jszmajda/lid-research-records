`docs/decisions/change-delivery.md` is written and linked from the `Key Design Decisions` entry in `docs/high-level-design.md`. Here is the decision doc in full for review:

```markdown
---
node: high-level-design
---

# Decision: Committed Change Delivery

## Context

This decision builds on MarketBoard's core command model in `docs/high-level-design.md`: editors submit stall-status commands over HTTPS, and the server assigns each committed edit a single authoritative event revision.

Once an edit commits, MarketBoard must propagate that revision to up to 800 simultaneous staff browsers across 40 weekend markets, where a busy event has 10–25 active editors averaging two changes per minute with opening-time bursts of 20 edits per second. Every candidate delivery model must show committed changes within 15 seconds under normal connectivity, recover the latest board after browser disconnections of up to 20 minutes, retain seven days of revisions, and sustain 99.5 percent availability during published event hours. Because all three viable approaches meet those baseline targets — and because event updates carry stall IDs and operational statuses rather than customer records, leaving both self-hosted and managed infrastructure permitted — baseline freshness and infrastructure eligibility are background invariants rather than eliminating gates.

How committed revisions reach browsers shapes `change-store`, `delivery`, and `browser-sync` together. Reversing the choice later requires reworking persistence indexing and publication, server session handling, and browser recovery protocols simultaneously.

## Decision Elements

All three options in contention satisfy MarketBoard's baseline freshness, recovery, and infrastructure-policy boundaries, so selection turns on five weighted criteria:

- **Low-latency update delivery and idle-read efficiency (major)** — How quickly committed edits appear in connected browsers during both opening-time bursts (20 edits/second) and normal operation, and how much read load `change-store` absorbs during quiet stretches (~2 edits/minute per busy market across up to 800 open browsers).
- **Vendor independence and operating-cost predictability (major)** — Freedom from coupling `delivery` and `browser-sync` to a third-party realtime provider's SDK, subscription model, availability, and per-connection or per-message billing. Under the tenet *Self-hosted and managed infrastructure are both permitted*, managed services remain eligible; avoiding external vendor coupling on the live board path is weighed as an architectural and cost priority rather than a hard constraint.
- **Operational and implementation simplicity (moderate)** — Engineering and operational effort required to run the live path at 99.5 percent event-hour availability, including connection scaling, rolling deployments, server-to-delivery publication plumbing, and client synchronization complexity across `change-store`, `delivery`, and `browser-sync`.
- **Authoritative revision continuity and connectivity failure visibility (moderate)** — Grounded in the tenets *A committed edit has one authoritative event revision regardless of its delivery route* and *Connectivity failures must be visible, not mistaken for an unchanged board*. Weighs how directly the transport preserves authoritative revision ordering without cross-system drift and how promptly a broken delivery path can be distinguished from an unchanged board.
- **Tolerance of intermittent field networks and middleboxes (minor)** — Market coordinators often access boards over cellular connections, mobile hotspots, and temporary venue Wi-Fi with aggressive NAT idle timeouts and packet loss. Weighs how naturally the transport traverses proxies and brief drops without custom keepalive and reconnect machinery.

## Options in the Domain

### Five-Second HTTPS Polling

**Description**: Browsers run a periodic timer that issues an authenticated HTTPS `GET` every five seconds carrying the highest event revision currently rendered. `delivery` remains a stateless request/response handler backed by cursor queries against `change-store` (`revision > sinceRevision`), returning any newer revisions or indicating that a full board snapshot is required when a browser reconnects after a wide gap. No persistent connections, server-side fan-out brokers, or publication outboxes are needed.

**Demonstration**:
`GET /events/{eventId}/changes?since=142` every 5s → `{ "headRevision": 144, "changes": [...] }` (or `{ "headRevision": 142, "changes": [] }` when idle).

**Analysis**:
- **weak** (*Low-latency update delivery and idle-read efficiency*): Committed edits wait up to five seconds plus round-trip time before polling browsers observe them (~2.5 seconds average lag), and 800 open browsers generate ~160 read requests per second even when no stall statuses change.
- **strong** (*Vendor independence and operating-cost predictability*): Uses standard HTTPS `fetch` calls to MarketBoard's own service with no external realtime provider, proprietary SDK, or per-connection third-party fees.
- **strong** (*Operational and implementation simplicity*): `delivery` stays completely stateless across horizontal scaling and rolling deploys, `change-store` serves indexed read queries without an outbox or pub/sub bridge, and `browser-sync` uses a single request loop for both live updates and post-disconnect catch-up.
- **partial** (*Authoritative revision continuity and connectivity failure visibility*): Responses read authoritative revisions directly from `change-store`, but network loss is detected only when a scheduled poll fails or times out, creating a multi-second window before degraded connectivity is distinguishable from an idle interval.
- **strong** (*Tolerance of intermittent field networks and middleboxes*): Independent short-lived HTTPS requests traverse restrictive proxies, NAT timeouts, and mobile network handoffs without maintaining persistent socket state.

**Summary**: Trades multi-second update lag and continuous idle read traffic for stateless server operation and a minimal client protocol.

### Self-Hosted WebSockets

**Description**: Browsers open a WebSocket session directly to MarketBoard's `delivery` tier, supplying subscription credentials and their last known event revision. `change-store` persists replayable event revisions and reliably publishes committed edits (for example, via a durable outbox or ordered log tail) to `delivery`. `delivery` manages active socket sessions, replays missed revisions on connect when within the replay window (or directs the browser to load a snapshot), sends periodic heartbeats, and streams newly committed revisions as they arrive. `browser-sync` tracks socket liveness, surfaces disconnected state immediately on close or missed heartbeats, and reconnects with jittered backoff and revision-based catch-up for outages up to 20 minutes.

**Demonstration**:
`WSS /events/{eventId}/stream?since=142` → server replays `143..144`, then pushes `{ "revision": 145, ... }` on commit and periodic heartbeat frames while idle.

**Analysis**:
- **strong** (*Low-latency update delivery and idle-read efficiency*): Committed revisions push over open sockets immediately upon publication from `change-store`, and idle boards produce zero read queries against `change-store`.
- **strong** (*Vendor independence and operating-cost predictability*): Uses the standard browser `WebSocket` API against MarketBoard-operated services, avoiding realtime vendor SDKs, external provider outages, and per-connection or per-message fees.
- **weak** (*Operational and implementation simplicity*): MarketBoard owns stateful connection capacity for up to 800 concurrent sockets, graceful connection draining during deploys, reconnect-herd mitigation, and reliable publication plumbing between `change-store` and `delivery`.
- **strong** (*Authoritative revision continuity and connectivity failure visibility*): `delivery` streams MarketBoard's native event revisions without an external relay, socket close or heartbeat timeout directly reflects loss of reachability to MarketBoard, and reconnect catch-up reconciles strictly by authoritative revision.
- **weak** (*Tolerance of intermittent field networks and middleboxes*): Cellular handoffs and NAT idle timeouts drop long-lived TCP connections, requiring explicit server/client heartbeats, bounded backoff, and seamless switching between revision replay and snapshot recovery in `browser-sync`.

**Summary**: Achieves immediate push updates and full vendor independence at the cost of owning stateful socket operations, reliable internal publication, and client reconnect/catch-up machinery.

### Hosted Realtime Service

**Description**: MarketBoard delegates persistent connection management and fan-out to a managed third-party realtime service. `delivery` mints short-lived, event-scoped provider subscription tokens for authorized browsers and publishes committed revisions from `change-store` to the provider's HTTP/publish API, backed by an outbox and reconciliation worker to retry failed publishes. `browser-sync` embeds the provider's client SDK to maintain the live subscription while querying MarketBoard's HTTPS endpoints for initial snapshots and gap recovery when revisions arrive out of order or after extended disconnects.

**Demonstration**:
`change-store` commits revision `145` + outbox record → `delivery` publishes `{ "revision": 145, ... }` to provider channel `event.{eventId}` → provider SDK delivers frame to subscribed browsers.

**Analysis**:
- **strong** (*Low-latency update delivery and idle-read efficiency*): Provider edge connections push published revisions to subscribed browsers in well under a second without idle read polling against `change-store`.
- **weak** (*Vendor independence and operating-cost predictability*): Couples `delivery` token issuance, publication retries, and `browser-sync` subscriptions to a vendor's API and SDK, introduces recurring peak-connection and message-volume charges across 800 browsers and bursty edits, and makes event-hour availability partly dependent on an external realtime provider.
- **partial** (*Operational and implementation simplicity*): Offloads WebSocket scaling, load-balancer tuning, and edge keepalives to the provider, while MarketBoard still builds and operates token minting, outbox retry/reconciliation for failed provider publishes, and gap recovery against `change-store`.
- **partial** (*Authoritative revision continuity and connectivity failure visibility*): Introduces an external hop between `change-store` commit and provider fan-out; a browser can maintain a healthy socket to the provider while MarketBoard-to-provider publication is failing or delayed, requiring additional end-to-end staleness signaling and revision-gap reconciliation.
- **strong** (*Tolerance of intermittent field networks and middleboxes*): Mature provider SDKs supply pre-tuned keepalives, automatic reconnects, and HTTP-based fallback transports for constrained mobile and venue networks.

**Summary**: Offloads socket infrastructure and field-network transport edge cases in exchange for recurring vendor fees, provider coupling, and cross-system publication reconciliation.

## Selection

MarketBoard selects **Self-Hosted WebSockets**.

Self-hosted WebSockets is the only option with **strong** fit on both **major** criteria: it delivers immediate push updates during opening-time bursts without imposing 160-requests-per-second idle polling load on `change-store`, and it keeps MarketBoard free of recurring realtime vendor fees and third-party protocol coupling. Five-second HTTPS polling is simpler to operate and naturally resilient on flaky networks, and a hosted realtime service offloads socket scaling and transport fallbacks, but each scores **weak** on one of the two **major** criteria. MarketBoard deliberately accepts the **moderate** operational cost of stateful socket management and the **minor** field-network engineering work in order to get fast updates without tying the board to an external realtime provider.

This choice turns directly on two tenets — *A committed edit has one authoritative event revision regardless of its delivery route* and *Connectivity failures must be visible, not mistaken for an unchanged board* — which self-hosted WebSockets supports by streaming native event revisions directly from MarketBoard and tying socket health directly to MarketBoard reachability rather than an intermediary relay. Under *Self-hosted and managed infrastructure are both permitted*, rejecting a hosted realtime service reflects a coupling and cost trade-off on the core synchronization path rather than a compliance restriction, leaving managed infrastructure available for commodity persistence and hosting.

Committing to self-hosted WebSockets forecloses purely stateless deployment for `delivery` (load balancers and rolling deploys must support WebSocket upgrades and graceful connection draining) and forecloses treating `change-store` as a passive query-only store. Downstream, it obligates:

- **`change-store`**: Persist sequential, replayable per-event revisions (retained for seven days and covering the 20-minute disconnect recovery window), serve consistent board snapshots with their head revision, and guarantee reliable publication of every committed revision to `delivery`.
- **`delivery`**: Issue or validate WebSocket subscription credentials outside `access`'s HTTPS command path, sustain up to 800 concurrent socket sessions and 20-edits-per-second burst fan-out, run keepalive heartbeats, and drain sessions cleanly across deploys.
- **`browser-sync`**: Manage the WebSocket connection lifecycle, surface disconnected or reconnecting status immediately when socket liveness drops, reconnect with jittered backoff across intermittent field networks, and catch up from the last applied revision via replay or full snapshot recovery.
```

If this decision doc and the updated HLD look good to close Phase 1, let me know whether you want any adjustments (including to `## Tenets` or the stale "still-open" phrasing in `docs/intent/access/access-design.md`) and which of the three nodes — `change-store`, `delivery`, or `browser-sync` — you'd like to draft first in Phase 2.