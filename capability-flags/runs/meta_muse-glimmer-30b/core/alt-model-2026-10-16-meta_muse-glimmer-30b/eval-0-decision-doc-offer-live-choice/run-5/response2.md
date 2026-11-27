Updated the HLD to make the tradeoff explicit for a cold reader.

## Approach
Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Delivery of committed changes uses self-hosted WebSockets.

Self-hosted WebSockets were selected over five-second HTTPS polling and a hosted realtime service. Polling would meet the 15-second freshness goal with the simplest stateless operation, but introduces repeated reads and a few seconds of lag, and requires browsers to run a polling loop and the store to support cursor queries. A hosted realtime service would provide the lowest latency with less connection operations work, but introduces recurring fees and provider coupling.

Self-hosted WebSockets give fast, push-based updates without a vendor bill. The tradeoff is accepting extra work on connection capacity, reconnect handling, and reliable publication. The store must provide replayable revisions; delivery must manage sessions and guarantee publication; browsers must implement reconnect and catch-up logic. The team accepts this operational work to avoid recurring realtime fees and to keep the board independent of an external provider.

The change is in `docs/high-level-design.md`. Phase 1 HLD is now readable cold and records why the self-hosted WebSockets tradeoff was accepted.

Approve this revision and proceed to Phase 2 LLD drafting for change-store, delivery, and browser-sync?