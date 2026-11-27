The decision doc is written at `docs/decisions/change-delivery.md` and linked from the WebSockets entry in the HLD's Key Design Decisions. Nothing is committed to git.

## What the doc says

- **Context**: why the delivery route matters — it shapes the change store, delivery and browser sync at once, so reversing it means redesigning all three. It also lists what holds under every option (the 15-second goal, one authoritative revision, 20-minute recovery, no sensitive data), so those don't separate the options.
- **Criteria**: five, with the weights below.
- **Options**: polling, self-hosted WebSockets and hosted realtime, each described as its advocate would and rated against every criterion.
- **Selection**: WebSockets is the only option strong on both major criteria. It is the weakest on operational burden, and the doc says plainly that this cost is accepted, and that polling would have won had minimum operational burden been the overriding concern.
- **Obligations**: what the choice requires of each of the three nodes, and that polling is the cheaper retreat if the socket tier ever threatens availability.

| Criterion | Weight | Polling | Self-hosted WebSockets | Hosted realtime |
|---|---|---|---|---|
| Update latency | major | partial | strong | strong |
| Independence from a realtime provider | major | strong | strong | weak |
| Operational and build burden | moderate | strong | weak | partial |
| Visibility of connectivity failures | moderate | strong | partial | partial |
| Load proportional to change | minor | weak | strong | strong |

## Please check

- **The weights are my reading of your reasoning.** You named fast updates and vendor independence as what you were buying and operations work as what you'd pay, so I made the first two major and operational burden moderate. Correct any that are off.
- **I added two criteria you didn't name.** One is visibility of connectivity failures, taken from your tenet; sockets are weaker than polling here because a connection can die silently and look like a quiet board. The other is load proportional to change. The first turns into a browser-sync obligation: heartbeats and revision-gap detection.
- **The doc says no tenet backs the vendor-independence weight.** The fourth tenet permits managed infrastructure, so the doc presents independence as a judgment about the delivery path specifically. If you add the vendor tenet (question 3 below), I'll cite it instead.
- **Two claims rest on my own estimates.** "Typically well under a second" for socket push and "about 160 requests a second" for polling (800 browsers every five seconds) are not measured.

## Still open from last time

2. **Freshness goal**: tighten it, or keep 15 seconds with speed as a bonus? The doc currently assumes 15 seconds stays.
3. **Vendor tenet**: add a lean toward self-operated infrastructure on the path that carries board updates, or leave the tenet as is?
4. **Access design**: may I update its two stale lines ("still-open" delivery approach; subscription credentials "will belong to the delivery node")?

Once you've answered these and approved the approach, I'll start on the change store, delivery and browser sync nodes.