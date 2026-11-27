I wrote the decision doc at `docs/decisions/change-delivery-transport.md` and linked it from the Key Design Decisions entry in the HLD. Nothing is committed.

## What the doc says

- **Context:** all three options meet the stated goals (15-second freshness, 800 browsers, 20-minute recovery, one authoritative revision), so the choice turns on what the project values beyond them.
- **Criteria and fit:**

| Criterion | Weight | Polling | Self-hosted WebSockets | Hosted service |
|---|---|---|---|---|
| Update latency | major | weak | strong | strong |
| Independence from a realtime provider | major | strong | strong | weak |
| Recurring cost | moderate | strong | strong | weak |
| Operational burden | moderate | strong | weak | partial |
| Visibility of connectivity failure | moderate | strong | partial | partial |
| Load when nothing changes | minor | weak | strong | strong |

- **Selection:** self-hosted WebSockets is the only option strong on both major criteria. Its one weak fit, operational burden, is accepted deliberately.
- **Obligations:** the doc lists what the choice requires of the change store, delivery and browser sync, matching the HLD.
- **When to reopen:** if connection operations threaten the 99.5 percent availability target, if scale grows well past 800 browsers or one region, or if fast updates stop mattering. In that case it names polling as the first option to revisit.

## Please check

- **The weights are my reading of what you said.** You named fast updates and vendor independence as the reasons, so I made those major and everything else moderate or minor. If recurring cost or operational burden should rank differently, say so.
- **I added one criterion you didn't name.** "Visibility of connectivity failure" comes from the existing tenet, and it cuts against the chosen option: a silently dead socket looks like a quiet board, where a failed poll is explicit. The doc treats that as an obligation on delivery and browser sync, not a reason to change the choice.
- **The 160 requests per second figure for polling** is 800 browsers divided by the five-second interval.

## Still open from before

1. **Freshness goal.** Should "within 15 seconds" tighten now that sockets are chosen for speed, or stay as the floor? The decision doc currently describes it as the floor.
2. **Vendor tenet.** Is avoiding vendor coupling a project-wide lean to record as a tenet, or specific to realtime delivery? The doc currently treats it as a weighed criterion, with the "both permitted" tenet unchanged.
3. **Access node wording.** May I update the stale "still-open change-delivery approach" wording in `access-design.md`, and does authorizing a socket subscription stay with Delivery?

Once you approve the HLD and the decision doc, I'll start on the change store design.