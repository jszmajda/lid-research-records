I've updated the HLD (`docs/high-level-design.md`) for self-hosted WebSockets. Nothing else is touched yet, and this is the Phase 1 stop.

**What changed**
- **Approach:** the open choice is replaced by the decision. Committed changes reach browsers over self-hosted WebSockets, with no realtime vendor or provider coupling. The approach text also states that we own connection-capacity and reconnect operations as the cost of that.
- **Architecture bullets** now describe what each unwritten node owns under this approach:
  - Change store: ordered, replayable event revisions, plus reliable publication of each committed revision.
  - Delivery: socket sessions, subscription credentials, connection capacity, and fan-out.
  - Browser sync: connection, reconnect, catch-up from its last known revision, and visible connectivity state.
- **Key Design Decisions:** a new entry records the choice, why polling and the hosted service were rejected, and the trade-off we accepted.
- **Unchanged:** Goals, Non-Goals and Tenets. The 15-second freshness goal, the 20-minute recovery goal, and the "connectivity failures must be visible" tenet all still fit.

**For your review**
1. **Tenet:** the old text said neither cost nor operational burden was the overriding criterion. You've now leaned toward avoiding vendor coupling over minimizing operations. Should that become a one-line tenet, for example "Prefer infrastructure we operate over provider-coupled services when latency is comparable"? Its opposite is defensible, so it would pass the tenet test. I haven't added it, since it's your call.
2. **Decision doc:** the transport choice may stay live for a cold reader, and three nodes are about to be sized around it. I can write it up as a full decision doc in `docs/decisions/`, or leave the Key Design Decisions entry as the only record. Which do you want?
3. **Cascade into Access, which needs your OK:** `docs/intent/access/access-design.md` says authorization is independent of the "still-open change-delivery approach". That is now stale, and it sits in a different segment, so I haven't touched it. It also leaves open who authorizes a WebSocket subscription, which is currently assigned to the Delivery node. May I update Access's wording, or should that wait until Delivery is drafted?

Reply with numbered feedback or approval. Once you approve, the next phase is the LLD for the first of the three nodes.