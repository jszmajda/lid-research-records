HLD updated for the self-hosted WebSockets route — Phase 1 stop. Here's what changed and what I need from you.

**Approach** (rewritten, no longer open): committed changes reach browsers over WebSocket connections we host; the server publishes each new event revision to sessions subscribed to that event; a browser that fell behind catches up by replaying from the last revision it holds. The paragraph that weighed polling vs. sockets vs. hosted, and the line saying no criterion had been declared overriding, are gone — they were pre-decision framing.

**Architecture** — the three unwritten nodes now carry concrete responsibilities instead of "depends on the approach":
- Change store: revision history, replay by revision number, reliable publication of committed revisions to delivery.
- Delivery: socket session lifecycle, per-event subscriptions, fan-out of published revisions.
- Browser sync: subscribing, disconnect detection, reconnect, catch-up replay from the last held revision.

**Key Design Decisions** — new entry *"Self-hosted WebSockets deliver committed changes,"* naming both rejected options and why: polling is cheapest to operate but spends repeated reads and carries seconds of lag; a hosted service removes most connection ops but costs recurring fees and couples delivery to one provider's subscription model. Self-hosting accepts connection-capacity and reconnect operations as the price of low-latency updates with no vendor in the path.

Goals, Non-Goals, and Tenets are unchanged.

Four things for you:

1. **Record this as a full decision doc?** It clears the bar for one — three credible options traded against latency, recurring cost, operational burden, and vendor coupling, and all three nodes are about to be sized around the result, so a cold reader feeling the ops load later could be tempted to reverse it. A doc at `docs/decisions/change-delivery-approach.md`, linked from Key Design Decisions, would let them re-run the judgment. The alternative is the Key Design Decisions entry above, which is already written and may be enough. Your call.

2. **Latency goal.** I left the goal at "within 15 seconds." You chose this route for fast updates, so the capability will far exceed the stated target — but tightening a goal is a requirements change, not a consequence of the architecture. Leave 15 seconds as the commitment, or record something tighter?

3. **A tenet candidate.** Self-hosting creates a class of choices no spec will anticipate: what gives when connection capacity or catch-up cost is strained. One lean worth stating — *"When a browser's catch-up is expensive, prefer complete replay over a fast resume"* — its opposite (drop the gap, resend the whole board, get them live sooner) is a choice another project could reasonably make, so it's a real tenet rather than a platitude. Want it added, something else, or nothing?

4. **One cascade into Access.** `access-design.md` says authorization is "independent of the still-open change-delivery approach" and that subscription credentials "will belong to the delivery node." The substance is still right; the wording assumes the choice is open. That's a different segment, so I'm asking before touching it: want me to reword those two lines as part of this change, or leave Access until we reach it?

Once you've ruled on these, we'll move to the three nodes.