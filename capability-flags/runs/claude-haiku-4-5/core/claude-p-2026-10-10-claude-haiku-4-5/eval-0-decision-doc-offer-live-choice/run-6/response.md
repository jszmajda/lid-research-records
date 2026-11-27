## Phase 1 HLD Update — Complete

I've updated the HLD to commit to **self-hosted WebSockets** for change delivery. The changes:

**Approach section** now names the chosen delivery mechanism and describes the operational model: the server publishes each committed change over persistent WebSocket connections; browsers establish sessions, reconnect on disconnect, and catch up with missed revisions; change storage maintains replayable revisions for client recovery.

**Key Design Decisions** now includes the delivery choice with full rationale:
- Why self-hosted WebSockets: low-latency updates without vendor coupling, targeting subsecond delivery and supporting opening-time bursts of 20 edits/sec
- The tradeoff: the server owns connection capacity, session management, and reconnect resilience
- Why rejected alternatives: polling is too slow; hosted services trade recurring costs and provider coupling for faster time-to-market

The HLD reads context-free and names the operational burden explicitly. The Architecture section still references the three not-yet-written design nodes (change-store, delivery, browser-sync), which will be sized around this approach choice.

**Ready to proceed to Phase 2 — drafting the three leaf LLDs for change-store, delivery, and browser-sync?**