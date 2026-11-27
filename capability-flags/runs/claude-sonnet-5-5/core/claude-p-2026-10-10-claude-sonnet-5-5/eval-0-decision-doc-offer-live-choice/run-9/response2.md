I wrote the decision doc at `docs/decisions/change-delivery-approach.md` and linked it from the HLD's Key Design Decisions entry.

**What the doc says**
- **Context:** every option meets the HLD goals, so the choice turns on what the project pays for. It also sets the shape of the change store, delivery and browser sync, which makes it expensive to reverse later.
- **Criteria:**
  - Vendor cost and provider coupling: major.
  - Update latency: moderate.
  - Connection and reconnect operations burden: moderate.
  - Statelessness and moving parts: minor.
- **Options:** each of the three gets a plain description of what it is and a strong/partial/weak fit against each criterion.
- **Selection:** self-hosted WebSockets is the only option strong on both vendor independence and latency. The doc states the accepted costs (connection operations and per-session state), what it forecloses, and what it obligates the three nodes to do. It also notes that the hosted service stays a viable fallback if connection operations prove heavy.

**Please check**
1. **Criterion weights.** I set vendor cost and coupling as "major" because you named it as the reason for the choice. Operations burden is "moderate". If you'd weigh these differently, tell me, since the Selection logic follows from them.
2. **Fallback paragraph.** The "hosted service remains a viable replacement" sentence is my addition, not something you said. Keep it or cut it?
3. **Pending from before.** The stale "still-open" sentence in `docs/intent/access/access-design.md` is still unfixed, and I'm waiting on your OK because it is in another segment.

If the HLD and this doc look right, I'll start the LLD for the first node. I'd suggest change-store, since delivery and browser sync both consume its revision and publication contract.