Done. Here's what I've updated:

**HLD Approach section** — now describes self-hosted WebSockets as the chosen approach and names the implications for change-store, delivery, and browser-sync.

**Decision doc** at `docs/decisions/realtime-delivery-approach.md` — records the three options (HTTPS polling, self-hosted WebSockets, hosted realtime service), the criteria that drove selection (update latency as major, operational complexity/vendor coupling/infrastructure cost as moderate), fit analysis for each option, and why self-hosted WebSockets was selected despite accepting the operational complexity trade.

**HLD Key Design Decisions** — added an entry linking to the decision doc.

The decision doc frames it from the landed state: a cold reader can see the three credible options, understand what criteria drove the choice, and re-run the judgment if circumstances change (e.g., if the team later decides vendor coupling is acceptable to reduce operational burden).

Does this capture the rationale correctly? Once approved, we'll move to the three nodes (change-store, delivery, browser-sync).