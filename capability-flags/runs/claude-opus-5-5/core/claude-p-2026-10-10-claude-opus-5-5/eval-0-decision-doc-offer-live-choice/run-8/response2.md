I wrote the decision up as `docs/decisions/change-delivery.md` and linked it from the Key Design Decisions entry in the high-level design. Nothing is committed.

The doc lays out the load and goals, five criteria with weights, each of the three options scored against them, and the selection with what it obligates in the three nodes.

## Please check these — they're my reading, not something you said

1. **The weights.** I marked update latency and provider independence as major, operational burden and failure visibility as moderate, and read load as minor. The selection rests on this: sockets are the only option strong on both majors. The earlier design said subsecond updates were "useful, but not required", so calling latency major is a step up — say so if that overstates it.

2. **A criterion we hadn't discussed: failure visibility.** It comes from the tenet that connectivity failures must be visible, and it cuts against sockets. A socket can stall without closing, so a quiet board and a dead connection look the same unless we build a liveness check. Polling gets this for free. I rated sockets "partial" and recorded stall detection as an obligation on browser sync. Is that the right place for it, and are you happy taking it on?

3. **When to revisit.** The doc says to revisit if running the connections costs more than a provider's fees and coupling would, or if update latency stops mattering to coordinators. Reword or drop if those aren't your triggers.

I also put a figure in the polling analysis: 800 browsers polling every five seconds is 160 requests per second. That's arithmetic from the design's numbers, not a measurement.

## Still open from before

- **Vendor independence as a tenet.** The doc currently says this is a choice for change delivery, not a rule against vendors, and the tenets are unchanged. If you want it as a general lean, I'll add the tenet and adjust that sentence.
- **The stale line in the access design.** `docs/intent/access/access-design.md` still calls the delivery approach "still-open". OK to reword that one sentence? No access spec changes.

Once you've approved the approach and the doc, I'll start on the three nodes.