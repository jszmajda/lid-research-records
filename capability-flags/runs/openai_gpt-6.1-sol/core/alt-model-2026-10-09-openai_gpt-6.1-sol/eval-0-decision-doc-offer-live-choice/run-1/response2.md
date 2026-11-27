Created `docs/decisions/board-change-delivery.md` and linked it from the HLD’s WebSocket decision. `git diff --check` passed.

Here is the decision document for review:

# Decision: Board Change Delivery

## Context

MarketBoard gives weekend market staff a shared view of stall closures, late arrivals, and power problems. Forty markets use the service, with up to 800 simultaneous staff browsers and opening-time bursts of 20 edits per second. Editors submit commands over HTTPS; the server owns each event’s board and assigns committed edits authoritative event revisions.

The delivery approach determines how browsers learn about committed changes. It also shapes revision storage, publication, and browser recovery, so this decision belongs to the high-level design, above the change store, delivery, and browser sync nodes.

All three options can meet the 15-second freshness target under normal connectivity. Subsecond updates are desirable, not a separate guarantee. Every option must support recovery after a browser has been disconnected for up to 20 minutes, seven days of revision retention, and the 99.5 percent event-hours availability target. These are shared constraints rather than reasons to prefer one option.

## Decision Elements

- **Low delivery latency — major.** Faster propagation helps staff coordinate around the same board. The tenet “Prefer low-latency, vendor-independent board delivery over minimizing connection-operations work” favors prompt push delivery even though polling meets the required freshness target.
- **Realtime-vendor independence and fee exposure — major.** Avoiding a provider-specific realtime subscription model and recurring realtime-vendor fees preserves control over delivery. This follows the same tenet; it does not prohibit managed infrastructure elsewhere or imply that self-hosting is free.
- **Implementation and operational burden — moderate.** Session capacity, interrupted connections, deployments, and reconnect bursts require engineering and operational work. This criterion weighs against self-hosted WebSockets, including the work needed to sustain event-hours availability.
- **Repeated read load — minor.** Avoiding unchanged-board reads reduces routine store and request traffic. Actual infrastructure savings depend on implementation and usage; no option has a quantified total-cost advantage here.

## Options in the Domain

### Five-second HTTPS polling

Each browser runs a polling loop, requesting changes after its last known event revision every five seconds. Delivery stays request/response, and the change store supports cursor-based reads. A returning browser resumes from its revision using the recovery contract.

- **Low delivery latency: partial.** The interval adds seconds of lag but can meet the 15-second target under normal connectivity.
- **Realtime-vendor independence and fee exposure: strong.** Standard HTTPS requests require no realtime provider or realtime subscription fees.
- **Implementation and operational burden: strong.** Stateless delivery avoids long-lived session management and socket reconnect operations, though cursor recovery and polling failures still need handling.
- **Repeated read load: weak.** Browsers request changes even when there are none; 800 browsers polling every five seconds produce roughly 160 requests per second before retries.

### Self-hosted WebSockets

Browsers maintain WebSocket connections to MarketBoard delivery servers. Delivery pushes committed revisions to event subscribers. The change store supplies replayable revisions and reliable publication, while browsers reconnect and catch up after interruption. HTTPS remains the command path.

- **Low delivery latency: strong.** Push delivery avoids waiting for a polling interval; realized latency still depends on publication and capacity.
- **Realtime-vendor independence and fee exposure: strong.** MarketBoard controls the subscription and recovery contract without a realtime vendor. Hosting, engineering, and operational costs remain.
- **Implementation and operational burden: weak.** MarketBoard owns connection capacity, session lifecycle, reconnect bursts, deployment interruptions, and reliable publication and replay integration.
- **Repeated read load: strong.** Connected browsers receive changes as they occur; recovery reads remain necessary after interruptions.

### Hosted realtime service

MarketBoard publishes committed changes through a hosted provider. Delivery wraps the provider, the change store supports publication reconciliation, and browsers use the provider’s subscription model. Recovery must still reconcile the browser’s view with authoritative event revisions.

- **Low delivery latency: strong.** Provider-managed push delivery offers a direct route to low-latency updates.
- **Realtime-vendor independence and fee exposure: weak.** Recurring fees and provider-specific publication and subscription contracts create cost exposure and coupling.
- **Implementation and operational burden: strong.** The provider operates connection infrastructure, reducing MarketBoard’s session-capacity work; provider integration, reconciliation, and outage recovery remain MarketBoard responsibilities.
- **Repeated read load: strong.** Subscriptions avoid routine unchanged-board polling, though reconciliation and recovery still require reads.

## Selection

Use **self-hosted WebSockets** for committed board changes. The major criteria of low latency and realtime-vendor independence outweigh the moderate criterion of minimizing implementation and operational burden. This selection follows the HLD tenet favoring low-latency, vendor-independent delivery over simpler connection operations.

Polling remains credible because it meets the freshness requirement with simpler operation. Hosted realtime remains credible because it offers low latency with less connection infrastructure work. Neither is selected: polling accepts seconds of lag and repeated reads, while hosted realtime accepts recurring realtime-vendor fees and provider coupling. Self-hosting is not selected on a claim of lower total cost; the accepted trade is additional engineering and operations for fast delivery under MarketBoard’s control.

The choice creates three downstream design obligations:

- **Change store:** Replayable authoritative event revisions and reliable publication of committed changes.
- **Delivery:** Self-hosted WebSocket sessions, event subscriptions, connection capacity, and interrupted-session handling.
- **Browser sync:** A revisioned board view, visible connectivity failures, reconnect, and catch-up from authoritative state.

The three nodes must agree on the revision and recovery contract. This decision does not choose a publication mechanism, replay API, reconnect policy, hosting topology, or a new latency guarantee; those details require downstream design review.

Reconsider the choice if connection operations prevent meeting availability or capacity goals, if engineering and hosting costs outweigh the value of vendor independence, or if seconds of delivery lag become acceptable enough to favor polling. Those conditions would change the weighting behind the selection.

---

**Does this capture the tradeoff you intended—particularly the weighting of latency and vendor independence above operational simplicity?** Once approved, we can start with the change-store node.