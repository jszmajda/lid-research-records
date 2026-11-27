I've updated `docs/high-level-design.md` for self-hosted WebSockets. This is the Phase 1 stop, so nothing past the HLD has been touched.

**What changed**
- **Approach:** the open question is gone. Committed changes go to browsers over self-hosted WebSockets, and the project owns connection capacity, sessions, and reconnect behavior. The paragraph also states the roles of the other three nodes:
  - The change store keeps replayable revisions and publishes each commit reliably.
  - Delivery manages socket sessions and fan-out.
  - Browser sync reconnects, catches up from its last held revision, and makes a lost connection visible.
- **Architecture:** the "depends on the approach" notes on the three unwritten nodes now say what each owns under this choice.
- **Key Design Decisions:** one new entry records WebSockets as the chosen approach. It names polling and the hosted service as the alternatives and states the tradeoff you accepted.

**For you to rule on**
1. **Tenet.** The HLD previously said neither operating cost nor minimum operational burden was the overriding criterion. Your choice leans one way, so I did not add a tenet on my own. Candidate: *"Avoid coupling the board to a realtime vendor, even at the cost of operating our own connections."* Its opposite is a defensible choice for another project. Should I add it under Tenets, or leave the choice as a decision entry only?
2. **Decision doc.** This choice weighs several criteria (latency, cost, vendor coupling, ops burden), and three nodes are about to be sized around it. Do you want a standalone decision doc in `docs/decisions/`, or is the Key Design Decisions entry enough?
3. **Existing tenet and goals.** "Self-hosted and managed infrastructure are both permitted" still holds as written. The goals are unchanged: 15-second freshness, 800 browsers, 20-minute recovery, and seven-day retention. Please confirm they are still right for sockets. In particular, do you want a tighter latency goal now that updates are pushed?
4. **Access cascade (separate segment, so I'm asking first).** `docs/intent/access/access-design.md` still says authorization "is independent of the still-open change-delivery approach." That is stale now. It also leaves open how WebSocket connections are authorized and re-checked after a session expires or an assignment is revoked. Do you want that wording refreshed and the open question recorded, or left for the delivery node?

Once you approve or amend the HLD, the next step is Phase 2, the LLD for each of the three nodes. I'd propose the order change store, then delivery, then browser sync, and I'll stop for review after each node's LLD.