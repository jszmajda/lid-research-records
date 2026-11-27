Phase 1 (HLD update) is done — stopping here for your review before anything else.

## What I changed in `docs/high-level-design.md`

**Approach** — rewritten to commit to self-hosted WebSockets as the delivery transport (fresh-author prose, no narration of the options we weighed): the server assigns each committed edit one revision and publishes it over WebSocket connections the project operates itself; store keeps replayable revisions + a commit→publication path; delivery owns socket sessions and fan-out; browser sync owns subscription, reconnect, and catch-up from a last-seen revision; the project owns its connection capacity and reconnection handling.

**Architecture** — resolved the three "depends on the approach" one-liners to what each node now owns (store: publication outbox feeding socket delivery; delivery: socket session management + fan-out; browser sync: reconnect/catch-up from last-seen revision). Still marked "Not written yet."

**Key Design Decisions** — added an entry recording the choice: self-hosted WebSockets, with polling rejected (repeated reads, lag) and hosted realtime rejected (recurring fees, provider coupling), naming the accepted cost (owning connection/reconnect ops) and how it sizes the three downstream nodes.

I left the **Tenets** untouched — "self-hosted and managed infrastructure are both permitted" still holds (we exercised that freedom, didn't contradict it), and the data-classification clause stays load-bearing for the nodes ahead.

## Two things for you to decide

1. **Promote this to a full decision doc?** This choice clears the bar for one — three credible options traded against multiple criteria (latency, operating cost, ops/connection burden, vendor coupling), and three design nodes about to be sized around it. The Key Design Decisions entry above is the lighter alternative and is already in place. Want me to expand it into `docs/decisions/change-delivery-transport.md` (laying out the options, criteria, and selection so a cold reader can re-run the judgment) and link it from the KDD entry? Or is the KDD entry enough?

2. **One cross-segment cascade to approve.** `docs/intent/access/access-design.md:10` says authorization is "independent of the still-open change-delivery approach" — the "still-open" is now stale. That's the access segment, so I didn't touch it. May I update that line to "independent of the change-delivery transport" (the point it makes is still true; only the wording is stale)?

Once you've reviewed, we can move on to the three nodes (change-store, delivery, browser-sync) in Phase 2.