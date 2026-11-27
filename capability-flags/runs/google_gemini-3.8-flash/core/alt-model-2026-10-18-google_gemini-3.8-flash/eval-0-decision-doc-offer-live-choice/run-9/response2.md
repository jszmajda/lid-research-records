I have written up the full decision document at `docs/decisions/change-delivery.md` and linked it from `docs/high-level-design.md § Key Design Decisions`.

### Decision Document (`docs/decisions/change-delivery.md`)

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Mechanism

## Context

MarketBoard coordinators need fast updates on stall status, closures, and operational alerts across forty concurrent weekend markets with up to 800 simultaneous staff browsers. During opening bursts, up to 20 edits per second may occur, and stale board states can lead to conflicting physical assignments on the ground. 

While edits are submitted as commands over HTTPS to an authoritative board, how committed revisions reach viewing browsers impacts update latency, operational maintenance, system architecture, and hosting cost. A delivery mechanism must reliably push or serve updates to browsers, support quick recovery after intermittent disconnects (up to 20 minutes), and keep operational dependencies within manageable bounds.

## Decision Elements

- **Freshness & Burst Latency** (major): Ability to deliver committed changes to connected browsers within seconds, comfortably satisfying the 15-second freshness target and handling opening bursts without backlog.
- **Provider Independence & Recurring Cost** (major): Avoiding commercial realtime vendor subscriptions and recurring per-message or per-connection fee exposure, keeping deployment self-contained.
- **Server Connection & Operational Overhead** (moderate): The operational complexity of managing persistent connection state, capacity scaling, socket lifecycle, and failover directly.
- **Protocol & Recovery Simplicity** (moderate): Simplicity of the synchronization protocol, client catch-up, and disconnect recovery logic.
- **Read Amplification & Database Load** (minor): Total request/query volume placed on the change storage layer by 800 connected browsers during quiet periods and peak bursts.

## Options in the Domain

### Five-second HTTPS Polling

Browsers periodically issue conditional HTTPS GET requests (e.g., passing a `since_revision` cursor) every 5 seconds to fetch recent changes.

- **Freshness & Burst Latency**: **partial**. Updates take on average 2.5 to 5 seconds to appear, meeting the 15-second goal, but burst edits face polling interval lag rather than immediate push notification.
- **Provider Independence & Recurring Cost**: **strong**. Completely self-contained; runs on standard web servers without third-party vendors or specialized connection services.
- **Server Connection & Operational Overhead**: **strong**. Completely stateless at the connection layer. Requests distribute across standard HTTP load balancers and server processes without persistent socket capacity or sticky sessions.
- **Protocol & Recovery Simplicity**: **strong**. Normal HTTP request/response. Catch-up after disconnect uses the exact same cursor query endpoint as normal polling.
- **Read Amplification & Database Load**: **weak**. 800 browsers polling every 5 seconds generate at least 160 requests per second continuously, mostly returning empty responses when no edits occur.

### Self-hosted WebSockets

The application server manages persistent bidirectional WebSocket connections to active browsers, pushing revision envelopes immediately upon commit, with client-managed reconnect backoff and replay queries.

- **Freshness & Burst Latency**: **strong**. Near-instantaneous push of committed revisions over open sockets, well within freshness targets even during 20 edits/sec peak bursts.
- **Provider Independence & Recurring Cost**: **strong**. Zero external vendor lock-in or per-connection/per-message commercial billing; all infrastructure runs within the project's own host environment.
- **Server Connection & Operational Overhead**: **weak**. We own socket connection capacity, socket heartbeat/keepalive monitoring, server process restart disruptions, and socket session distribution across instances.
- **Protocol & Recovery Simplicity**: **partial**. Requires defining a wire envelope, handling dropped connection detection, client backoff, and a dedicated reconnect/replay flow from the change store when sockets reconnect.
- **Read Amplification & Database Load**: **strong**. Idle clients consume no query bandwidth; the store queries or streams revisions only when mutations actually occur or when a client reconnects.

### Hosted Realtime Service

The backend publishes committed revision envelopes to an external hosted managed realtime service (such as Pusher, Ably, or AWS AppSync), and browsers subscribe directly to the managed service using vendor client SDKs.

- **Freshness & Burst Latency**: **strong**. Near-instantaneous push of committed revisions managed by globally distributed edge infrastructure.
- **Provider Independence & Recurring Cost**: **weak**. Strong vendor lock-in to proprietary SDKs and subscription APIs, plus ongoing commercial billing scaling with peak connections and message volume.
- **Server Connection & Operational Overhead**: **strong**. Connection management, socket state, edge presence, and heartbeat monitoring are completely offloaded to the hosted provider.
- **Protocol & Recovery Simplicity**: **partial**. Connection maintenance is managed by the vendor SDK, but cross-system reconciliation, credentials distribution, and historical gap filling still require application-level coordination.
- **Read Amplification & Database Load**: **strong**. Application database handles only publication upon commit; client connection fan-out is isolated to the vendor.

## Selection

We select **Self-hosted WebSockets**.

While self-hosted WebSockets introduce connection lifecycle and socket scaling responsibilities, they provide immediate revision dispatch without tying MarketBoard to a proprietary realtime provider or incurring recurring third-party vendor fees. 

HTTPS polling was rejected because, although operationally simpler, periodic polling incurs high repeated read amplification (160+ req/s constant load across 800 browsers) and adds 2–5 seconds of latency to coordinator visibility during time-sensitive morning bursts. Hosted realtime services were rejected because the recurring subscription cost and external vendor coupling are unnecessary for a focused operational footprint of 800 concurrent browsers.

This decision obligates downstream design in three components:
1. **Change store** must maintain an ordered revision feed with replayable history to service catch-up queries on reconnect.
2. **Delivery** must manage persistent WebSocket connections, handle connection heartbeats, and broadcast committed revisions.
3. **Browser sync** must implement connection maintenance, reconnect backoff, and revision gap-detection/catch-up logic.
```

---

### Phase 1 Stop & Review

The HLD and standalone decision doc are in place. Does this capture the reasoning and criteria to your satisfaction, and shall we proceed to Phase 2 (LLD check or draft)? If so, which of the three downstream nodes would you like to tackle first: `change-store`, `delivery`, or `browser-sync`?