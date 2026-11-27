Created `docs/decisions/self-hosted-websockets.md` and linked it from the HLD’s Key Design Decisions. It records the criteria, gives each option its strongest honest representation, and explains the accepted tradeoff and downstream obligations.

# Decision: Self-hosted WebSockets for committed-change delivery

## Context

MarketBoard keeps one authoritative, revisioned board per event. Editors submit commands over HTTPS, and every committed edit receives one event revision. Staff browsers then need to receive those revisions promptly and recover the latest board after connectivity failures.

The delivery mechanism must support up to 800 simultaneous browsers, opening-time bursts of 20 edits per second, and recovery after disconnections lasting up to 20 minutes. Five-second HTTPS polling, self-hosted WebSockets, and a hosted realtime service can all meet the 15-second freshness goal. The choice therefore turns on the value of faster updates, server read load, operational responsibility, recurring cost, and provider independence rather than on basic feasibility.

This decision does not change the HTTPS command boundary or the authoritative revision model. It selects how committed revisions reach browsers and establishes obligations for change storage, delivery, and browser recovery.

## Decision Elements

- **Update freshness — major.** Connected browsers should receive committed changes quickly. Meeting the 15-second goal is necessary, while lower latency provides useful headroom during opening-time activity.
- **Vendor independence and recurring cost — major.** The project prefers operating realtime connections itself over recurring realtime-vendor fees and provider coupling, as expressed in the HLD tenets.
- **Operational and implementation burden — moderate.** The approach should not impose connection, recovery, or provider-reconciliation work disproportionate to its benefits.
- **Server read amplification — moderate.** Delivery should avoid unnecessary repeated reads as browser counts grow, particularly because boards may remain unchanged between browser requests.

## Options in the Domain

### Five-second HTTPS polling

Each browser runs a polling loop and requests revisions after its last known cursor over HTTPS. Delivery remains request/response and does not maintain browser sessions. The change store provides cursor queries over the authoritative revision history.

**Analysis**

- **Update freshness: partial.** Polling meets the 15-second goal but introduces several seconds of lag and does not provide the same headroom as push delivery.
- **Vendor independence and recurring cost: strong.** Delivery uses the project's existing HTTPS infrastructure and introduces neither a realtime vendor nor a separate usage-based service bill.
- **Operational and implementation burden: strong.** Stateless requests avoid socket-capacity management, socket-session recovery, and a separate browser reconnect protocol. Browsers still need polling, cursor persistence, and visible connectivity failures.
- **Server read amplification: weak.** Every connected browser issues repeated cursor reads, including while its board is unchanged. At 800 simultaneous browsers, five-second polling produces a baseline of 160 requests per second before accounting for retries or multiple open views.

### Self-hosted WebSockets

The delivery service maintains a WebSocket session for each connected browser and publishes committed revisions to the appropriate event subscribers. The change store retains replayable revisions and reliably publishes committed changes. Browsers retain their last received revision, reconnect after failures, and catch up through replay or a fresh snapshot when necessary.

The project owns connection capacity, socket lifecycle behavior, publication reliability, and recovery semantics. No realtime provider sits between the server and browsers.

**Analysis**

- **Update freshness: strong.** Established connections allow committed revisions to be pushed immediately without waiting for the next polling interval.
- **Vendor independence and recurring cost: strong.** The approach adds no realtime-service subscription and keeps the delivery protocol and recovery behavior under project control.
- **Operational and implementation burden: weak.** The project must size and operate socket capacity, manage sessions, publish reliably, and define reconnect and catch-up behavior across the server and browser.
- **Server read amplification: strong.** Connected browsers do not repeatedly query unchanged boards. Revision replay supports recovery without making periodic reads the normal delivery path.

### Hosted realtime service

The server publishes committed changes to a managed realtime provider, and browsers use the provider's subscription model. The delivery component wraps provider integration and reconciles publication so that a committed change is not silently omitted when server and provider operations do not commit atomically. Provider credentials and browser subscription credentials become part of the delivery design.

The provider operates browser connections and supplies its own subscription and recovery model. The project remains responsible for mapping authoritative event revisions onto that model and for recovering the latest board consistently.

**Analysis**

- **Update freshness: strong.** Managed push subscriptions provide low-latency delivery without a polling interval.
- **Vendor independence and recurring cost: weak.** Usage creates recurring fees, while provider APIs, credentials, subscription semantics, and service limits couple delivery and browser behavior to the selected vendor.
- **Operational and implementation burden: partial.** The provider removes most browser-connection capacity work, but the project must still implement provider wrapping, credential handling, publication reconciliation, and revision-consistent recovery.
- **Server read amplification: strong.** The provider handles browser fanout, and browsers do not poll the change store for unchanged boards. Publication reconciliation adds provider-facing work rather than repeated browser reads.

## Selection

MarketBoard uses self-hosted WebSockets for committed-change delivery.

This option combines strong update freshness with strong vendor independence and no recurring realtime-service bill. Those major criteria outweigh its weak fit against operational and implementation burden. Polling remains operationally simpler but accepts repeated reads and polling lag; hosted realtime reduces connection operations but conflicts with the project's preference for provider independence.

The decision turns on the HLD tenet **“Prefer operating realtime connections ourselves over recurring realtime-vendor fees and provider coupling.”** It accepts the following obligations:

- The change store must retain replayable event revisions and reliably publish committed changes.
- Delivery must manage WebSocket sessions, connection capacity, subscriber routing, and publication to connected browsers.
- Browser sync must retain the last received revision, reconnect after failures, catch up without silently missing changes, and make connectivity failures visible.
- The three components must share revision and recovery contracts so that a committed edit retains one authoritative revision throughout delivery and recovery.

The project therefore foregoes both polling's stateless delivery simplicity and a hosted provider's connection-operations offload. HTTPS remains the command path; this decision does not introduce peer-to-peer updates, browser-side merging, offline editing, or multi-region active-active operation.

---

Please review the decision doc. The three design nodes and the Access LLD’s now-stale “still-open” wording remain untouched pending your approval to cascade.