I have written `docs/decisions/change-delivery-transport.md` and linked it from `docs/high-level-design.md` under Key Design Decisions:

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Transport

## Context

MarketBoard keeps one authoritative board per event (`docs/high-level-design.md`). Editors submit commands over HTTPS, and each committed edit receives a monotonic event revision. Up to 800 simultaneous staff browsers across forty weekend markets watch these boards, with a busy market averaging two edits per minute and opening-time bursts reaching 20 edits per second.

Committed revisions must reach connected browsers within 15 seconds under normal connectivity, and browsers disconnecting for up to 20 minutes must recover the latest board. Because the delivery transport determines what indexes and publication guarantees `change-store` provides, what session state `delivery` manages, and how `browser-sync` detects staleness and catches up, this choice shapes all three downstream nodes.

## Decision Elements

### Weighted Criteria

- **Vendor independence and recurring cost control (major)** — Avoid recurring per-connection or per-message vendor fees and proprietary client SDK coupling across weekend market events. The HLD tenet *Self-hosted and managed infrastructure are both permitted* leaves both routes open rather than mandating managed services.
- **Update latency and read efficiency (moderate)** — Deliver committed revisions quickly to up to 800 browsers during 20-edits-per-second opening bursts without high-frequency repeated read queries against the change store when boards are quiet.
- **Operational and implementation simplicity (moderate)** — Minimize stateful connection management, reconnect storm handling, and outbox/publication plumbing across `change-store`, `delivery`, and `browser-sync`.
- **Disconnect recovery and staleness visibility (minor)** — Support deterministic catch-up after disconnects of up to 20 minutes and make lost connectivity promptly visible to staff browsers, turning on the HLD tenet *Connectivity failures must be visible, not mistaken for an unchanged board*.

## Options in the Domain

### Five-second HTTPS polling

- **Description** — Browsers issue periodic `GET` requests every five seconds carrying their last applied event revision cursor. The server queries the change store for revisions after that cursor (or returns a full snapshot when the cursor is too old) and responds over stateless HTTP. No persistent connections or push brokers are maintained.
- **Demonstration** — `GET /events/{eventId}/changes?sinceRevision=104` every 5 seconds; returns `200 OK` with revisions `105..106` or an empty list.
- **Analysis**:
  - *Vendor independence and recurring cost control*: **strong** fit. Uses standard HTTPS infrastructure with no third-party realtime vendor fees or proprietary client libraries.
  - *Update latency and read efficiency*: **partial** fit. Meets the 15-second freshness goal with a multi-second polling lag, but 800 browsers generate ~160 requests per second against the server and change-store read path even when no edits occur.
  - *Operational and implementation simplicity*: **strong** fit. Delivery remains stateless request/response, the change store needs only indexed revision-range queries, and browsers run a timer loop without socket lifecycle management.
  - *Disconnect recovery and staleness visibility*: **strong** fit. Every poll naturally performs cursor catch-up, and failed poll requests directly trigger browser staleness indicators after the poll timeout.
- **Summary** — Simplest stateless operation, traded against multi-second delivery lag and continuous baseline read load.

### Self-hosted WebSockets

- **Description** — Browsers establish persistent WebSocket sessions to the MarketBoard delivery service and subscribe to an event starting from their known revision. When the change store commits an edit, it publishes the revision to the delivery layer, which pushes the update over subscribed sockets. Heartbeats detect dead connections, and reconnecting browsers replay missed revisions (or fall back to a snapshot) from the change store.
- **Demonstration** — Browser opens `wss://.../events/{eventId}/stream?sinceRevision=104`, receives pushed revision frames `105`, `106`, and re-establishes the socket with its latest revision after a drop.
- **Analysis**:
  - *Vendor independence and recurring cost control*: **strong** fit. Runs on self-hosted application instances with no per-connection or per-message realtime vendor billing and no provider lock-in.
  - *Update latency and read efficiency*: **strong** fit. Pushes committed revisions in subsecond time during opening bursts and eliminates repeated database reads during quiet periods.
  - *Operational and implementation simplicity*: **weak** fit. Requires stateful WebSocket connection capacity, heartbeat and reconnect storm handling in `delivery` and `browser-sync`, and reliable commit-to-delivery publication plus replay queries in `change-store`.
  - *Disconnect recovery and staleness visibility*: **strong** fit. Socket close events and missed heartbeats surface connectivity failures immediately, and reconnect handshakes replay missed revisions from the change store.
- **Summary** — Fast push updates without vendor coupling or recurring realtime fees, traded against owning stateful socket operations and reconnect/replay logic.

### Hosted realtime service

- **Description** — Browsers subscribe to event channels managed by an external realtime provider using short-lived credentials minted by MarketBoard's `delivery` component. When the change store commits a revision, an outbox publisher forwards the revision to the provider's API, which fans it out to connected browsers and handles socket termination and edge scaling.
- **Demonstration** — `delivery` mints a channel token for `event:{eventId}`; `change-store` outbox worker posts revision `105` to the provider API; browser SDK receives the event on its managed subscription.
- **Analysis**:
  - *Vendor independence and recurring cost control*: **weak** fit. Incurs recurring peak-connection and message-fanout charges across 800 concurrent browsers and couples `delivery` and `browser-sync` to a provider's auth, channel, and SDK model.
  - *Update latency and read efficiency*: **strong** fit. Delivers subsecond push updates without polling read load on the change store.
  - *Operational and implementation simplicity*: **partial** fit. Offloads socket connection scaling and edge heartbeats to the vendor, but requires `change-store` and `delivery` to build outbox publication reconciliation, credential minting, and fallback snapshot catch-up when provider history windows expire.
  - *Disconnect recovery and staleness visibility*: **partial** fit. Provider SDKs expose connection state, but bridging provider channel history with MarketBoard's authoritative 20-minute recovery window still requires custom reconciliation against the change store.
- **Summary** — Offloads socket connection ops for low-latency push, traded against recurring vendor fees, SDK coupling, and outbox reconciliation.

## Selection

Choose **Self-hosted WebSockets**.

Self-hosted WebSockets deliver subsecond updates during opening bursts and avoid continuous polling reads while keeping MarketBoard free of recurring realtime vendor fees and provider SDK coupling (**Vendor independence and recurring cost control**, **Update latency and read efficiency**). While **Five-second HTTPS polling** is operationally simpler and **Hosted realtime service** offloads socket termination, the concurrency scale of MarketBoard (up to 800 simultaneous browsers and 20 edits per second at peak) is small enough that stateful WebSocket sessions and replayable revisions are straightforward to operate in-house.

This decision engages three HLD tenets:
- *Self-hosted and managed infrastructure are both permitted*: permits choosing self-hosted sockets on cost and coupling grounds rather than defaulting to a managed realtime vendor.
- *A committed edit has one authoritative event revision regardless of its delivery route*: requires the change store, not the WebSocket broker, to remain the source of truth for revision ordering and replay.
- *Connectivity failures must be visible, not mistaken for an unchanged board*: requires explicit socket heartbeats and disconnect indicators in `delivery` and `browser-sync`.

### Downstream Obligations

- **`change-store`**: Persist sequential per-event revisions with at least a 20-minute replay index (within the 7-day retention window) and reliably publish committed revisions to the WebSocket delivery layer.
- **`delivery`**: Terminate self-hosted WebSocket connections, authenticate event subscriptions, fan out committed revisions to subscribed sessions, and run heartbeats to detect dropped connections.
- **`browser-sync`**: Maintain the WebSocket subscription, surface connection loss immediately on heartbeat timeout or socket close, and reconnect with the last applied revision to replay missed updates or load a fresh snapshot.
```

Does this Phase 1 update and decision doc look ready to approve? If so, let me know:
1. Which of the three nodes (`change-store`, `delivery`, or `browser-sync`) you want to start with in Phase 2 (`change-store` is a natural first step since `delivery` and `browser-sync` depend on its revision and replay contracts).
2. Whether you also want me to update the stale "still-open change-delivery approach" phrasing in `docs/intent/access/access-design.md`.