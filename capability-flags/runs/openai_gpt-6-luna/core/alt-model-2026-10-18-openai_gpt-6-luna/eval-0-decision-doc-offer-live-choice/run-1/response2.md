I wrote the decision record at `docs/decisions/self-hosted-websocket-delivery.md` and linked it from `docs/high-level-design.md`. It captures the alternatives, tradeoffs, selected criteria, downstream obligations, and conditions that would justify reconsidering the choice. `git diff --check` passed, and the HLD link points to the new file.

```markdown
---
node: high-level-design
---

# Decision: Self-Hosted WebSockets for Change Delivery

## Context

MarketBoard keeps one authoritative board per event. Editors submit commands over HTTPS, and the server assigns each committed edit an event revision. Up to 800 staff browsers may be connected at once, with opening-time bursts of 20 edits per second. The project aims to show committed changes within 15 seconds under normal connectivity, recover the latest board after a browser has been disconnected for up to 20 minutes, and remain available for 99.5 percent of published event hours. All three delivery approaches can meet the freshness goal; faster updates are useful, but no subsecond service level is required.

Change delivery must provide timely updates while preserving the authoritative revision history. Three approaches are viable: periodic HTTPS polling, self-hosted WebSockets, and a hosted realtime service. They place different burdens on read traffic, connection operations, and vendor dependence.

## Decision Elements

### Weighted criteria

- **Low delivery lag — major.** Coordinators should see board changes promptly. Although each approach can meet the 15-second freshness goal, avoiding unnecessary delay is valuable.
- **Avoid realtime-provider fees and coupling — major.** Delivery should not depend on a third-party realtime vendor or its pricing and provider-specific subscription model.
- **Operational simplicity — moderate.** The delivery mechanism should be supportable by the project team; additional connection and recovery operations are a real cost, but an acceptable one for this decision.

The 800-browser concurrency target, 20-edit-per-second burst target, 20-minute recovery window, and availability goal remain constraints for the downstream designs. Each approach must be validated against them.

## Options in the Domain

### Five-second HTTPS polling

Browsers periodically request changes over HTTPS, using a revision cursor so the server can return updates since the browser's last known revision. Requests and responses are stateless, and no long-lived browser sessions need to be operated.

- **Low delivery lag — weak.** A committed change may wait for the next five-second request before appearing in a connected browser.
- **Avoid realtime-provider fees and coupling — strong.** Delivery uses the existing HTTPS request path and does not require a realtime vendor.
- **Operational simplicity — strong.** The server handles ordinary requests rather than maintaining and recovering persistent browser connections.
- **Summary:** Simple connection operations in exchange for repeated reads and polling-interval lag.

### Self-hosted WebSockets

The server publishes committed revisions over WebSocket connections maintained with browsers. The application operates the connection service and defines how clients reconnect and catch up from their last applied revision.

- **Low delivery lag — strong.** The server can push a committed change to connected browsers without waiting for their next polling interval.
- **Avoid realtime-provider fees and coupling — strong.** The application owns realtime delivery rather than relying on a hosted realtime provider.
- **Operational simplicity — weak.** The team must provide connection capacity, manage connection lifecycle and reliable publication, and support reconnect and catch-up behavior.
- **Summary:** Fast, vendor-independent delivery with more connection and recovery operations owned by the project.

### Hosted realtime service

The application publishes committed revisions to a realtime provider, and browsers subscribe using that provider's client model. The provider operates much of the persistent connection infrastructure.

- **Low delivery lag — strong.** A provider can push updates to connected browsers without polling delay.
- **Avoid realtime-provider fees and coupling — weak.** The approach introduces recurring service fees and a dependency on the provider's API and subscription model.
- **Operational simplicity — strong.** The provider takes on much of the connection-capacity and session-management work, while the application still needs to reconcile publication with committed revisions.
- **Summary:** Lower connection-management burden in exchange for recurring fees and provider dependence.

## Selection

Use self-hosted WebSockets to deliver committed changes to connected browsers. This option reduces update lag while avoiding recurring realtime-service fees and provider coupling. It is preferred over five-second polling, which introduces repeated reads and avoidable delay, and over a hosted realtime service, which reduces connection operations but adds vendor dependence and recurring fees.

The choice accepts the operational burden of connection capacity, reliable publication, and browser reconnect and catch-up behavior. It is specific to MarketBoard's change-delivery approach; it does not prohibit managed infrastructure elsewhere in the system.

The downstream designs must preserve replayable authoritative revisions, provide reliable publication from the change store to delivery, manage WebSocket sessions, and let browsers recover missed changes after reconnecting. They must also size and verify the service against the project's concurrency, edit-burst, freshness, and recovery goals.

Reconsider this choice if operating the connection service threatens the project's availability or capacity goals, or if the balance of provider cost and operational burden changes materially.
```

Please review the decision record and let me know if its criteria or rationale need correction. Before the downstream cascade continues, I also still need your ruling on whether avoiding realtime-vendor coupling should be a broader tenet, and whether to clean up the stale “still-open” wording in the existing Access design.