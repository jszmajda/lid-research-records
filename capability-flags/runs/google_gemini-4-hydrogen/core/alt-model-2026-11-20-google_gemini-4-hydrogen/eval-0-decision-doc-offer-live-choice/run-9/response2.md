Recorded the decision doc at `docs/decisions/change-delivery.md` and linked it from `docs/high-level-design.md` (`## Key Design Decisions`):

```markdown
---
node: high-level-design
---

# Decision: Change Delivery Mechanism

## Context

MarketBoard maintains one authoritative revisioned board per event, updated by editors over HTTPS and displayed to up to 800 simultaneous staff browsers with opening-time bursts of 20 edits per second. The change-delivery mechanism determines how committed revisions travel from the server to connected browsers, and it directly shapes three downstream components that must be designed together: the change store (query vs. publication model), the delivery service (stateless HTTP vs. session management vs. provider integration), and browser sync (polling loop vs. reconnect and catch-up vs. provider SDK).

All three candidate mechanisms can satisfy the 15-second freshness goal and the project's tenets (*Self-hosted and managed infrastructure are both permitted*; *A committed edit has one authoritative event revision regardless of its delivery route*; *Connectivity failures must be visible, not mistaken for an unchanged board*). The decision therefore turns on how the project trades update latency, read efficiency, vendor independence, and operational complexity.

## Decision Elements

### Weighted criteria

- **Vendor independence and predictable cost** (**major**): Avoiding recurring per-connection or per-message realtime vendor bills and avoiding coupling core delivery and browser sync to an external provider's subscription model. Derived from the project's infrastructure posture (*Self-hosted and managed infrastructure are both permitted*, leaving cost and coupling open to preference).
- **Update latency and read efficiency** (**moderate**): Delivering committed edits quickly (ideally subsecond, well within the 15-second freshness goal) without generating continuous repeated read load across 800 browsers during quiet periods.
- **Connection and reconnect operational burden** (**moderate**): Minimizing the stateful connection-capacity, session-lifecycle, publication, and client reconnect/catch-up machinery that MarketBoard must own and operate to maintain 99.5% availability during event hours.

## Options in the Domain

### Five-second HTTPS polling

- **Description**: Browsers periodically request changes since their last seen event revision over standard HTTPS endpoints every five seconds. The change store serves cursor-based revision queries, delivery remains stateless request/response, and browser sync runs a polling loop that surfaces errors when polls fail.
- **Analysis**:
  - Vendor independence and predictable cost: **strong** — relies only on standard HTTPS hosting with no realtime vendor dependency or per-connection fees.
  - Update latency and read efficiency: **weak** — introduces up to five seconds of polling lag and generates steady repeated read traffic (~160 requests/second across 800 browsers) even when no edits occur.
  - Connection and reconnect operational burden: **strong** — stateless request/response requires no persistent socket capacity management, session state, or specialized reconnect protocol.
- **Summary**: Simplest stateless operation, trading away subsecond latency and read efficiency.

### Self-hosted WebSockets

- **Description**: Browsers maintain persistent WebSocket connections to the MarketBoard delivery service, which pushes committed revisions as they occur. The change store provides replayable revisions and reliable publication to delivery, delivery manages WebSocket sessions and fan-out for up to 800 browsers, and browser sync implements reconnect and revision catch-up logic.
- **Analysis**:
  - Vendor independence and predictable cost: **strong** — runs on self-hosted infrastructure with no recurring realtime vendor bill or provider coupling.
  - Update latency and read efficiency: **strong** — pushes committed edits immediately (subsecond under normal connectivity) with no repeated polling reads during idle periods.
  - Connection and reconnect operational burden: **weak** — requires owning WebSocket connection capacity, session lifecycle, reliable store-to-delivery publication, and client reconnect/catch-up to recover missed revisions and surface connectivity failures.
- **Summary**: Fast updates and full vendor independence, paid for by owning stateful connection and reconnect operations.

### Hosted realtime service

- **Description**: MarketBoard publishes committed edits to a managed third-party realtime provider, which maintains browser connections and fans out updates. The change store requires publication reconciliation with the provider, delivery wraps provider authentication and publishing, and browser sync uses the provider's client subscription model.
- **Analysis**:
  - Vendor independence and predictable cost: **weak** — introduces recurring realtime vendor fees and couples delivery and browser sync to the provider's subscription and credential model.
  - Update latency and read efficiency: **strong** — delivers subsecond push updates without repeated polling reads.
  - Connection and reconnect operational burden: **partial** — offloads socket capacity and fan-out operations to the provider, but still requires publication reconciliation and provider credential management.
- **Summary**: Fast updates with lower connection-ops burden, at the cost of recurring fees and provider coupling.

## Selection

**Self-hosted WebSockets** is selected.

It wins on the highest-weighted criterion (**Vendor independence and predictable cost**: strong) while also achieving **strong** fit on **Update latency and read efficiency**. Although **Five-second HTTPS polling** is operationally simpler and **Hosted realtime service** offloads socket fan-out, MarketBoard explicitly accepts the extra connection-capacity and reconnect operations work rather than paying recurring realtime vendor fees, coupling the board to a provider, or accepting five-second polling lag and continuous read traffic. Because the HLD tenet *Self-hosted and managed infrastructure are both permitted* leaves either infrastructure model open, the choice turns on prioritizing vendor independence and fast push updates over minimizing connection operations.

Committing to self-hosted WebSockets creates specific downstream obligations across the three unauthored nodes:

- **Change store**: Must support replayable revision queries (for catch-up after disconnects of up to 20 minutes) and reliable publication of committed revisions to the delivery service.
- **Delivery**: Must manage self-hosted WebSocket sessions, authorization/subscription scoping, and fan-out for 800 simultaneous browsers during 20 edits/second bursts.
- **Browser sync**: Must implement WebSocket subscription, reconnect with revision catch-up, and visible connectivity-failure states per the tenet *Connectivity failures must be visible, not mistaken for an unchanged board*.
```

Does `docs/decisions/change-delivery.md` and the HLD update look good to lock in? If so, let me know whether to also clean up the "still-open change-delivery approach" phrasing in `docs/intent/access/access-design.md`, and which of the three nodes (`change-store`, `delivery`, or `browser-sync`) you want to draft first for Phase 2.