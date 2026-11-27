`docs/decisions/change-delivery.md` has been written and linked from `docs/high-level-design.md` under `## Key Design Decisions`. Here is the decision doc in full for Phase 1 review:

---

```markdown
---
node: high-level-design
---

# Decision: Change Delivery to Connected Browsers

## Context

MarketBoard commits all editor commands over HTTPS onto one server-assigned revision sequence per event (`docs/high-level-design.md` § Key Design Decisions); this decision governs how those committed revisions reach connected browsers.

Across 40 weekend markets, roughly 120 coordinators maintain stall-status boards viewed by up to 800 simultaneous staff browsers. A busy market has 10–25 active editors and averages two status changes per minute, with opening-time bursts up to 20 edits per second. Connected browsers must reflect committed changes within 15 seconds under normal connectivity, recover the latest board after disconnects of up to 20 minutes, and operate at 99.5 percent availability during published event hours while the store retains seven days of revisions. Because updates carry stall IDs and operational statuses rather than customer records, both self-hosted and managed infrastructure are permitted, and the 15-second freshness ceiling admits short-interval polling alongside push transports.

Three downstream subsystems—`change-store`, `delivery`, and `browser-sync`—are shaped directly by this choice. Polling centers the system on stateless cursor reads; self-hosted sockets center it on server-managed sessions, internal publication, and replay; a hosted realtime provider centers it on external publication reconciliation and vendor subscription lifecycles. Reversing the choice after implementation requires coordinated rewrites across storage publication, session delivery, and browser recovery.

## Decision Elements

Selection turns on five weighted criteria:

- **Vendor independence and predictable operating cost (major).** Avoids coupling `delivery` and `browser-sync` to a third-party realtime SDK, proprietary channel/auth semantics, and per-connection or per-message recurring charges across weekend peaks. Although the tenet *Self-hosted and managed infrastructure are both permitted* allows managed providers on data-sensitivity grounds, protocol independence and un-metered connection scaling remain direct architectural considerations.
- **Update latency and read efficiency (major).** Delivers committed edits promptly during active coordination—including 20-edit-per-second opening bursts—without generating high volumes of empty read traffic across 800 browsers when markets average two changes per minute.
- **Operational simplicity and deploy resilience (major).** Minimizes ongoing operational work to sustain 99.5 percent event-hour availability across rolling deploys, instance restarts, horizontal scaling, stateful connection limits, and outdoor mobile-network reconnect bursts.
- **Authoritative revision alignment (moderate).** Derived from the tenet *A committed edit has one authoritative event revision regardless of its delivery route*. Measures how directly live delivery and catch-up operate against the change store's single revision sequence without reconciling ordering, drops, or duplicates across an external broker boundary.
- **End-to-end connectivity visibility (moderate).** Derived from the tenet *Connectivity failures must be visible, not mistaken for an unchanged board*. Measures how directly and promptly a browser on a quiet market detects that it can no longer receive committed updates from MarketBoard itself, rather than mistaking transport silence or intermediary health for an unchanged board.

## Options in the Domain

### Five-Second HTTPS Polling

**Description.** Browsers run a periodic five-second timer that issues stateless HTTPS `GET` requests carrying the event ID and last applied revision cursor. `delivery` queries `change-store` against an indexed `(event_id, revision)` table and returns any committed revisions newer than the cursor (or a current snapshot when a browser initializes or falls outside its catch-up cursor expectation). Every server instance is stateless; load balancers distribute requests evenly without sticky routing or cross-instance pub/sub.

**Demonstration.**
```text
Browser ── GET /events/{id}/changes?after=142 ──▶ Delivery ──▶ Change Store
Browser ◀─ 200 OK { latestRevision: 144, changes: [143, 144] } ────────────
(repeats every 5s with jitter; failed polls mark board connectivity degraded)
```

**Analysis.**
- **Strong** on *Vendor independence and predictable operating cost*: uses standard browser `fetch` and HTTPS handlers on MarketBoard infrastructure with no external realtime provider, SDK, or connection meter.
- **Partial** on *Update latency and read efficiency*: meets the 15-second freshness goal (~2.5-second mean polling delay plus request latency), but adds multi-second lag compared with push and generates ~160 read requests per second across 800 browsers even when no edits occur.
- **Strong** on *Operational simplicity and deploy resilience*: instances remain stateless; rolling deploys, autoscaling, and transient cellular blips require no socket draining, session registries, or cross-node fan-out.
- **Strong** on *Authoritative revision alignment*: every poll reads committed revisions directly from `change-store` in revision order, with no separate publication pipeline that can drift from storage.
- **Partial** on *End-to-end connectivity visibility*: each poll verifies reachability through MarketBoard's full read path so failures surface within one or two poll cycles without separate heartbeats, though connection loss between polls goes unnoticed until the next request.

**Summary.** Trades subsecond push and low idle read volume for stateless operation and direct store reads.

### Self-Hosted WebSockets

**Description.** Browsers open a standard WebSocket connection to MarketBoard's `delivery` tier, authenticated with delivery-issued subscription credentials scoped to the event. `change-store` persists replayable event revisions and reliably publishes committed edits (for example, via a transactional outbox or store notification backed by durable revision reads) to `delivery` instances, which fan revisions out to subscribed sockets and exchange periodic heartbeats. When a socket drops or observes a revision gap, `browser-sync` marks connectivity degraded, reconnects with jittered backoff, and catches up from its last applied revision (falling back to a snapshot if needed).

**Demonstration.**
```text
Browser ◀══ WS /events/{id}/stream (fromRevision=142 + heartbeats) ══▶ Delivery
Editor  ── POST /events/{id}/commands ──▶ Change Store (commits rev 143) ──▶ Delivery
Browser ◀══ WS frame { revision: 143, patch: ... } ═════════════════════ Delivery
```

**Analysis.**
- **Strong** on *Vendor independence and predictable operating cost*: relies on the browser-native WebSocket protocol and MarketBoard-controlled servers, incurring no third-party realtime licensing, per-connection fees, or proprietary client coupling.
- **Strong** on *Update latency and read efficiency*: pushes committed edits in subsecond time during both quiet periods and 20-edit-per-second opening bursts without repeated empty cursor polls from idle browsers.
- **Weak** on *Operational simplicity and deploy resilience*: MarketBoard owns socket file-descriptor and memory capacity for 800 concurrent browsers, heartbeat tuning, cross-instance fan-out to preserve 99.5 percent availability across multiple `delivery` nodes, and reconnect/catch-up surge control during rolling deploys or venue cellular drops.
- **Partial** on *Authoritative revision alignment*: keeps persistence, publication, and replay within MarketBoard's own revision model, but still separates commit from socket push and therefore requires reliable internal store-to-delivery publication plus revision-gap catch-up.
- **Strong** on *End-to-end connectivity visibility*: sockets terminate directly on MarketBoard's `delivery` tier; close events and missed heartbeats promptly expose broken cellular links or unavailable MarketBoard servers without an external intermediary masking backend publication failures.

**Summary.** Delivers low-latency, vendor-free updates and direct liveness detection in exchange for owning stateful socket operations and reconnect recovery.

### Hosted Realtime Service

**Description.** Browsers load a managed realtime provider's client SDK and subscribe to per-event channels using short-lived capability tokens minted by MarketBoard's `delivery` component. When an edit commits, `change-store` records the revision and an outbox entry that `delivery` publishes over HTTPS to the provider's API, reconciling retries and acknowledgments. The provider terminates all 800 concurrent connections, absorbs rolling MarketBoard deploys without dropping client sockets, and handles transport-level reconnects.

**Demonstration.**
```text
Browser ── POST /events/{id}/realtime-token ──▶ Delivery (returns scoped provider token)
Browser ◀══ Provider SDK subscription (channel: event:{id}) ══▶ Realtime Provider
Change Store (commits rev 143 + outbox) ──▶ Delivery ── HTTPS publish ──▶ Realtime Provider
```

**Analysis.**
- **Weak** on *Vendor independence and predictable operating cost*: binds `delivery` token issuance/publication and `browser-sync` subscription/recovery semantics to a provider's API and client SDK, while adding recurring peak-connection and message charges.
- **Strong** on *Update latency and read efficiency*: pushes committed revisions with subsecond latency and offloads idle connection maintenance from MarketBoard's read path.
- **Strong** on *Operational simplicity and deploy resilience*: offloads stateful connection scaling, edge socket termination, and deploy-time connection persistence to the provider, keeping MarketBoard's own servers stateless HTTP workers plus an outbox publisher.
- **Weak** on *Authoritative revision alignment*: splits committed state and live fan-out across an external organizational and network boundary; provider publish failures, retries, or ordering differences require outbox reconciliation, idempotent browser deduplication by event revision, and MarketBoard catch-up endpoints when provider replay falls short of the 20-minute recovery window.
- **Partial** on *End-to-end connectivity visibility*: the provider SDK detects browser-to-provider network drops quickly, but a browser can show a healthy provider connection while MarketBoard-to-provider publication is stalled unless MarketBoard also publishes and monitors end-to-end application heartbeats through the provider.

**Summary.** Offloads stateful socket infrastructure for low-latency push at the cost of recurring vendor fees, SDK coupling, and cross-provider publication reconciliation.

## Selection

MarketBoard selects **Self-Hosted WebSockets**.

Against the three **major** criteria, Self-Hosted WebSockets is the only option that scores **strong** on both *Vendor independence and predictable operating cost* and *Update latency and read efficiency*, deliberately accepting a **weak** fit on *Operational simplicity and deploy resilience*. Five-second HTTPS polling avoids both socket operations and vendor lock-in, but pays for statelessness with multi-second update lag and ~160 read requests per second across 800 mostly idle browsers. A hosted realtime service eliminates socket-hosting burden while preserving fast push, and is permitted under *Self-hosted and managed infrastructure are both permitted*, but introduces recurring fees and couples `delivery` and `browser-sync` to a provider's subscription model. Because 800 concurrent connections and 20 edits per second at opening bursts are modest in absolute scale, owning WebSocket capacity and reconnect handling is a bounded operational cost worth trading for fast updates without vendor lock-in.

The two **moderate** tenet-derived criteria reinforce this choice. Keeping persistence, publication, and session fan-out inside MarketBoard better supports *A committed edit has one authoritative event revision regardless of its delivery route* than reconciling commits across a third-party broker, and terminating sockets directly on MarketBoard's `delivery` tier directly serves *Connectivity failures must be visible, not mistaken for an unchanged board* without an external broker whose connection health can diverge from MarketBoard's own publication health.

Committing to Self-Hosted WebSockets forecloses purely stateless request-only operation on the delivery tier and forecloses delegating client subscription recovery to a vendor SDK. It creates three coordinated downstream obligations:

- **`change-store`**: persist ordered, replayable event revisions covering the 20-minute browser recovery window (within the seven-day retention period), serve current board snapshots, and guarantee reliable publication of every committed revision to `delivery`.
- **`delivery`**: manage self-hosted WebSocket session lifecycles and subscription credentials for up to 800 simultaneous browsers and 20-edit-per-second bursts, run liveness heartbeats, fan out committed revisions across `delivery` instances to sustain 99.5 percent event-hour availability across deploys, and serve revision catch-up.
- **`browser-sync`**: manage browser WebSocket connections, surface degraded connectivity promptly when heartbeats or sockets fail, reconnect with jittered backoff to prevent synchronized reconnect storms, and catch up cleanly from the browser's last applied revision.
```

---

### Before Moving to Phase 2 (LLDs)

1. Does this HLD + decision doc capture your intent as written, or would you adjust any criterion or framing?
2. Should vendor-coupling avoidance remain scoped to this realtime decision (leaving managed services with standard interfaces—like managed Postgres or Redis—on the table for the LLDs), or become a general tenet?
3. When we enter Phase 2, should we also clean up the stale *"still-open change-delivery approach"* line in `docs/intent/access/access-design.md`, and which of `change-store`, `delivery`, or `browser-sync` would you like to draft first?