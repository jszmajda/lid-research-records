Created `docs/decisions/change-delivery.md` and linked it from the HLD. It records why the operational burden is acceptable without claiming self-hosting is free or cheapest overall.

## Decision: Self-hosted WebSockets for board changes

### Context

MarketBoard serves 40 weekend markets and up to 800 simultaneous staff browsers. Coordinators need committed stall-status changes to reach connected browsers within 15 seconds under normal connectivity, including opening-time bursts of 20 edits per second. Subsecond updates are desirable, not a separate performance requirement.

The delivery approach shapes three components: change store, delivery, and browser sync. All options retain HTTPS commands and one authoritative event revision per committed edit. Browsers need recovery after disconnections of up to 20 minutes; revisions are retained for seven days. The event-hours availability goal is 99.5 percent. These are common design obligations, not reasons to eliminate an option before its detailed design exists.

Five-second polling, self-hosted WebSockets, and a hosted realtime service are credible approaches. They differ in update latency, recurring service costs and provider coupling, and the operations work MarketBoard owns.

### Decision Elements

- **Update latency — major.** Favor prompt delivery of committed changes over routinely waiting for the next polling interval. The HLD tenet prefers low-latency updates over minimizing connection and reconnect operations work; the 15-second freshness requirement remains the acceptance target.
- **Realtime vendor independence — major.** Favor delivery without a realtime provider’s subscription model, credentials, and recurring service fees. This follows the HLD tenet favoring realtime vendor independence. It does not prohibit ordinary hosting services or imply that self-hosting is free.
- **Operations simplicity — moderate.** Favor fewer persistent connections to operate and fewer connection-capacity and recovery incidents to manage. This weighs against self-hosted WebSockets, but carries less weight than latency and realtime vendor independence.

No option is eliminated by a gate. Total infrastructure and support costs have not been quantified, so this decision does not claim that self-hosted WebSockets are the cheapest overall approach.

### Options in the Domain

#### Five-second HTTPS polling

Browsers periodically request committed changes after their last known event revision. Delivery remains request/response and can use familiar stateless HTTP operations. At 800 active browsers, a five-second interval implies roughly 160 polling requests per second even when boards are quiet, before retries or other traffic.

- **Update latency: partial fit.** Healthy browsers normally wait up to one polling interval before requesting a new change; this can meet the freshness target but introduces several seconds of lag.
- **Realtime vendor independence: strong fit.** Polling uses ordinary HTTPS without a realtime provider or its service fees.
- **Operations simplicity: strong fit.** There are no long-lived socket sessions to operate, though repeated reads and polling traffic still require capacity planning.

The change store needs cursor queries, delivery serves those queries, and browsers own polling and catch-up loops.

#### Self-hosted WebSockets

Browsers maintain connections to MarketBoard’s delivery service, which pushes committed revisions without waiting for a polling interval. MarketBoard controls session behavior and operates the connection infrastructure. Replayable revisions support recovery when a connection or publication attempt fails.

- **Update latency: strong fit.** Connected browsers can receive committed changes promptly through server push; actual latency depends on publication and delivery capacity.
- **Realtime vendor independence: strong fit.** Delivery avoids a realtime provider’s fees and subscription model, while still incurring hosting and support costs.
- **Operations simplicity: weak fit.** MarketBoard owns connection capacity, session lifecycle, service interruptions, and reconnect bursts. Browsers still need explicit recovery logic.

The change store needs replayable revisions and reliable publication, delivery manages socket sessions, and browsers reconnect and catch up.

#### Hosted realtime service

MarketBoard publishes committed changes through a provider, and browsers subscribe through that provider’s SDK or protocol. The provider operates connection infrastructure, offering a quick route to low-latency delivery and reducing direct connection-capacity work.

- **Update latency: strong fit.** Provider-managed push can deliver promptly without waiting for a polling interval.
- **Realtime vendor independence: weak fit.** Delivery depends on provider APIs, credentials, pricing, and subscription semantics; switching providers creates integration work.
- **Operations simplicity: strong fit.** The provider manages connections, although MarketBoard still owns publication reconciliation, provider incidents, and browser recovery.

The change store needs publication reconciliation, delivery wraps the provider, and browsers use its subscription model.

### Selection

Use self-hosted WebSockets for committed board changes. This turns on the HLD tenet preferring low-latency updates and realtime vendor independence over minimizing connection and reconnect operations work. Polling is simpler and vendor-independent but trades away prompt push delivery. Hosted realtime offers prompt delivery with less connection operations work but introduces recurring realtime service fees and provider coupling.

The accepted tradeoff is ownership of connection capacity and reconnect recovery, not a guarantee of lower total cost. Detailed design must still show how the required freshness, recovery, burst capacity, and event-hours availability goals are met.

The downstream obligations are:

- **Change store:** authoritative revisions, replayable history, and reliable publication of committed changes. The publication mechanism and replay interfaces belong in its design.
- **Delivery:** self-hosted socket sessions, connection capacity, and delivery of committed revisions. Session authentication, restart behavior, and replay coordination belong in its design.
- **Browser sync:** subscriptions, a revisioned view, reconnect, and catch-up. Recovery sequencing and visible connectivity failures belong in its design.

Five-second polling and a hosted realtime service are not the primary delivery approach. HTTPS remains the command boundary. The decision belongs to the HLD because its substance spans all three downstream nodes.

---

`git diff --check` passed.

One additional consideration to check: **should total hosting/support cost or event-hours staffing impose a hard constraint?** Neither currently has a specified limit.

Do you approve this decision record and the updated HLD, or would you like revisions before we move to the three nodes?