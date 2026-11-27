Written to `docs/decisions/change-delivery.md` and linked from `docs/high-level-design.md` (`## Key Design Decisions`):

```markdown
---
node: high-level-design
---

# Decision: Change Delivery

## Context

MarketBoard maintains one authoritative board per event. Editors submit mutations over HTTPS, and up to 800 simultaneous staff browsers view the resulting board state across busy markets with 10–25 editors, averaging two edits per minute with opening-time bursts up to 20 edits per second.

All viable delivery mechanisms must satisfy the project's baseline requirements: deliver committed changes within 15 seconds under normal connectivity, recover the latest board after up to 20 minutes of browser disconnection, retain seven days of event revisions, and operate at 99.5 percent availability during published event hours. Because all three options in the domain can meet these baselines, none is eliminated by a hard gate.

The choice of delivery mechanism shapes three downstream design nodes together—`change-store` (revision history, read indexes, and publication), `delivery` (request handling, socket sessions, or provider wrapping), and `browser-sync` (polling, reconnects, and catch-up). Reversing the choice later requires redesigning all three nodes.

## Decision Elements

All three options satisfy the 15-second freshness floor, scale requirements, and single-region pilot scope. The criteria below are the ones that differentiate them:

- **Update responsiveness (major):** How quickly committed edits reach connected staff browsers during normal traffic and opening-time bursts of 20 edits per second. Subsecond delivery is not a hard requirement, but fast propagation reduces duplicate coordinator actions during opening-time bursts.
- **Vendor independence and cost predictability (major):** Avoiding recurring realtime vendor fees and runtime coupling to a third-party delivery provider's connection quotas, SDK, and availability. Per the tenet *Self-hosted and managed infrastructure are both permitted*, managed delivery is weighed on this criterion rather than barred as a gate.
- **Operational simplicity (moderate):** Minimizing stateful infrastructure and failure modes required to hold 99.5 percent availability for 800 concurrent browsers—including connection capacity, deploy-time reconnect storms, and session lifecycle management.
- **Authoritative revision alignment (moderate):** Grounded in the tenet *A committed edit has one authoritative event revision regardless of its delivery route*. How directly delivery preserves the change store's revision sequence without reconciliation gaps across an external broker, including 20-minute disconnect catch-up.
- **Connectivity failure visibility (minor):** Grounded in the tenet *Connectivity failures must be visible, not mistaken for an unchanged board*. How promptly a browser detects a broken delivery path and surfaces stale state to staff.

## Options in the Domain

### Five-Second HTTPS Polling

**Description:** Browsers run a polling loop on a five-second interval, requesting changes since their last known event revision over HTTPS. `change-store` exposes cursor-based revision queries; `delivery` stays a stateless request/response endpoint returning revision deltas or snapshots; `browser-sync` manages the polling timer, backoff, and cursor advancement. No persistent connections or pub/sub infrastructure are required.

**Analysis:**
- *Update responsiveness:* **weak** — Introduces up to five seconds of polling lag on every edit plus request latency; opening-time bursts arrive in five-second batches rather than continuously.
- *Vendor independence and cost predictability:* **strong** — Uses standard HTTPS hosting with no realtime vendor fees or provider lock-in; cost scales with HTTP request volume.
- *Operational simplicity:* **strong** — Fully stateless delivery; standard load balancing, zero-downtime deploys, and no connection-capacity or thundering-herd session management.
- *Authoritative revision alignment:* **strong** — Browsers read revision cursors directly from `change-store`, eliminating publication drift between storage and delivery.
- *Connectivity failure visibility:* **partial** — Failed polls surface connectivity loss within one poll interval plus timeout, slower than an active socket drop.

**Summary:** Simplest stateless operation and direct store alignment, traded for multi-second update lag and repeated read load.

### Self-Hosted WebSockets

**Description:** MarketBoard runs its own WebSocket tier alongside the HTTPS command API. `change-store` persists replayable event revisions and reliably publishes committed changes; `delivery` manages authenticated WebSocket sessions, connection capacity, and fan-out to subscribed event boards; `browser-sync` maintains the socket lifecycle, heartbeats, reconnect backoff, and revision-based replay catch-up after disconnects.

**Analysis:**
- *Update responsiveness:* **strong** — Pushes committed revisions to connected browsers in subsecond time, keeping boards current during 20-edit/sec opening bursts.
- *Vendor independence and cost predictability:* **strong** — No recurring per-connection or per-message realtime vendor bill and no dependency on a third-party provider's protocol or uptime.
- *Operational simplicity:* **weak** — Requires owning stateful connection capacity for 800 concurrent browsers, graceful deploy drains, reconnect-storm handling, and reliable store-to-delivery publication.
- *Authoritative revision alignment:* **strong** — Publication and replay read directly from `change-store` revisions under MarketBoard's control, keeping live pushes and 20-minute catch-up on one revision sequence.
- *Connectivity failure visibility:* **strong** — Socket close events and heartbeats detect broken connections promptly so browsers can surface disconnected state immediately.

**Summary:** Fast updates and full vendor independence with direct revision alignment, traded for owning WebSocket session operations and reconnect complexity.

### Hosted Realtime Service

**Description:** MarketBoard delegates persistent browser connections to a managed realtime messaging provider. `change-store` writes revisions and reconciles publication to the provider; `delivery` wraps the provider's publish API and issues subscription credentials; `browser-sync` uses the provider's client SDK for subscriptions and falls back to `change-store` snapshots or replay when reconnecting after a gap.

**Analysis:**
- *Update responsiveness:* **strong** — Pushes committed revisions to connected browsers in subsecond time with provider-managed fan-out.
- *Vendor independence and cost predictability:* **weak** — Introduces recurring usage-based vendor fees and couples `delivery` and `browser-sync` to a specific provider's subscription model, quotas, and service availability.
- *Operational simplicity:* **partial** — Offloads WebSocket connection capacity and fan-out scaling, but adds provider credential management, SDK lifecycle, and store-to-provider publication reconciliation.
- *Authoritative revision alignment:* **partial** — Introduces an external broker between `change-store` and browsers; dropped or out-of-order provider publications require explicit reconciliation against the store's authoritative revision sequence.
- *Connectivity failure visibility:* **strong** — Provider SDKs expose live connection state and disconnect callbacks promptly.

**Summary:** Fastest path to low-latency push with less connection-tier operations, traded for recurring vendor fees, provider coupling, and external publication reconciliation.

## Selection

**Self-Hosted WebSockets** is selected.

It is the only option with a **strong** fit on both major criteria—*update responsiveness* and *vendor independence and cost predictability*—while also scoring **strong** on *authoritative revision alignment* (upholding *A committed edit has one authoritative event revision regardless of its delivery route*) and *connectivity failure visibility* (upholding *Connectivity failures must be visible, not mistaken for an unchanged board*). Five-second HTTPS polling avoids stateful delivery operations but gives up fast update propagation and adds continuous read traffic; a hosted realtime service avoids connection-tier operations but introduces recurring vendor fees, provider coupling, and reconciliation across an external broker.

This selection knowingly accepts a **weak** fit on *operational simplicity*. That trade is bounded by the pilot's scale (800 concurrent browsers, single-region) and remains consistent with *Self-hosted and managed infrastructure are both permitted*, which leaves infrastructure choice to the merits of each component rather than mandating managed services.

**Implications and downstream obligations:**
- **Forecloses:** Stateless request/response-only delivery and offloading connection scaling to a third-party realtime provider.
- **`change-store`:** Must persist replayable event revisions (supporting both 20-minute reconnect catch-up and 7-day retention) and provide reliable publication of committed revisions to `delivery`.
- **`delivery`:** Must own WebSocket session lifecycle, subscription authorization, connection capacity for 800 simultaneous browsers, graceful drains, and per-event fan-out.
- **`browser-sync`:** Must own WebSocket connection management, heartbeat/disconnect detection that visibly surfaces connectivity loss, reconnect backoff, and revision-based catch-up replay.
```

Please review `docs/decisions/change-delivery.md` and `docs/high-level-design.md`—let me know any edits, whether you want me to clean up the "still-open change-delivery approach" phrasing in `docs/intent/access/access-design.md`, and which downstream node (`change-store`, `delivery`, or `browser-sync`) you want to draft first once Phase 1 is approved.