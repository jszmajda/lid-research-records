Decision doc written at `docs/decisions/change-delivery-approach.md`, and the Key Design Decisions entry in the HLD now points to it rather than carrying a compressed version of the argument.

The doc gives a cold reader the machinery to re-run the judgment:

- **Context** — why the route is a free choice at all (commands arrive over HTTPS either way), and why it is load-bearing: it sizes three of the four design nodes, so reversing it later means rebuilding them rather than swapping a transport.
- **Decision Elements** — three major criteria (recurring external cost, control of the delivery path, connection and reconnect operations owned) and three moderate ones (latency beyond the 15-second floor, failure visibility in the browser, browser-side recovery complexity). No gates: all three options clear every goal and tenet, so I said that explicitly instead of inventing eliminating constraints.
- **Options** — each described as its advocate would describe it, with a fit verdict per criterion. Polling is the honest winner on operations and recovery; the hosted service is the honest winner on connection ops and failure visibility.
- **Selection** — self-hosted WebSockets, stated as what it is: a deliberate trade of a major criterion (operations) for a moderate one (latency), justified by the domain rather than by the weights. It also records what committing forecloses — a stateless delivery tier — and the three downstream obligations.

Two things in the doc you should rule on, because they are yours and I wrote them in as assumptions:

1. **The reason latency beats operations.** I wrote that the 15-second goal is a floor for acceptability rather than a description of how the board should feel — coordinators reacting to closures during an opening-time burst stop trusting a board that is always five seconds stale. That is my reading of why you accepted the ops work. If your actual reason is different, that paragraph is the one to correct, since everything else in Selection leans on it.

2. **The strain on a tenet.** I recorded that this choice puts *connectivity failures must be visible* under more strain than the alternatives would — an idle socket and a quiet board look identical — so satisfying that tenet becomes project work rather than a property of the transport. Worth confirming you want it named that plainly, since it is the one place the doc says the chosen option is weaker on something the project committed to.

Still open from the last stop:

- **Latency goal** — leave the commitment at 15 seconds, or record something tighter? (Related to #1 above: the doc currently argues the floor understates the intent, which is a slightly awkward position for the HLD to hold if the goal stays as-is.)
- **Tenet candidate** — *"When a browser's catch-up is expensive, prefer complete replay over a fast resume."* Add, replace, or drop?
- **Access cascade** — `access-design.md` still says authorization is "independent of the still-open change-delivery approach." Reword those two lines now, or leave Access until we reach it?