I have written the project-level decision document at `docs/decisions/change-delivery-approach.md` and linked it from `docs/high-level-design.md` under `## Key Design Decisions`.

### `docs/decisions/change-delivery-approach.md`

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Approach

## Context

MarketBoard keeps one authoritative board per event. Editors submit commands over HTTPS, and the server assigns each committed edit a single event revision. Up to 800 simultaneous staff browsers across forty weekend markets watch these boards, with a busy market seeing 10-25 editors, an average of two status changes per minute, and opening-time bursts up to 20 edits per second.

Committed changes must reach connected browsers within 15 seconds under normal connectivity, and browsers disconnected for up to 20 minutes must recover the latest board. Because the delivery mechanism determines how the change store indexes and publishes revisions, how the delivery service manages state or external providers, and how browsers subscribe and recover from disconnects, the three components (`change-store`, `delivery`, and `browser-sync`) are shaped around this choice.

## Decision Elements

### Weighted Criteria

- **Update latency and read efficiency (major)** — How quickly committed edits appear in connected browsers during opening-time bursts and how much repeated read load idle boards impose on the server and change store.
- **Vendor independence and recurring cost control (major)** — Freedom from third-party realtime provider lock-in, proprietary client subscription protocols, and per-connection or per-message recurring vendor fees. The HLD tenet *Self-hosted and managed infrastructure are both permitted* leaves both routes open rather than mandating one by policy.
- **Server connection and session operational simplicity (moderate)** — How little stateful connection management, capacity planning, and server-side session lifecycle handling MarketBoard operators must run during published event hours.
- **Publication and recovery coordination simplicity (moderate)** — How directly the system maintains the HLD tenets *A committed edit has one authoritative event revision regardless of its delivery route* and *Connectivity failures must be visible, not mistaken for an unchanged board* across the store, delivery layer, and reconnecting browsers.

## Options in the Domain

### Five-Second HTTPS Polling

Browsers periodically issue HTTPS requests every five seconds with their last applied revision cursor (`sinceRevision`). The delivery service runs stateless request/response handlers that query the change store for revisions after the cursor (or return a full board snapshot when the cursor is too old) and return them directly.

- **Update latency and read efficiency**: **weak** — Normal propagation adds up to five seconds of polling lag plus request overhead, and 800 browsers polling every five seconds generate ~160 reads per second even when boards are idle.
- **Vendor independence and recurring cost control**: **strong** — Uses standard HTTPS handlers and internal infrastructure with no external realtime vendor dependency or recurring per-connection fees.
- **Server connection and session operational simplicity**: **strong** — Delivery servers remain stateless HTTP workers without long-lived socket registries, heartbeat timers, or connection-draining coordination.
- **Publication and recovery coordination simplicity**: **strong** — Normal delivery and post-disconnect catch-up use the exact same cursor query path against the change store, requiring no separate push-publication channel or outbox reconciliation.

*Summary*: Simplest stateless operation and unified read path, at the cost of continuous read load and multi-second propagation lag.

### Self-Hosted WebSockets

Browsers maintain persistent WebSocket connections to MarketBoard's delivery service. When the change store commits a revision, it publishes the revision to the delivery service, which fans it out immediately to sessions subscribed to that event. Browsers track connection health through socket lifecycle and heartbeats, and upon reconnecting present their last applied revision so the delivery service can replay missed revisions from the change store (or trigger a snapshot reload if the gap exceeds the 20-minute replay window).

- **Update latency and read efficiency**: **strong** — Committed edits push to subscribed browsers immediately upon publication without repeated polling reads during quiet periods.
- **Vendor independence and recurring cost control**: **strong** — Runs entirely on MarketBoard's own infrastructure using standard WebSocket protocols, avoiding third-party realtime vendor coupling and usage-based billing.
- **Server connection and session operational simplicity**: **weak** — MarketBoard owns stateful socket capacity for up to 800 concurrent browsers, session tracking, heartbeat supervision, and reconnect storms during network blips or deployments.
- **Publication and recovery coordination simplicity**: **partial** — Requires reliable publication from the change store to delivery nodes and explicit reconnect/replay handshakes, though authority and connection state remain within one system boundary.

*Summary*: Low-latency push updates and full vendor independence, at the cost of owning stateful WebSocket capacity and reconnect/catch-up coordination.

### Hosted Realtime Service

Browsers subscribe to event channels managed by a third-party realtime provider using the provider's client SDK. After the change store commits an authoritative revision, the delivery service publishes the revision to the provider's API, deals with any publication failures via an outbox or reconciliation loop, and issues scoped subscription tokens to authorized browsers.

- **Update latency and read efficiency**: **strong** — Pushes committed updates with low latency while offloading fan-out traffic from MarketBoard servers.
- **Vendor independence and recurring cost control**: **weak** — Couples browser sync and delivery to a proprietary provider SDK and API, and incurs recurring fees scaled to concurrent connections and message fan-out.
- **Server connection and session operational simplicity**: **strong** — Offloads long-lived socket termination, connection scaling, and heartbeat management to the external provider.
- **Publication and recovery coordination simplicity**: **weak** — Because the HLD tenet *A committed edit has one authoritative event revision regardless of its delivery route* forbids treating the provider as the source of truth, the store and delivery service must run an outbox and reconciliation mechanism to guarantee committed revisions reach the external provider, and browsers must still reconcile provider channel state with authoritative event revisions after disconnects.

*Summary*: Offloads socket operations for fast updates, at the cost of recurring vendor fees, provider coupling, and cross-boundary publication reconciliation.

## Selection

**Self-Hosted WebSockets** is selected.

It wins on the two major criteria: it delivers immediate push updates without idle polling load (**Update latency and read efficiency**) while keeping the protocol and runtime free of external realtime vendor lock-in and recurring connection/message fees (**Vendor independence and recurring cost control**). While the HLD tenet *Self-hosted and managed infrastructure are both permitted* allows a hosted realtime service in principle, a hosted provider still leaves MarketBoard building outbox reconciliation and revision-authority checks to satisfy *A committed edit has one authoritative event revision regardless of its delivery route*, while adding provider coupling and ongoing cost. Five-second HTTPS polling avoids stateful socket operations (**Server connection and session operational simplicity**), but pays for that simplicity with multi-second lag and continuous read load across 800 browsers.

Committing to self-hosted WebSockets forecloses stateless-only delivery workers and obligates the three downstream nodes as follows:

- `change-store` must persist ordered, replayable event revisions (supporting at least the 20-minute reconnect window within its seven-day retention) and reliably publish committed revisions to `delivery`.
- `delivery` must authenticate and manage WebSocket sessions for up to 800 concurrent browsers, fan out live revisions during bursts up to 20 edits per second, and serve revision replay on reconnect.
- `browser-sync` must manage the WebSocket connection lifecycle, surface disconnections immediately per *Connectivity failures must be visible, not mistaken for an unchanged board*, and execute reconnect catch-up from the browser's last applied revision.
```

---

Please let me know if you approve **Phase 1 (HLD + decision doc)** or have any adjustments, and which of the three downstream nodes (`change-store`, `delivery`, or `browser-sync` — plus whether to update the phrasing in `access-design.md`) you'd like to start **Phase 2 (LLD)** with.