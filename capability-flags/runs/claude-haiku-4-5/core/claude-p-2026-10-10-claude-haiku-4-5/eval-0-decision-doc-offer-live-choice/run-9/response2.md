## Phase 1 Complete: HLD Updated with Decision Doc

I've created a comprehensive decision doc at `docs/decisions/realtime-delivery.md` that explains the reasoning for someone new to the project. It analyzes all three options fairly against these decision elements:

**Criteria (major impact):**
- Update latency (polling lags 0–5 seconds; both WebSockets and hosted services deliver subsecond)
- Operational cost structure (polling and WebSockets are one-time; hosted services recur with vendor lock-in)

**Criteria (moderate impact):**
- Implementation complexity (polling is simplest; WebSockets moderate; hosted is simplest)
- Connection operations burden (polling and hosted offload; WebSockets puts burden on MarketBoard)

**The analysis:**
- **Polling:** Simplest but laggy during peak activity
- **Hosted services:** Fast and operationally simple but ongoing fees and lock-in
- **WebSockets:** Balances fast updates with vendor independence by accepting the connection-management burden

The decision doc also specifies what choosing WebSockets obligates downstream: the change store must support replayable revisions, delivery must manage reconnects reliably, browsers must implement reconnect logic, and operations must monitor connection health.

The HLD now links to this doc from its Key Design Decisions section, so future readers can understand not just what was chosen but why the other options were ruled out.

**Ready to proceed to the three component LLDs (change-store, delivery, browser-sync)?**