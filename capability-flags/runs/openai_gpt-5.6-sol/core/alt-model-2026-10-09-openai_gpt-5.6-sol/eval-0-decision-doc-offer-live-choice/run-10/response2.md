The architectural decision is recorded in `docs/decisions/realtime-delivery.md` and linked from the HLD.

```markdown
---
node: high-level-design
---

# Decision: Realtime Change Delivery

## Context

MarketBoard browsers need to learn about committed stall-status changes while coordinators are using an event board. The required freshness target is 15 seconds under normal connectivity, but faster delivery reduces the period in which staff act on a stale board. The pilot must support up to 800 simultaneous browsers and opening-time bursts of 20 edits per second.

Commands remain HTTPS request/response operations. This decision concerns only how committed revisions reach browsers and how a browser catches up after losing connectivity. Every option preserves one authoritative event revision and can meet the stated freshness target, so the choice turns on responsiveness, operational ownership, and external coupling rather than basic feasibility.

## Decision Elements

- **Delivery independence (major).** Core board freshness should not depend on a realtime provider's API, pricing, credentials, or continued availability unless that dependency buys a decisive advantage.
- **Update responsiveness (major).** Connected browsers should receive committed changes promptly rather than routinely waiting for most of the 15-second freshness allowance.
- **Operational burden (moderate).** The service should avoid infrastructure and failure modes that the team cannot operate reliably, while accepting justified operational work.
- **Recovery clarity (moderate).** A browser that disconnects for up to 20 minutes must be able to detect that it may be stale and recover an ordered view from authoritative revisions. This criterion applies the tenets that committed edits have authoritative event revisions and connectivity failures remain visible.
- **Steady-state resource use (minor).** Delivery should avoid unnecessary database reads and network requests at the expected browser count, without optimizing prematurely for multi-region or substantially larger scale.

## Options in the Domain

### Five-Second HTTPS Polling

Each browser sends a request every five seconds with its last observed revision. The server returns later revisions or an unchanged response. Requests are stateless, ordinary HTTPS capacity handles delivery, and browser recovery uses the same cursor query as routine polling.

- **Delivery independence: strong.** The application owns the protocol and does not require a realtime provider.
- **Update responsiveness: weak.** Delivery adds up to roughly five seconds of routine polling delay even when the service and browser are healthy.
- **Operational burden: strong.** Stateless requests use familiar request/response scaling, timeout, and retry mechanisms.
- **Recovery clarity: strong.** Normal delivery and catch-up share one cursor-based read path, so reconnect behavior introduces little additional state.
- **Steady-state resource use: weak.** Every connected browser generates repeated requests and revision reads even when a board has not changed.

Polling minimizes connection operations at the cost of routine lag and repeated idle work.

### Self-Hosted WebSockets

The service holds persistent WebSocket sessions and publishes committed event revisions to connected browsers. The store retains replayable revisions and a reliable publication boundary. Browsers retain their last applied revision, reconnect after interruption, catch up from the store, and then resume live delivery.

- **Delivery independence: strong.** The application owns its delivery protocol and has no realtime-provider fee or API dependency.
- **Update responsiveness: strong.** A committed revision can be pushed immediately over existing connections.
- **Operational burden: weak.** The team owns connection capacity, session lifecycle, liveness detection, publication failures, reconnect behavior, and monitoring.
- **Recovery clarity: partial.** Revision-based replay gives recovery an authoritative basis, but the transition between catch-up and live delivery must prevent gaps and duplicates from corrupting the displayed board.
- **Steady-state resource use: partial.** Persistent sessions consume connection capacity, but idle boards do not cause repeated database reads and request traffic.

Self-hosting trades additional connection and recovery operations for low-latency delivery without provider coupling.

### Hosted Realtime Service

The application publishes committed changes through a managed realtime provider. Delivery wraps the provider's publish and authorization APIs, while browsers use its subscription client. Application-owned revisions remain authoritative, so publication reconciliation and catch-up are still needed when a commit is not observed through the provider.

- **Delivery independence: weak.** Board delivery depends on provider APIs, credentials, pricing, service limits, and client behavior.
- **Update responsiveness: strong.** Managed persistent connections provide low-latency delivery.
- **Operational burden: strong.** The provider operates connection capacity and much of the reconnect transport, reducing infrastructure work for the application team.
- **Recovery clarity: partial.** The provider handles transport reconnection, but the application must reconcile provider delivery with authoritative stored revisions.
- **Steady-state resource use: strong.** Connection capacity is offloaded and idle browsers do not create application polling reads, in exchange for usage-based provider cost.

Hosted realtime minimizes connection operations but makes a third party part of the board's core delivery path.

## Selection

MarketBoard uses **self-hosted WebSockets** for committed change delivery. This option is strong on both major criteria: it provides prompt updates while keeping the protocol, operating cost, and evolution of core board delivery under application control. The choice accepts a weaker fit on operational burden because avoiding provider coupling and routine polling lag matters more for this service than minimizing connection-management work.

The selection preserves the authoritative-revision and visible-connectivity-failure tenets. WebSocket messages are a fast delivery route, not an independent source of truth, and a lost connection must lead to explicit recovery rather than being interpreted as an unchanged board.

This choice forecloses treating delivery as stateless polling or delegating session capacity to a hosted realtime vendor. It creates these downstream obligations:

- The change store must retain replayable event revisions and provide a reliable boundary between committing and publishing a change.
- Delivery must operate WebSocket session capacity, publish committed revisions, detect interrupted sessions, and expose enough health information to diagnose delivery failures.
- Browser sync must track the last applied revision, show loss of connectivity, reconnect, catch up without revision gaps, and then resume live updates.
- Operational verification must cover connection capacity, publication delay, disconnect recovery, and the transition from replay to live delivery at the expected pilot load.
```

`git diff --check` passes. Please approve this Phase 1 decision, or give numbered changes. On approval, I’ll move to the three Phase 2 design nodes: change store, delivery, and browser sync.