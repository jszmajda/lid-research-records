Created `docs/decisions/self-hosted-websocket-delivery.md` and linked it from the HLD’s decision entry. The record lays out the criteria, compares the three approaches, and documents the operational work accepted with self-hosting. `git diff --check` passes.

**Decision record for review:**

```markdown
---
node: high-level-design
---

# Decision: Self-Hosted WebSocket Delivery

## Context

MarketBoard maintains one authoritative stall-status board per event. Editors submit commands over HTTPS, and the server assigns each committed edit an event revision. The system must deliver committed changes to as many as 800 simultaneous staff browsers, recover the latest board after a browser has been disconnected for up to 20 minutes, and meet a 15-second freshness goal under normal connectivity.

Delivery affects more than the browser transport. The change store must make committed revisions available for delivery and later recovery; the delivery component must communicate changes to connected browsers; and browser sync must recover when a connection is interrupted. Three approaches meet the freshness goal but distribute operating work, cost, and recovery responsibilities differently.

## Decision Elements

- **Avoid recurring realtime-vendor fees and provider coupling — major, grounded in the HLD tenet.** The project prefers to own connection operations rather than take on a recurring dependency on a hosted realtime provider.
- **Deliver updates with low latency — moderate.** Faster propagation improves coordinators' view of current stall conditions, although subsecond delivery is not a project goal and the 15-second freshness target remains sufficient.
- **Keep delivery operations manageable — moderate.** The system must support its expected browser concurrency and recover cleanly from ordinary network interruptions. Persistent connection capacity and reconnect handling create work that must be weighed against simpler request/response operation or provider-managed connections.
- **Avoid unnecessary repeated reads — moderate.** The board has up to 800 simultaneous browsers, while edits are much less frequent than browser polling would be. The delivery approach should not create avoidable read load just to detect changes.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically make HTTPS requests for changes since their last observed event revision. The server responds with any newer revisions, or with no changes. The change store needs cursor queries; delivery remains stateless request/response; and each browser runs a polling loop.

- **Low-latency updates — partial.** A five-second interval adds up to several seconds of detection delay, although it remains within the 15-second freshness goal under normal connectivity.
- **Avoid recurring realtime-vendor fees and coupling — strong.** Delivery uses the application's HTTPS service without a realtime provider.
- **Manageable delivery operations — strong.** Requests do not require the application to maintain a long-lived session for each browser, and ordinary HTTP reconnect behavior is sufficient.
- **Avoid unnecessary repeated reads — weak.** Browsers continue requesting updates when no event revision has changed; cursor queries reduce the work per request but do not remove the repeated reads.

### Self-hosted WebSockets

The application maintains WebSocket connections to browsers and pushes committed event revisions over those connections. The change store retains replayable revisions and reliably publishes committed changes to delivery. Delivery owns session and connection-capacity management. Browser sync reconnects and catches up from its last observed revision after interruption.

- **Low-latency updates — strong.** The server can push a committed change without waiting for a browser polling interval.
- **Avoid recurring realtime-vendor fees and coupling — strong.** The application operates the connection service itself rather than depending on a hosted realtime provider.
- **Manageable delivery operations — weak.** The application team owns connection capacity, session lifecycle, reliable publication, and reconnect-related failure handling.
- **Avoid unnecessary repeated reads — strong.** Connected browsers do not need to poll for changes; reads occur for initial state and catch-up rather than on a fixed interval.

### Hosted realtime service

The application publishes committed event changes to a hosted realtime provider, which manages browser subscriptions and connections. The change store and application must reconcile publication with committed revisions; delivery wraps the provider's publication and subscription model; and browsers use the provider's client behavior to subscribe and recover.

- **Low-latency updates — strong.** The provider delivers published changes to subscribed browsers without a polling interval.
- **Avoid recurring realtime-vendor fees and coupling — weak.** The service introduces recurring provider costs and makes delivery depend on the provider's APIs and subscription model.
- **Manageable delivery operations — strong.** The provider takes on much of the connection-capacity and session-management burden, though the application still owns publication correctness and provider integration.
- **Avoid unnecessary repeated reads — strong.** Browsers receive published changes rather than periodically querying for them.

## Selection

Use self-hosted WebSockets to deliver committed event revisions to connected browsers. It combines low-latency push with the project's preference to avoid recurring realtime-vendor fees and provider coupling. Five-second polling avoids a realtime-provider dependency and simplifies connection operations, but repeatedly reads for changes and adds avoidable update delay. A hosted realtime service provides low-latency delivery with less connection work, but its recurring fees and provider coupling conflict with the project's major decision element.

The selection accepts the operational burden of self-hosting: MarketBoard must size and operate connection capacity, maintain WebSocket sessions, and handle reconnect and catch-up. This decision turns on the HLD tenet to avoid recurring realtime-vendor costs and coupling, even when self-hosting adds connection operations.

The choice obligates the change store to retain replayable event revisions and reliably publish committed changes to delivery. Delivery must manage WebSocket sessions and connected-client capacity. Browser sync must reconnect and catch up from a known revision so a transient disconnection does not leave the board stale. The detailed publication mechanism, session behavior, and catch-up protocol belong in the corresponding component designs.
```

Please review and approve this decision record. After approval, I’ll proceed with the three component nodes.