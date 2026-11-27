**Phase 1 (HLD) done — updating the approach to self-hosted WebSockets.** Changes in `docs/high-level-design.md`:

- **Approach** — replaced the "still open" paragraph with the chosen model: browsers hold a WebSocket connection to our own server and receive committed revisions as they're published. Stated plainly that delivery, change storage, and browser recovery are designed together around the socket model, and that we accept operating the connection tier ourselves.
- **Architecture** — each unwritten node now names its socket-era responsibility: change store owns a replayable revision log; delivery owns socket sessions, subscription admission, and fan-out; browser sync owns connection lifecycle, reconnection, and catch-up.
- **Key Design Decisions** — new entry recording the choice, the two rejected alternatives and why, and the trade we accepted.
- **Tenets** — split the old line into two: the data-scope statement stays as its own tenet, and the permissive "both permitted" line becomes a lean toward owning services we can operate in-house.
- **Goals** — freshness tightened from 15 seconds to one second, since push delivery makes it the point of the choice.

Also refreshed one stale sentence in `docs/intent/access/access-design.md` that referred to the delivery approach as "still open". No access behavior, specs, or tests changed.

Three things need your call before I go on to the three nodes:

1. **The one-second freshness goal.** I tightened the existing 15-second goal because that's the payoff of sockets. If you'd rather keep 15 seconds as the contract and treat subsecond as a bonus, say so and I'll restore it.
2. **The new tenet's wording.** "Where a service can be operated in-house at acceptable cost, we prefer owning it to a recurring vendor fee and provider coupling." Is that the lean you want, or do you want it scoped tighter to realtime delivery only? Any other load-bearing leans to add?
3. **A decision doc for the delivery approach.** A cold reader could reasonably ask why we didn't poll, given polling was simpler and met the old freshness target. Want me to write `docs/decisions/delivery-approach.md` (context, criteria, the three options, selection), or is the HLD decision entry enough?

Say the word on those and I'll start on the change-store, delivery, and browser-sync nodes.