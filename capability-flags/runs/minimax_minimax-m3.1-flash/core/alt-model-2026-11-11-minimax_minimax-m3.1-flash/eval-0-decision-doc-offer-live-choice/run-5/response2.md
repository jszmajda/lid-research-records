Wrote `docs/decisions/change-delivery-mechanism.md` (project-level decision, owned by the HLD) and linked it from the HLD's Key Design Decisions entry.

**Structure** — Context (why the choice exists, the reader/burst profile, the 2-second freshness target, the 20-minute disconnect recovery, the fixed command path, and the three components that will be sized around the answer); Decision Elements (two gates, six weighted criteria); Options in the Domain (one `###` per option with description, demonstration, per-element analysis, and summary); Selection.

**Gates** — freshness (a change must reach a connected browser within the target; polling's five-second cycle fails it in the worst case, so it is eliminated rather than scored down), and one authoritative revision (all three pass).

**Criteria** — independence from a managed realtime provider (major, derived from the *Operate rather than rent* tenet), operational burden (major), update latency (major), serving load and capacity risk (moderate), browser implementation complexity (moderate), read-path amplification (minor).

**Selection** — polling is out on the gate; between the two push mechanisms, independence decides and the hosted service is rejected on it. The doc names the obligations it creates for the change store, delivery, and browser-sync nodes, and closes with the two conditions that would reopen the decision: relaxing freshness to ten seconds or more, or the socket tier failing the availability target at the required connection population — the latter being exactly the exception built into the tenet.

One thing to settle: the freshness target and the tenet wording were still open from my previous message, and the decision doc leans on both. It states the target as **2 seconds** (my earlier pick) and the gate elimination of polling follows from it — if the target is 10 seconds or more, polling passes the gate and the decision would flip on operational burden. Please confirm the target number and the tenet wording, and I'll adjust the doc and HLD to match.

Ready to move on to the three nodes (change-store, delivery, browser-sync) once that's settled.