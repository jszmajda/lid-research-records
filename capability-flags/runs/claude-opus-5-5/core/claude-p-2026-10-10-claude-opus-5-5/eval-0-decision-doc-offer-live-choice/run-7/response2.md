The decision is written up at `docs/decisions/change-delivery.md`, and the Key Design Decisions entry in the high-level design now gives a one-line reason and points to it. Nothing is committed.

## What the doc says

- **Context:** why the choice has to be made once at project level, and what is the same under every option (including that all three meet the 15-second goal).
- **Criteria:**

  | Criterion | Weight |
  |---|---|
  | Update speed beyond the 15-second goal | major |
  | Independence from a realtime vendor | major |
  | Operations work MarketBoard owns | moderate |
  | Risk to the 99.5% availability goal | moderate |
  | Repeated work when boards are idle | minor |

- **Options:** each of the three is described as its advocate would and rated against every criterion.
- **Selection:** self-hosted WebSockets is the only option strong on both major criteria. The doc states the price plainly: the weakest fit on operations work, and a stateful socket tier whose restarts browsers will see. It also names the fallbacks if the weighting changes: polling keeps independence, a hosted service keeps speed.

## Please check

1. **The weights are my reading of what you said.** You named fast updates and vendor independence as worth the operations work, so I made those major and operations moderate. If operations work is really a major concern you are choosing to pay anyway, the doc should say that instead.
2. **I added the availability criterion.** It didn't come up when we compared options, but it cuts against sockets: restarting a socket server drops every connection on it during event hours. Keep it, or cut it if you think it overstates the risk.
3. **No tenet decides this, and the doc says so.** The tenets permit self-hosted and managed alike. If preferring to own operations over depending on a vendor is a standing lean for this project, it could become a tenet; if it was a one-off call for delivery, leave it.

## Still open from before

4. **Does the freshness goal stay at 15 seconds**, or do you want a tighter number in Goals now that sockets are chosen? The delivery node will be sized against it.
5. **May I fix the stale line in `docs/intent/access/access-design.md`** that still calls the delivery approach "still-open"? It is a one-sentence reword with no spec changes.

Once you approve the approach and the doc, I'll start the three nodes, change store first unless you prefer another order.