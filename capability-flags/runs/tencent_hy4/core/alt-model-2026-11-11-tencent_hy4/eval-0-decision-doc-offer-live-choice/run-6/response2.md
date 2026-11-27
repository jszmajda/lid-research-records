Done. I wrote the full decision doc at `docs/decisions/realtime-delivery.md` (project-level, owned by the HLD) and linked it from the Key Design Decisions row. It's written cold — present tense, no chronology, each option given its strongest honest representation, criteria weighted, tenet loop closed in Selection.

**Phase 1 output — new artifact in full** (`docs/decisions/realtime-delivery.md`):

```
---
node: high-level-design
---

# Decision: Delivery of Committed Changes to Browsers

## Context

This decision builds on the HLD's choice that editors submit commands over HTTPS and that each committed edit receives one authoritative event revision; it settles only how those committed revisions reach browsers.

MarketBoard keeps one authoritative board per event. Editors commit stall-status changes as commands; browsers display a revisioned view of the board and must show committed changes within 15 seconds under normal connectivity, for up to 800 simultaneous browsers with opening-time bursts of 20 edits per second, and must recover the latest board after a disconnection of up to 20 minutes. Delivery is a transport for committed revisions, not the source of truth: a committed edit has one authoritative event revision regardless of its delivery route, event updates contain only stall IDs and operational statuses, and connectivity failures must be visible rather than mistaken for an unchanged board.

Three routes can satisfy those hard constraints: five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service. Because none is ruled out by a standing constraint — self-hosted and managed infrastructure are both permitted — the choice is a weighing of tradeoffs, and three other design nodes (change store, delivery, browser sync) are sized around whichever route is selected. What is at stake is a long-lived commitment to a class of operational work and a class of external dependency, both expensive to reverse once those nodes are built around them.

## Decision Elements

No gate eliminates an option: all three routes satisfy the inherited constraints (15-second freshness at the stated scale, 20-minute recovery, a single authoritative revision, and visible connectivity failures). Those constraints are background; selection turns on the graded criteria below.

- **Update latency** — **major**. Time from a committed revision to its display in connected browsers. All three meet the 15-second Goal, but the project prefers faster delivery, so lower lag weighs in an option's favour.
- **Vendor coupling and recurring fees** — **major**. The degree to which the board depends on a third-party realtime provider and its recurring charges. Importance derives from the tenet **Self-hosted and managed infrastructure are both permitted**: neither route is mandated, so independence from a realtime vendor is a live preference that can drive selection.
- **Operational burden owned by the project** — **major**. The connection capacity, session liveness, reconnect and catch-up handling, and reliable publication the project must build and run itself. Lower owned burden is preferred.
- **Reliability of surfacing connectivity failures** — **moderate**. How directly a route lets the browser distinguish a dropped connection from an unchanged board. Importance derives from the tenet **Connectivity failures must be visible, not mistaken for an unchanged board**.

## Options in the Domain

### Five-Second HTTPS Polling

Browsers periodically request board changes over HTTPS, carrying a cursor for the last revision they have seen; the server answers with any newer revisions. It is the simplest stateless operation: no long-lived connections to own, and delivery stays ordinary request/response. The change store needs cursor queries over revision history. A failed poll is an ordinary failed HTTP request, so a browser can tell a connectivity problem from an unchanged board without extra machinery.

- **Update latency** — **weak** fit. A committed revision waits up to one polling interval, adding a few seconds of lag; it meets the 15-second Goal but offers no fast-update headroom.
- **Vendor coupling and recurring fees** — **strong** fit. No third-party realtime dependency; cost is repeated reads against the project's own store.
- **Operational burden owned by the project** — **strong** fit. Stateless request/response; no connection capacity, sessions, or reconnect logic to run.
- **Reliability of surfacing connectivity failures** — **strong** fit. A failed request is directly observable by the browser.

**Summary.** Lowest operational and dependency cost, at the price of repeated reads and a few seconds of lag.

### Self-Hosted WebSockets

The server holds long-lived WebSocket connections to browsers and pushes committed revisions as they are published. The change store retains replayable revisions and publishes them reliably; delivery manages sessions; browsers run reconnect and catch-up logic from their last seen revision after a disconnect. Updates arrive without waiting for a poll, with no third-party realtime vendor in the path.

- **Update latency** — **strong** fit. Committed revisions are pushed on publication, so display lag is not bounded by a polling interval.
- **Vendor coupling and recurring fees** — **strong** fit. No provider dependency; the transport runs on the project's own infrastructure.
- **Operational burden owned by the project** — **weak** fit. The project owns connection capacity at up to 800 simultaneous browsers, session liveness, publication reliability, and reconnect/catch-up correctness.
- **Reliability of surfacing connectivity failures** — **partial** fit. A dropped socket is detectable, but the project must build the liveness, reconnect, and catch-up handling that turns it into a visible, recoverable state rather than a stale board.

**Summary.** Fast updates with no realtime vendor, in exchange for owning connection and reconnect operations.

### Hosted Realtime Service

A managed realtime provider carries committed revisions to subscribed browsers; delivery wraps the provider's publication model, the change store reconciles provider publications with authoritative revisions, and browsers use the provider's subscription model. It is the quickest route to low-latency updates with the least connection-operations work owned by the project.

- **Update latency** — **strong** fit. Managed pub/sub delivers committed revisions without a polling interval.
- **Vendor coupling and recurring fees** — **weak** fit. The board depends on a specific provider's SDK, subscription semantics, and availability, and incurs recurring fees.
- **Operational burden owned by the project** — **strong** fit. The provider operates connection capacity and most reconnect handling.
- **Reliability of surfacing connectivity failures** — **partial** fit. Provider SDKs expose disconnect state, but the board inherits the provider's reliability and reconciliation behaviour rather than controlling it.

**Summary.** Lowest-latency path with the least owned connection work, at the price of recurring fees and provider coupling.

## Selection

Self-hosted WebSockets is selected. It is the only route that fits the two **major** criteria the project weighs most — low update latency and independence from a realtime vendor — strongly at the same time. Five-second HTTPS polling is **weak** on update latency and a hosted realtime service is **weak** on vendor coupling and recurring fees; each is weak on one of the two major criteria, so neither is preferred despite being **strong** on operational burden. Self-hosted WebSockets is **weak** on operational burden owned and only **partial** on surfacing connectivity failures; the project accepts that cost to get fast updates without coupling the board to a realtime vendor.

The decision turns on the tenet **Self-hosted and managed infrastructure are both permitted**, which leaves both self-hosted and managed routes open and makes this a weighing rather than a constraint-settled pick, and on the tenet **Connectivity failures must be visible, not mistaken for an unchanged board**, which the owned WebSocket transport must itself satisfy. It stays consistent with **A committed edit has one authoritative event revision regardless of its delivery route**: delivery remains a transport and the change store remains the source of truth.

Committing to this route forecloses a provider-managed transport and stateless request/response delivery. It obligates the change store to retain replayable revisions and publish reliably, the delivery node to manage WebSocket sessions, and the browser-sync node to implement reconnect and catch-up from the last seen revision — the three nodes sized around this decision.
```

The Phase 1 stop is still open, so these still need your ruling — I won't decide them for you or start the three nodes:

1. **Approve the Phase 1 output** — the revised HLD (with the new row + link) and this decision doc — as settled, or give numbered feedback?
2. **Latent-criteria probe.** Before I finalize the criteria above: is there anything a thoughtful critic would weigh that isn't captured — especially a criterion that cuts *against* self-hosted WebSockets? I included operational burden and failure-visibility as the two that do; anything else that could move the decision?
3. **Standing tenet (still unanswered from before).** Writing the doc surfaced this concretely: the lean that actually drives the choice — accept connection/reconnect operations work to avoid realtime-vendor coupling — is a project preference, not a recorded tenet. The existing tenet only says both routes are *permitted*. Do you want that lean added as a one-line tie-breaker under `## Tenets`, or leave the tenet list as-is?
4. **Cross-segment cascade (still unanswered).** I have not touched any node. `docs/intent/access/access-design.md` still says authorization is "independent of the still-open change-delivery approach," which is now stale, and access is a separate segment. Fix that one line now, or fold it into the three-node work you said comes after? I'll pause at each segment boundary before propagating either way.