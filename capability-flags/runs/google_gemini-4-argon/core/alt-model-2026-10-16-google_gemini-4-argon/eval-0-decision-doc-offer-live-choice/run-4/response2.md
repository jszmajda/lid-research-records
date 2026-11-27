I have written `docs/decisions/change-delivery-transport.md` and linked it from `docs/high-level-design.md` under `## Key Design Decisions`:

```markdown
---
node: high-level-design
---

# Decision: Change-Delivery Transport

## Context

MarketBoard serves up to 800 simultaneous staff browsers across forty weekend markets, with 10-25 active editors on a busy market averaging two status changes per minute and opening-time bursts up to 20 edits per second. Editors submit commands over HTTPS, and each committed edit receives one authoritative event revision.

The system must deliver committed revisions to connected browsers within 15 seconds under normal connectivity, recover the latest board after up to 20 minutes of disconnection, and surface connectivity failures rather than letting a disconnected browser appear current. The delivery transport shapes three downstream components at once: how `change-store` indexes and publishes revisions, what `delivery` operates at runtime, and how `browser-sync` subscribes, detects staleness, and catches up.

## Decision Elements

- **Vendor independence and recurring cost predictability (major)** — Whether the core board-sync path stays free of third-party realtime provider SDKs, credential provisioning, and per-connection or per-message billing. The project's infrastructure tenet permits both self-hosted and managed infrastructure, leaving vendor coupling vs. operational ownership as a direct tradeoff.
- **Update latency and read amplification under load (moderate)** — How quickly committed edits reach up to 800 connected browsers during opening-time bursts of 20 edits per second, and whether quiet markets still generate continuous read traffic against the change store.
- **Connection and recovery operations burden (moderate)** — How much stateful session management, publication plumbing, and reconnect catch-up machinery the system must operate and maintain to keep browsers synchronized and make disconnections visible (per the tenet that connectivity failures must be visible, not mistaken for an unchanged board).
- **Multi-component failure surface (minor)** — Whether a committed write in the change store requires cross-vendor reconciliation or outbox recovery to guarantee it reaches the delivery channel (per the tenet that a committed edit has one authoritative event revision regardless of its delivery route).

## Options in the Domain

### Five-Second HTTPS Polling

- **Description** — Browsers request changes over standard stateless HTTPS every five seconds, passing the last seen event revision as a cursor (`?since=<revision>`). The delivery service queries the change store for revisions after that cursor and returns them in a normal HTTP response. If a browser falls behind the retention window of the cursor query or reconnects after a longer gap, it fetches a full board snapshot.
- **Analysis**
  - **Vendor independence and recurring cost predictability**: **strong** — Uses standard HTTPS request/response handling with no external realtime provider or per-connection fees.
  - **Update latency and read amplification under load**: **partial** — Meets the 15-second freshness goal with ~2.5-second average and 5-second worst-case polling delay, but 800 browsers polling every five seconds generate ~160 requests per second even when no edits occur.
  - **Connection and recovery operations burden**: **strong** — Delivery servers remain stateless with no long-lived socket registries, heartbeats, or server-push fan-out; recovery is an ordinary poll request with the last known cursor.
  - **Multi-component failure surface**: **strong** — Browsers read committed revisions directly from the change store via the HTTP handler; no separate publication pipeline can fall out of sync with committed writes.
- **Summary** — Simplest stateless operation, at the cost of multi-second update lag and constant baseline read traffic.

### Self-Hosted WebSockets

- **Description** — Browsers open a persistent WebSocket session to the MarketBoard delivery service for their assigned event. When an edit commits in the change store, the store publishes the new revision to the delivery service, which fans it out to subscribed sockets. Heartbeats detect dropped connections so browsers can visibly mark the board stale, reconnect, and replay missed revisions from the change store starting at their last applied revision (or load a snapshot if the gap is too large).
- **Analysis**
  - **Vendor independence and recurring cost predictability**: **strong** — Runs entirely on MarketBoard's own runtime and standard WebSocket protocols with no third-party realtime vendor coupling or usage-metered messaging fees.
  - **Update latency and read amplification under load**: **strong** — Pushes committed revisions subsecond as they occur and eliminates empty polling reads during quiet periods.
  - **Connection and recovery operations burden**: **weak** — MarketBoard owns stateful socket capacity for up to 800 concurrent connections, heartbeat monitoring, reliable store-to-delivery publication, and browser reconnect/replay sequencing.
  - **Multi-component failure surface**: **partial** — Requires internal publication from the change store to socket workers, though missed pushes are recoverable from the authoritative revision log on reconnect.
- **Summary** — Subsecond updates and zero vendor coupling, at the cost of owning stateful connection management and reconnect replay.

### Hosted Realtime Service

- **Description** — Browsers subscribe to event channels hosted by a managed realtime provider using short-lived tokens issued by the delivery service. After committing an edit to the change store, the server publishes the revision to the provider's API (backed by an outbox or reconciliation worker so transient provider errors do not drop committed revisions), and the provider handles socket termination, fan-out, and reconnect transport.
- **Analysis**
  - **Vendor independence and recurring cost predictability**: **weak** — Couples `delivery` and `browser-sync` to a provider's channel model, token lifecycle, and client SDK, and introduces recurring connection and message costs across 800 browsers.
  - **Update latency and read amplification under load**: **strong** — Pushes updates subsecond without baseline polling queries against the change store.
  - **Connection and recovery operations burden**: **partial** — Offloads socket termination and connection scaling to the provider, though MarketBoard still must issue subscription tokens and reconcile missed revisions after up-to-20-minute disconnects.
  - **Multi-component failure surface**: **weak** — Splits commit and delivery across an external network boundary, requiring an outbox and publication reconciliation loop so provider outages do not silently drop authoritative revisions.
- **Summary** — Offloads socket infrastructure for fast updates, at the cost of recurring vendor fees, SDK coupling, and external publication reconciliation.

## Selection

Choose **Self-Hosted WebSockets**.

All three options satisfy the 15-second freshness target and the 800-browser concurrency goal. Self-hosted WebSockets win because **vendor independence and recurring cost predictability** (major) and **update latency and read amplification** (moderate) outweigh the added **connection and recovery operations burden** (moderate). While the project's tenets permit both self-hosted and managed infrastructure, avoiding a third-party realtime provider eliminates recurring per-connection/per-message billing, provider SDK coupling in the browser, and external publication reconciliation across a vendor boundary. Compared to five-second HTTPS polling, WebSockets deliver subsecond updates during opening-time bursts without ~160 requests/second of idle polling load.

Committing to this option forecloses a purely stateless delivery tier and obligates the three downstream nodes as follows:
- `change-store` must persist ordered, replayable event revisions and reliably publish committed revisions to the delivery tier.
- `delivery` must authenticate and manage WebSocket sessions, track event subscriptions, run connection heartbeats, and fan out published revisions.
- `browser-sync` must maintain the WebSocket subscription, surface connection loss immediately per the visible-connectivity-failure tenet, and execute reconnect catch-up against the change store's revision history.
```

Please review the decision doc and HLD update. Once you approve Phase 1 (and let me know if you want the stale line in `docs/intent/access/access-design.md` cleaned up as well), which of the three nodes (`change-store`, `delivery`, or `browser-sync`) would you like to start with in Phase 2?