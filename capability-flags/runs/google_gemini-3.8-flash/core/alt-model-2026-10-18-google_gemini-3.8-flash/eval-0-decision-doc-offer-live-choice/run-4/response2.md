I have authored the decision doc at `docs/decisions/change-delivery-mechanism.md` and updated `docs/high-level-design.md` to link directly to it.

Here is the decision doc:

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Mechanism

## Context

MarketBoard coordinates stall closures, power issues, and late arrivals across 40 weekend markets. Up to 800 staff browsers concurrently view live board status, updated by 10–25 active editors per market. Around market opening, write activity spikes up to 20 edits per second across the system.

The system requires an authoritative mechanism to deliver committed board revisions to connected browsers. The delivery model shapes three interdependent components: the change store's publication and query model, the delivery tier's connection and session architecture, and the browser sync tier's connection lifecycle and catch-up behavior. Choosing the delivery mechanism determines whether the system incurs external recurring service costs, how connection capacity and state are managed, and how browsers detect and recover from disconnects.

## Decision Elements

- **Latency and update freshness** (major; derives from goal of timely operational board status): How quickly committed edits appear on connected browsers, especially during high-activity morning bursts.
- **Infrastructure cost and vendor independence** (moderate): Recurring operational expense and exposure to third-party vendor platform lock-in.
- **Operational complexity and connection management** (moderate): Burden of hosting long-lived connections, session tracking, socket capacity planning, and protocol-level recovery.
- **Implementation surface across tiers** (minor): Total implementation effort required across the server store, delivery infrastructure, and client browser runtime.

## Options in the Domain

### Five-Second HTTPS Polling

Browsers periodically issue conditional HTTPS requests (using cursor revision parameters or `ETag`/`If-None-Match`) every five seconds to retrieve new revisions from the change store.

- **Latency and update freshness**: **weak**. Introduces an inherent multi-second lag (up to 5 seconds plus network round-trip) between command commit and display update. Bursts of 20 edits/sec compound read delays.
- **Infrastructure cost and vendor independence**: **strong**. Completely standard HTTP infrastructure without proprietary vendor dependencies or realtime subscription pricing tiers.
- **Operational complexity and connection management**: **strong**. Stateless request/response model. No socket session state, connection leak management, or heartbeat monitoring on the server.
- **Implementation surface across tiers**: **strong**. The change store provides cursor-based revision range queries; delivery is standard HTTP endpoints; browsers run a simple timer loop.

### Hosted Realtime Service

The backend publishes committed revisions to a managed third-party realtime message broker (e.g., Pusher, Ably, or AWS AppSync/IoT), which handles browser WebSocket subscriptions and distribution.

- **Latency and update freshness**: **strong**. Delivers subsecond broadcast of committed edits directly to client subscriptions.
- **Infrastructure cost and vendor independence**: **weak**. Incurs ongoing commercial subscription fees scaling with message counts, connection concurrency, and peak bandwidth. Couples the architecture to proprietary client SDKs and vendor-managed infrastructure.
- **Operational complexity and connection management**: **strong**. Offloads connection state, session limits, load balancing, and network edge presence to the hosted provider.
- **Implementation surface across tiers**: **partial**. The change store requires outbox reconciliation to publish to the external service; delivery delegates session management to the provider; browsers use vendor SDKs for connection and channel recovery.

### Self-Hosted WebSockets

The MarketBoard server terminates persistent WebSocket connections directly, managing active client sessions and multiplexing revision broadcasts to subscribed browsers per market event.

- **Latency and update freshness**: **strong**. Pushes committed revisions immediately upon database commit, achieving subsecond latency to active viewers.
- **Infrastructure cost and vendor independence**: **strong**. Operates entirely on standard self-hosted compute instances without per-message or per-connection vendor fees or proprietary platform dependencies.
- **Operational complexity and connection management**: **partial**. Requires server-side connection lifecycle management, socket file-descriptor sizing, heartbeat/ping-pong monitoring, graceful connection drainage, and reconnection burst handling.
- **Implementation surface across tiers**: **partial**. The change store must support fast in-memory or pub/sub fanout alongside replayable revision queries; delivery manages active connection registries; browsers implement reconnect backoff, heartbeat tracking, and revision gap catch-up.

## Selection

Self-hosted WebSockets is selected.

While five-second HTTPS polling minimizes operational overhead, its multi-second latency undermines coordinator coordination during opening-time bursts where status changes happen rapidly. Conversely, a hosted realtime service provides low latency but introduces recurring commercial fees and vendor coupling that conflict with maintaining a lean, self-contained deployment.

Self-hosted WebSockets achieves low-latency updates while retaining complete vendor independence and predictable infrastructure costs. We accept the additional operational complexity of hosting stateful connections—specifically session capacity planning, heartbeat monitoring, and client reconnect/replay logic—in exchange for immediate board synchronization without external platform lock-in.

Downstream obligations:
- **Change store** (`docs/intent/change-store/`): Must maintain sequential, replayable revision histories to support catch-up requests, alongside an event publication channel feeding the delivery tier.
- **Delivery** (`docs/intent/delivery/`): Must manage client connection lifecycles, event channel subscription multiplexing, heartbeat timeouts, and live broadcast fanout.
- **Browser sync** (`docs/intent/browser-sync/`): Must manage client WebSocket connection state, exponential backoff reconnects, heartbeat health checks, and gap-fill replay queries following disconnects.
```

---

### Phase 1 Stop: Review & Next Steps

1. Does `docs/decisions/change-delivery-mechanism.md` accurately capture the criteria, domain options, and trade-off rationale you want recorded for future readers?
2. Which downstream node should we tackle next in Phase 2?
   - `change-store` (`docs/intent/change-store/`): revision sequencing, replay queries, and internal publication.
   - `delivery` (`docs/intent/delivery/`): WebSocket session management, channel subscriptions, and live fanout.
   - `browser-sync` (`docs/intent/browser-sync/`): client connection lifecycle, heartbeat tracking, reconnect backoff, and catch-up queries.