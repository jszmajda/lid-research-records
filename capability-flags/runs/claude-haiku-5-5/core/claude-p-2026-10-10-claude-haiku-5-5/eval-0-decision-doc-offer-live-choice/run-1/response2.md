I wrote the decision doc at `docs/decisions/change-delivery-approach.md` and linked it from the HLD's Key Design Decisions entry. It's a local file, not a Claude Docs page, since you didn't ask for a doc there. Nothing is committed.

The doc follows the decision-doc template and is written for a new reader. It covers:

- **Context:** why the delivery route has to be chosen before the three nodes can be designed.
- **Criteria:** six, with importance levels. Five are the ones that separate the options. The sixth is authorization on open subscriptions, which I added because it cuts against the socket options and tenet 3 requires it.
- **Options:** polling, self-hosted WebSockets, and a hosted realtime service, each with a verdict per criterion.
- **Selection:** why sockets won, the case where polling would have been the right choice (if operational simplicity outranks latency), what the choice forecloses, and what it obligates the change store, delivery, and browser sync to do.

Three things I wrote that you should check:

- **Connection capacity is not sized.** The doc says 800 browsers and 20 edits per second in bursts still need sizing, and assigns that to the delivery node.
- **Authorization on open sockets is a new obligation.** When an assignment is revoked, delivery must end or re-check open sessions. Access's revocation guarantee applies only to the next command.
- **Priority order.** I treated vendor independence and latency as weighing more than operational simplicity. That is the reading of your stated trade, but it's the part of the doc most worth confirming.

Next is the three nodes. Say when you want me to start on the change store.