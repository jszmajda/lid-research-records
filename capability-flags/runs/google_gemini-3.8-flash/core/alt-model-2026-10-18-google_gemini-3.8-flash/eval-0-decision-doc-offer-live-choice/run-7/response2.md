I have written the decision doc at `docs/decisions/change-delivery.md` and linked it from the Key Design Decisions section of `docs/high-level-design.md`.

Here is `docs/decisions/change-delivery.md`:

```markdown
---
node: high-level-design
---

# Decision: Change Delivery via Self-Hosted WebSockets

## Context

MarketBoard coordinators need fast updates on stall closures, power issues, and late arrivals across up to 800 simultaneous staff browsers during busy weekend markets. In bursts, edit rates reach 20 edits per second. The project needs a mechanism to deliver committed event revisions to connected browsers that balances update latency, operational complexity, and vendor dependence.

## Decision Elements

- **Freshness target** *(gate)* — Must deliver committed changes to connected browsers within 15 seconds under normal connectivity (HLD goal).
- **Scale and burst capacity** *(gate)* — Must support 800 concurrent connected browsers and opening-time bursts of 20 edits per second without message loss (HLD goal).
- **Delivery latency** *(weighted criterion: moderate)* — Lower propagation delay provides staff with a near-instant view of board changes. Subsecond delivery improves coordinator confidence during fast-moving incidents.
- **Vendor independence and recurring cost** *(weighted criterion: major)* — Avoiding ongoing per-connection or per-message realtime provider costs and external platform coupling.
- **Operational and implementation complexity** *(weighted criterion: major)* — The burden of managing persistent connections, connection lifecycle, reconnection storms, and state synchronization across disconnects.

## Options in the Domain

### Option 1: Five-Second HTTPS Polling

Browsers issue periodic HTTPS requests every five seconds querying for new revisions since their last observed cursor.

- Freshness target: **passes** — 5-second polling interval meets the 15-second freshness target.
- Scale and burst capacity: **passes** — Stateless HTTPS requests scale horizontally using standard HTTP caching and infrastructure.
- Delivery latency: **weak** — Inherent lag averaging 2.5 seconds (up to 5 seconds) before changes appear.
- Vendor independence and recurring cost: **strong** — Standard HTTPS infrastructure with no third-party realtime subscription fees.
- Operational and implementation complexity: **strong** — Simplest implementation; stateless request/response with cursor queries and no connection management overhead. However, 800 browsers polling every 5 seconds creates continuous read traffic (~160 req/sec) even during periods of zero edits.

### Option 2: Self-Hosted WebSockets

The server maintains persistent WebSocket connections with active browser clients, broadcasting new revisions as edits commit.

- Freshness target: **passes** — Immediate push delivers updates within milliseconds.
- Scale and burst capacity: **passes** — 800 concurrent persistent socket connections per event cluster is well within capacity for a modern server instance.
- Delivery latency: **strong** — Subsecond delivery immediately upon server revision assignment.
- Vendor independence and recurring cost: **strong** — Runs entirely on self-hosted infrastructure with zero third-party service fees and no provider lock-in.
- Operational and implementation complexity: **partial** — Requires managing connection lifecycles, heartbeats, reconnect backoff, and revision catch-up/replay logic in the browser client and server delivery layer.

### Option 3: Hosted Realtime Service

A third-party managed realtime service (e.g., Pusher, Ably) handles client connections, channel subscriptions, and fan-out distribution.

- Freshness target: **passes** — Subsecond managed push delivery.
- Scale and burst capacity: **passes** — Managed infrastructure absorbs connection scale and burst volume.
- Delivery latency: **strong** — Low-latency push directly to client SDKs.
- Vendor independence and recurring cost: **weak** — Incurs ongoing recurring subscription/usage costs and introduces architectural coupling to external vendor SDKs and APIs.
- Operational and implementation complexity: **strong** — Offloads connection handling, socket state, and scaling operations to a managed platform, requiring only server-side publication and client subscription wiring.

## Selection

Option 2 (Self-Hosted WebSockets) is selected.

While Option 1 (HTTPS polling) offers the lowest operational complexity and Option 3 (Hosted realtime) offloads connection operations, Option 2 best balances immediate delivery with cost and independence. The team accepts the added engineering responsibility of connection management, heartbeat monitoring, and reconnection replay to achieve low-latency updates while avoiding ongoing vendor fees and third-party coupling.

This decision commits the downstream design:
- `change-store`: Must support revision replay for reconnecting clients alongside real-time publication hooks.
- `delivery`: Must manage socket session lifecycles, heartbeats, and local connection fan-out.
- `browser-sync`: Must implement connection monitoring, exponential backoff reconnection, and revision catch-up.
```

With Phase 1 complete, are you ready to proceed to Phase 2 (LLD check/draft) for the three downstream nodes (`change-store`, `delivery`, and `browser-sync`), or are there any adjustments you'd like to make to the HLD or decision doc?