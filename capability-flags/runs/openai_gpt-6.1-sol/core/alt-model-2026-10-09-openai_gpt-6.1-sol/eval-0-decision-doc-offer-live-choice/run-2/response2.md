Created `docs/decisions/change-delivery.md` and linked it from the HLD. `git diff --check` passed.

Here is the decision document for review:

# Decision: Self-hosted WebSockets for Board Changes

## Context

MarketBoard gives weekend market staff a shared view of stall closures, late arrivals, and power problems. Editors submit commands over HTTPS to one authoritative board per event. The server assigns each committed edit an event revision; change delivery carries those revisions to browsers rather than becoming a second source of truth.

The pilot serves up to 800 simultaneous browsers, with opening-time bursts of 20 edits per second. Connected browsers must show committed changes within 15 seconds under normal connectivity. Browsers must recover the latest board after disconnections of up to 20 minutes; the system retains seven days of event revisions and targets 99.5 percent availability during published event hours. All three delivery approaches can meet the freshness target. Subsecond updates are desirable, not a separate guarantee.

The choice spans change storage, delivery, and browser sync, so the high-level design owns it. It determines whether the project operates long-lived connections, depends on a realtime provider, or accepts polling lag and repeated reads. Self-hosted and managed infrastructure are both permitted; vendor independence is a preference for realtime delivery, not a prohibition on managed infrastructure generally.

## Decision Elements

- **Fast board updates — major.** Prefer prompt delivery of committed changes over a scheduled polling delay. This follows the tenet favoring fast board updates over minimizing connection and reconnect operations work.
- **Realtime vendor independence — major.** Prefer control of the delivery service and browser protocol over coupling to a provider's subscription model. This follows the same tenet's preference for realtime vendor independence.
- **Recurring realtime service fees — moderate.** Prefer avoiding a separate realtime provider bill. This is distinct from minimizing total cost: self-hosted compute and engineering time still cost money, and no cost estimate establishes which option is cheapest overall.
- **Implementation and operational burden — moderate.** Prefer less connection-capacity, publication, and reconnect work when the higher-priority criteria are comparable. This weighs against self-hosted WebSockets; taking on that work can affect delivery effort and event-hour reliability.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes after their last applied event revision. The change store supports cursor queries, delivery remains request/response, and browsers run a polling loop with recovery after failed requests. Stateless requests avoid operating a fleet of persistent connections. Successful polls can meet the freshness target, but even healthy browsers wait for the next poll and repeatedly query when nothing has changed.

- **Fast board updates: partial fit.** A five-second schedule introduces up to roughly five seconds of scheduling delay before request and processing time.
- **Realtime vendor independence: strong fit.** The project controls the HTTPS interface without a realtime provider.
- **Recurring realtime service fees: strong fit.** There is no separate realtime service bill, though repeated requests and reads consume infrastructure resources.
- **Implementation and operational burden: strong fit.** Request/response delivery avoids persistent-session capacity and reconnect management; polling and cursor recovery still need implementation.

### Self-hosted WebSockets

Browsers maintain connections to a project-operated delivery service. The service sends committed event revisions as they become available. Change storage provides replayable revisions and reliable publication; delivery manages sessions and live and replayed changes; browsers reconnect and catch up from their applied revision. This permits prompt delivery while keeping the service and protocol under project control.

- **Fast board updates: strong fit.** Connected browsers receive changes without waiting for a scheduled poll.
- **Realtime vendor independence: strong fit.** The project operates delivery and controls its protocol without adopting a realtime provider's subscription model.
- **Recurring realtime service fees: strong fit.** There is no separate realtime provider bill; hosting and operations costs remain.
- **Implementation and operational burden: weak fit.** The project owns connection capacity, session lifecycle, reliable publication, and reconnect and catch-up behavior, including recovery during service interruptions.

### Hosted realtime service

A realtime provider operates browser subscriptions and persistent connections. Change storage reconciles committed revisions with publication, delivery wraps the provider, and browsers use its subscription and recovery model. The provider reduces connection-management work and offers a quick path to low-latency delivery, while the project remains responsible for authoritative storage and publication correctness.

- **Fast board updates: strong fit.** Provider subscriptions deliver updates without a scheduled polling interval.
- **Realtime vendor independence: weak fit.** Delivery and browser integration depend on the provider's APIs and subscription model.
- **Recurring realtime service fees: weak fit.** Provider service charges add a recurring expense, with the amount dependent on the chosen provider and usage.
- **Implementation and operational burden: strong fit.** The provider operates connection capacity; the project still implements publication reconciliation and browser recovery integration.

## Selection

Use self-hosted WebSockets for delivery of committed board changes. The major criteria favor prompt updates and realtime vendor independence over the moderate preference for lower implementation and operational burden. This applies the HLD tenet: prefer realtime vendor independence and fast board updates over minimizing connection and reconnect operations work.

Polling meets the required freshness target and offers simpler operations, but sacrifices the preferred promptness of updates. Hosted realtime offers prompt updates with less connection work, but introduces provider coupling and recurring service fees. Self-hosted WebSockets combine the two major preferences at the explicit cost of owning connection and reconnect operations. The selection does not establish lower total cost or guaranteed subsecond delivery.

The downstream design obligations are:

- **Change store:** retain replayable event revisions and provide reliable publication of committed changes. The specific persistence and publication mechanism belongs in its design node.
- **Delivery:** operate WebSocket sessions, size connection capacity for 800 simultaneous browsers, and deliver live and replayed revisions while accounting for opening-time bursts and the event-hour availability target.
- **Browser sync:** track the applied revision, make connectivity failures visible, and reconnect and catch up after disconnections of up to 20 minutes.

HTTPS remains the command path, with server-side authorization and one authoritative revision per committed edit. Polling and hosted realtime are not the primary delivery architecture. The three pending design nodes resolve the concrete replay, publication, session, and recovery contracts around this selection.

---

**Does this capture the reasoning and priorities you want a new maintainer to understand?**