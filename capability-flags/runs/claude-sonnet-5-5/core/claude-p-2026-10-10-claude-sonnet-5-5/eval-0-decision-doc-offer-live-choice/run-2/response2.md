I wrote the decision doc at `docs/decisions/change-delivery-approach.md` and linked it from the Key Design Decisions entry in `docs/high-level-design.md`.

**What the doc covers**
- **Context:** why the choice shapes the change store, delivery, and browser sync together, and why reversing it later would be expensive.
- **Gates:** the inherited 15-second freshness, 800-browser and burst load, and 20-minute recovery requirements. All three options pass these, so the choice turns on the criteria.
- **Criteria:**
  - Major: provider independence, visible connectivity failure (tenet), and revision integrity (tenet).
  - Moderate: update latency, recurring cost, and operational burden.
- **Options:** each of the three is described in its strongest honest form, with a fit verdict per element.
- **Selection:**
  - Self-hosted sockets are the only option strong on both latency and provider independence.
  - Polling is weakest on latency and spends constant read load.
  - The hosted service is weakest on independence and adds fees.
  - The accepted cost is the operational burden.
  - The downstream obligations on each of the three nodes are listed.

**Please check**
1. **Criteria weights:** I set provider independence as major and operational burden as moderate, based on your statement that you'd accept the ops work to avoid vendor coupling. If you'd weigh them differently, the Selection reasoning changes with them.
2. **Gap I added:** the doc says socket silence (a half-open connection) must be detectable so it isn't mistaken for an unchanged board. I derived this from your tenet on visible connectivity failures, not from anything you said directly.
3. **Edit not applied:** I haven't added the tenet leaning toward infrastructure we operate. The doc notes the lean in Selection but the tenets list is unchanged. Say if you want it recorded there.

When this reads right, tell me and I'll start on the three nodes, beginning with the change store LLD.