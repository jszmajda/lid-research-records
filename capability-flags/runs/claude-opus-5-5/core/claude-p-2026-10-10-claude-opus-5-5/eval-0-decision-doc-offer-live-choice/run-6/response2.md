The decision doc is written at `docs/decisions/change-delivery.md`, and the HLD's Key Design Decisions entry now points to it. Nothing is committed.

It lays out why the choice exists, the five criteria it turns on, each of the three options described as its advocate would, and why self-hosted WebSockets wins. It says plainly that this option is the weakest of the three on operational burden and build effort, and that this is the cost you chose to accept. It closes with what the three nodes are now obligated to do and when the judgment should be re-run.

Three things in it are my reading rather than something you said, so please check them:

- **Criteria weights.** I rated vendor independence and update speed as major, operational burden and build effort as moderate, and recurring cost as minor. You named vendor coupling and fast updates as your reasons; the "minor" on cost is my inference from you not mentioning the fees.
- **Re-run triggers.** I wrote that the choice should be revisited if the team can no longer staff connection operations, if reconnects cause recurring incidents during event hours, or if fast updates turn out not to matter to coordinators.
- **Restart behaviour.** The doc states that a server restart or deploy drops all its connections at once and causes a burst of reconnects. That is a cost of this option we did not discuss, and the delivery node will have to address it.

Three questions from before are still open, and the first two affect the doc:

1. **Does the freshness goal tighten?** The doc treats 15 seconds as the only commitment and fast updates as value beyond it. If you want a tighter number, both the Goals section and the doc change, and delivery gets sized to it.
2. **Is vendor independence a standing lean or a one-off?** The doc currently says no tenet decides this and the hosted option lost only for this path. If it should tip future choices too, I'd reword the fourth tenet and the doc would cite it.
3. **May I fix the two stale lines in the Access design?** They still call the delivery approach "still-open" and mention "delivery-specific subscription credentials".

Once you approve the HLD and the doc, or send changes, I'll start on the change-store node.