Wrote `docs/decisions/change-delivery.md` and linked it from `docs/high-level-design.md` under `## Key Design Decisions`.

### `docs/decisions/change-delivery.md`

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Mechanism

## Context

MarketBoard coordinates 40 weekend markets with roughly 120 coordinators and up to 800 simultaneous staff browsers. A busy market has 10–25 editors averaging two stall-status changes per minute, with opening-time bursts up to 20 edits per second. Editors submit commands over HTTPS and the server commits each change with one authoritative event revision.

The board must show committed changes in connected browsers within 15 seconds under normal connectivity, recover the latest board after up to 20 minutes of browser disconnection, retain seven days of event revisions, and maintain 99.5% availability during published event hours. All three delivery mechanisms in this problem space can meet those baseline targets and satisfy the project's authorization and single-revision invariants.

Choosing a delivery mechanism sets the contract for three downstream components simultaneously: `change-store` (how revisions are indexed and published), `delivery` (how updates leave the server), and `browser-sync` (how browsers subscribe, detect disconnection, and catch up). Reversing the choice after those nodes are designed and implemented requires reworking all three.

## Decision Elements

All three options pass the standing architectural constraints — including the 15-second freshness goal, 800-browser concurrency, server-side command authorization, and the tenet that *self-hosted and managed infrastructure are both permitted* — so no binary gate eliminates an option in contention. Selection turns on weighted criteria:

- **Update latency and burst responsiveness (major):** How quickly committed stall changes appear in connected browsers, particularly during opening-time bursts of 20 edits per second. While 15 seconds is the hard freshness target, faster updates reduce coordination lag during active market setup.
- **Vendor independence and recurring cost control (major):** Avoiding recurring third-party realtime service fees and coupling board delivery semantics, credentials, or failure modes to an external realtime provider.
- **Operational simplicity and failure surface (moderate):** How little stateful connection infrastructure, capacity management, and reconnect/replay machinery the team must build, monitor, and operate.
- **Read-path efficiency under idle concurrency (moderate):** Avoiding unnecessary repeated reads across up to 800 browsers during typical periods averaging two changes per minute.
- **Connectivity failure visibility (moderate):** Directly engages the tenet *Connectivity failures must be visible, not mistaken for an unchanged board*. How readily the delivery transport surfaces a dropped or stalled connection so the browser can indicate stale state promptly.
- **Authoritative revision continuity across disconnects (moderate):** Engages the tenet *A committed edit has one authoritative event revision regardless of its delivery route*. How cleanly live delivery and catch-up after up to 20 minutes offline reconcile against the single authoritative revision stream without gaps or duplicate divergence.

## Options in the Domain

### Five-second HTTPS polling

**Description.** Delivery remains stateless request/response over HTTPS. Browsers run a polling loop every five seconds, sending their last applied event revision as a cursor. The `change-store` serves cursor queries returning any committed revisions since that cursor (or a full snapshot if the browser is too far behind). No persistent server-side connection state or pub/sub broker is needed; horizontal scaling uses standard stateless HTTP load balancing.

**Analysis.**
- *Update latency and burst responsiveness:* **weak** — introduces an average of 2.5 seconds and up to 5 seconds of polling lag per edit, plus request round-trip time, even when connectivity is healthy.
- *Vendor independence and recurring cost control:* **strong** — uses standard self-hosted HTTPS infrastructure with no third-party realtime vendor fees or provider lock-in.
- *Operational simplicity and failure surface:* **strong** — stateless request/response avoids long-lived connection pools, sticky sessions, socket memory limits, and live publication fan-out.
- *Read-path efficiency under idle concurrency:* **weak** — 800 browsers polling every five seconds generate ~160 read requests per second continuously, most returning empty results during normal two-edits-per-minute operation.
- *Connectivity failure visibility:* **partial** — failed or timed-out polls surface connectivity loss within one to two poll intervals (5–10 seconds), rather than immediately on transport drop.
- *Authoritative revision continuity across disconnects:* **strong** — live updates and 20-minute disconnect recovery use the same cursor-query path against the authoritative revision store, eliminating live-vs.-replay seam bugs.

**Summary.** Simplest stateless operation and unified catch-up path, trading away subsecond latency and read-path efficiency.

### Self-hosted WebSockets

**Description.** The `delivery` component maintains long-lived WebSocket sessions for connected browsers and fans out committed event revisions as they occur. The `change-store` persists replayable event revisions and provides reliable publication of committed changes to `delivery`. `browser-sync` maintains the WebSocket connection, monitors connection health, and runs reconnect and revision catch-up logic (requesting missed revisions since its last applied revision) after any disconnection up to 20 minutes.

**Analysis.**
- *Update latency and burst responsiveness:* **strong** — pushes committed changes to connected browsers in subsecond time, keeping opening-time bursts responsive without waiting on poll intervals.
- *Vendor independence and recurring cost control:* **strong** — runs on self-hosted infrastructure with no recurring realtime vendor bill and no dependency on third-party subscription protocols or credentials.
- *Operational simplicity and failure surface:* **weak** — requires owning connection capacity for 800+ concurrent sockets, graceful deploys/restarts, reliable store-to-delivery publication, and client reconnect/catch-up coordination.
- *Read-path efficiency under idle concurrency:* **strong** — idle connected browsers generate minimal heartbeat traffic rather than continuous store queries; work scales with actual edits rather than polling frequency.
- *Connectivity failure visibility:* **strong** — socket close events and missed heartbeats surface transport loss promptly, letting browsers mark the board disconnected rather than silently stale.
- *Authoritative revision continuity across disconnects:* **partial** — live push and post-disconnect replay are separate paths that must be carefully reconciled on event revision numbers so reconnects neither drop nor reorder committed edits.

**Summary.** Fast updates and full vendor independence with efficient idle concurrency, trading away stateless operational simplicity.

### Hosted realtime service

**Description.** A managed third-party realtime provider (e.g., hosted pub/sub or WebSocket service) owns browser connection capacity, fan-out, and transport-level reconnects. The `change-store` writes revisions and uses a publication reconciliation mechanism (such as an outbox) to publish committed events to the provider. `delivery` wraps the provider's publishing API and issues scoped subscription credentials; `browser-sync` uses the provider's client SDK and subscription model, falling back to the server for 20-minute catch-up if the provider's history window is exceeded.

**Analysis.**
- *Update latency and burst responsiveness:* **strong** — delivers subsecond push updates to connected browsers and absorbs opening-time fan-out bursts through managed edge infrastructure.
- *Vendor independence and recurring cost control:* **weak** — introduces recurring vendor fees (scaling with connections and messages) and couples `delivery` and `browser-sync` to a specific provider's credential model, SDK, and delivery guarantees.
- *Operational simplicity and failure surface:* **partial** — offloads socket capacity and fan-out scaling, but still requires managing provider credentials, handling provider outages, and building publication reconciliation between the authoritative store and the external service.
- *Read-path efficiency under idle concurrency:* **strong** — idle browsers stay connected to the managed provider rather than polling the origin store.
- *Connectivity failure visibility:* **strong** — provider SDK connection state callbacks surface disconnects promptly to the browser UI.
- *Authoritative revision continuity across disconnects:* **partial** — requires reconciling two externalized delivery boundaries (authoritative store → provider publication, and provider stream → origin catch-up on long disconnects) so missed provider publishes do not leave browsers behind.

**Summary.** Fast updates with less self-hosted socket operations, trading away vendor independence and recurring cost predictability while retaining store-to-provider reconciliation complexity.

## Selection

**Self-hosted WebSockets** is selected.

It is the only option with **strong** fit on both major criteria: it delivers fast, subsecond updates during active market operations and opening bursts without tying MarketBoard to a third-party realtime vendor or recurring per-connection/per-message fees. It also scores **strong** on read-path efficiency under 800 concurrent browsers and directly supports the tenet *Connectivity failures must be visible, not mistaken for an unchanged board* through prompt transport-drop detection.

The deliberate trade-off is accepting **weak** fit on operational simplicity (compared to five-second HTTPS polling) and **partial** fit on revision continuity across the live-push/replay boundary. Because the tenet *Self-hosted and managed infrastructure are both permitted* leaves both self-hosted and hosted paths open, this selection turns on prioritizing fast updates and vendor independence over minimizing self-hosted connection operations. To uphold the tenet *A committed edit has one authoritative event revision regardless of its delivery route*, the live push stream and disconnect catch-up path must both key strictly off authoritative event revisions.

### Implications and downstream obligations

- **Foreclosed:** Keeping delivery strictly stateless request/response, and offloading WebSocket connection scaling to a managed realtime provider.
- **`change-store`:** Must persist replayable event revisions (supporting at least 20-minute browser catch-up and 7-day operational retention) and provide reliable publication of committed changes to `delivery`.
- **`delivery`:** Must manage self-hosted WebSocket sessions, subscription authorization, connection capacity for 800+ simultaneous browsers, and live revision fan-out.
- **`browser-sync`:** Must implement WebSocket connection lifecycle management, explicit disconnected/stale UI state on transport loss, and reconnect catch-up from the browser's last applied event revision.
```

Please review `docs/decisions/change-delivery.md` and the HLD link. Once you approve Phase 1 (and let me know if you want to leave `## Tenets` and `docs/intent/access/access-design.md` as-is), tell me which of the three nodes (`change-store`, `delivery`, `browser-sync`) you want to draft first.