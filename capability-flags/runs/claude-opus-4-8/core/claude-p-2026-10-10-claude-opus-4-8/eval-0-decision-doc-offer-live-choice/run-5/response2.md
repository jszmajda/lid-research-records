Done. The decision doc is written and linked from the HLD.

**`docs/decisions/websocket-delivery.md`** (owned by the HLD, no EARS IDs), structured so a cold reader can re-run the judgment:

- **Context** — what delivery has to do, the load (800 browsers, 20 edits/s bursts, 15s freshness, 20-min recovery), and why a reversal later is expensive.
- **Decision Elements** — freshness and the one-authoritative-revision tenet are called out as *background* (every option meets them, so they don't drive selection). The criteria that actually decide it: vendor independence *(major)*, recurring cost *(major)*, update latency *(moderate)*, operational burden *(moderate)*, read load *(minor)*.
- **Options in the Domain** — polling, self-hosted WebSockets, and hosted realtime each in their own right, each given its honest best case, with a verdict + basis per criterion.
- **Selection** — self-hosted wins on the two major criteria while matching the hosted service on latency and read load; it's deliberately weak on operational burden, and that's named as the accepted price. It also spells out what the choice commits downstream to each of the three nodes.

**One judgment I want to put in front of you rather than settle myself.** The selection turns on "vendor independence" being weighted *major*, but no tenet backs that — your infrastructure tenet is explicitly neutral ("self-hosted and managed infrastructure are both permitted"). So this is a one-off weighing for delivery, not a project-wide lean, and I wrote it up that way. If you'd actually want a preference for owning infrastructure over vendor coupling to govern *future* choices the arrow hasn't reached yet, that'd be a new tenet — but I didn't want to manufacture one from a single decision. Leave it as a local weighing, or add a tenet?

Once you've read the doc and answered that, we can move to the three nodes (Phase 2 LLDs), one segment at a time.