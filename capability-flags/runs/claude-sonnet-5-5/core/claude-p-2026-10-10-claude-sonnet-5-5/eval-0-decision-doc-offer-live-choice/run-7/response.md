I updated `docs/high-level-design.md` for the self-hosted WebSockets choice and stopped there. Nothing is committed, and the access node and the three unwritten nodes are untouched.

**What changed in the HLD**
- **Approach:** the "still open" paragraph is replaced with the chosen design.
  - Committed changes reach browsers over self-hosted WebSockets, with no realtime vendor, and arrive well inside the 15-second target.
  - We own connection capacity, reconnects, and catch-up.
  - The change store keeps replayable revisions and publishes each committed one reliably.
  - Delivery manages socket sessions and subscription credentials.
  - Browsers detect disconnects, reconnect, and catch up from their last seen revision.
- **Architecture:** the change-store, delivery, and browser-sync entries no longer say "depends on the approach". Each now states what it owns under WebSockets.
- **Key Design Decisions:** a new entry records the choice, accepts the connection and reconnect operations burden, and names polling and the hosted service as rejected.
- **Tenets, goals, and non-goals:** unchanged. "Self-hosted and managed infrastructure are both permitted" still holds.
- **Access node:** nothing needed there. It already puts delivery-specific subscription credentials outside its scope.

**Questions for you**
1. **Decision doc:** this choice looks live enough that a cold reader could want to re-litigate it. It trades several criteria (vendor cost and coupling, operations burden, latency), and three nodes are about to be sized around it. Do you want a full decision doc at `docs/decisions/self-hosted-websocket-delivery.md`, or is the Key Design Decisions entry enough? I'll only write the doc if you say yes.
2. **Edits:** any numbered feedback on the HLD wording above?
3. **Next:** once you approve the HLD, I'll start Phase 2 (LLD) on the three nodes. Should I begin with change-store, then delivery, then browser-sync? Each will stop for your review, and I'll flag anything that crosses between them.