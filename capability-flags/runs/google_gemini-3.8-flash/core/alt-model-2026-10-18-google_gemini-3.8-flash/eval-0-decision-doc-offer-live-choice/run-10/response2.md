I have created the decision document at `docs/decisions/change-delivery-approach.md` and linked it directly from `docs/high-level-design.md`.

### Decision Document (`docs/decisions/change-delivery-approach.md`)

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Approach

## Context

MarketBoard coordinates stall status across weekend markets, serving up to 800 concurrent staff browsers across 40 markets. An authoritative board state is maintained per event, with edits submitted via HTTPS. The system requires committed updates to appear on connected browsers promptly, remain resilient across intermittent connectivity (up to 20-minute disconnections), and handle opening-time bursts of 20 edits per second.

The delivery mechanism is the architectural bridge between committed database revisions and browser display. The choice determines the storage requirements (cursor querying vs. replay log), transport connection topology, server capacity planning, and browser reconnection protocols.

## Decision Elements

- **Freshness & Latency** (major) — Speed of propagating committed edits to connected browsers. While the explicit goal is within 15 seconds, low-latency (sub-second) updates significantly improve coordinator situational awareness during high-activity opening bursts.
- **Vendor Independence & Ongoing Cost** (major) — Avoidance of recurring per-message/per-connection third-party SaaS fees and external proprietary API lock-in.
- **Operational Simplicity** (moderate) — Minimizing operational footprint, custom connection state management, memory overhead for idle connections, and protocol failure modes.
- **Catch-up & Reconnect Complexity** (moderate) — The engineering burden on storage and client recovery to reliably resume state after connection drops of up to 20 minutes, aligned with the tenet *Connectivity failures must be visible, not mistaken for an unchanged board*.

## Options in the Domain

### Five-Second HTTPS Polling

Browsers poll an HTTPS endpoint every 5 seconds supplying their last seen revision ID or cursor. The server queries the change store for revisions newer than the cursor and returns any new delta or an empty response.

- **Freshness & Latency**: **partial** fit. Updates arrive with an expected 2.5-second average lag and up to 5 seconds of delay. While well within the 15-second goal, it lacks sub-second immediacy.
- **Vendor Independence & Ongoing Cost**: **strong** fit. Uses standard stateless HTTP endpoints; zero third-party fees and trivial proxy caching.
- **Operational Simplicity**: **strong** fit. Fully stateless web tier without long-lived TCP socket management or process session tables.
- **Catch-up & Reconnect Complexity**: **strong** fit. Reconnect logic is identical to normal polling; recovering from a 20-minute disconnect uses the same cursor query as a routine 5-second poll.

### Self-Hosted WebSockets

The application runs a WebSocket server (integrated or dedicated gateway). Connected browsers maintain persistent bidirectional TCP connections. When an edit commits, the server broadcasts revision payloads to all sockets subscribed to that event.

- **Freshness & Latency**: **strong** fit. Delivers committed edits to browsers immediately upon commit with sub-second latency.
- **Vendor Independence & Ongoing Cost**: **strong** fit. Runs on owned/standard host infrastructure without message-tier SaaS bills or vendor lock-in.
- **Operational Simplicity**: **partial** fit. Requires managing stateful connection capacity across up to 800 concurrent connections, heartbeat/keepalive timers, and process restarts.
- **Catch-up & Reconnect Complexity**: **partial** fit. Requires an explicit replay log or revision window in the change store, client-side backoff/reconnect handling, and a dual-mode sync protocol (live streaming plus revision gap catch-up).

### Hosted Realtime Service

The backend publishes committed revision envelopes to a third-party managed realtime service (e.g., Pusher, Ably, AWS IoT Core) via REST API, and browsers subscribe directly to event channels using the vendor's client SDK.

- **Freshness & Latency**: **strong** fit. Provides immediate sub-second fan-out.
- **Vendor Independence & Ongoing Cost**: **weak** fit. Introduces recurring operational bills scaling with connection count and message volume, along with coupling to vendor SDKs and infrastructure availability.
- **Operational Simplicity**: **strong** fit. Connection capacity, socket multiplexing, and edge distribution are offloaded to the managed service provider.
- **Catch-up & Reconnect Complexity**: **partial** fit. Reconnect handling is partially encapsulated in vendor SDKs, but reconciling missed publications and verifying authoritative event revisions against the backend remains a server and client responsibility.

## Selection

Self-Hosted WebSockets is selected.

This choice prioritizes immediate, sub-second update delivery to coordinators during critical opening bursts while ensuring complete vendor independence and avoiding recurring SaaS bills.

Although Five-Second HTTPS Polling provides the simplest operational model and Hosted Realtime offloads socket operations, Self-Hosted WebSockets provides the optimal balance for the system's operational scale: 800 concurrent connections across 40 markets is well within the capacity of a single modern server process. In exchange, the project accepts the operational responsibility for socket connection lifecycle and client reconnection handling.

This decision commits the downstream nodes to specific responsibilities:
- `change-store`: Must maintain an ordered revision log allowing replay of recent revisions to satisfy catch-up requests.
- `delivery`: Must manage client WebSocket sessions, subscription routing per event, and broadcast publishing.
- `browser-sync`: Must implement connection health monitoring, reconnection backoff, and a catch-up sequence that requests missed revisions before resuming live broadcast processing.
```

---

### Phase 1 Boundary Check

The Phase 1 HLD update and its corresponding decision document are complete. 

Which of the three downstream design nodes should we tackle first for Phase 2 (LLD check and draft): `change-store`, `delivery`, or `browser-sync`?