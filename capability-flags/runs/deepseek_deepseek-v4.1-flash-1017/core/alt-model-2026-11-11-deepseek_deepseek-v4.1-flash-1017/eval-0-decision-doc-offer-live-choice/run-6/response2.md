# Decision: Change delivery route

## Context

MarketBoard keeps one authoritative board per event. Editors submit commands over HTTPS and the server assigns each committed edit one event revision; browsers display a revisioned view. The open question is how a committed revision reaches the staff browsers viewing that board — up to 800 simultaneous browsers per event, with opening-time bursts of 20 edits per second, and a goal of showing changes within 15 seconds under normal connectivity.

The route determines the shape of three neighboring nodes. The change store must expose whatever read path delivery needs. Delivery owns the transport and its failure handling. Browser sync must know how to subscribe and recover. A route that meets the freshness goal but imposes a vendor dependency or heavy read load is weighed differently from one that trades operational work for independence.

Two constraints apply to every route. Each committed edit has one authoritative revision (commands are server-side authorized, and the revision is assigned once at commit). Both self-hosted and managed infrastructure are permitted. Subsecond updates are useful but not required; connectivity failures must be visible rather than mistaken for an unchanged board.

## Decision Elements

All three options deliver each committed revision to connected browsers within the 15-second goal, so freshness alone eliminates none. Both infrastructure types are permitted, so no option is excluded on that ground either. The decision is therefore among weighted criteria.

- **Update latency** — major. How soon a committed change appears to a connected browser without a refresh.
- **Connectivity-failure visibility** — major. Whether a failed delivery path is distinguishable from an idle board, supporting the tenet that connectivity failures must be visible.
- **Vendor coupling and recurring cost** — major. Whether operation depends on a third-party realtime service, its pricing, and its credentials.
- **Operational burden** — moderate. Connection capacity, publication reliability, reconnect handling, and the on-call surface the project must own.
- **Change-store read load** — moderate. How many repeated reads delivery forces on the store when nothing has changed.
- **Browser complexity** — minor. Subscription, reconnect, and catch-up logic carried in the client.

## Options in the Domain

### Five-second HTTPS polling

Browsers request board state or revisions after a cursor every five seconds over HTTPS. The server answers from the change store; delivery stays request/response with no persistent connection. Any load-balanced web server can answer. The client can surface a failed request, and the store can serve incremental reads with cursor queries.

- **Update latency**: partial — up to five seconds plus request time. Meets the 15-second goal but leaves seconds of lag and cannot approach subsecond.
- **Connectivity-failure visibility**: partial — a failed request can be surfaced, but a slow or delayed poll is hard to distinguish from an unchanged board; fidelity depends on client instrumentation.
- **Vendor coupling and recurring cost**: strong — ordinary HTTPS infrastructure, no realtime vendor.
- **Operational burden**: strong — no sessions to hold, no connection capacity to plan, no server-side reconnect logic. Repeated reads are the cost.
- **Change-store read load**: weak — every browser repeats reads each interval; 800 browsers at five seconds is roughly 160 requests per second even when nothing has changed.
- **Browser complexity**: strong — a timer and a fetch, with cursor handling only.

Summary: cheapest to operate and simplest, at the price of lag and repeated reads.

### Self-hosted WebSockets

Each browser opens one persistent socket to the delivery tier for the event it displays. On commit, the server publishes the new revision to the open sessions for that event. Delivery tracks sessions per event and owns capacity for up to 800 concurrent connections plus opening-time bursts. A browser that drops reconnects and catches up from the last revision it saw.

A browser-visible board carries `event_id` and `last_seen_revision`; on (re)connect it presents the latter and receives revisions after it.

- **Update latency**: strong — publication at commit makes updates near-instant.
- **Connectivity-failure visibility**: strong — socket state is explicit; a dropped connection is detectable and can be shown to the user.
- **Vendor coupling and recurring cost**: strong — no realtime vendor and no per-connection fee; runs on project infrastructure at infrastructure cost only.
- **Operational burden**: weak — the project owns connection capacity, publication reliability, reconnect storms, and a stateful tier, adding on-call surface.
- **Change-store read load**: strong — a browser reads once at connect or catch-up, then receives pushes; no repeated polling.
- **Browser complexity**: partial — must manage reconnect and catch-up from a revision cursor.

Summary: fastest updates without vendor dependence, paid for in connection and reconnect operations.

### Hosted realtime service

A managed realtime provider holds subscriptions and fan-out. Delivery publishes committed revisions to the provider, and browsers connect through the provider's client SDK and subscription model. Delivery reconciles published revisions with the store.

- **Update latency**: strong — provider fan-out is near-instant.
- **Connectivity-failure visibility**: strong — the provider exposes connection state and reconnect events.
- **Vendor coupling and recurring cost**: weak — recurring fees, provider-specific protocol and credentials, and migration cost if the provider is replaced.
- **Operational burden**: partial — less connection operations than self-hosting, but publication reconciliation, credentials, and provider integration remain, and capacity is bounded by the provider's tiers.
- **Change-store read load**: strong — pushes rather than repeated reads.
- **Browser complexity**: partial — the provider's subscription model, with reconnect largely handled by its SDK.

Summary: quickest low-latency path with the least connection operations, at recurring cost and provider coupling.

## Selection

Self-hosted WebSockets wins on the two major criteria that separate the options. On update latency it delivers near-instant publication against polling's seconds of lag. On vendor coupling and recurring cost it matches polling's independence and beats the hosted service's fees and provider-specific operations. Polling loses because the project values prompt updates and because repeated reads scale badly; the hosted service loses because recurring cost and provider coupling were the tradeoff the project chose not to make.

The decision is consistent with the tenet that both self-hosted and managed infrastructure are permitted: the choice is weighed rather than excluded. It supports the tenet that connectivity failures must be visible, because an explicit socket state distinguishes a dropped link from an unchanged board better than an interval poll whose silence can read as either. The one-revision invariant applies to every option and does not discriminate. No current tenet states a general preference between self-operated and vendor-provided delivery; the preference applied here — accepting operational work to avoid recurring fees and provider coupling — is weighed as project judgment, not as a tenet.

The accepted cost is operational burden: connection capacity for 800 browsers and reconnect/catch-up are work the project takes on rather than a reason to rent a provider. Committing obliges three downstream nodes. The change store must retain replayable revisions and a read path for catch-up. Delivery must own socket session lifecycle and reliable publication of committed revisions. Browser sync must reconnect and catch up from the last revision the browser saw. It forecloses a hosted provider for the pilot and commits the project to operating a stateful delivery tier within the 99.5 percent availability goal.

---

Written to `docs/decisions/change-delivery.md`, with the HLD's Key Design Decisions entry linking to it.

Still open:

1. **Approval.** Does the HLD revision plus this doc read right? If so, I'll start with change-store and stop at each of the three segments.
2. **Tenet.** The doc now notes no tenet covers the self-operated-vs-vendor lean. Want me to add the candidate tenet after all?
3. **Cascade.** `docs/intent/access/access-design.md:10` still says "the still-open change-delivery approach" — update now, or with the delivery node?