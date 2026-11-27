I wrote the decision doc and linked it from the HLD's Key Design Decisions section.

```markdown
---
node: high-level-design
---

# Decision: Self-Hosted WebSockets for Change Delivery

## Context

MarketBoard runs one authoritative board per event across forty weekend markets. About 120 coordinators maintain boards for up to 800 simultaneous staff browsers; a busy market has 10-25 editors and averages two status changes per minute, with larger bursts around opening time.

Committed changes must reach connected browsers within fifteen seconds under normal connectivity, support opening-time bursts of twenty edits per second, recover the latest board after a browser has been disconnected for up to twenty minutes, retain seven days of revisions, and achieve 99.5 percent availability during published event hours. Every option considered can meet these requirements; the decision is which operating tradeoff to accept while doing so.

The tenets require one authoritative event revision per committed edit regardless of delivery route, require connectivity failures to be visible rather than mistaken for an unchanged board, and permit both self-hosted and managed infrastructure. Event updates contain stall IDs and operational statuses, not customer records.

## Decision Elements

- **Vendor independence** — *major.* How much the board's delivery depends on a third-party realtime provider, including migration cost if the provider's pricing or terms change.
- **Recurring vendor cost** — *moderate.* Whether delivery carries usage-based or subscription fees from a realtime vendor, as distinct from ordinary infrastructure cost.
- **Operational burden** — *major.* The connection capacity, session state, publication reliability, and reconnect behavior the project must operate itself.
- **Update latency** — *moderate.* How quickly a committed revision reaches connected browsers, and how much headroom that leaves against the fifteen-second freshness goal.
- **Implementation simplicity** — *moderate.* The amount of new protocol, session, and recovery behavior the delivery, change-store, and browser components must carry.

## Options in the Domain

### Five-Second HTTPS Polling

Browsers re-request board state every five seconds over ordinary HTTPS. Delivery stays stateless request/response: the store exposes cursor queries so a browser can fetch revisions after the last one it displayed, and browsers run a polling loop. A lost request is visible as a failed poll, and the next poll is the recovery mechanism; there is no persistent connection to rebuild.

**Analysis**

- Vendor independence: **strong** — no realtime provider is involved.
- Recurring vendor cost: **strong** — no vendor fees, though repeated reads consume server and database capacity.
- Operational burden: **strong** — no connection capacity or session state to operate; the load is repeated reads from every browser.
- Update latency: **partial** — a change can wait up to the polling interval plus request time before display; the fifteen-second goal is met with limited headroom.
- Implementation simplicity: **strong** — stateless delivery and cursor-based reads, with the browser owning a simple polling loop.

**Summary:** The simplest stateless option, paid for with repeated reads and a few seconds of lag.

### Self-Hosted WebSockets

Each connected browser holds a persistent WebSocket to delivery. The server pushes committed revisions as they are published; the change store keeps replayable revisions and reliably publishes them, and delivery manages the live sessions. When a connection drops, the browser reconnects and catches up from the last revision it displayed. The project operates the connection capacity and the reconnect path.

**Analysis**

- Vendor independence: **strong** — the project owns the delivery path and can change infrastructure without a provider migration.
- Recurring vendor cost: **strong** — no realtime vendor bill; the project pays for the infrastructure that holds the connections.
- Operational burden: **weak** — the project owns connection capacity, session state, publication reliability, and reconnect storms.
- Update latency: **strong** — a committed revision is pushed as soon as it is published, leaving wide headroom against the fifteen-second goal.
- Implementation simplicity: **partial** — delivery needs session management and reliable publication, and the browser needs reconnect and catch-up behavior.

**Summary:** Fast push delivery without a vendor, paid for by owning connections and reconnect behavior.

### Hosted Realtime Service

Delivery wraps a realtime provider. The server publishes committed revisions to the provider, the change store reconciles publication so revisions are not lost between commit and publish, and browsers use the provider's subscription model. The provider owns connection scaling and reconnect handling.

**Analysis**

- Vendor independence: **weak** — the board's delivery is coupled to the provider, and replacing it means migrating publication and subscription behavior.
- Recurring vendor cost: **weak** — delivery carries recurring usage or subscription fees.
- Operational burden: **strong** — the provider operates connection capacity and reconnect behavior; the project still reconciles publication.
- Update latency: **strong** — the provider pushes revisions to subscribers with low delay.
- Implementation simplicity: **partial** — less connection code, but publication reconciliation and provider-specific subscription handling remain.

**Summary:** The least connection operations and quickest low-latency route, paid for with recurring fees and provider coupling.

## Selection

Self-hosted WebSockets wins on the two criteria the project weighted most heavily: vendor independence and operational burden. It keeps delivery under the project's control, avoids recurring realtime vendor fees and provider coupling, and uses a push model that leaves substantial headroom against the fifteen-second freshness goal. The cost it accepts is the operational burden of owning connection capacity and reconnect behavior — the criterion on which it scores weakest and where a hosted service would be strongest. That cost is accepted deliberately to keep the board independent of a realtime vendor.

Five-second polling is the strongest option on implementation simplicity and also avoids vendor cost, but its repeated reads and seconds of lag leave less freshness headroom. A hosted realtime service is the strongest option on connection operations and latency, but the recurring fees and provider coupling are the tradeoff the project declines.

The decision turns on the tenet permitting self-hosted and managed infrastructure: self-hosting is an allowed route, and the project prefers it here over the managed alternative. The tenet requiring one authoritative revision per committed edit still governs: self-hosted delivery pushes revisions the store has already committed, and reconnect catch-up reads those same revisions. The tenet requiring connectivity failures to be visible becomes a downstream obligation: reconnect and catch-up must distinguish a dropped connection from an unchanged board rather than silently showing stale state.

Downstream, this commits the change store to retaining replayable revisions and publishing them reliably, delivery to managing WebSocket sessions, and browser sync to reconnecting and catching up from the last displayed revision.
```

Does this capture the tradeoff the way you want? If you approve the HLD and this decision doc, I'll move on to the three node designs.