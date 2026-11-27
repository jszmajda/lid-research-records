Added `docs/decisions/realtime-change-delivery.md` and linked it from the HLD. The record explains the options, the priorities behind the selection, and the operational and design work it commits the three downstream components to. `git diff --check` passes.

> **node:** high-level-design
>
> # Decision: Realtime Change Delivery
>
> ## Context
>
> MarketBoard serves up to 800 staff browsers for each event, with 10–25 editors and opening-time bursts of 20 edits per second. Editors submit commands over HTTPS, and each committed edit receives one authoritative event revision. Connected browsers need timely updates, while a browser disconnected for up to 20 minutes must be able to recover the current board. The project targets delivery within 15 seconds under normal connectivity and availability of 99.5 percent during published event hours.
>
> The delivery mechanism determines the work required of the change store, delivery service, and browser sync: how committed revisions are read or published, how clients receive updates, and how a client resumes after losing its connection. The options considered can all meet the stated freshness target, but they differ in update latency, realtime-provider dependency, recurring service costs, and operational ownership.
>
> ## Decision Elements
>
> There is no gate among the considered options: each can meet the current 15-second freshness target and support revision-based recovery when designed to do so.
>
> ### Weighted criteria
>
> - **Major — Low latency for connected browsers.** Faster notification makes operational changes visible sooner than the 15-second maximum target requires.
> - **Major — Realtime-provider independence.** Avoid making board delivery dependent on a hosted realtime provider.
> - **Moderate — Recurring realtime-service spend.** Prefer not to add a continuing provider fee for the delivery channel.
> - **Moderate — Operational burden.** Limit the connection capacity, session lifecycle, and reconnect work the project must own.
>
> The existing infrastructure tenet permits both self-hosted and managed infrastructure; it does not prefer either. The latency and provider-independence priorities are specific to this delivery choice.
>
> ## Options in the Domain
>
> ### Five-second HTTPS polling
>
> Browsers periodically request changes over HTTPS, using a revision cursor so the server returns changes committed after the browser's last applied revision. This keeps delivery stateless and requires no long-lived client sessions, at the cost of repeated reads and polling-interval delay.
>
> - **Low latency — weak.** A five-second interval adds up to five seconds of wait before a committed change is requested, before request processing and transfer time.
> - **Realtime-provider independence — strong.** Browsers communicate directly with MarketBoard over HTTPS.
> - **Recurring realtime-service spend — strong.** The option does not require a hosted realtime service.
> - **Operational burden — strong.** Delivery remains request/response and does not own persistent browser sessions, though the service handles repeated reads.
>
> ### Self-hosted WebSockets
>
> The delivery service maintains WebSocket sessions with browsers and publishes notifications for committed event revisions. The change store must retain replayable revisions and support reliable publication; clients reconnect and catch up from their last applied revision after a disconnect.
>
> - **Low latency — strong.** The server can notify connected browsers as committed changes are published, without waiting for a polling interval.
> - **Realtime-provider independence — strong.** MarketBoard operates the delivery service and does not depend on an external realtime provider.
> - **Recurring realtime-service spend — strong.** The delivery path does not introduce a hosted realtime-provider fee.
> - **Operational burden — weak.** The project owns connection capacity, WebSocket session lifecycle, publication reliability, and reconnect/catch-up behavior.
>
> ### Hosted realtime service
>
> MarketBoard publishes committed changes to a hosted realtime provider, which maintains subscriber connections and delivers updates through its subscription model. The change store and delivery service must reconcile committed revisions with provider publication, and browsers must use provider subscriptions and recovery behavior.
>
> - **Low latency — strong.** The provider can push updates to connected browsers without a polling interval.
> - **Realtime-provider independence — weak.** Delivery depends on the selected provider's publication and subscription interfaces.
> - **Recurring realtime-service spend — weak.** The delivery channel incurs a continuing provider charge.
> - **Operational burden — strong.** The provider manages much of the connection capacity and session infrastructure, although MarketBoard still integrates publication and browser recovery with its service.
>
> ## Selection
>
> Choose **self-hosted WebSockets** for change delivery. It provides low-latency notifications while avoiding realtime-provider coupling and recurring realtime-service spend. Five-second polling has less connection-management work but adds repeated reads and several seconds of update delay. A hosted realtime service also provides low-latency delivery and lowers connection operations, but introduces the provider dependency and recurring fee this choice aims to avoid.
>
> This selection accepts the weaker operational-burden fit: MarketBoard must plan for connection capacity, operate session lifecycle and publication, and provide reconnect and catch-up behavior. It commits the change store to replayable revisions and reliable publication, delivery to WebSocket session management, and browser sync to reconnecting and applying missed revisions. The detailed mechanisms belong in those component designs. The decision preserves the HLD tenets that each committed edit has one authoritative revision and that connectivity failures remain visible rather than appearing as an unchanged board. The infrastructure-permission tenet remains neutral; this decision is specific to realtime change delivery.

Please review this record before we proceed with the three node designs. The existing Access design also still calls the delivery choice “open”; should I update that adjacent reference as part of the cascade?