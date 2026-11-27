I have documented the decision in `docs/decisions/change-delivery-approach.md` and linked it from `docs/high-level-design.md`.

Here is the decision document:

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Approach

## Context

MarketBoard coordinators relay time-sensitive stall closures, late arrivals, and power issues across weekend markets. Up to 800 staff browsers simultaneously view board state, with peak bursts of 20 edits per second around event opening. Committed changes must be delivered reliably to viewers within 15 seconds, and subsecond updates significantly improve coordination flow.

The delivery mechanism determines how changes move from the server to staff browsers, placing distinct architectural requirements on change storage, connection management, and client recovery.

## Decision Elements

- **Latency and update freshness** (major; derives from goal of delivering committed changes within 15 seconds, with low-latency subsecond updates preferred): How quickly committed edits reach connected browsers under active market operations.
- **Vendor independence and operating costs** (major; derives from tenet "Self-hosted and managed infrastructure are both permitted"): Avoiding recurring third-party service fees and coupling to proprietary realtime subscription APIs.
- **Operational and connection management complexity** (moderate): The engineering burden of connection scaling, heartbeat monitoring, session state, and reconnect/gap handling.
- **Change store and query load** (moderate): The storage and read load imposed on the backend by browsers polling or requesting revisions.

## Options in the Domain

### Five-Second HTTPS Polling

- **Description**: Browsers periodically issue HTTPS GET requests with a revision cursor (`GET /events/{id}/changes?since={rev}`) every five seconds. The server queries the change store for revisions newer than the cursor.
- **Analysis**:
  - *Latency and update freshness*: **partial fit**. Meets the 15-second delivery goal comfortably, but introduces average update lag of 2.5 seconds and cannot provide subsecond freshness.
  - *Vendor independence and operating costs*: **strong fit**. Uses standard HTTP infrastructure without vendor bills or proprietary SDKs.
  - *Operational and connection management complexity*: **strong fit**. Stateless request/response model; standard HTTP load balancers and caching apply without maintaining persistent connection state.
  - *Change store and query load*: **weak fit**. 800 simultaneous browsers polling every 5 seconds generate at least 160 requests per second continuously, mostly returning empty results during quiet periods and stressing read indexes.
- **Summary**: Simplest stateless operations, but incurs steady read query overhead and visible update lag.

### Self-Hosted WebSockets

- **Description**: The server maintains persistent WebSocket connections with active browsers grouped by event. When an edit commits, the server broadcasts the revision payload over open sockets. The backend maintains an ordered, replayable revision log, and browsers execute reconnect, backoff, and catch-up replay or snapshot recovery.
- **Analysis**:
  - *Latency and update freshness*: **strong fit**. Pushes committed revisions immediately upon commit, achieving subsecond propagation to connected clients.
  - *Vendor independence and operating costs*: **strong fit**. Runs on standard server infrastructure with zero third-party subscription fees or vendor lock-in.
  - *Operational and connection management complexity*: **partial fit**. Requires server-side socket session lifecycle tracking, heartbeat/ping-pong handling, edge connection limits, and client-side reconnect and replay state machines.
  - *Change store and query load*: **strong fit**. Read traffic occurs primarily on initial connection and reconnect catch-up; steady-state delivery is push-based without polling query load.
- **Summary**: Immediate low-latency updates and zero vendor fees at the cost of managing connection capacity and reconnect/replay flows.

### Hosted Realtime Service

- **Description**: The application offloads connection fan-out to a third-party managed realtime service (such as Pusher, Ably, or AWS AppSync). The server publishes committed event revisions via the provider's REST API, and browsers subscribe directly through the vendor's client SDK.
- **Analysis**:
  - *Latency and update freshness*: **strong fit**. Managed global connection infrastructure delivers subsecond updates to browsers.
  - *Vendor independence and operating costs*: **weak fit**. Introduces ongoing monthly per-connection and per-message service bills, along with lock-in to proprietary subscription protocols and client SDKs.
  - *Operational and connection management complexity*: **strong fit**. Connection scaling, socket edge availability, and channel fan-out are fully managed by the vendor.
  - *Change store and query load*: **partial fit**. The change store must still support initial state snapshots and occasional publication reconciliation when provider deliveries fail.
- **Summary**: Fastest path to low-latency delivery with minimal connection operations, but incurs recurring SaaS costs and tight vendor coupling.

## Selection

We select **Self-Hosted WebSockets**.

While five-second polling is operationally simpler, its recurring read query volume (160 req/s across 800 clients) and multi-second latency degrade coordinator responsiveness during fast opening bursts. Hosted realtime platforms offer low latency and managed connections, but introduce recurring subscription fees and vendor lock-in for a pilot system whose scale (800 concurrent browsers, 40 markets) is well within the capacity of a standard self-hosted WebSocket process.

Accepting the operational responsibility for persistent connections and reconnect recovery aligns with keeping MarketBoard self-contained while satisfying the need for fast updates.

This decision obligates downstream nodes:
1. **Change store** (`docs/intent/change-store/`): Must maintain a durable, ordered log of event revisions for replay, plus snapshot generation when a reconnecting client's gap exceeds available replay history.
2. **Delivery** (`docs/intent/delivery/`): Must own WebSocket endpoint lifecycle, connection authentication, event-based channel broadcasting, and heartbeat management.
3. **Browser sync** (`docs/intent/browser-sync/`): Must maintain client socket state, backoff reconnection, tracking of last-seen revision, catch-up replay requests, and snapshot recovery fallback.
```

Does this decision doc and the updated HLD capture your intent? If approved, which of the three downstream nodes (`change-store`, `delivery`, or `browser-sync`) would you like to design first in Phase 2?