## Phase 1: HLD Check — Updated with Self-Hosted WebSockets Choice

I've updated the HLD to record your selection of self-hosted WebSockets for delivery. Here's what changed:

**Approach section** now states that committed changes are delivered over self-hosted WebSockets, and specifies the three structural requirements this choice imposes:
- The change store must provide replayable revisions for browser recovery
- Delivery manages WebSocket sessions and republishes queued revisions on reconnect
- Browsers implement reconnect detection and catch-up logic

**Architecture section** is now concrete about each component's responsibilities under this choice:
- **Change store**: replayable revisions indexed by event, ordered by revision number, with durability for republish
- **Delivery**: WebSocket session lifecycle, revision routing to connected clients, queuing and replay for disconnected clients
- **Browser sync**: connection management, reconnect detection, catch-up on reconnect, ordered revision application

**Key Design Decisions** now includes the self-hosted WebSockets choice with explicit rationale (avoiding vendor lock-in and recurring costs) and the tradeoff it accepts (increased connection management complexity).

The HLD is now ready to guide the three component LLDs you mentioned. 

**Does this align with your intent, or should I adjust the approach descriptions?**