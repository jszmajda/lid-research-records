Here's the updated HLD. I've recorded your selection of self-hosted WebSockets in both the Approach and Key Design Decisions sections:

**Approach (updated):**
Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered via self-hosted WebSockets, enabling fast updates without vendor coupling or recurring realtime service fees.

Self-hosted WebSockets require the project to own connection capacity and reconnect logic. Change storage must support replayable revisions so clients can catch up after disconnection. Delivery owns session management and publication reliability. Browsers implement reconnection and revision catch-up.

**Key Design Decision (added):**
Self-hosted WebSockets for change delivery. Selected over HTTPS polling (introduces 5+ second lag) and hosted realtime services (vendor coupling and recurring fees). The project accepts the operational burden of connection management and reconnect logic to gain fast, vendor-independent updates. Change storage will support replayable revisions for client catch-up; delivery will own session management; browsers will implement reconnection and revision recovery.

Does this capture the direction, or would you like any adjustments before we move into the three node designs?