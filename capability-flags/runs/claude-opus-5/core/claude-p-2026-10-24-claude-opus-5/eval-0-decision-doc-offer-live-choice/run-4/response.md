Phase 1 (HLD) is updated for the self-hosted WebSockets choice. `docs/high-level-design.md` changed in three places:

**Approach** — no longer presents an open choice. It now states that committed changes reach browsers over self-hosted WebSocket connections with no realtime vendor in the path, and names what that settles for each downstream node: the change store keeps revisions replayable from a named revision and publishes reliably to delivery; delivery owns socket sessions, per-event fan-out, and capacity limits; browsers subscribe, detect drops, reconnect, and catch up from their last known revision. It records plainly that owning connection capacity and reconnect behavior is the accepted cost.

**Architecture** — the three unwritten node bullets no longer say "depends on the approach"; each now names its actual duties (revision history + replay + publication; socket sessions + fan-out + capacity; subscription + disconnect detection + reconnect + catch-up).

**Key Design Decisions** — new entry, *Self-hosted WebSockets for change delivery*, naming both rejected alternatives with why: five-second polling (cheapest, stateless, but several seconds of lag and repeated reads at 800 browsers) and a hosted realtime service (less connection ops, but recurring fees and provider coupling). It states the accepted cost: we own capacity for 800 browsers and own reconnect/catch-up correctness.

Goals, Non-Goals, and Problem were already consistent with this route and are unchanged.

Three things need your call before I move to Phase 2:

1. **Decision doc?** This choice clears the bar for one: three credible options traded against more than one criterion (latency, operating cost, ops burden, vendor coupling), and three design nodes are about to be sized around the result — a cold reader could reasonably be tempted to reverse it. I can write `docs/decisions/change-delivery-route.md` laying out the criteria and all three options at re-runnable resolution, linked from the Key Design Decisions entry. The alternative is to leave it as the entry I just wrote, which already names the alternatives and the accepted cost. Your call — I don't think it's clearly needed, so I'd only write it if you want the reasoning preserved at that depth for the pilot-to-production conversation.

2. **Tenet 4.** It currently reads "Self-hosted and managed infrastructure are both permitted." That's still true as a permission, but your reasoning here leaned a specific way — fast updates without tying the board to a vendor. Do you want it sharpened to a lean, e.g. *"When both meet the freshness and availability goals, prefer infrastructure we operate over a recurring vendor dependency"*, or left permissive so a future node (metrics, push notifications) can pick a managed service without arguing against a tenet?

3. **One stale cross-segment line.** `docs/intent/access/access-design.md` refers to "the still-open change-delivery approach" and says subscription credentials "will belong to the delivery node." Both are now settled. That's the access segment, not the one I'm changing, so I'm not editing it without asking — want me to update those two lines now, or leave access alone until we have the delivery node written and its credential contract is real?

Once you've ruled on these, I'll start Phase 2 with the three nodes. Which order do you want them in? I'd suggest change store first, since both delivery and browser sync depend on how revisions replay and publish.