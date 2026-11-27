I have written the decision doc at `docs/decisions/change-delivery.md` and linked it from `docs/high-level-design.md`. Here is the decision doc in full:

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Mechanism

## Context

MarketBoard coordinates stall status across 40 weekend markets, serving up to 800 simultaneous staff browsers with 10–25 active editors per busy market and opening-time bursts of up to 20 edits per second. Editors submit commands over HTTPS to a single authoritative board per event (`docs/high-level-design.md`). Once a command commits and receives an event revision, that change must reach connected browsers within 15 seconds, and browsers returning from disconnects of up to 20 minutes must recover the current board state.

The change-delivery mechanism determines the architecture of three downstream components simultaneously: how `change-store` indexes revisions and publishes committed writes, what `delivery` runs and exposes to clients, and how `browser-sync` subscribes, detects connectivity loss, and catches up after a gap. Because five-second polling, self-hosted WebSockets, and hosted realtime services all satisfy the 15-second freshness target and the infrastructure tenet permits both self-hosted and managed services, a reader inspecting the system later needs the criteria and tradeoffs that led to owning WebSocket infrastructure rather than choosing simpler stateless polling or offloaded connection management.

## Decision Elements

### Weighted Criteria

- **Vendor independence and recurring cost control (major)** — Derived from the tenet *Prefer owning operational runtime over coupling to external realtime vendors when the latency benefit justifies the operational work*. Avoid recurring per-connection or per-message vendor billing across 800 concurrent browsers and avoid coupling the server publication contract and browser client to a third-party realtime SDK.
- **Update latency and read efficiency under load (major)** — Deliver committed stall status changes to connected browsers promptly during 20-edit-per-second opening bursts without generating continuous redundant read queries from 800 browsers against the change store when boards are quiet or bursting.
- **Operational and state-management simplicity (moderate)** — Minimize the connection lifecycle, fan-out, and delivery-reconciliation machinery that the system must operate to maintain 99.5% event-hours availability.
- **Explicit connectivity visibility and 20-minute recovery (moderate)** — Derived from the tenet *Connectivity failures must be visible, not mistaken for an unchanged board* and the 20-minute disconnect recovery goal. Support clear browser-side detection of lost delivery and deterministic catch-up to the authoritative event revision.

## Options in the Domain

### Option 1: Five-Second HTTPS Polling

Browsers run a periodic timer that issues an HTTPS `GET` every five seconds carrying the event ID and the browser's last applied revision cursor. The delivery tier stays stateless request/response, querying `change-store` for revisions newer than the cursor (or returning a full snapshot when the cursor is too old) and returning them in the HTTP response.

- **Vendor independence and recurring cost control**: **strong** — Uses standard self-hosted HTTPS request handling with no third-party realtime provider, SDK, or per-message billing.
- **Update latency and read efficiency under load**: **weak** — Introduces multi-second propagation lag (2.5 seconds average, 5+ seconds worst-case before network transit) and generates ~160 requests per second across 800 browsers even when no edits occur, requiring `change-store` or a read cache to absorb constant cursor-query load alongside opening-time write bursts.
- **Operational and state-management simplicity**: **strong** — Requires no persistent connection state, socket draining during deploys, or in-memory session routing; any stateless HTTP worker can serve any poll request.
- **Explicit connectivity visibility and 20-minute recovery**: **strong** — Failed HTTP poll cycles directly signal degraded connectivity to the browser, and reconnecting after up to 20 minutes uses the same cursor-query or snapshot fallback path as normal polling.

**Summary**: Trades lower update responsiveness and continuous background read load for stateless HTTP operation.

### Option 2: Self-Hosted WebSockets

Browsers open a persistent WebSocket connection to the self-hosted `delivery` tier for their active event. When `change-store` commits an edit with a new event revision, it reliably publishes the revision to `delivery`, which fans the update out over subscribed sockets. Browsers track heartbeats and socket state to surface disconnects immediately, and upon reconnecting send their last applied revision so `delivery` and `change-store` can replay missed revisions (covering at least a 20-minute window) or instruct the browser to load a fresh snapshot.

- **Vendor independence and recurring cost control**: **strong** — Runs entirely on self-hosted infrastructure using standard WebSocket protocols, incurring no external per-connection or per-message vendor fees and keeping client and server contracts provider-neutral.
- **Update latency and read efficiency under load**: **strong** — Pushes committed revisions immediately upon publication with subsecond delivery under normal connectivity, and performs work proportional to actual edits rather than browser count during quiet periods.
- **Operational and state-management simplicity**: **weak** — Requires `delivery` to manage long-lived socket capacity for up to 800 concurrent connections, heartbeats, connection draining on deploy, and cross-process fan-out, while requiring `change-store` to guarantee reliable publication and `browser-sync` to implement reconnect backoff and revision catch-up.
- **Explicit connectivity visibility and 20-minute recovery**: **strong** — Socket close events and missed heartbeats immediately expose connectivity loss in the UI, and explicit revision-cursor handshake on reconnect replays missed revisions from `change-store` up to the 20-minute retention window.

**Summary**: Delivers immediate push updates and zero vendor coupling at the cost of owning WebSocket session lifecycle, reliable internal publication, and client reconnect replay.

### Option 3: Hosted Realtime Service

Browsers subscribe to event channels through a managed third-party realtime provider SDK. When `change-store` commits an edit, `delivery` publishes the revision to the provider's HTTP/socket API, and the provider handles connection termination, fan-out to 800 browsers, and transport-level reconnects.

- **Vendor independence and recurring cost control**: **weak** — Introduces recurring peak-connection and message-fan-out charges across 40 weekend markets and couples subscription token minting, server publication, and browser connection state to a proprietary provider API.
- **Update latency and read efficiency under load**: **strong** — Pushes revisions with subsecond latency and offloads fan-out traffic from `change-store` and self-hosted HTTP workers.
- **Operational and state-management simplicity**: **partial** — Offloads socket termination and connection scaling to the vendor, but requires `change-store` and `delivery` to run an outbox and publication-reconciliation loop to handle provider API failures, plus credential rotation and vendor-outage handling.
- **Explicit connectivity visibility and 20-minute recovery**: **partial** — Provider SDKs manage transport reconnection, but aligning the provider's ephemeral channel history with MarketBoard's authoritative event revisions and 20-minute catch-up window still requires custom gap detection and snapshot fallback against MarketBoard's own API.

**Summary**: Offloads socket connection scaling for low-latency push, but introduces recurring vendor costs, provider coupling, and external publication reconciliation.

## Selection

Choose **Option 2: Self-Hosted WebSockets**.

Self-hosted WebSockets win on the two major criteria: they provide immediate push updates without constant polling read load (**Update latency and read efficiency under load**), and they avoid both recurring per-connection/per-message vendor fees and third-party SDK lock-in (**Vendor independence and recurring cost control**). While Option 1 (Five-Second HTTPS Polling) scores higher on **Operational and state-management simplicity**, accepting multi-second lag and 160 RPS of continuous cursor polling across 800 browsers is a worse trade than owning a bounded WebSocket tier for 800 connections. While Option 3 (Hosted Realtime Service) offloads socket termination, it still requires outbox reconciliation and custom revision catch-up while failing the major vendor-independence criterion.

This decision turns on the tenet *Prefer owning operational runtime over coupling to external realtime vendors when the latency benefit justifies the operational work*, while upholding *A committed edit has one authoritative event revision regardless of its delivery route* and *Connectivity failures must be visible, not mistaken for an unchanged board*.

Committing to self-hosted WebSockets forecloses a purely stateless delivery tier and obligates the three downstream nodes as follows:

- `change-store` must persist ordered, replayable event revisions covering at least the 20-minute reconnect window (and 7-day audit retention) and provide a reliable publication path so committed revisions are never silently dropped before reaching `delivery`.
- `delivery` must authenticate WebSocket subscriptions, maintain active event session registries for up to 800 browsers, emit heartbeats, and fan out published revisions.
- `browser-sync` must manage the WebSocket lifecycle, surface socket disconnects and missed heartbeats as visible stale-board state, and execute reconnect catch-up from its last applied revision with snapshot fallback.
```

Does this decision doc and the updated HLD look ready to approve for Phase 1? Once you confirm, let me know:
1. Whether I should also update the stale wording in `docs/intent/access/access-design.md` ("independent of the still-open change-delivery approach").
2. Which of the three nodes (`change-store`, `delivery`, or `browser-sync`) you want to tackle first in Phase 2.