Created `docs/decisions/self-hosted-websockets.md` with the full rationale:

```markdown
---
node: high-level-design
---

# Decision: Self-hosted WebSockets for realtime delivery

## Context

MarketBoard must show committed stall-status changes to as many as 800 simultaneous staff browsers within 15 seconds under normal connectivity. Opening-time traffic can reach 20 edits per second, and a browser must recover the latest board after a disconnection lasting up to 20 minutes.

Editors already submit commands over HTTPS, and the server assigns each committed edit one authoritative event revision. The remaining choice is how those revisions reach browsers. That choice shapes the change store's read and replay model, the delivery service's operating responsibilities, browser recovery, and ongoing service costs. All three options considered here can preserve authoritative event revisions and meet the 15-second freshness goal.

## Decision Elements

- **Update freshness — major.** Prefer prompt delivery after a commit. The 15-second goal is a ceiling, not a reason to accept avoidable lag when a lower-latency option is otherwise affordable.
- **Vendor independence and cost exposure — major.** Prefer avoiding a required realtime provider, its recurring service fees, and coupling to its subscription and recovery model. Self-hosting still consumes infrastructure and staff time; this criterion concerns dependency on a realtime vendor specifically.
- **Operational burden — major.** Weigh the work of capacity planning, handling persistent connections, recovering failed connections, and operating the publication path. A lower-latency design is not worthwhile if its operating burden is ignored.
- **Storage and recovery complexity — moderate.** Weigh the read models and publication behavior needed to support initial board loads, catch-up after interruption, and seven days of retained event revisions.

## Options in the Domain

### Five-second HTTPS polling

Each browser requests changes through a cursor every five seconds. The server answers through ordinary stateless HTTPS request/response handling, and the change store supports cursor queries. A browser that has fallen behind uses its last cursor or reloads a board snapshot.

**Analysis**

- **Update freshness: partial.** Polling meets the 15-second goal, but a committed change normally waits for the next polling request before delivery begins.
- **Vendor independence and cost exposure: strong.** Delivery needs no realtime vendor, provider credentials, or provider-specific browser SDK.
- **Operational burden: strong.** Stateless requests avoid persistent-connection capacity and server-side socket session management. The trade is repeated reads: 800 active browsers polling every five seconds produce an average of 160 requests per second before retries, including when no changes exist.
- **Storage and recovery complexity: strong.** Cursor queries provide a direct catch-up mechanism without requiring a realtime publication path.

**Summary:** Polling minimizes connection operations and vendor dependency, but accepts polling lag and repeated reads.

### Self-hosted WebSockets

The delivery service accepts WebSocket connections and publishes each committed revision to subscribed browsers. The change store retains replayable revisions and reliably makes committed changes available for publication. Browsers own reconnect behavior and use their last received revision to catch up after an interruption. Editor commands remain on HTTPS.

**Analysis**

- **Update freshness: strong.** Connected browsers can receive a revision as soon as the delivery service publishes it, without waiting for a polling interval.
- **Vendor independence and cost exposure: strong.** The board does not depend on a realtime service subscription, proprietary subscription model, or vendor-specific recovery behavior.
- **Operational burden: weak.** MarketBoard owns persistent-connection capacity, socket lifecycles, reliable publication, deployment draining, and reconnect spikes. The team must monitor and operate these paths rather than delegating them to a provider.
- **Storage and recovery complexity: partial.** Replayable revisions give browsers a direct catch-up mechanism, but the store and delivery service must coordinate reliable publication and preserve enough history for recovery.

**Summary:** Self-hosted sockets provide fast, vendor-independent updates in exchange for the project's highest connection and recovery operating burden.

### Hosted realtime service

The delivery service publishes committed changes through a hosted realtime provider, and browsers use that provider's subscription model. The provider operates the persistent-connection infrastructure. MarketBoard remains responsible for reconciling its authoritative revisions with provider publication and for protecting provider credentials.

**Analysis**

- **Update freshness: strong.** A managed realtime path can deliver changes promptly without a polling interval.
- **Vendor independence and cost exposure: weak.** The board incurs recurring service fees and becomes coupled to provider quotas, APIs, subscription semantics, and recovery behavior. Changing providers would affect both delivery and browser sync.
- **Operational burden: strong.** The provider carries connection-capacity and much of the socket-reconnect burden. MarketBoard still operates publication reconciliation, credentials, monitoring, and provider-failure handling.
- **Storage and recovery complexity: partial.** The authoritative revision history remains available for board recovery, but the system must reconcile committed revisions with externally acknowledged publication and map provider recovery onto board state.

**Summary:** Hosted realtime combines low latency with reduced connection operations, but introduces the recurring fees and provider coupling the project wants to avoid.

## Selection

Choose self-hosted WebSockets. Polling has the simplest operating model, but its repeated reads and polling delay are less attractive when persistent connections can deliver updates promptly. Hosted realtime removes much of that connection work, but its recurring fees and provider coupling outweigh that benefit for MarketBoard.

This choice turns on the tenet **Realtime independence over minimal connection operations**: the project accepts self-hosted connection and reconnect work rather than making board updates depend on a realtime vendor. It does not change the HTTPS command boundary or the single authoritative event revision.

The choice obligates the change store to provide replayable revisions and reliable publication, delivery to manage socket sessions and connection capacity, and browser sync to reconnect and catch up. These costs are explicit parts of the design, including the work needed to meet the 800-browser and 99.5-percent event-hours availability goals. Reconsider the choice if operating those paths cannot meet those goals or demonstrably costs more than the project is willing to pay for realtime vendor independence.
```

I also:

- Added the **Realtime independence over minimal connection operations** tenet to the HLD.
- Replaced the HLD’s decision paragraph with a link to this decision record.
- Clarified that managed infrastructure remains permitted outside realtime delivery.
- Updated Access to describe self-hosted WebSockets as the selected delivery approach.

Please review the decision record and revised tenet. Once approved, I’ll start with the change-store LLD and stop for its review.