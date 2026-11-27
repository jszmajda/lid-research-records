**Phase 1 — HLD updated for the self-hosted WebSockets choice** (`docs/high-level-design.md`):

- **Approach**: now states committed changes reach browsers over self-hosted WebSockets — the store keeps replayable revisions and publishes reliably, delivery owns socket sessions, browsers reconnect and catch up. The "still open" / option-mapping prose is gone.
- **Architecture**: the change-store, delivery, and browser-sync bullets no longer say "depending on the approach"; each now names its WebSockets-era ownership.
- **Key Design Decisions**: added **Self-hosted WebSockets for change delivery**, naming both rejected options (five-second polling, hosted realtime) and the accepted cost (owning connection capacity and reconnect handling).

Tenets, Goals, and Non-Goals needed no change — none of them depended on which delivery option won.

Two things before I proceed to the three nodes:

1. **Decision doc offer.** This choice was three credible options traded on multiple criteria, and the change-store, delivery, and browser-sync nodes will all be sized around it — a cold reader could reasonably re-litigate it. Want me to record it as a full decision doc at `docs/decisions/self-hosted-websockets-delivery.md` (the Key Design Decisions row already stands as the alternative)? 

2. **Stale phrasing in the access segment** (cross-segment cascade, so asking rather than editing): `access-design.md` still says authorization "is independent of the still-open change-delivery approach," which is no longer true. Shall I cascade a small wording fix into that node?

Approve the HLD as shown (with any numbered feedback), and answer those two, and I'll move on to Phase 2 for the three nodes.