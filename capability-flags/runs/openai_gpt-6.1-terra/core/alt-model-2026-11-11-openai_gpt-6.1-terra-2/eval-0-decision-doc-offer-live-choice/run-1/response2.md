I added `docs/decisions/change-delivery.md` and linked it from the HLD. Here is the decision document for review:

---

# Decision: Delivery of Board Changes

## Context

MarketBoard keeps one authoritative board per event. Editors submit commands over HTTPS, and connected staff browsers need to reflect committed changes. The pilot targets 800 simultaneous browsers, opening-time bursts of 20 edits per second, and 99.5 percent availability during event hours. Changes should appear within 15 seconds under normal connectivity; subsecond delivery would be useful but is not required. Browsers must recover the latest board after disconnections of up to 20 minutes, and event revisions are retained for seven days.

The delivery approach shapes the change store, the delivery service, and browser synchronization. It also determines which operational responsibilities MarketBoard takes on and whether it depends on a realtime provider.

## Decision Elements

- **Update latency — major.** Faster updates make the board more useful to staff coordinating an active market, even though all three options can meet the 15-second target.
- **Realtime provider independence and fees — major.** Avoid coupling delivery to a realtime provider and paying recurring realtime-service fees.
- **Operational burden — major.** Connection management, recovery, reliable publication, and availability require implementation and ongoing operations.
- **Repeated request and read load — moderate.** The delivery method affects how much work the system performs when browsers are connected but the board has not changed.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes after their last known revision. The change store supports cursor queries, and delivery remains request/response. Browsers run a polling loop and recover missed changes through subsequent requests.

- **Partial fit — update latency.** Changes can wait several seconds for the next poll, although the approach can meet the 15-second target.
- **Strong fit — realtime provider independence and fees.** Delivery does not require a realtime provider.
- **Strong fit — operational burden.** Stateless request/response avoids managing persistent socket sessions, though the browser still needs a polling loop and recovery behavior.
- **Weak fit — repeated request and read load.** Browsers make recurring requests and reads even when there are no changes.

### Self-hosted WebSockets

MarketBoard operates WebSocket connections to push committed changes to browsers. The change store retains replayable revisions and supports reliable publication; delivery manages sessions and capacity; browsers reconnect and catch up after interruptions.

- **Strong fit — update latency.** Established connections allow changes to be pushed promptly without waiting for a polling interval.
- **Strong fit — realtime provider independence and fees.** MarketBoard does not depend on a hosted realtime service or pay its recurring service fees.
- **Weak fit — operational burden.** MarketBoard owns connection capacity, session management, reliable publication, and reconnect and catch-up behavior.
- **Strong fit — repeated request and read load.** Connected browsers do not need a periodic poll to discover each change.

### Hosted realtime service

A provider manages realtime connections and distributes changes to subscribed browsers. Delivery wraps the provider; the change store supports publication reconciliation; browsers use the provider's subscription model.

- **Strong fit — update latency.** Provider-managed subscriptions can push changes promptly.
- **Weak fit — realtime provider independence and fees.** Delivery depends on a provider and incurs recurring service fees.
- **Partial fit — operational burden.** The provider handles connection infrastructure, but MarketBoard still owns publication reconciliation, integration, and browser recovery behavior.
- **Strong fit — repeated request and read load.** Connected browsers do not need a periodic poll to discover each change.

## Selection

Use **self-hosted WebSockets** for committed board changes. The value of fast updates and avoiding realtime-provider coupling and fees outweighs the added connection and recovery operations. Polling would be simpler to operate but adds repeated reads and seconds of lag; a hosted service would reduce connection operations but introduce provider coupling and recurring fees.

This choice commits MarketBoard to managing connection capacity and sessions, reliable publication, replayable revisions, and browser reconnect and catch-up. Those mechanisms and their failure handling belong in the change store, delivery, and browser sync designs. The authoritative-revision and visible-connectivity-failure tenets remain important constraints on those designs. The existing 15-second freshness target remains the requirement; selecting WebSockets does not promise subsecond delivery.

---

Do you approve the HLD and decision document? In particular, I’ve treated repeated read load as **moderate** importance: does that match your priorities, and is there another consideration—such as staffing for event-hours operations—that should affect the comparison?

Also, should the preference for fast updates and provider independence be a general project tenet, or remain specific to this decision? The access design still calls delivery “open”; may I correct that wording when we cascade?