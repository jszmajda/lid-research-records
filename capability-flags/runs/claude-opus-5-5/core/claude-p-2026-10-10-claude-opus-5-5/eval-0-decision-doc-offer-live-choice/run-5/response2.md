The decision doc is written at `docs/decisions/change-delivery-transport.md`, and the HLD's Key Design Decisions entry now links to it. I also added a `docs/decisions/` row to the navigation table in `CLAUDE.md`. Nothing is committed to git.

## What the doc says

- **Context:** what the decision covers, why three nodes are sized around it, and what holds under every option and so doesn't help choose. All three meet the 15-second goal, all must recover after a 20-minute disconnect, and nothing rules out a third party.
- **Criteria**, each with a weight:

  | Criterion | Weight | Polling | Self-hosted sockets | Hosted service |
  |---|---|---|---|---|
  | Update latency | major | weak | strong | strong |
  | Vendor independence | major | strong | strong | weak |
  | Operational burden | moderate | strong | weak | strong |
  | Build complexity across the three nodes | moderate | strong | weak | partial |
  | Read load on the change store | minor | weak | strong | strong |

- **Options:** each one described as its advocate would, with the basis for every verdict above.
- **Selection:** self-hosted WebSockets is the only option strong on both major criteria. The doc states plainly that it is weak on the two moderate ones and that this is the trade accepted. It then lists what the choice obligates in each of the three nodes, what it forecloses, and when to re-run the judgment.

## Please check these — they are my reading, not something you said

1. **The weights.** I marked latency and vendor independence as major, and ops burden and build complexity as moderate, from your "accept the ops work to get fast updates without a vendor". If ops burden is really major and you are accepting it anyway, the doc should say that instead.
2. **Why latency matters.** I wrote that a board lagging by seconds invites coordinators to keep using the group chats. That is my rationale; replace it if yours is different.
3. **The re-run conditions.** I listed three: the socket tier threatening the 99.5 percent availability goal, growth well beyond the pilot or a multi-region goal, and latency turning out not to matter. I also named polling as the nearest fallback, since replaying revisions after a given revision is the same query a polling browser would make.
4. **No tenet decides this.** The doc says the weight on vendor independence is specific to this decision, because the existing tenet permits both self-hosted and managed. If you'd rather it be a standing lean, say so and I'll add a tenet and cite it.

## Still open from last time

- **Access design:** `docs/intent/access/access-design.md` still calls the delivery approach "still-open". May I fix that wording? The larger question — who authorizes opening a socket, and what happens to an open socket when a session expires or an assignment is revoked — I'd raise when we draft delivery.
- **HLD approval:** I took your reply as a yes to the decision doc, not yet to the HLD text itself. Once you approve both, I'll start the change store node, then delivery, then browser sync, pausing at each.