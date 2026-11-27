## Phase 1 Stop: HLD Review

I've updated the HLD to record your selection of self-hosted WebSockets. Here's what changed:

**Updated Approach section:** Now specifies WebSockets delivery and names the trade-off (operating cost and vendor independence vs. connection management burden), along with how the three components will handle this.

**Updated Architecture section:** Changed from conditional language ("depending on the approach") to concrete responsibilities:
- Change store: maintains replayable revisions and publication outbox
- Delivery: manages WebSocket sessions, reliable publication, connection tracking  
- Browser sync: handles subscription, reconnection, catch-up recovery

**Added Key Design Decision:** Recorded the WebSockets choice with its criteria and trade-off rationale, so a cold reader can understand why this architecture was chosen.

The HLD now reads as fresh and doesn't rely on knowing there was a decision in progress.

**Question for the stop:** Would you like me to create a full decision doc for this choice (capturing the rationale behind why WebSockets was selected over polling or hosted services), or is the Key Design Decision entry sufficient? Since this shapes the architecture of three major components, a decision doc might be useful for future reference, but a row works too.