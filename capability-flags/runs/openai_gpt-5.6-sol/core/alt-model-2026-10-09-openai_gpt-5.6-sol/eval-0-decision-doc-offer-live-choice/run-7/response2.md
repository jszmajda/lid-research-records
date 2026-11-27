**Phase 1 Decision Document**
Created `docs/decisions/realtime-change-delivery.md` and linked it from `docs/high-level-design.md`.

```markdown
---
node: high-level-design
---

# Decision: Realtime Change Delivery

## Context

MarketBoard serves up to 800 simultaneous staff browsers across forty weekend markets. A busy market normally produces two status changes per minute and can burst to 20 edits per second around opening time. Connected browsers must show committed changes within 15 seconds, and a browser returning after a disconnection of up to 20 minutes must recover the latest board.

HTTPS remains the command path, and the server assigns each committed edit one authoritative event revision. The delivery mechanism must distribute those revisions without becoming a second source of truth. Five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service can all satisfy the stated freshness and scale goals, but they place materially different costs and responsibilities on the system.

## Decision Elements

- **Avoiding recurring delivery-service fees (major).** MarketBoard favors paying for its own general-purpose application capacity over adding a fee tied to a realtime provider's connections or messages.
- **Provider independence (major).** Change delivery should not make browser synchronization depend on one vendor's subscription protocol, credentials, or publication semantics.
- **Update immediacy (moderate).** Although the formal target is 15 seconds, operational status changes are more useful when connected staff see them promptly.
- **Operational simplicity (moderate).** Persistent connection capacity, reconnect storms, deployment draining, and session observability consume engineering and operating effort.
- **Recovery integrity (major).** Live delivery and reconnect catch-up must preserve the authoritative event revision sequence and make connectivity failures visible rather than presenting stale data as current.

## Options in the Domain

### Five-Second HTTPS Polling

Each browser periodically requests changes after its last applied revision. The application remains stateless between requests, while the change store provides efficient cursor queries over retained event revisions.

- **Strong fit for avoiding recurring delivery-service fees.** Polling uses the existing HTTPS application stack without a dedicated realtime provider, though repeated reads increase application and database load.
- **Strong fit for provider independence.** The browser depends only on the application's HTTP contract.
- **Weak fit for update immediacy.** A committed change can wait nearly five seconds for the next request, and reducing the interval increases repeated reads.
- **Strong fit for operational simplicity.** Request handling, scaling, timeouts, and retries follow the existing stateless HTTPS model.
- **Strong fit for recovery integrity.** The normal polling cursor also serves as the catch-up cursor, so live operation and recovery use the same mechanism.

Summary: Polling minimizes connection operations at the cost of repeated reads and avoidable update lag.

### Self-Hosted WebSockets

The application operates persistent WebSocket sessions and publishes committed event revisions directly to connected browsers. Reconnecting browsers identify their last applied revision, catch up from retained revisions, and then resume live delivery.

- **Strong fit for avoiding recurring delivery-service fees.** The system uses its own application and network capacity rather than paying a realtime provider, while accepting the infrastructure cost of persistent connections.
- **Strong fit for provider independence.** Session, publication, and recovery contracts remain under MarketBoard's control.
- **Strong fit for update immediacy.** The server can publish a committed revision without waiting for a browser request interval.
- **Weak fit for operational simplicity.** MarketBoard must own connection capacity, session lifecycle, reconnect storms, backpressure, deployment draining, and observability.
- **Partial fit for recovery integrity.** Revisioned replay can preserve ordering and expose gaps, but MarketBoard must implement reliable publication and the transition from catch-up to live delivery correctly.

Summary: Self-hosted WebSockets exchange additional engineering and connection operations for fast updates without provider fees or coupling.

### Hosted Realtime Service

The application publishes committed changes through a managed provider, and browsers use that provider's subscription client. The provider operates connection capacity and session infrastructure while MarketBoard reconciles authoritative revisions with provider publication.

- **Weak fit for avoiding recurring delivery-service fees.** Connections, messages, or throughput introduce a continuing provider charge that can grow with usage.
- **Weak fit for provider independence.** Browser subscriptions, credentials, publication APIs, and some recovery behavior become coupled to the selected provider.
- **Strong fit for update immediacy.** Managed persistent connections deliver changes without a polling interval.
- **Strong fit for operational simplicity.** The provider absorbs most connection fleet, reconnect, and session-capacity operations.
- **Partial fit for recovery integrity.** MarketBoard still needs to reconcile durable authoritative revisions with provider publication and handle gaps the provider cannot replay.

Summary: Hosted realtime delivery buys lower connection-operations burden with recurring fees and provider coupling.

## Selection

MarketBoard uses self-hosted WebSockets for committed-change delivery. Avoiding a realtime-provider fee and retaining control of the synchronization contract outweigh the moderate operational-simplicity advantage of polling and the substantial operational advantage of a hosted service. WebSockets also provide the lowest-latency path for connected staff, while HTTPS remains available for commands and snapshot recovery.

This selection accepts ownership of persistent connection capacity, session lifecycle, reconnect storms, backpressure, deployment draining, and delivery observability. It also creates three downstream design obligations:

- The change store must retain replayable event revisions and make committed changes reliably available for publication and catch-up.
- Delivery must manage WebSocket sessions and publish revisions without replacing the change store as the source of truth.
- Browser sync must expose connectivity state, reconnect with the last applied revision, catch up before resuming live updates, and recover a snapshot when retained history cannot bridge a gap.

The authoritative-revision tenet governs both live publication and recovery: a delivery path may transport a committed revision but may not create or reinterpret one. The visible-connectivity-failure tenet requires browser sync to distinguish a current board from one whose live connection or recovery has failed.
```

Please confirm this Phase 1 decision record. Also confirm whether the next phase should clean up the stale “still-open change-delivery approach” wording in `access-design.md` while drafting the change-store, delivery, and browser-sync nodes.