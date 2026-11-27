I wrote the decision doc at `docs/decisions/change-delivery-approach.md` and linked it from the Key Design Decisions entry in `docs/high-level-design.md`. I read your "write that up properly" as a yes to the decision doc. Nothing is committed.

**What the doc says**
- **Context:** why delivery shapes the change store, delivery, and browser sync nodes. It states that all three options meet the 15-second goal, so the decision is about what the project takes on in exchange for fast updates.
- **Decision elements:**
  - **Gates:** the inherited freshness, scale, and 20-minute recovery requirements. All three options pass.
  - **Criteria:** vendor independence and failure visibility are marked major. Update latency, connection operations, and recurring cost are moderate. Stateless simplicity is minor.
- **Options:** polling, self-hosted WebSockets, and the hosted service. Each is described as its advocate would, with a fit verdict per criterion.
- **Selection:** self-hosted WebSockets. The doc states what it forecloses and what it obligates downstream:
  - The change store keeps replayable revisions and publishes reliably.
  - Delivery owns sessions, credentials, and capacity.
  - Browser sync handles reconnect, catch-up, and silent stale connections.
  - Subscriptions are authorized server-side.

**Please check these**
1. **Criteria weights.** The major/moderate/minor weights are my reading of what you told me. You stated vendor independence directly. Failure visibility as major comes from the existing "connectivity failures must be visible" tenet. Recurring cost is marked moderate because the HLD says cost was never declared overriding. Tell me if any weight is wrong, since the Selection rests on them.
2. **No new tenet.** I did not add the vendor-avoidance tenet, because you didn't answer that question. The doc cites only the existing tenets. If you want it as a tenet, the doc's vendor-independence criterion should name it.
3. **Assumed numbers.** The doc has no cost figures or connection-capacity numbers, because none exist yet. The "at least the 20-minute recovery window" replay obligation comes from the recovery goal. The seven-day retention goal sits separately in the HLD.
4. **Access cascade.** This is still open from my last message. The stale "independent of the still-open approach" wording in `access-design.md`, and how socket connections are authorized and re-checked on revocation, are in another segment. Should I refresh that wording, or leave it for the delivery node?

Once you approve, I'll move to Phase 2 with the change store LLD first.