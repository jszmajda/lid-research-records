I have written the decision doc at `docs/decisions/change-delivery.md` and linked it from `docs/high-level-design.md` under `Key Design Decisions`.

### `docs/decisions/change-delivery.md`

```markdown
---
node: high-level-design
---

# Decision: Change-Delivery Mechanism

## Context

MarketBoard serves 40 weekend markets, where roughly 120 coordinators maintain stall-status boards viewed by up to 800 simultaneous staff browsers. A busy market has 10-25 active editors and averages two status changes per minute, with opening-time bursts reaching 20 edits per second.

Editors submit commands over HTTPS to a single authoritative server per event, which assigns each committed edit a monotonic event revision. Connected browsers must reflect committed changes within 15 seconds under normal connectivity and recover the latest board after disconnections of up to 20 minutes.

The change-delivery mechanism determines not only how updates cross the network, but also the responsibilities of three downstream components:
- `change-store`: whether it serves repeated cursor queries, replayable revision streams with reliable publication, or external provider reconciliation.
- `delivery`: whether it handles stateless HTTP responses, stateful socket sessions, or third-party provider webhooks/SDK calls.
- `browser-sync`: whether browsers run a timer-driven polling loop, manage WebSocket connections with reconnect/catch-up logic, or embed a vendor subscription client.

## Decision Elements

All three options satisfy the foundational invariants in the HLD: one authoritative event revision per committed edit, visible connectivity failures (`Connectivity failures must be visible, not mistaken for an unchanged board`), and the 15-second freshness target. Both self-hosted and managed infrastructure are permitted by the project tenets (`Self-hosted and managed infrastructure are both permitted`). Because every option passes those baselines, selection turns on the following graded criteria:

- **Update latency during active coordination (major)** — How quickly committed changes reach connected staff browsers after an editor submits a command, particularly during opening-time bursts when coordinators are actively triaging stall closures and power problems.
- **Vendor independence and recurring cost (major)** — Freedom from third-party realtime provider lock-in, external credential/outage dependencies, and per-connection or per-message recurring billing across 800 concurrent weekend browsers.
- **Server and client operational simplicity (moderate)** — The engineering and operational work required to run connections, handle dropped sessions, and recover missed revisions across the store, delivery layer, and browser client.
- **Read load efficiency under steady state (minor)** — Avoiding redundant database or cache reads when boards are quiet between edits.

## Options in the Domain

### Five-second HTTPS polling

Browsers request changes since their last known revision every five seconds over standard HTTPS (`GET /events/{id}/changes?since={rev}`). The delivery tier remains stateless request/response, and the change store serves indexed cursor queries over recent revisions.

**Analysis:**
- **Update latency during active coordination (major): partial** — Meets the 15-second requirement with an average lag of ~2.5 seconds and a normal ceiling of 5 seconds plus request round-trip, but feels noticeably delayed when coordinators are watching changes land live during opening bursts.
- **Vendor independence and recurring cost (major): strong** — Uses standard HTTPS infrastructure with no third-party realtime vendor, SDK, or per-message fee.
- **Server and client operational simplicity (moderate): strong** — Stateless HTTP handlers require no persistent connection registry, session draining, or socket capacity management; browser recovery after a disconnect uses the same polling loop as normal operation.
- **Read load efficiency under steady state (minor): weak** — 800 browsers polling every 5 seconds generate 160 requests per second even when no edits are occurring, requiring cache or read-index sizing for mostly empty responses.

**Summary:** Simplest to operate and completely vendor-free, at the cost of multi-second update lag and continuous baseline read traffic.

### Self-hosted WebSockets

Browsers open a persistent WebSocket connection to the MarketBoard delivery tier and subscribe to their event. When an edit commits, the change store persists the revision and publishes it to the delivery tier, which fans it out to subscribed sockets. On reconnect, browsers present their last seen revision to replay missed revisions (or fetch a full snapshot if too far behind).

**Analysis:**
- **Update latency during active coordination (major): strong** — Pushes committed revisions immediately upon publication, delivering subsecond updates under normal connectivity.
- **Vendor independence and recurring cost (major): strong** — Runs on self-hosted application infrastructure with standard WebSocket protocols, avoiding recurring realtime vendor bills and proprietary client/server coupling.
- **Server and client operational simplicity (moderate): weak** — MarketBoard owns persistent connection capacity (up to 800 concurrent sockets), heartbeat/liveness detection, reliable store-to-delivery publication, and explicit client reconnect and catch-up state machines.
- **Read load efficiency under steady state (minor): strong** — Idle boards consume only lightweight keepalive frames; reads occur only on initial load, edit publication, and reconnect replay.

**Summary:** Delivers fast updates without vendor lock-in or recurring realtime fees, in exchange for owning connection management and reconnect/replay mechanics.

### Hosted realtime service

Browsers subscribe to event channels through a managed realtime provider. When an edit commits to the change store, the delivery tier publishes the revision to the provider's API, and the provider handles connection fan-out, heartbeats, and regional socket termination.

**Analysis:**
- **Update latency during active coordination (major): strong** — Pushes committed revisions in subsecond time once published to the provider.
- **Vendor independence and recurring cost (major): weak** — Incurs ongoing per-connection and per-message charges and couples `delivery` and `browser-sync` to a vendor SDK, token-minting flow, and external service availability.
- **Server and client operational simplicity (moderate): partial** — Offloads socket termination and connection scaling to the vendor, but requires the change store and delivery tier to implement an outbox and publication reconciliation so committed edits are never silently dropped when the provider API fails or times out.
- **Read load efficiency under steady state (minor): strong** — Quiet boards do not generate origin read traffic; idle connection state is held by the provider.

**Summary:** Offloads socket connection ops while achieving low latency, but introduces recurring vendor fees, provider coupling, and external publication reconciliation.

## Selection

**Chosen: Self-hosted WebSockets.**

Self-hosted WebSockets is the only option that scores **strong** on both major criteria: subsecond update delivery during active coordination and full independence from a third-party realtime vendor. While five-second polling is simpler to operate, it introduces multi-second lag and continuous idle read traffic. While a hosted realtime service offloads socket capacity management, it introduces recurring vendor costs and couples both server delivery and browser clients to an external provider — without even eliminating server-side reliability work, since the store still must reconcile failed external publications.

At MarketBoard's scale (800 concurrent browsers and bursts of 20 edits per second), self-hosted WebSocket connection capacity fits comfortably within standard application infrastructure. We accept the moderate operational tradeoff — building and operating socket session management, reliable publication, and reconnect replay — in order to get fast updates without tying the board to a realtime vendor.

Regarding tenets:
- The tenet *Self-hosted and managed infrastructure are both permitted* leaves both hosted and self-hosted routes open; selection here turns on weighing vendor coupling and recurring cost against bounded self-hosted connection work.
- The tenet *A committed edit has one authoritative event revision regardless of its delivery route* obligates the change store and delivery tier to treat WebSocket frames strictly as projections of committed store revisions, never as unpersisted broadcast messages.
- The tenet *Connectivity failures must be visible, not mistaken for an unchanged board* obligates `browser-sync` and `delivery` to use explicit heartbeats and connection-state tracking so dropped sockets surface immediately to the coordinator.

**Downstream obligations:**
- `change-store` must persist ordered event revisions, support replay queries from a client's last seen revision (covering at least the 20-minute disconnect recovery window), and reliably publish committed revisions to `delivery`.
- `delivery` must authenticate and manage WebSocket sessions, track event subscriptions, emit heartbeats, and fan out published revisions to connected sockets.
- `browser-sync` must maintain the WebSocket lifecycle, surface disconnected states to the user, reconnect with backoff, and catch up from the last applied revision (via replay or snapshot fallback) before resuming live updates.
```

---

### Ready for your approval (Phase 1 stop)

Does the updated HLD and `docs/decisions/change-delivery.md` capture the decision as you want it? Also, let me know if you want to:
1. Keep `## Tenets` as-is or add a vendor-independence tie-breaker tenet.
2. Touch `docs/intent/access/access-design.md` (removing "still-open" on line 10) or leave `access` alone.
3. Proceed to Phase 2 (LLD drafting) — and if so, which of the three nodes (`change-store`, `delivery`, `browser-sync`) you'd like to tackle first.