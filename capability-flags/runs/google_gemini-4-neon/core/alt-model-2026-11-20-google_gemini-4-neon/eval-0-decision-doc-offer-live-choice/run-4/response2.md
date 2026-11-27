Created `docs/decisions/change-delivery.md` and linked it from the **Key Design Decisions** entry in `docs/high-level-design.md`:

```markdown
---
node: high-level-design
---

# Decision: Self-Hosted WebSockets for Change Delivery

## Context

MarketBoard maintains one authoritative board per market event. Editors submit mutations over HTTPS, and up to 800 simultaneous staff browsers view the resulting revisioned board across 40 weekend markets. Busy markets average two status changes per minute with opening-time bursts up to 20 edits per second. Standing goals require committed changes to appear in connected browsers within 15 seconds under normal connectivity, recovery after up to 20 minutes disconnected, seven days of retained event revisions, and 99.5% availability during published event hours.

Three downstream design nodes — `change-store`, `delivery`, and `browser-sync` — are shaped directly by how committed changes move from the server to connected browsers. Polling, self-hosted WebSockets, and a hosted realtime service can each satisfy the 15-second freshness ceiling and standing tenets, but they impose incompatible contracts on revision storage, publication, server session handling, and browser recovery. Reversing this choice after those three nodes are specified and built requires redesigning all three together.

## Decision Elements

All three options satisfy the standing goals (15-second freshness, 800 simultaneous browsers, 20 edits/sec bursts, 20-minute disconnect recovery, seven-day retention) and standing tenets (including *Self-hosted and managed infrastructure are both permitted*), so no gate eliminates an option in contention. Selection turns on the following weighted criteria:

- **Update latency and burst responsiveness (major):** How quickly committed edits reach connected browsers under normal load and during 20-edits/sec opening-time bursts. Faster-than-ceiling delivery reduces coordination mistakes when multiple staff act on stall status changes simultaneously.
- **Vendor cost and provider independence (major):** Exposure to recurring realtime-provider fees and architectural coupling to a third-party vendor's subscription model, credential flow, and operational limits.
- **Operational simplicity and deploy resilience (moderate):** Effort and operational risk of maintaining 99.5% availability during published event hours, including connection capacity for 800 browsers, server restarts or rolling deploys, and thundering-herd reconnects.
- **Connectivity failure visibility (moderate — derives from tenet *Connectivity failures must be visible, not mistaken for an unchanged board*):** How promptly and reliably a browser detects that live updates have stopped and surfaces a disconnected state rather than presenting a stale board as current.
- **Steady-state read load and revision consistency (minor — relates to tenet *A committed edit has one authoritative event revision regardless of its delivery route*):** Background read load across 800 connected browsers during quiet periods (~2 edits/min) and the coordination needed to keep delivered updates aligned with authoritative store revisions.

## Options in the Domain

### Five-second HTTPS polling

**Description**
Browsers run a five-second polling loop over HTTPS, requesting changes since their last known event revision. `change-store` exposes cursor-indexed revision queries, `delivery` remains a stateless request/response HTTP tier serving incremental deltas or snapshots, and `browser-sync` schedules polls, applies returned revisions in order, and flags connectivity loss when consecutive polls fail or time out.

**Analysis**
- **Update latency and burst responsiveness:** **weak** — Introduces up to five seconds of polling lag plus request round-trip time under normal conditions; opening-time bursts arrive in batched five-second windows rather than continuously.
- **Vendor cost and provider independence:** **strong** — Uses standard HTTPS infrastructure with no realtime vendor fees or third-party subscription coupling.
- **Operational simplicity and deploy resilience:** **strong** — Stateless HTTP handlers scale horizontally behind standard load balancers, tolerate rolling deploys and server restarts without dropping long-lived sessions, and avoid reconnect storms.
- **Connectivity failure visibility:** **partial** — Failures are detected reliably on the next failed or timed-out poll cycle, typically within 5–10 seconds, rather than on immediate socket drop.
- **Steady-state read load and revision consistency:** **partial** — 800 browsers polling every five seconds generate ~160 read requests per second even when a market has zero edits; however, every response reads directly from the authoritative revision store with no separate publication pipeline to reconcile.

**Summary**
Simplest stateless operations and full independence, trading away sub-second updates and accepting constant background read traffic.

### Self-hosted WebSockets

**Description**
Connected browsers hold persistent WebSocket connections to MarketBoard's own delivery servers. `change-store` persists replayable event revisions and reliably publishes committed edits (e.g., via transactional outbox or equivalent durable handoff), `delivery` authenticates subscriptions, manages long-lived WebSocket sessions, enforces connection capacity, and fans out edits to subscribed browsers, and `browser-sync` maintains the socket, detects drops, reconnects, and replays missed revisions from the store.

**Analysis**
- **Update latency and burst responsiveness:** **strong** — Committed edits are pushed immediately over open sockets, delivering sub-second updates during steady state and smooth incremental delivery during 20-edits/sec bursts.
- **Vendor cost and provider independence:** **strong** — Runs on self-hosted infrastructure with no recurring realtime vendor fees and no third-party subscription or credential coupling.
- **Operational simplicity and deploy resilience:** **weak** — Requires owning stateful connection capacity for 800+ sockets, heartbeat/timeout tuning, graceful draining during deploys or restarts, and jittered reconnect/catch-up behavior to avoid reconnect storms during event hours.
- **Connectivity failure visibility:** **strong** — Socket close events and explicit server/client heartbeats allow browsers to detect dropped connections promptly and surface stale-connection status.
- **Steady-state read load and revision consistency:** **partial** — Eliminates repeated empty reads during quiet periods (reads occur on initial load and reconnect catch-up), but requires reliable publication from `change-store` to `delivery` plus revision-ordered replay to keep live push and catch-up strictly aligned with authoritative revisions.

**Summary**
Fast updates without realtime vendor fees or lock-in, trading away stateless simplicity and taking on connection-capacity and reconnect operations.

### Hosted realtime service

**Description**
A managed third-party realtime provider terminates browser connections and fans out updates. `change-store` persists authoritative revisions and runs publication reconciliation to ensure committed edits reach the provider, `delivery` wraps the provider's publish API and issues scoped subscription tokens, and `browser-sync` connects using the provider's client SDK and falls back to revision catch-up on disconnect.

**Analysis**
- **Update latency and burst responsiveness:** **strong** — Managed edge fan-out delivers sub-second updates under normal traffic and absorbs 20-edits/sec bursts without custom fan-out tuning.
- **Vendor cost and provider independence:** **weak** — Incurs recurring usage/connection fees and couples `delivery` and `browser-sync` to the provider's channel model, auth tokens, rate limits, and client SDK.
- **Operational simplicity and deploy resilience:** **partial** — Offloads stateful WebSocket termination, connection scaling, and rolling-deploy socket churn to the provider, while adding external-service failure handling, provider credential management, and cross-boundary publication reconciliation.
- **Connectivity failure visibility:** **strong** — Provider client SDKs emit explicit connection-state transitions so browsers can surface disconnect status promptly.
- **Steady-state read load and revision consistency:** **partial** — Avoids steady-state polling reads, but introduces an external publication boundary where failed or delayed publishes must be reconciled against authoritative store revisions.

**Summary**
Quickest path to low-latency delivery with lower connection-ops burden, trading away cost predictability and architectural independence from a realtime vendor.

## Selection

**Self-hosted WebSockets** is selected.

Against the two major criteria, self-hosted WebSockets is the only option with a **strong** fit on both **update latency and burst responsiveness** and **vendor cost and provider independence**. Five-second HTTPS polling avoids vendor coupling and offers the simplest stateless operations, but scores **weak** on update latency and imposes steady background read load across 800 browsers. A hosted realtime service matches WebSockets on latency and reduces connection-ops work, but scores **weak** on recurring vendor cost and provider coupling.

This choice explicitly accepts the **weak** fit on **operational simplicity and deploy resilience** — owning stateful connection capacity, rolling-deploy connection draining, and reconnect/catch-up mechanics — as a manageable operational cost at 800 simultaneous browsers in exchange for fast updates and full architectural independence. It aligns with the tenet *Connectivity failures must be visible, not mistaken for an unchanged board* through immediate socket-state and heartbeat detection, preserves *A committed edit has one authoritative event revision regardless of its delivery route* by anchoring live push and reconnect replay to the store's authoritative revision sequence, and operates within *Self-hosted and managed infrastructure are both permitted*.

**What this forecloses**
- Keeping `delivery` as a purely stateless HTTP request/response tier.
- Offloading WebSocket termination and fan-out operations to a managed realtime vendor without reworking `delivery` and `browser-sync`.

**Downstream obligations**
- `change-store`: Persist replayable event revisions (covering 20-minute disconnect catch-up and seven-day retention) and reliably publish committed changes for live fan-out.
- `delivery`: Own WebSocket session lifecycle, subscription authorization, connection capacity for 800 simultaneous browsers, live fan-out during 20-edits/sec bursts, and graceful disconnect/drain handling across deploys.
- `browser-sync`: Own WebSocket subscription lifecycle, prompt disconnect visibility, jittered reconnect, and revision-ordered catch-up from `change-store` without gaps or duplicate application.

**Revisit triggers**
Re-evaluate this decision if stateful connection operations or reconnect storms jeopardize the 99.5% event-hours availability goal, or if simultaneous browser concurrency scales well beyond the 800-browser target.
```

Please review `docs/high-level-design.md` and `docs/decisions/change-delivery.md`. Once approved (or with any revisions), let me know if you want to clean up the "still-open" phrasing in `docs/intent/access/access-design.md` and which of the three nodes (`change-store`, `delivery`, `browser-sync`) we should start in Phase 2.