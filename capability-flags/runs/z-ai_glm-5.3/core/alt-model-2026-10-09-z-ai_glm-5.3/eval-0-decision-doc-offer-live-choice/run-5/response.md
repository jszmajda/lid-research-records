HLD updated for self-hosted WebSockets. Phase 1 changes, now stopped for your review:

1. **Approach** now states the chosen delivery: committed edits publish to a board-operated WebSocket layer that pushes to connected browsers; disconnected browsers recover by replaying revisions. The "still open" framing and the three-way comparison are gone — the comparison lives in Key Design Decisions, where it belongs.
2. **Architecture** notes for the three unwritten nodes now carry their WebSocket-shaped obligations: change store (replayable revisions, reliable publication path), delivery (WebSocket sessions, connection capacity), browser sync (socket subscription, reconnect/catch-up).
3. **Key Design Decisions** gains the entry: self-hosted WebSockets, with polling rejected (repeated reads, lag) and hosted realtime rejected (fees, provider coupling), and the accepted consequences named.
4. **Tenet trimmed**: I removed "Self-hosted and managed infrastructure are both permitted" — the delivery choice settles it, so keeping the lean would be residue. The customer-records half stays. Restore it if you intended it to lean on future choices beyond delivery.

Two things for you:

- **Cascade into the access segment (paused at the boundary):** `access-design.md:10` still says authorization is "independent of the still-open change-delivery approach." The substance is fine — commands stay on HTTPS — but "still-open" is now stale. May I make that one-line fix there?
- **Decision doc offer:** this choice clears the bar — three credible options traded across latency, cost, ops burden, and vendor coupling, with three segments about to be sized around it. I've recorded it as a Key Design Decisions entry; want a full decision doc in `docs/decisions/` as well, or is the entry enough?

On your approval (and answers), I'll start Phase 2 on the three nodes — tell me whether to take them one at a time (change store first, since delivery and browser sync lean on it) or another order.