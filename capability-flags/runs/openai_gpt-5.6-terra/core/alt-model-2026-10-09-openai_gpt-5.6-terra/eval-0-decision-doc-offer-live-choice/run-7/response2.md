## Phase 1: Decision Record

Added `docs/decisions/browser-delivery-transport.md` and linked it from the HLD's Key Design Decisions section.

```markdown
---
node: high-level-design
---

# Decision: Browser Delivery Transport

## Context

MarketBoard delivers committed stall-status changes from one authoritative event board to as many as 800 simultaneous staff browsers. Coordinators need fast visibility of closures, late arrivals, and power problems, while a disconnected browser must recover the latest board after up to 20 minutes away. The delivery transport determines the read load, the amount of connection infrastructure the team operates, and whether the board relies on a realtime provider.

Editors continue to submit commands over HTTPS. The selected transport applies only to server-to-browser delivery after a command has committed an event revision.

## Decision Elements

- **Delivery latency: major.** Connected browsers should receive committed changes promptly rather than waiting for a periodic read. Fast status visibility is central to a shared operational board.
- **Provider independence: major.** Per the tenet to avoid vendor coupling when the team can operate the required infrastructure, the transport should not require a realtime-service provider.
- **Operational responsibility: moderate.** The team must be able to sustain delivery during published event hours, including the 800-browser peak and opening-time edit bursts. Avoiding connection operations is beneficial but may be traded for the higher-priority criteria.
- **Recovery correctness: major.** A browser that reconnects must obtain missed committed revisions without treating a disconnected board as current. This supports the authoritative-revision and visible-connectivity-failure tenets.
- **Read efficiency: moderate.** Routine delivery should not create repeated read traffic from every connected browser when changes are infrequent.

## Options in the Domain

### Five-Second HTTPS Polling

**Description.** Each browser requests board changes at a fixed five-second interval. The change store exposes a cursor or revision query so each poll can request changes after the browser's last applied revision.

**Analysis.**

- **partial** fit for delivery latency: a committed change can wait almost five seconds before a connected browser asks for it.
- **strong** fit for provider independence: polling uses the board's existing HTTPS service without a realtime provider.
- **strong** fit for operational responsibility: request/response delivery avoids long-lived connection sessions and their reconnect lifecycle.
- **strong** fit for recovery correctness: the cursor query can return revisions after the browser's last applied revision.
- **weak** fit for read efficiency: every connected browser continues issuing reads even when the board has not changed.

**Summary.** Stateless and operationally simple, with periodic delivery delay and repeated reads.

### Self-Hosted WebSockets

**Description.** The delivery service holds WebSocket sessions for connected browsers and publishes committed event revisions to the relevant sessions. The change store retains replayable revisions; after a lost session, a browser reconnects, catches up from its last applied revision, then resumes live delivery.

**Analysis.**

- **strong** fit for delivery latency: the service can publish a committed revision to connected browsers without waiting for a browser request interval.
- **strong** fit for provider independence: the team operates the realtime transport rather than delegating it to a provider.
- **partial** fit for operational responsibility: delivery must manage session capacity, connection loss, reconnects, and reliable publication at the required peak.
- **strong** fit for recovery correctness: replayable revisions and reconnect catch-up provide a defined recovery path before live delivery resumes.
- **strong** fit for read efficiency: live changes are pushed to relevant connected browsers instead of requiring periodic reads while idle.

**Summary.** Low-latency, provider-independent delivery with team-owned connection and recovery operations.

### Hosted Realtime Service

**Description.** The board publishes committed revisions to a managed realtime provider. Browsers use the provider's subscription and reconnection model, while the board reconciles its authoritative revision history with provider publication.

**Analysis.**

- **strong** fit for delivery latency: managed subscriptions can deliver committed changes without polling delay.
- **weak** fit for provider independence: the board's realtime path depends on a provider's service, credentials, API, and availability.
- **strong** fit for operational responsibility: the provider operates connection capacity and much of the reconnect infrastructure.
- **partial** fit for recovery correctness: the board still needs reconciliation between committed revisions and provider publication so provider delivery does not become the authority.
- **strong** fit for read efficiency: managed subscriptions avoid routine browser polling reads.

**Summary.** Low-latency delivery with reduced connection operations, in exchange for provider dependency and recurring service cost.

## Selection

MarketBoard uses self-hosted WebSockets for browser delivery. It best satisfies the major latency, provider-independence, and recovery-correctness criteria while also avoiding the repeated idle reads of polling. The selection turns on the tenet to avoid vendor coupling when the team can operate the required infrastructure.

This choice accepts a weaker fit for operational responsibility than polling or a hosted service. The delivery node must therefore define session-capacity, reconnect, and reliable-publication behavior; the change-store node must retain replayable revisions; and the browser-sync node must catch up after reconnecting before it relies on live messages. Hosted realtime remains a credible alternative if the team can no longer sustain those operations or accepts provider coupling as the preferable trade.
```

Please explicitly approve this Phase 1 decision record before I draft the change-store node.