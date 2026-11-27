I wrote the decision doc at `docs/decisions/change-delivery-transport.md`. It is owned by the HLD, carries no spec IDs, and is linked from the Key Design Decisions entry in `docs/high-level-design.md`.

**What it contains**
- **Context:** the load numbers and the freshness goal. It states that all three options meet every goal, so this is a trade between latency, operations, cost, and coupling rather than a feasibility question. It also says switching later means redesigning the store, delivery, and browser sync.
- **Decision elements:** no gate eliminates any option. I left the inherited constraints out as background, because every option passes them.
  - Vendor independence: major.
  - Update latency: moderate.
  - Connection and reconnect operations: moderate.
  - Recurring cost: moderate.
  - Design simplicity: moderate.
- **Options:** each of the three has its strongest honest description and a strong/partial/weak verdict per criterion.
- **Selection:**
  - **Reasoning:** self-hosted WebSockets is the only option that is strong on both vendor independence and latency. It is weakest on connection operations and simplicity.
  - **Judgment call:** the doc says plainly that the goals and tenets don't force this choice, and that it rests on your preference for fast updates without realtime-vendor coupling.
  - **Obligations:** it lists what the change store, delivery, and browser sync each inherit.
  - **Fallback:** it names polling as the fallback if connection operations cost more than expected.

**Please check**
1. **Weights:** I set vendor independence as major and the rest as moderate, based on your stated reason. You haven't ranked cost or latency. Does that match your thinking? In particular, I wrote that latency is useful but not required, so independence carries the decision more than speed does.
2. **Fallback line:** I added that polling is the natural fallback because the revision cursor serves both. That is my claim, not yours. Keep it, or cut it?
3. **Still open from before:** the tenet lean ("prefer self-hosted over provider coupling"), and permission to fix the stale "still-open" wording in `access-design.md`. The decision doc now records the vendor-coupling lean as a criterion, so a tenet may be redundant. Do you want one anyway?

Once you approve the HLD and this doc, I'll move to Phase 2 and draft the LLDs. Which node do you want first?