I've updated `docs/high-level-design.md` for self-hosted WebSockets. Please review it, since this is the Phase 1 stop and nothing beyond the HLD has been touched.

**What changed**
- **Approach:** committed changes now reach browsers over self-hosted WebSockets, chosen for fast updates without a realtime vendor. I removed the "still open" and "neither cost nor ops burden is overriding" language.
- **Consequences:**
  - The change store keeps replayable revisions and publishes committed revisions reliably.
  - Delivery manages socket sessions and connection capacity.
  - Browser sync handles reconnect and catch-up, and shows connectivity loss rather than a stale board.
- **Architecture entries:** the three unwritten nodes (change store, delivery, browser sync) each now state what they own under the WebSockets approach.
- **Key Design Decisions:** I added a row recording the choice, the two rejected options with why, and the accepted ops cost.

**For your numbered feedback**
1. **Decision doc or row?** This choice will likely stay live: it trades cost, latency, and ops burden, and three nodes are about to be sized around it. I can write a standalone decision doc at `docs/decisions/` with your criteria and the three options, linked from that HLD row. Or the row alone is enough. Which do you prefer?
2. **Tenet 4:** it still reads "Self-hosted and managed infrastructure are both permitted." That doesn't contradict the choice, but you may want it reworded now that the board's delivery is self-hosted. I left it unchanged. Should I?
3. **Access node:** `docs/intent/access/access-design.md` still says authorization is independent of the "still-open change-delivery approach." That's a different segment, so I haven't edited it. Do you want me to update that sentence, or leave it for the delivery node pass?

When you approve, I'll start on the three nodes (change store, delivery, browser sync). Tell me which to draft first.