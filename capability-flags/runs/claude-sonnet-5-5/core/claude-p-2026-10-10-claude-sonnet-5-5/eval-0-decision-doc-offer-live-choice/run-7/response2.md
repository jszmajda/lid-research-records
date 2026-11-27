I wrote the decision doc at `docs/decisions/self-hosted-websocket-delivery.md` and linked it from the HLD's Key Design Decisions entry. Nothing is committed.

**What's in it**
- **Context:** why the choice exists and which three nodes it shapes.
- **Decision Elements:** all three options meet the standing requirements, so no option is eliminated. The choice rests on five weighted criteria:
  - vendor independence (major)
  - update latency (moderate)
  - operational burden (moderate)
  - recurring cost (moderate)
  - protocol simplicity (minor)
- **Options in the Domain:** one section per option, each with a fit verdict per criterion. Self-hosted WebSockets is weak on operational burden and protocol simplicity, which is the tradeoff you accepted.
- **Selection:**
  - It wins on vendor independence, latency, and cost.
  - It lists what the choice obligates in the change store, delivery, and browsers.
  - It names when to revisit the choice.

**Please check**
1. **Criteria weights are my reading of your rationale, not something you stated.** I put vendor independence as major and the rest as moderate or minor. If you'd rank them differently, such as cost over independence, the Selection reasoning changes with them.
2. **No tenet decides this.** The existing tenet "self-hosted and managed infrastructure are both permitted" keeps all options open, so the doc says the choice rests on the project's preference. Do you want a tenet that leans this way, or is it fine as stated?
3. **The revisit triggers are my suggestion.** Costly connection operations against the 99.5 percent availability goal, or a relaxed freshness requirement. Keep, change, or drop them?

When you approve the HLD and this doc, I'll start Phase 2 with the change-store LLD.