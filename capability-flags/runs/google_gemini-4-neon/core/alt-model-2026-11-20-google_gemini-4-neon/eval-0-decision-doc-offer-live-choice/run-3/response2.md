I wrote `docs/decisions/change-delivery.md` and linked it from `docs/high-level-design.md` under `Key Design Decisions`. Here is the decision doc for review:

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Mechanism

## Context

This decision builds on the HLD's HTTPS command boundary: editors submit commands to the server, which assigns each committed edit one authoritative event revision per board.

MarketBoard serves 40 weekend markets with roughly 120 coordinators and up to 800 simultaneous staff browsers. A busy market has 10–25 editors averaging two status changes per minute, with opening-time bursts up to 20 edits per second. Connected browsers must reflect committed changes within 15 seconds under normal connectivity, recover the latest board after up to 20 minutes disconnected, and maintain 99.5% availability during published event hours.

Three delivery mechanisms can satisfy the 15-second freshness goal and are permitted by the project's tenets (which allow both self-hosted and managed infrastructure and require one authoritative event revision regardless of delivery route). The choice cannot be deferred or isolated to one component: `change-store`, `delivery`, and `browser-sync` are all shaped around it — storage query patterns, publication reliability, server session management, and browser recovery logic depend directly on how committed edits reach browsers.

## Decision Elements

All three options satisfy the 15-second freshness ceiling, the single-authoritative-revision invariant, and the infrastructure-hosting policy, so none of those act as eliminating gates. Selection turns on the following weighted criteria:

- **Update latency and burst responsiveness** (**major**): How quickly committed edits reach connected browsers, especially during opening-time bursts of 20 edits per second across up to 800 browsers. While 15 seconds is the hard ceiling, sub-second or near-instant updates reduce stale-board coordination errors during opening rushes.
- **Vendor independence and predictable operating cost** (**major**): Avoiding recurring per-connection or per-message realtime vendor bills and avoiding architectural coupling to a third-party provider's subscription model, quotas, and credential lifecycle. The HLD tenet *Self-hosted and managed infrastructure are both permitted* leaves managed services allowed as policy; this criterion weighs the operational and financial cost of taking on a realtime vendor dependency.
- **Connection and reconnect operational burden** (**moderate**): The engineering and operational cost of managing connection capacity for 800 simultaneous browsers, fan-out across server instances, and reconnect/catch-up storms during spotty venue connectivity while holding 99.5% event-hour availability.
- **Connectivity-failure visibility and gap-free recovery** (**moderate**): How reliably disconnects are detected and surfaced to staff browsers, and how cleanly browsers catch up after up to 20 minutes offline without missing or silently stalling on revisions. Directly engages the HLD tenets *Connectivity failures must be visible, not mistaken for an unchanged board* and *A committed edit has one authoritative event revision regardless of its delivery route*.
- **Steady-state read amplification** (**minor**): Background read load placed on the change store when 800 browsers remain open during quiet periods (averaging two edits per minute).

## Options in the Domain

### Five-Second HTTPS Polling

**Description.** Browsers periodically issue HTTPS requests (every five seconds) carrying their last seen event revision. The change store serves cursor-based revision queries; delivery remains stateless request/response endpoints behind standard load balancing; browsers run a polling loop, apply returned revisions in order, and fall back to a snapshot if the gap exceeds replay bounds.

**Analysis**

- *Update latency and burst responsiveness*: **weak** — Connected browsers experience up to five seconds of lag on every edit plus request round-trip time, and burst edits arrive in coarse five-second batches rather than continuously.
- *Vendor independence and predictable operating cost*: **strong** — Uses only standard HTTPS hosting with no realtime vendor fees or provider-specific SDKs.
- *Connection and reconnect operational burden*: **strong** — Delivery stays stateless; there are no long-lived socket sessions to balance, drain on deploy, or recover in a reconnect storm.
- *Connectivity-failure visibility and gap-free recovery*: **partial** — Failed polls surface connectivity loss within one poll interval and cursor queries provide deterministic revision catch-up, but transient drops between poll ticks are not surfaced until the next scheduled poll.
- *Steady-state read amplification*: **weak** — 800 browsers polling every five seconds generate ~160 requests per second against the backend even when no edits are occurring.

**Summary.** Simplest stateless operation at the cost of multi-second lag and constant background read traffic.

### Self-Hosted WebSockets

**Description.** Browsers open a persistent WebSocket connection to the self-hosted delivery service and subscribe to an event board. The change store persists replayable event revisions and reliably publishes committed edits; the delivery service manages WebSocket sessions, subscription authorization, live fan-out, and replay handoff; browsers maintain the connection, visibly flag disconnects, reconnect with backoff, and catch up from their last seen revision.

**Analysis**

- *Update latency and burst responsiveness*: **strong** — Committed edits are pushed immediately to subscribed browsers, delivering sub-second updates during both steady state and 20 edits/second bursts.
- *Vendor independence and predictable operating cost*: **strong** — Runs on self-hosted infrastructure with no recurring realtime-vendor usage fees or external subscription-protocol lock-in.
- *Connection and reconnect operational burden*: **weak** — The team owns long-lived connection capacity for 800 simultaneous browsers, graceful restarts, fan-out coordination, and reconnect/catch-up load under unstable market-venue networks.
- *Connectivity-failure visibility and gap-free recovery*: **strong** — Socket close events and heartbeats surface disconnects promptly, and replayable revisions in the change store give deterministic, gap-free catch-up from the browser's last seen revision.
- *Steady-state read amplification*: **strong** — Edits are pushed on commit; the change store handles reads only on initial board load and post-disconnect catch-up.

**Summary.** Fast updates and full vendor independence in exchange for owning stateful connection and reconnect operations.

### Hosted Realtime Service

**Description.** Browsers subscribe to event channels through a third-party managed realtime service (e.g., Pusher, Ably, or a cloud managed WebSocket/pub-sub service). The change store persists authoritative revisions and uses a publication outbox or reconciliation mechanism to push commits to the provider; delivery wraps the provider's channel credentials and publishing API; browsers use the provider's client SDK for subscriptions and fall back to the server for revision catch-up when gaps occur.

**Analysis**

- *Update latency and burst responsiveness*: **strong** — Managed edge connections push committed edits to connected browsers with sub-second latency, including during opening-time bursts.
- *Vendor independence and predictable operating cost*: **weak** — Introduces recurring connection/message fees and couples delivery and browser sync to a provider's channel model, limits, and token lifecycle.
- *Connection and reconnect operational burden*: **partial** — Offloads raw socket scaling and connection infrastructure, though the team still owns reliable publication reconciliation between the change store and the provider plus provider credential management.
- *Connectivity-failure visibility and gap-free recovery*: **partial** — Provider SDKs surface connection state, but separating authoritative revision storage from third-party message delivery requires explicit reconciliation so missed or out-of-order publications do not leave browsers silently behind.
- *Steady-state read amplification*: **strong** — Pushes occur only on commit, avoiding continuous background polling reads against the change store.

**Summary.** Low-latency updates with reduced raw socket operations at the cost of recurring vendor fees, provider coupling, and publication reconciliation.

## Selection

**Self-Hosted WebSockets** is selected.

It is the only option with a **strong** fit on both **major** criteria: delivering fast updates during opening-time bursts while keeping operating costs predictable and avoiding coupling to a realtime vendor. Five-second HTTPS polling avoids stateful connection management but gives up fast updates and introduces steady-state read amplification; a hosted realtime service matches the latency profile but introduces recurring vendor fees, provider coupling, and an extra store-to-provider publication reconciliation boundary.

This selection explicitly accepts a **weak** fit on **connection and reconnect operational burden**. At MarketBoard's scale (800 simultaneous browsers, 40 markets, single-region pilot), owning WebSocket session capacity and reconnect recovery is bounded and preferable to vendor coupling or multi-second polling lag.

**Tenet alignment:**

- *A committed edit has one authoritative event revision regardless of its delivery route* — preserved because the change store remains the sole source of ordered revisions, and WebSocket push and reconnect replay both carry those revisions.
- *Connectivity failures must be visible, not mistaken for an unchanged board* — directly reinforced by persistent socket lifecycle and heartbeat monitoring paired with explicit browser connection state.
- *Self-hosted and managed infrastructure are both permitted* — remains intact at the project level; this choice declines a managed realtime provider on cost and coupling grounds rather than a blanket ban on managed services.

**Implications and downstream obligations:**

- Forecloses stateless request/response-only delivery and offloaded socket infrastructure.
- **`change-store`** must persist replayable event revisions (covering 20-minute reconnect recovery and seven-day operational retention) and provide reliable publication of committed edits.
- **`delivery`** must own WebSocket session management, subscription authorization, live fan-out at 800 browsers and 20 edits/second bursts, and revision replay handoff.
- **`browser-sync`** must own WebSocket subscription management, visible disconnect/stale indicators, reconnect backoff, and gap-free catch-up from the last seen revision.

Revisit this decision if self-hosted WebSocket operations or venue-network reconnect storms materially threaten the 99.5% event-hour availability goal, or if browser concurrency grows far beyond the pilot's 800-browser envelope.
```

Let me know if you want any adjustments to `docs/decisions/change-delivery.md` or `docs/high-level-design.md`, whether you want the stale phrasing in `docs/intent/access/access-design.md` ("the still-open change-delivery approach") updated, and which of the three nodes (`change-store`, `delivery`, or `browser-sync`) you'd like to tackle first in Phase 2.