The decision doc is written at `docs/decisions/change-delivery.md`, and the Key Design Decisions entry in the HLD now points to it. Nothing is committed.

## What the doc says

- **Context:** the board replaces group chats, so how quickly a change appears matters beyond the 15-second goal. The delivery mechanism shapes the change store, delivery and browser sync together, so a wrong choice is paid for in all three.
- **Criteria:** all three options meet the goals and tenets, so there are no gates. The doc weighs five criteria:

  | Criterion | Weight | Polling | Self-hosted WebSockets | Hosted service |
  |---|---|---|---|---|
  | Update latency | major | weak | strong | strong |
  | Provider independence | major | strong | strong | weak |
  | Recurring cost | moderate | partial | strong | weak |
  | Operational burden | moderate | strong | weak | strong |
  | Build effort | minor | strong | weak | strong |

- **Selection:** self-hosted WebSockets is the only option strong on both major criteria. It is the weakest on operational burden and build effort, and the doc says that cost is accepted deliberately.
- **Downstream obligations:** it lists what the choice requires of the three nodes, and notes that the 99.5 percent availability goal now covers a connection tier the team runs itself.
- **When to revisit:** if connection operations cost more effort than the board's scale justifies, or simultaneous browsers grow well beyond 800.

## Please check

- **The weights are my reading of what you said.** You named fast updates and vendor independence as worth the extra operations work, so I made those two major and the rest lower. Change any that are off, especially recurring cost at moderate.
- **Build effort is a criterion I added.** It cuts against the chosen option and wasn't in the original sketches beyond "quickest route" for the hosted service. Say if you'd rather drop it.
- **The polling load figure is derived.** "About 160 reads per second" is 800 browsers divided by a five-second interval, not a measurement.

## Still open from last time

The doc assumes the current state on the first two of these, so your answers may change it.

1. **Sockets are delivery-only.** Do commands stay on HTTPS, with sockets carrying revisions server-to-browser only? The HLD and the doc both say so.
2. **Freshness goal.** Does 15 seconds stay as the outer bound, or do you want a tighter number?
3. **Vendor independence as a tenet.** Is it a one-off call for delivery, or a lean to record for future choices? The doc currently treats it as a one-off and says the "both permitted" tenet still applies elsewhere.
4. **Access node wording.** May I update `access-design.md`, which still calls the delivery approach open? And who authorizes a viewer's socket subscription to an event: access or delivery?

Once you approve the approach and the doc, I'll start on the three nodes, beginning with the change store unless you prefer another order.