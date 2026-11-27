Created `docs/decisions/self-hosted-websockets.md` and linked it from the HLD’s Key Design Decisions.

# Decision: Self-hosted WebSockets for change delivery

## Context

MarketBoard keeps one authoritative, revisioned board per event. Editors submit commands over HTTPS, and every committed edit receives one event revision. Staff browsers then need to receive those revisions promptly, remain connected through opening-time bursts, and recover the latest board after connectivity failures.

The delivery mechanism determines more than the browser transport. It shapes the change store's read and publication model, the delivery service's operating responsibilities, and browser recovery. The system must support 800 simultaneous browsers, bursts of 20 edits per second, recovery after disconnections lasting up to 20 minutes, and seven days of revision retention. Connected browsers must show committed changes within 15 seconds under normal connectivity; subsecond delivery is useful but is not a requirement.

## Decision Elements

### Gates

- **Vendor-independent board synchronization.** Receiving stall updates must not require an external realtime provider. This gate follows from the decision to avoid coupling the board to a realtime vendor.

### Weighted criteria

- **Update freshness — major.** Favor prompt delivery of committed changes, while treating subsecond latency as a benefit rather than a contractual target.
- **Operational burden — major.** Consider the work required to run delivery during published event hours, including capacity, failures, reconnects, and recovery. This criterion weighs against the tenet **Prefer owning update-delivery connection operations over coupling board synchronization to a realtime vendor** when that ownership requires substantial new operations.
- **Recurring delivery cost — moderate.** Prefer avoiding a usage-based realtime service bill, without treating all operating effort as free.
- **Downstream implementation fit — moderate.** Consider what the choice requires from revision storage, publication, delivery sessions, and browser catch-up. These components must form one coherent recovery path rather than three independent mechanisms.

## Options in the Domain

### Five-second HTTPS polling

**Description.** Browsers request changes every five seconds over ordinary HTTPS. The server remains request/response and does not retain browser connection sessions. The change store provides cursor-based queries so each browser can request revisions after its current position. Browser sync runs a polling loop and tracks the latest received cursor.

**Analysis.**

- **Vendor-independent board synchronization: passes.** Delivery uses the project's own HTTPS service.
- **Update freshness: partial fit.** Five-second polling can meet the 15-second freshness goal under normal connectivity, but introduces polling delay and does not provide the prompt delivery available from a persistent connection.
- **Operational burden: strong fit.** Stateless requests avoid socket capacity management, persistent-session failures, and socket reconnect handling.
- **Recurring delivery cost: strong fit.** There is no realtime vendor bill, although repeated reads consume server and storage capacity.
- **Downstream implementation fit: partial fit.** Cursor queries and a polling loop are comparatively simple, but the approach accepts repeated reads and delivery lag throughout the board's update path.

**Summary.** Minimizes delivery operations and implementation complexity in exchange for repeated reads and slower updates.

### Self-hosted WebSockets

**Description.** The project operates persistent WebSocket connections between its delivery service and staff browsers. Committed event revisions are published reliably to connected sessions. The change store retains replayable revisions so a reconnecting browser can catch up from its last received revision and recover the latest board. Delivery owns connection capacity and sessions; browser sync owns reconnect and catch-up behavior.

**Analysis.**

- **Vendor-independent board synchronization: passes.** Socket infrastructure and publication remain under the project's control.
- **Update freshness: strong fit.** Established connections allow committed revisions to be pushed promptly without waiting for the next polling interval.
- **Operational burden: weak fit.** The project must provision and monitor connection capacity, operate reliable publication, and handle connection failures and reconnect storms.
- **Recurring delivery cost: strong fit.** There is no realtime vendor bill; infrastructure and operating effort remain project costs.
- **Downstream implementation fit: partial fit.** Replayable revisions provide a direct catch-up path, but require reliable publication, session management, and coordinated browser reconnect logic across all three delivery-related nodes.

**Summary.** Provides fast, vendor-independent updates in exchange for owning connection and recovery operations.

### Hosted realtime service

**Description.** An external realtime provider maintains browser connections and subscriptions. The delivery service wraps the provider's publication API, while browser sync uses the provider's subscription model. The change store and delivery service reconcile publication with the provider so committed revisions are not silently lost when publication fails.

**Analysis.**

- **Vendor-independent board synchronization: eliminated.** Board updates depend on an external realtime provider's availability, API, and subscription model.
- **Update freshness: strong fit.** Provider-managed persistent subscriptions support prompt delivery without polling delays.
- **Operational burden: strong fit.** The provider operates connection capacity and much of the socket infrastructure, although the project must still handle credentials, provider failures, and publication reconciliation.
- **Recurring delivery cost: weak fit.** Usage generates recurring provider fees.
- **Downstream implementation fit: partial fit.** Provider subscriptions reduce connection code, but provider wrapping and publication reconciliation add their own cross-component behavior and failure cases.

**Summary.** Reduces connection operations while introducing recurring fees and a provider dependency.

## Selection

Self-hosted WebSockets are selected because prompt updates and vendor independence outweigh the additional operating burden for MarketBoard. Five-second HTTPS polling remains operationally attractive, but its repeated reads and polling delay are unnecessary when fast updates are a priority. The hosted service also provides prompt updates, but fails the vendor-independence gate and adds recurring fees.

This selection applies the tenet **Prefer owning update-delivery connection operations over coupling board synchronization to a realtime vendor** despite the operational-burden criterion favoring the alternatives. It does not introduce a subsecond freshness guarantee; the existing 15-second goal remains the requirement.

The choice commits the change store to replayable revisions and reliable publication, delivery to socket sessions and connection capacity, and browser sync to reconnect and catch-up. It forecloses reliance on a hosted realtime provider for board synchronization and accepts that connection failures, reconnect behavior, and publication reliability are MarketBoard's own operational responsibilities.

---

Please review the decision doc. Once approved, I’ll start with the Change Store node.