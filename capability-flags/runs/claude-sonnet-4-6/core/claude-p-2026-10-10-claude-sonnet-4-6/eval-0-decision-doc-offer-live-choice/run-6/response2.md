`docs/decisions/websocket-delivery.md` is written and linked from the HLD.

The doc covers:

- **Context** — why the delivery choice is load-bearing: it shapes the store, delivery, and browser-sync nodes.
- **Decision Elements** — five criteria: change freshness and operational independence as major, read load, connection complexity, and recurring cost as moderate. The operational independence criterion names the tenet it turns on.
- **Options in the Domain** — all three options at full strength, each scored per criterion with a verdict and factual basis, not editorialized.
- **Selection** — self-hosted WebSockets wins on both major criteria; polling loses on freshness and read load; hosted service loses on operational independence and cost. The connection management complexity is named as the accepted cost, sized into the delivery and browser-sync nodes. Downstream obligations for all three nodes are stated explicitly.

Ready to move to the three LLD nodes whenever you are.