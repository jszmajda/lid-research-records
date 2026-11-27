Done — the full decision doc is written and linked.

## `docs/decisions/change-delivery-transport.md` (new)

A project-level decision doc, owned by the HLD, written to be read cold by someone new:

- **Context** — why the transport is the hinge: three unwritten nodes (change-store, delivery, browser-sync) get sized around it, so it's expensive to unwind.
- **Decision Elements** — no gate (all three options meet the 15s freshness target and preserve one authoritative revision, so those are background). Five weighted criteria, with **vendor independence** as the major one.
- **Options in the Domain** — each of the three transports in its strongest honest form, with a per-criterion verdict (strong/partial/weak).
- **Selection** — the reasoning a new reader can re-run: vendor independence removes the hosted service; between the two vendor-free options, sockets beat polling on latency and read cost, and **the connection/reconnect operations burden is named as the live tradeoff accepted deliberately**, not an oversight.

The HLD's Key Design Decisions entry now links to it.

## Two things still open from the last stop

1. **The vendor-independence tenet (Q2).** The decision doc turns on vendor independence as its major criterion, but that lean isn't yet a recorded tenet — the existing *"self-hosted and managed infrastructure are both permitted"* only permits both, it doesn't favor self-hosting. Shall I add the tenet *"Realtime delivery runs on infrastructure we operate, not a third-party realtime vendor"* to the HLD? That would let the doc's Selection name a recorded tenet rather than a bare criterion. (I'd keep the "both permitted" tenet as-is for non-realtime infrastructure.)

2. **The access-design cascade (Q3).** `access-design.md:10` still calls the delivery approach "still-open" — a one-word staleness fix in a different segment. May I make it?

Once you've settled those, we'll start the three nodes as LLD drafts.