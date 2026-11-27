Done. The decision doc is written at `docs/decisions/change-delivery.md` and linked from the HLD's Key Design Decisions entry.

It's structured so a newcomer can re-run the judgment, not just read the outcome:

- **Context** — why the delivery path is a separate, load-bearing choice (three components are sized around it), stated from the domain with no conversation history.
- **Decision Elements** — no gate eliminates any option (all three meet the 15s floor, 800-browser scale, and 20-min recovery; the no-customer-records tenet keeps a managed provider admissible), so it turns on five weighted criteria. **Vendor independence** is the single *major* one; latency, recurring cost, operational burden, and failure visibility are *moderate*. Failure visibility is tied to the tenet that connectivity failures must stay visible.
- **Options** — one subhead each for polling, self-hosted sockets, and hosted service, each given its strongest honest form with a verdict-led analysis bullet per criterion.
- **Selection** — the reasoning chain: vendor independence removes the hosted service; latency breaks the tie between the two self-owned options in favor of sockets; operational burden is the accepted price. It states plainly that no tenet forces this — "both permitted" leaves it a deliberate lean to vendor independence over minimum burden — and lists what the choice forecloses and the obligations it pushes onto the three downstream nodes.

**This is the Phase 1 stop.** Please review the HLD edits and the decision doc. A couple of things worth your eye in particular:

1. In the doc I weighted **vendor independence as the only major criterion** and latency/cost/burden as moderate — that's my read of your "fast updates *without* tying the board to a vendor." If latency mattered to you as much as vendor independence (co-major), tell me and I'll re-balance the Selection.
2. I recorded that this choice **does not turn on a tenet** — the "both permitted" tenet explicitly leaves the hosted option on the table. If you'd rather the project actually *lean* toward self-hosting as a standing rule (so future delivery-style choices default that way), that would be a new tenet in the HLD — say so and I'll propose one.

Once you're happy with Phase 1, we'll move to the three nodes, starting with change-store (its replayable-revision contract is what delivery and browser-sync build on).