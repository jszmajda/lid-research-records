Done. The decision doc is written and linked.

**`docs/decisions/delivery-transport.md`** (project-level; owned by the HLD) — written to be read cold by someone who wasn't here:

- **Context** — why the transport is the hinge for the change store, delivery, and browser sync, and why getting it wrong is expensive; plus the board invariants every option already satisfies (framed as background, not differentiators).
- **Decision Elements** — no eliminating gate, so selection rests on six weighted criteria: vendor independence (*major*), then update latency, connection-state visibility, recurring cost, operational burden, and connectivity robustness (*moderate*). Connection-state visibility is tied to the tenet *Connectivity failures must be visible*. I surfaced one criterion that cuts **against** the chosen option — connectivity robustness across restrictive networks, where long-lived sockets fare worse than plain HTTPS — so the doc doesn't flatter the recommendation.
- **Options in the Domain** — each of the three given its strongest honest form, with a per-criterion verdict (strong/partial/weak) and a one-line trade.
- **Selection** — self-hosted WebSockets, won on vendor independence plus latency and visibility over polling, with the hosted service set aside for fees and coupling; it states plainly the two criteria it loses (operational burden, connectivity robustness) as the accepted price, names the tenet it turns on, and lists what it forecloses and obligates downstream.

I linked it from the HLD's Key Design Decisions entry.

**This is still the Phase 1 stop.** Please review the HLD edits and the decision doc. A couple of things worth your eye:
1. In the decision doc I weighted **vendor independence as *major*** — that reflects your "without tying the board to a realtime vendor." Note this sits slightly against tenet 4 (*self-hosted and managed both permitted*), which I read as keeping the choice open, not as a standing lean. The doc treats independence as a weighting for *this* decision, not a project-wide rule. Tell me if you'd actually prefer it as a tenet.
2. I added **connectivity robustness** as a criterion the discussion hadn't named — flagging it because it's the main thing that argues against sockets and will land as real pressure on browser-sync's reconnect/catch-up.

On your approval, we'll move to the three nodes (Phase 2 onward), pausing at each segment boundary.