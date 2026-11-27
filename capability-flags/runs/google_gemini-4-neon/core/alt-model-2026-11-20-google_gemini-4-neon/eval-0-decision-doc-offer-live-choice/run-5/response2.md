Wrote `docs/decisions/change-delivery.md` and linked it from `docs/high-level-design.md` under **Key Design Decisions**.

Here is the decision doc for review:

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Mechanism

## Context

MarketBoard maintains one authoritative board per event across roughly 40 weekend markets, serving up to 800 simultaneous staff browsers with 10–25 active editors per busy market. Steady-state traffic averages two status changes per minute per market, with opening-time bursts up to 20 edits per second. Editors already submit mutations over HTTPS, and the server assigns each committed edit a single authoritative event revision.

How committed revisions reach connected browsers is a foundational architectural choice because three components must be designed together around it: **change store** (revision indexing and publication), **delivery** (request handling, socket sessions, or third-party publication), and **browser sync** (polling loops, reconnects, and catch-up). All three candidate mechanisms can meet the standing goals — 15-second freshness, 800 simultaneous browsers, 20 edits/second bursts, 20-minute disconnect recovery, and 99.5% event-hour availability — and the project's tenets permit both self-hosted and managed infrastructure. Because no binary gate eliminates a candidate, selection turns on how each option trades latency, operational burden, vendor coupling, and revision-consistency complexity.

## Decision Elements

All candidates satisfy the standing project goals and infrastructure tenets, so no binary gates eliminate an option in contention. Selection is governed by the following weighted criteria:

- **Update freshness beyond the 15-second floor** *(major)*: How quickly committed stall changes appear in connected browsers during busy opening-time bursts, reducing stale reads and duplicate coordinator actions.
- **Vendor independence and predictable operating cost** *(major)*: Avoiding recurring per-connection or per-message realtime vendor fees and avoiding architectural coupling to a third-party provider's subscription protocol and credential model.
- **Operational simplicity during peak market hours** *(moderate)*: Minimizing stateful connection infrastructure, proxy/load-balancer tuning, capacity management for 800 concurrent browsers, and reconnect-storm exposure during event hours.
- **Publication and revision-consistency simplicity** *(moderate — derives from tenet: "A committed edit has one authoritative event revision regardless of its delivery route")*: How directly the delivery path stays aligned with the authoritative revision log and supports gap-free catch-up after disconnects of up to 20 minutes.
- **Read amplification at idle** *(minor)*: How much server read and request load connected browsers generate during quiet periods (two edits per minute across 800 browsers).
- **Connectivity failure detection fidelity** *(minor — derives from tenet: "Connectivity failures must be visible, not mistaken for an unchanged board")*: How reliably and promptly a browser can distinguish an unchanged board from a broken delivery link.

## Options in the Domain

### Five-second HTTPS polling

**Description**
Browsers run a periodic HTTPS polling loop (every five seconds) passing their last-seen event revision cursor. The change store serves indexed cursor queries (`revisions > last_seen`), delivery remains stateless request/response behind standard HTTP infrastructure, and browser sync advances its view from each poll response or falls back to a full snapshot after long disconnects.

**Analysis**
- Update freshness beyond the 15-second floor: **weak** — updates wait up to the polling interval plus round-trip latency (multi-second lag) even under healthy connectivity.
- Vendor independence and predictable operating cost: **strong** — runs entirely on standard self-hosted HTTP infrastructure with no realtime vendor dependency or per-message fees.
- Operational simplicity during peak market hours: **strong** — stateless request/response handlers scale behind standard load balancers with no long-lived socket state or reconnect-storm session recovery.
- Publication and revision-consistency simplicity: **strong** — browsers query the authoritative revision store directly by cursor, eliminating any publication hop between commit and delivery.
- Read amplification at idle: **weak** — 800 connected browsers polling every five seconds generate ~160 requests per second of mostly empty reads during steady-state periods.
- Connectivity failure detection fidelity: **partial** — failed or timed-out HTTP polls surface connectivity loss directly without heartbeat machinery, though detection waits for the next poll cycle.

**Summary**
Simplest stateless operation and direct store consistency, at the cost of multi-second update lag and continuous idle read traffic.

### Self-hosted WebSockets

**Description**
The application runs its own WebSocket delivery tier alongside the HTTPS command API. When an edit commits, the change store persists the revision and publishes it reliably to the delivery tier, which fans updates out to subscribed WebSocket sessions. Delivery manages connection capacity, subscription credentials, and revision replay; browser sync maintains the socket, detects silent drops via heartbeats, and replays missed revisions on reconnect.

**Analysis**
- Update freshness beyond the 15-second floor: **strong** — committed edits push to connected browsers in sub-second time once published.
- Vendor independence and predictable operating cost: **strong** — no recurring realtime vendor bill and no dependency on a third-party subscription protocol or provider lifecycle.
- Operational simplicity during peak market hours: **weak** — requires owning stateful WebSocket connection capacity, proxy/timeout configuration, graceful restarts, and reconnect-storm handling across 800 browsers.
- Publication and revision-consistency simplicity: **partial** — requires reliable publication from the change store to delivery plus revision replay on reconnect so no committed revision is lost between the store and a client.
- Read amplification at idle: **strong** — connected browsers generate traffic proportional to actual edits plus lightweight keepalive frames rather than periodic store queries.
- Connectivity failure detection fidelity: **partial** — clean socket closes surface immediately, but half-open network drops require explicit heartbeat/timeout handling so a stalled socket is not mistaken for an unchanged board.

**Summary**
Low-latency updates without vendor lock-in or recurring realtime fees, at the cost of owning stateful connection operations and store-to-delivery publication.

### Hosted realtime service

**Description**
The server publishes committed event revisions to a managed realtime messaging provider (e.g., hosted pub/sub or managed WebSockets). Delivery wraps the provider's publish API and issues provider-scoped subscription credentials; the change store supports publication reconciliation and fallback replay; browsers connect through the provider's client SDK and subscription model.

**Analysis**
- Update freshness beyond the 15-second floor: **strong** — managed edge infrastructure pushes published revisions to connected browsers in sub-second time.
- Vendor independence and predictable operating cost: **weak** — introduces recurring connection/message fees and couples delivery credentials, browser subscriptions, and operational troubleshooting to a specific provider.
- Operational simplicity during peak market hours: **partial** — offloads socket fleet scaling and edge connection handling to the vendor, while retaining operational responsibility for provider credentials, quotas, and vendor outages.
- Publication and revision-consistency simplicity: **weak** — adds an external network boundary between committing a revision and publishing it, requiring publication reconciliation and store-backed replay to guarantee consistency with the authoritative revision log.
- Read amplification at idle: **strong** — idle browsers stay connected to the provider's edge without generating periodic read queries against the change store.
- Connectivity failure detection fidelity: **strong** — provider client SDKs supply built-in heartbeats and explicit connection-state transitions, though visibility still depends on the provider's edge health.

**Summary**
Fast updates with reduced connection-fleet operations, at the cost of recurring vendor fees, provider coupling, and external publication reconciliation.

## Selection

**Self-hosted WebSockets** is selected.

It is the only option with a **strong** fit on both **major** criteria — delivering fast, sub-second updates during opening-time bursts while preserving vendor independence and predictable operating cost. Five-second HTTPS polling scores strong on operational simplicity and store consistency, but sacrifices update freshness and introduces steady idle read load; a hosted realtime service matches the latency and idle-efficiency profile, but trades away vendor independence and adds an external publication-reconciliation boundary.

This choice explicitly accepts a **weak** fit on operational simplicity and a **partial** fit on publication and failure-detection complexity. The tenet *"Self-hosted and managed infrastructure are both permitted"* leaves infrastructure posture open rather than forcing a managed service, while the tenets *"A committed edit has one authoritative event revision regardless of its delivery route"* and *"Connectivity failures must be visible, not mistaken for an unchanged board"* translate directly into downstream design requirements rather than disqualifiers.

**Implications of committing:**
- **Foreclosed:** Stateless request/response-only delivery, and offloading socket-fleet scaling and reconnect state machines to a managed realtime provider.
- **Downstream obligations:**
  - **Change store** (`docs/intent/change-store/`): must persist replayable event revisions (covering the 20-minute disconnect recovery window and 7-day retention goal) and provide reliable publication of committed revisions to delivery.
  - **Delivery** (`docs/intent/delivery/`): must own WebSocket session lifecycle, subscription credentials, connection capacity for 800 concurrent browsers and 20 edits/second bursts, fan-out, and revision replay.
  - **Browser sync** (`docs/intent/browser-sync/`): must own WebSocket subscriptions, explicit heartbeat and staleness detection so connectivity failures remain visible, and reconnect with revision catch-up.
```

Please review `docs/decisions/change-delivery.md` and the linked `docs/high-level-design.md`. Let me know if you want any adjustments, whether to also clean up the "still-open change-delivery approach" phrasing in `docs/intent/access/access-design.md`, and if we're approved to move to Phase 2 for `change-store`, `delivery`, and `browser-sync`.