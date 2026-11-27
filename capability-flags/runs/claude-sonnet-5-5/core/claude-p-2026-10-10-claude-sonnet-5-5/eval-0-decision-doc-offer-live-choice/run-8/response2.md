I wrote the decision doc at `docs/decisions/change-delivery-approach.md`. The HLD's Key Design Decisions row now links to it and keeps only a one-sentence summary. Nothing is committed yet.

**What the doc says**
- **Context:** the load (800 browsers, 20 edits/s bursts), the freshness and recovery goals, and why the delivery route shapes the change store, delivery, and browser sync.
- **Elements:** all three options pass the inherited goals, so none is eliminated. The elements that separate them are:
  - Vendor independence and fees (major)
  - Update latency (moderate)
  - Operational burden (moderate)
  - Connectivity-failure visibility (moderate, from the tenet)
  - Availability exposure (moderate, from the 99.5% goal)
- **Options:** each of the three is described as its advocate would, with a fit verdict per element.
- **Selection:** self-hosted WebSockets, why it wins, the ops cost you accepted, what it obligates in each of the three nodes, and what it forecloses.

**Please check these, which are my reading of your priorities rather than things you stated**
1. **Weights:** I made vendor independence the major criterion, since you said you'd take the ops work to avoid vendor coupling. I rated latency and operational burden as moderate. If you'd rank them differently, the Selection reasoning changes.
2. **Two criteria I added:** connectivity-failure visibility and availability exposure. Both come from the HLD's own tenet and goal, and WebSockets rate only "partial" on each. Are they criteria you want recorded?
3. **Two open design questions the doc hands to the node drafts:** detecting a silently dropped socket, and what browsers see when a socket server restarts mid-event.

Nothing else is changed. Tenet 4 and the Access node's "still-open" sentence are still waiting on your answers from my previous message. Once you approve this doc, I'll start on the three nodes. Which one first?