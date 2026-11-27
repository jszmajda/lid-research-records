The decision doc is written at `docs/decisions/change-delivery.md` and linked from the Key Design Decisions entry in the HLD. Nothing is committed, and the three nodes are still untouched.

## What the doc says

- **Context:** the route shapes the change store, delivery and browser recovery together, so reversing it later means reworking all three. All three routes meet the stated goals, so the goals don't decide it.
- **Criteria and weights:**

  | Criterion | Weight | Polling | Self-hosted WebSockets | Hosted service |
  |---|---|---|---|---|
  | Update latency | major | weak | strong | strong |
  | Provider independence and recurring cost | major | strong | strong | weak |
  | Operational burden | moderate | strong | weak | strong |
  | Visibility of connectivity failure | moderate | strong | partial | partial |
  | Design work across the three components | minor | strong | weak | partial |

- **Selection:** self-hosted WebSockets is the only option strong on both major criteria. What it gives up is operational burden and design work.
- **When to reopen it:** the hosted service becomes stronger if the connection operations work proves too heavy during event hours, or if provider dependence comes to matter less. Polling becomes stronger if fast updates don't change how coordinators work.
- **What it obligates:** replayable revisions and reliable publication in the change store, dead-connection detection in delivery, visible connection loss and catch-up in browser sync, and capacity planning for 800 connections reconnecting at once.

## Two things to check in the doc

- **The weights are my reading of your reasoning.** You said fast updates and vendor independence were worth the operations work, so I marked those two major and operational burden moderate. The whole selection rests on that ordering, so correct it if it's off.
- **I added a criterion we hadn't discussed.** "Visibility of connectivity failure" comes from the existing tenet, and it cuts against the choice: an idle socket and a dead one look the same until something detects the difference, whereas a failed poll is its own signal. It doesn't change the outcome, but it puts an explicit obligation on delivery and browser sync.

## Still open from last time

1. **Is "own it rather than rent it" a tenet?** The doc says plainly that no tenet backs the weight on provider independence. If you want that lean recorded as a tenet, I'll add it to the HLD and cite it in the doc; otherwise it stays a one-off judgment.
2. **Does the freshness goal stay at 15 seconds?** The doc and HLD both treat 15 seconds as a ceiling that still holds, including after a reconnect.
3. **May I update the Access node?** Its design still calls the delivery approach "still-open". The underlying question is whether Access or Delivery authorizes a socket connection; tell me which, or I'll raise it again when we draft Delivery.

Once you approve the HLD and the decision doc, I'll start on the change store node.