Created `docs/decisions/self-hosted-websocket-delivery.md` and linked it from the HLD’s Key Design Decisions section.

# Decision: Self-hosted WebSocket delivery

## Context

MarketBoard browsers need committed stall-status changes delivered within 15 seconds under normal connectivity, with faster updates useful but not required. The service must support 800 simultaneous browsers and recover the latest board after disconnections lasting up to 20 minutes. Editors will continue to submit commands over HTTPS, and every committed edit will retain one authoritative event revision.

The delivery mechanism determines how the change store, delivery service, and browser synchronization work together. It also determines whether MarketBoard primarily pays in repeated reads, self-managed persistent connections, or realtime provider fees and coupling. All three candidate mechanisms can meet the 15-second freshness goal, so that goal is background rather than a gate that eliminates an option.

## Decision Elements

- **Responsive updates — major.** Prefer prompt delivery of committed changes, while recognizing that subsecond delivery is not a requirement.
- **Avoidance of realtime vendor fees and coupling — major.** Prefer a delivery path without a recurring realtime service bill or dependency on a provider's subscription model and availability.
- **Operational and infrastructure burden — moderate.** Prefer less ongoing work to manage capacity, availability, reconnections, and avoidable read load.
- **Implementation and recovery complexity — moderate.** Prefer a simple interaction among revision storage, publication, and browser catch-up, with fewer failure modes to design and operate.

## Options in the Domain

### Five-second HTTPS polling

Browsers request changes over HTTPS every five seconds. Delivery remains request/response and does not maintain persistent sessions. The change store provides cursor-based queries, and each browser advances its cursor as responses arrive.

#### Analysis

- **Responsive updates — partial.** Changes normally wait for the next polling request, introducing several seconds of lag while remaining within the 15-second goal.
- **Avoidance of realtime vendor fees and coupling — strong.** Polling uses MarketBoard's own HTTPS service and introduces neither a realtime vendor bill nor provider coupling.
- **Operational and infrastructure burden — partial.** Stateless requests avoid persistent-connection capacity and reconnect operations, but browsers repeatedly read for changes, including when nothing has changed.
- **Implementation and recovery complexity — strong.** Cursor queries and a browser polling loop are comparatively simple; recovery uses the same request path as normal updates.

### Self-hosted WebSockets

MarketBoard operates its own WebSocket endpoint and pushes committed changes to connected browsers. The change store retains replayable revisions and reliably publishes commits. Delivery manages socket sessions and capacity, while browsers reconnect and catch up from event revisions after interruption.

#### Analysis

- **Responsive updates — strong.** Connected browsers receive published changes promptly without waiting for a polling interval.
- **Avoidance of realtime vendor fees and coupling — strong.** MarketBoard uses its own infrastructure and protocol implementation, with no recurring realtime vendor bill or provider-specific browser subscription model. MarketBoard still bears its own infrastructure costs.
- **Operational and infrastructure burden — weak.** The team owns persistent-connection capacity, availability, and reconnect behavior for up to 800 simultaneous browsers.
- **Implementation and recovery complexity — weak.** Reliable publication, replayable revisions, session management, reconnect handling, and browser catch-up must work together so browsers can recover the authoritative update sequence after interruptions.

### Hosted realtime service

A hosted provider accepts published changes and delivers them through its subscription service. MarketBoard wraps provider integration in its delivery component, reconciles publication with the authoritative change store, and uses the provider's browser subscription model.

#### Analysis

- **Responsive updates — strong.** The provider's realtime subscriptions can deliver changes promptly without a polling interval.
- **Avoidance of realtime vendor fees and coupling — weak.** The service adds recurring fees and ties publication, browser subscriptions, credentials, and part of delivery availability to an external provider.
- **Operational and infrastructure burden — strong.** The provider handles persistent-connection capacity and much of the connection operations work, although MarketBoard still operates publication reconciliation and provider integration.
- **Implementation and recovery complexity — partial.** MarketBoard avoids building socket-session management but must reconcile authoritative commits with provider publication and adapt browser recovery to provider behavior.

## Selection

Use self-hosted WebSockets for committed-change delivery. This option is strong on both major criteria: it provides fast updates and avoids recurring realtime vendor fees and provider coupling. Its weaker operational and implementation simplicity is an accepted tradeoff, not an overlooked cost. Polling remains operationally simpler but sacrifices responsiveness and adds repeated reads; hosted realtime reduces connection operations but loses the desired vendor independence.

The tenet that self-hosted and managed infrastructure are both permitted allows either operational model; this decision chooses self-hosting because vendor independence and prompt updates outweigh the convenience of managed realtime delivery for MarketBoard.

HTTPS remains the editor command boundary, and the 15-second freshness goal does not become a subsecond guarantee. Five-second polling is not selected as the normal delivery route, and a hosted realtime provider is not selected as the primary delivery dependency.

The choice creates three downstream obligations:

- **Change store:** retain replayable event revisions and reliably publish committed changes.
- **Delivery:** own WebSocket sessions, connection capacity, and publication to connected browsers.
- **Browser sync:** manage subscriptions, reconnect after interruptions, and catch up from event revisions.

Please review the decision document and updated HLD. Once you approve them, I’ll proceed to the three node designs.