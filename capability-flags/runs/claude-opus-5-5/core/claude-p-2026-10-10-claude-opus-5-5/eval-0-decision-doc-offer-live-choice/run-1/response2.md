I wrote the decision up as `docs/decisions/change-delivery.md` and linked it from the HLD's Key Design Decisions entry. Nothing is committed, and the three nodes are still untouched.

## What the doc says

- **Context:** the decision covers how a committed revision reaches every browser, at the load and goals the HLD states. It shapes the change store, delivery and browser sync at once.
- **No option is ruled out:** all three meet the 15-second, 20-minute-recovery and 800-browser goals, and the tenets permit managed infrastructure.
- **Criteria and how each option fits:**

| Criterion | Weight | Polling | Self-hosted WebSockets | Hosted service |
|---|---|---|---|---|
| Update latency | major | weak | strong | strong |
| Provider independence | major | strong | strong | weak |
| Failure visibility | major | strong | partial | partial |
| Build and operations burden | moderate | strong | weak | partial |
| Recurring cost | minor | partial | strong | weak |

- **Selection:** self-hosted WebSockets is the only option strong on both latency and provider independence. It pays in build and operations burden, which is weighted lower.
- **What it commits us to:** replayable history and reliable publication in the change store, session and capacity management in delivery, and dead-connection detection plus catch-up in the browser.
- **When to revisit:** if a few seconds of lag turns out to be fine, polling wins; if the connection work proves unsustainable and a provider dependency becomes acceptable, the hosted service wins.

## Please check

1. **The weights are my reading of your one sentence.** You said you'd accept the operations work for fast updates without a vendor tie, so I made latency and provider independence major, burden moderate and recurring cost minor. Correct any that are wrong, especially cost: your reply dropped the "vendor bill" wording from the original sketch.
2. **I added failure visibility as a criterion you didn't name.** It comes from the tenet that connectivity failures must be visible, and it cuts against the choice: a failed poll is an explicit error, while a half-open socket can look like an unchanged board. The doc records this as a tension and as an obligation on browser sync. Say so if you'd rather it not be in there.

## Still open from before

3. **Freshness goal:** does "within 15 seconds" tighten now, and to what figure, or stay as the floor?
4. **Vendor independence as a tenet:** the doc says this weight is specific to this decision because no tenet covers it. Do you want a general tenet, or should it stay local?
5. **Access node:** `docs/intent/access/access-design.md` still calls the delivery approach "still-open". May I fix that wording, and is delivery the right owner for authorizing socket connections?

Once you approve the HLD and the decision doc, or send changes, I'll start on the change store, delivery and browser-sync nodes.