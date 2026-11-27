## Decision Record Added

Created `docs/decisions/realtime-delivery.md` and linked it from the HLD's Key Design Decisions.

```markdown
---
node: high-level-design
---

# Decision: Self-Hosted WebSocket Delivery

## Context

MarketBoard delivers committed stall-status changes to as many as 800 staff browsers during a market event. Editors submit commands over HTTPS, and every committed command receives one authoritative event revision. The delivery mechanism must distribute those revisions quickly while preserving a recoverable, revisioned board after temporary browser disconnections.

The delivery choice determines obligations for change storage, server delivery, and browser synchronization. A poor fit would either add a recurring external dependency, leave staff waiting for updates, or make missed changes unrecoverable after a connection failure.

## Decision Elements

- **Low-latency propagation (major).** Connected browsers should receive committed changes with substantially less delay than the 15-second freshness goal where normal connectivity permits.
- **Provider independence (major).** The board should not depend on a hosted realtime provider for its core update path.
- **Operational burden (moderate).** The pilot must operate reliably during published event hours without requiring multi-region active-active infrastructure.
- **Recoverable delivery (major).** A browser disconnected for up to 20 minutes must be able to recover the latest board from retained event revisions.

## Options in the Domain

### Five-Second HTTPS Polling

**Description.** Each browser requests revisions newer than its cursor at a fixed five-second interval. The server responds with matching revisions or an indication that none are available.

**Analysis.**

- **Weak** fit for low-latency propagation: a committed change can wait almost five seconds before the next browser request.
- **Strong** fit for provider independence: delivery uses the board's existing HTTPS infrastructure.
- **Strong** fit for operational burden: requests remain stateless and do not require long-lived connection management.
- **Strong** fit for recoverable delivery: cursor queries can replay revisions after a missed polling interval or reconnect.

**Summary.** Stateless and simple to operate, with repeated reads and bounded polling delay.

### Self-Hosted WebSockets

**Description.** Browsers maintain WebSocket sessions to MarketBoard. After each committed revision, the delivery service publishes it to connected sessions. A browser reconnects after transport failure and replays revisions after its last received revision before it resumes live updates.

**Analysis.**

- **Strong** fit for low-latency propagation: committed revisions can be sent immediately to connected sessions.
- **Strong** fit for provider independence: MarketBoard owns the update path and does not require a realtime vendor.
- **Partial** fit for operational burden: the service must provision connection capacity, manage session lifecycle, and handle reconnects.
- **Strong** fit for recoverable delivery: replayable revisions let a reconnecting browser catch up before returning to live delivery.

**Summary.** Low-latency vendor-independent delivery, with explicit connection and reconnect operations work.

### Hosted Realtime Service

**Description.** MarketBoard publishes committed revisions through a managed realtime provider, and browsers subscribe using that provider's connection model. MarketBoard reconciles its revision history with provider publication.

**Analysis.**

- **Strong** fit for low-latency propagation: managed subscriptions can distribute updates promptly to connected browsers.
- **Weak** fit for provider independence: the core update path depends on provider availability, credentials, and subscription semantics.
- **Strong** fit for operational burden: the provider operates connection capacity and much of the reconnect infrastructure.
- **Partial** fit for recoverable delivery: provider publication must remain reconciled with the authoritative revision history to recover missed changes.

**Summary.** Low-latency delivery with reduced connection operations, at the cost of recurring fees and provider coupling.

## Selection

MarketBoard uses self-hosted WebSockets for committed board updates. This option best satisfies the major criteria of low-latency propagation and provider independence while retaining a clear recovery path through replayable revisions. The project accepts its moderate operational burden: the delivery service must manage WebSocket capacity and sessions, and browser synchronization must reconnect and catch up after an interruption.

This selection turns on the tenet that self-hosted and managed infrastructure are both permitted: provider independence is valuable for this delivery path, but self-hosting is chosen only with the associated operational responsibilities made explicit. It forecloses polling as the primary live-update mechanism and avoids a hosted realtime provider. It obligates the change-store, delivery, and browser-sync design nodes to define revision replay, reliable publication, session management, reconnect, and catch-up behavior.
```

Please approve this Phase 1 decision record and HLD update before I draft the three leaf design nodes.