I updated `docs/high-level-design.md` to adopt self-hosted WebSockets for committed-change delivery. Nothing else changed. The three design nodes (change store, delivery, browser sync) are not written yet, as you asked.

**Approach (revised)**

> Keep one authoritative board per event. Editors submit commands over HTTPS. The server assigns each committed edit an event revision and pushes committed revisions to connected browsers over self-hosted WebSockets. Browsers display a revisioned view of the board and catch up on missed revisions after reconnecting. Subsecond updates are useful but not required; the freshness target is 15 seconds.
>
> Change storage, delivery, and browser recovery are designed together around this choice: the change store keeps replayable revisions and publishes each one reliably, delivery manages socket sessions, and browsers handle reconnect and catch-up.

**Architecture bullets (revised)**

- **Change store:** holds the replayable revision history that serves catch-up and the reliable publication of each committed revision to delivery.
- **Delivery:** owns WebSocket sessions, subscriptions, and push of committed revisions to connected browsers.
- **Browser sync:** owns the socket connection, reconnect, and catch-up from the last applied revision.

**New Key Design Decisions entry**

> **Self-hosted WebSockets for committed-change delivery.** Browsers receive committed event revisions over sockets the project runs itself, so the board is not tied to a realtime vendor and has no recurring realtime fee. The project owns connection capacity and reconnect handling in exchange. Rejected: five-second HTTPS polling, which is the simplest stateless option but repeats reads and adds a few seconds of lag on every browser; and a hosted realtime service, which offers the quickest low-latency route but adds recurring fees and couples delivery to one provider's subscription model.

The tenets and goals are unchanged. The 20-minute recovery goal now means the change store has to replay up to 20 minutes of revisions to a reconnecting browser.

**Decision record**

This choice is live enough to re-litigate later, so it could be recorded as a standalone decision doc at `docs/decisions/self-hosted-websockets.md` with the options and criteria laid out. The Key Design Decisions entry above is the alternative. Do you want the decision doc, or is the entry enough?

**Review**

Please review the HLD changes and send any numbered feedback. Once you approve, I'll move on to the three nodes.