I've updated the HLD to the self-hosted WebSockets approach. The changes, per Phase 1 (stop for review below):

**Approach** — now states push delivery over self-hosted WebSockets as the chosen route, and names what each of the three unbuilt nodes must design for: the change store keeps replayable revisions, delivery owns socket sessions and reliable publication, browser sync owns reconnect and catch-up from the last seen revision.

**Tenets** — added a lean: *self-hosted infrastructure over realtime vendors* (the load-bearing tie-breaker behind the choice).

**Key Design Decisions** — added the delivery decision with both rejected alternatives (polling's lag-and-reads cost, hosted service's fees and coupling) and why the trade landed on owning connection management; plus a replayable-revision-history decision that follows from it. Context-free read: a cold reader can reconstruct the tradeoff without our conversation.

Three questions before I proceed to the three nodes:

1. **Decision doc?** This choice is likely to stay live — three credible options, multiple criteria, and the three downstream nodes will be sized around it. Want it recorded as a full decision doc at `docs/decisions/` (HLD row linking to it), or is the existing Key Design Decisions row enough?
2. **Freshness goal** — the goal still says "within 15 seconds," but you chose WebSockets for fast updates. Should the goal tighten (e.g., subsecond or ~1s for connected browsers), or stay at 15s as the guaranteed floor?
3. **Stale line in access-design.md:10** — "the still-open change-delivery approach" is now residue. May I fix that line (small cross-segment cleanup)?

Once you've reviewed the updated HLD (`docs/high-level-design.md`) and answered, I'll walk the three nodes — change store, delivery, browser sync — one LLD stop at a time.