Here's the updated HLD reflecting the self-hosted WebSockets decision:

---

## **Updated Approach Section**

Keep one authoritative board per event. Editors submit commands over HTTPS; browsers display a revisioned view of the board. Committed changes are delivered over self-hosted WebSockets for fast updates without the operational overhead of managing a realtime service vendor relationship.

The server maintains persistent WebSocket connections to browsers. Each committed edit becomes one event revision and is published to all connected clients. Browsers initiate reconnection after disconnects, and the server maintains replayable revision history so clients can catch up to current state.

This approach trades connection management and reconnect recovery complexity for fast, vendor-independent delivery. Subsecond updates are possible but not required; the system targets 15-second freshness.

---

The HLD now names the specific delivery mechanism (self-hosted WebSockets) and describes the key operational constraints it introduces:
- **Server side**: persistent connection management and revision replay
- **Browser side**: reconnect and catch-up logic

This choice clarifies what the three downstream design nodes (Change Store, Delivery, Browser Sync) need to own, and the Tenets still hold—the authoritative revision boundary remains at the server.

**Ready to proceed with Phase 2 (LLD check/draft) for the three nodes: Change Store, Delivery, and Browser Sync?**