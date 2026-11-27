I added `docs/decisions/self-hosted-websocket-delivery.md` and linked it from the HLD’s decision entry. The record lays out the context, criteria, three delivery models, trade-offs, and downstream responsibilities. `git diff --check` passes.

```markdown
---
node: high-level-design
---

# Decision: Self-Hosted WebSockets for Change Delivery

## Context

MarketBoard gives weekend-market coordinators and staff one shared board per event. Editors submit changes over HTTPS, and the server assigns each committed change an event revision. Connected staff browsers need to see those changes promptly, while disconnected browsers must be able to recover the latest board from revision history.

The pilot targets up to 800 simultaneous browsers and opening-time bursts of 20 edits per second. Under normal connectivity, committed changes must appear within 15 seconds; a browser disconnected for up to 20 minutes must recover the latest board. Low-latency updates are desirable beyond that minimum. The delivery model affects the change store, server delivery responsibilities, and browser recovery behavior.

Three models meet the freshness target: periodic HTTPS polling, self-hosted WebSockets, and a hosted realtime service. The choice trades update latency and provider dependence against implementation and operational work. Choosing push delivery does not change the requirement for one authoritative event revision or remove the need to recover from connectivity failures.

## Decision Elements

- **Low-latency updates — major.** Staff should see committed board changes promptly while connected. Faster push delivery is preferred even though the 15-second target does not require subsecond updates.
- **Avoid realtime-service fees and provider coupling — major.** Change delivery should not depend on a realtime vendor's pricing, service availability, or subscription API.
- **Time to deliver a working implementation — moderate.** A simpler route to a working delivery path is useful, while the implementation must still meet the freshness target.
- **Ongoing operational burden — moderate.** The approach should account for the work of operating and recovering delivery infrastructure. Stateless requests and offloaded connection management reduce some operational work; repeated reads and provider integration introduce other work.

The project also has shared concurrency and recovery targets. At this design level, they constrain implementation and sizing rather than eliminate one of the three delivery models.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes over HTTPS, using a revision cursor to ask for changes since their last update. Each request completes independently; the server does not maintain a connection for each browser. The browser repeats the request on a five-second loop.

- **Low-latency updates — partial.** Changes are discovered on the next poll, introducing up to a polling interval of detection delay in addition to request and processing time.
- **Avoid realtime-service fees and provider coupling — strong.** Delivery uses the existing HTTPS request/response boundary and does not rely on a realtime provider.
- **Time to deliver a working implementation — strong.** A periodic HTTPS request is the simplest delivery path, although its cadence adds update delay.
- **Ongoing operational burden — strong.** The request/response flow is stateless, though it requires cursor queries and creates repeated reads from active browsers.

**Summary:** operationally simple and provider-independent, with recurring reads and polling delay.

### Self-hosted WebSockets

The application maintains WebSocket sessions with connected browsers and publishes committed changes over those sessions. The change store retains replayable revisions so delivery can recover from publication interruptions and browsers can catch up after reconnecting. MarketBoard operates connection capacity, publication reliability, session lifecycle, and reconnect support itself.

- **Low-latency updates — strong.** The server can push a committed change to connected browsers without waiting for their next polling request.
- **Avoid realtime-service fees and provider coupling — strong.** The application owns the delivery path and does not depend on a hosted realtime service.
- **Time to deliver a working implementation — weak.** The application must build a persistent-connection delivery path and coordinate it with revision history and recovery.
- **Ongoing operational burden — weak.** The application must manage connection capacity, session lifecycle, reliable publication, and reconnect/catch-up behavior.

**Summary:** push delivery without a realtime vendor, in exchange for owning connection and recovery operations.

### Hosted realtime service

The application publishes committed changes to a third-party realtime provider, which maintains browser subscriptions and distributes updates. The application integrates with the provider's publication and subscription APIs and reconciles publication with committed event revisions.

- **Low-latency updates — strong.** The provider pushes updates to subscribed browsers without polling delay.
- **Avoid realtime-service fees and provider coupling — weak.** The design relies on provider pricing, availability, credentials, and subscription semantics.
- **Time to deliver a working implementation — strong.** The service offers a quick path to low-latency updates through its publication and subscription APIs.
- **Ongoing operational burden — strong.** The provider reduces the need to operate connection capacity and reconnect infrastructure, though the application still owns provider integration and publication reconciliation.

**Summary:** a quick path to low-latency delivery with less connection operations work, at the cost of provider dependence and recurring fees.

## Selection

Choose self-hosted WebSockets for change delivery. It provides low-latency updates to connected browsers without recurring realtime-service fees or coupling the board to a provider's subscription model. This decision prioritizes those two outcomes over the stateless simplicity of polling and the lower connection-management burden and quicker setup of a hosted service.

The choice assigns concrete work to the system: the change store must retain replayable event revisions and support reliable publication; delivery must manage WebSocket sessions and publication; browsers must reconnect and catch up from revisions. The implementation must size and operate the service for the project's browser concurrency and event-hour availability targets. The exact publication mechanism, retry behavior, and reconnect protocol remain for the change-store, delivery, and browser-sync designs.
```

Does this capture the rationale and trade-off accurately? Please send any corrections. I also left the preference to avoid realtime-vendor fees and coupling specific to this decision; should it instead be a project-wide tenet? I’ll wait for your review before starting the three design nodes.