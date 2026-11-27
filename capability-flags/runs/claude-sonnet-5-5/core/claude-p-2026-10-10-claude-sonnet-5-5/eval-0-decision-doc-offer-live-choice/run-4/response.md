I've updated `docs/high-level-design.md` for self-hosted WebSockets. This is the Phase 1 stop. I haven't touched any LLD, spec, test or code.

**What changed in the HLD**
- **Approach:** the open "polling vs. sockets vs. hosted" paragraph is replaced. It now says committed revisions are pushed to subscribed browsers over self-hosted WebSockets, and that we own connection capacity for 800 browsers and the reconnect behavior.
- **Architecture:** the three unwritten nodes now state their ownership under this choice, instead of "depends on the approach":
  - **Change store:** replayable revision history and reliable publication to delivery.
  - **Delivery:** socket sessions, subscription credentials, and fan-out of published revisions.
  - **Browser sync:** socket subscription, reconnect, and catch-up from the last seen revision.
- **Key Design Decisions:** one new entry records the choice, the two rejected options, and why. It notes that all three could meet the 15-second goal, so the choice rests on latency and vendor independence.

Please review that text and send numbered feedback or approval.

**Questions for you**
1. **Decision doc:** should this choice also get a standalone decision doc (`docs/decisions/`) laying out the criteria and options for a cold reader? The three nodes are about to be sized around it, so it could stay live to re-litigate. The Key Design Decisions entry above is the lighter alternative, and it is what's recorded now. Which do you want?
2. **Tenet:** the existing tenet says self-hosted and managed infrastructure are both permitted. Do you want a one-line lean added, such as "prefer self-hosted infrastructure over provider coupling when costs are comparable"? I haven't added one, since only you can say whether that's a real preference. I also left the "neither cost nor operational burden is the overriding criterion" line out of the Approach. Your choice accepts the ops burden for the sake of vendor independence, which may be worth capturing as that tenet.
3. **Cascade into Access, which is a separate segment:** `docs/intent/access/access-design.md` still calls the delivery approach "still-open". Its Architecture section also says delivery subscription credentials "will belong to the delivery node", which is consistent with the new HLD. May I update that stale "still-open" wording? I won't touch it without your say-so.

Once you approve the HLD, the next stop is the Phase 2 LLD drafts for change-store, delivery and browser-sync. Say which node you want first, or I'll go in that order.