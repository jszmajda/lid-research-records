Written up as `docs/decisions/change-delivery-approach.md`, owned by the HLD (`node: high-level-design`) and linked from the Key Design Decisions entry. Structure and the substance of each section:

**Context** — why the decision exists from the domain alone: commands are request/response but change notification is server-initiated and long-lived, so the route isn't implied by the command path. Names the load (40 markets, 800 browsers, 20 edits/sec bursts) and what's at stake: change store, delivery, and browser sync are all shaped by this, so a wrong call rebuilds three components rather than swapping a transport.

**Decision Elements** — no gates, stated explicitly and why: every stated goal is reachable by all three routes, the tenets permit both self-hosted and managed infrastructure, and board traffic is stall IDs and statuses rather than customer records, so nothing eliminates an option. The decision turns entirely on weighted criteria:

- Freedom from a realtime vendor — *major*
- Operations burden the project absorbs — *major*
- Update latency above the required floor — *moderate* (grades headroom over the 15-second requirement, not the floor)
- Fidelity of disconnection signalling — *moderate*, turning on the tenet *connectivity failures must be visible, not mistaken for an unchanged board*
- Deploy and restart behavior — *moderate*
- Read cost at idle — *minor*

Two of those weren't in last session's sketch and both cut against the recommendation: deploy/restart behavior (holding per-connection state makes every deployment a mass disconnection, and the reconnect surge is the system's peak load) and the fidelity criterion that actually favors sockets. I kept them separate because they move the decision in opposite directions.

**Options in the Domain** — each of the three in its own subsection with description, per-criterion fit verdicts, and a one-line trade. Each is written as its advocate would describe it; polling in particular gets its real strength spelled out, including the one your sketch didn't name — with polling, catch-up and steady state are the *same* constantly-exercised path, where with sockets catch-up is a separate mechanism that mostly runs during incidents.

**Selection** — self-hosted WebSockets. The two major criteria pull against each other and vendor freedom wins: hosted delivery is the strongest option on operations and ties on latency, but it's the only one that puts a third party, a per-connection bill, and a provider-defined subscription model inside two of the four design nodes — a structural price for a board carrying stall statuses. Polling keeps the same independence far more cheaply but is weak on the criterion that motivated the question. The accepted costs are stated plainly rather than softened, including the restart surge and the loss of polling's self-exercising catch-up path. It closes with what the commitment obligates in each of the three nodes and what it forecloses (stateless serving processes).

Still open from the last stop, and worth settling at the root before we size the nodes:

**The capacity tenet.** Owning connection capacity creates a class of choices no spec will anticipate — what the server does when it's at its limit. The two defensible leans are *protect the browsers already connected, refusing new connections* versus *admit everyone and let every connection degrade*. Which way should MarketBoard lean, or would you rather leave it off the tenet list and have the delivery node settle it concretely?

If you also have a lean on the restart-surge side of the same question — whether reconnect behavior should favor getting every browser back quickly or spreading the surge out to protect the server — say so and I'll record it; otherwise it goes to delivery as a design question. Once the tenets are settled, I'll move to Phase 2 and ask which of the three nodes to draft first.