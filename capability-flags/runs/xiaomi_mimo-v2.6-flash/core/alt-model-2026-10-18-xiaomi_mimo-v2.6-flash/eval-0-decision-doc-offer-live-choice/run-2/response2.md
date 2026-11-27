**Decision doc written** at `docs/decisions/self-hosted-websockets-delivery.md`, linked from the HLD's Key Design Decisions entry. Full text:

---
node: high-level-design
---

# Decision: Self-hosted WebSockets deliver committed changes

## Context

MarketBoard editors commit stall-status changes over HTTPS, and each committed edit receives one authoritative event revision. Up to 800 simultaneous browsers must display those revisions with committed changes visible within 15 seconds under normal connectivity, at burst loads of 20 edits per second around opening time. The delivery channel is the pivot for three design nodes — change store, delivery, and browser sync — so its choice sizes how each is built: how the store answers "what changed since revision N," how committed revisions reach connected browsers, and how a browser resumes after a gap. Three channels are in contention: five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service. All three can meet the freshness goal, and the project's tenets permit both self-hosted and managed infrastructure, so the selection is a tradeoff judgment rather than a constraint.

## Decision Elements

No gate eliminates an option: every channel meets the freshness goal, and the tenets permit both self-hosted and managed infrastructure. The decision turns on weighted criteria:

- **Update latency — major.** Time from commit to display in connected browsers under normal connectivity. Subsecond fan-out is useful headroom; the hard requirement is 15 seconds.
- **Recurring cost and provider coupling — major.** Ongoing fees and dependence on a third party's pricing, availability, credentials, and subscription model.
- **Operational burden we own — moderate.** Connection capacity, session liveness, reconnect bursts, and reliable publication carried by the project's own operations.
- **Design simplicity across the three nodes — moderate.** How much machinery each channel demands of the change store, delivery, and browser sync.
- **Visibility of connectivity failure — moderate.** Importance derives from the tenet *connectivity failures must be visible, not mistaken for an unchanged board*: how directly the channel distinguishes a broken connection from a board that simply hasn't changed.

The tenet *self-hosted and managed infrastructure are both permitted* engages by failing to gate — hosted delivery stays permissible on principle, leaving the choice to these criteria.

## Options in the Domain

### Five-second HTTPS polling

**Description.** Browsers re-request the board, or the changes since a cursor revision, every five seconds over ordinary HTTPS. The server answers each request independently — no persistent connection, no session state between requests. The store needs cursor queries ("everything after revision N"); delivery stays request/response; the browser runs a polling loop. Failures are individual request failures.

**Analysis:**
- Latency — **partial**: an update can wait up to five seconds plus request time before first display; meets the 15-second goal with the least headroom of the three, and never reaches subsecond.
- Recurring cost and provider coupling — **strong**: no third-party service, no fees, no provider coupling.
- Operational burden we own — **strong**: no connection capacity or session liveness to manage; each request is independent.
- Design simplicity — **strong**: the simplest stateless operation; the store needs only cursor queries and browsers need only a loop.
- Visibility of connectivity failure — **partial**: a stopped or failing polling loop looks exactly like an unchanged board unless the browser explicitly tracks request failure.

**Summary.** The least operational work; trades away update speed and issues repeated reads.

### Self-hosted WebSockets

**Description.** The server holds persistent socket connections whose capacity the project owns. The store keeps a monotonically revised history that can replay from any prior revision, and delivery publishes each committed revision to subscribed sockets as it commits. A browser reconnects with its last-seen revision and catches up from replay, so a gap in connection is recoverable rather than lost.

**Analysis:**
- Latency — **strong**: committed revisions fan out to connected browsers in subsecond time.
- Recurring cost and provider coupling — **strong**: no realtime vendor fee or coupling; cost is ordinary infrastructure.
- Operational burden we own — **weak**: the project owns connection capacity, reconnect bursts, session liveness, and reliable publication from store to sockets.
- Design simplicity — **partial**: the store needs replayable revisions and reliable publication, delivery manages sessions, and browsers need reconnect and catch-up logic.
- Visibility of connectivity failure — **strong**: a disconnect is a first-class event; the browser knows it is stale rather than inferring it.

**Summary.** Fast updates without a realtime vendor; carries the connection and reconnect operations work.

### Hosted realtime service

**Description.** A third-party realtime provider fronts subscriptions. The application server publishes each committed revision through the provider's API; the store reconciles publication (confirming the provider accepted the revision); delivery wraps the provider's SDK, credentials, and limits; browsers subscribe through the provider's subscription model. The provider owns connection capacity and much of the reconnect machinery.

**Analysis:**
- Latency — **strong**: subsecond delivery as a service guarantee of the provider.
- Recurring cost and provider coupling — **weak**: recurring fees at 800-connection scale, plus coupling to the provider's availability, pricing, credentials, and subscription model.
- Operational burden we own — **strong**: the provider owns connection capacity and reconnect infrastructure.
- Design simplicity — **partial**: integration and credential wrapping plus publication reconciliation replace connection management, rather than removing the work.
- Visibility of connectivity failure — **partial**: failure modes split between provider status and application health, so a stale browser can stem from either.

**Summary.** The least connection operations at the price of recurring fees and provider coupling.

## Selection

**Self-hosted WebSockets.** The decision turns on the two major criteria: it delivers the fastest updates of the contention without introducing a realtime vendor's fees or coupling — polling loses on latency margin, the hosted service loses on cost and coupling. The criterion it scores weakest on — operational burden we own — is accepted as the price of the other two: connection capacity and reconnect handling become delivery's job by design, not an accident.

Committing forecloses stateless request/response delivery and any hosted subscription model. It obligates the downstream nodes: the change store must keep replayable revisions and a reliable publication path; delivery must own socket sessions, subscription handling, and reconnect capacity; browser sync must reconnect with a last-seen revision and catch up from replay. The selection is not carried by a tenet against its opposition — *self-hosted and managed infrastructure are both permitted* leaves hosted delivery permissible, so the judgment rests on the criteria — and the *connectivity failures must be visible* tenet is served downstream by first-class disconnect and catch-up behavior in delivery and browser sync.

---

Still open from my last message:

1. **Access cascade** — `access-design.md` still says authorization is "independent of the still-open change-delivery approach." The substance holds; "still-open" is now stale. ACCESS is a separate segment, so I'm asking rather than editing: want me to update that line?

2. Approve Phase 1 and I'll start the first of the three nodes (change store, delivery, browser sync), stopping at each.