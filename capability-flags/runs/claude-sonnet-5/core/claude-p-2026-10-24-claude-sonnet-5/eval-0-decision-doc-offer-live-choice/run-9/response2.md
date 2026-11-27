Done — I've written a full decision doc at `docs/decisions/realtime-delivery-approach.md` and linked it from the HLD's Key Design Decisions row.

It lays out, for a cold reader:
- **Context**: why this one choice sizes three downstream nodes (change store, delivery, browser sync) at once.
- **Decision Elements**: no option is gated out (all three hit the 15s freshness goal); the real weighing is on update latency/headroom, operational burden, cost/vendor coupling, connectivity-failure visibility (tied to the HLD tenet), and downstream implementation load.
- **Options in the Domain**: polling, self-hosted WebSockets, and hosted realtime, each with an honest per-criterion verdict (strong/partial/weak) and a one-line summary of its essential trade.
- **Selection**: why self-hosted WebSockets won — the two push-based options tie on latency, hosted wins on ops burden, but self-hosted wins on cost/vendor independence, and that's the trade-off the market chose to accept. It also spells out what this forecloses (a vendor-brokered path) and what it obligates downstream (replayable revisions + reliable publication in the change store, session lifecycle in delivery, reconnect/catch-up in browser sync).

Ready to move on to the three downstream nodes — change store, delivery, and browser sync — whenever you want to start. Given the decision doc, that'll mean Phase 2 LLD drafts for each, in whatever order you'd like to tackle them.