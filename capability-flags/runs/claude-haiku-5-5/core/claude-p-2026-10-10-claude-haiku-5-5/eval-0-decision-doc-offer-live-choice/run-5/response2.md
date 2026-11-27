I wrote the decision doc at `docs/decisions/committed-change-delivery.md` and linked it from the HLD's Key Design Decisions row. Nothing is committed.

The doc is written for a reader who wasn't in the discussion. It covers:
- **Context:** why the delivery route matters, the load, and the 15-second freshness requirement.
- **Decision elements:** three gates inherited from the HLD (one authoritative revision, freshness, visible disconnects), and weighted criteria. Vendor coupling, recurring cost, and connection operations burden are major. Availability ownership is also major, and I added it because it wasn't in the earlier discussion.
- **Three options:** polling, self-hosted WebSockets, and a hosted realtime service. Each gets a description and a fit verdict against each element.
- **Selection:** self-hosted WebSockets, the tradeoff stated plainly. Operations burden is weak for this option, and the doc says that cost was accepted on purpose rather than overlooked. It also lists what the choice commits us to: connection capacity sizing, seven days of replayable revisions, reliable publication, browser disconnect and catch-up behavior, and an availability answer for the 99.5% goal.

Before the three nodes, check two things in the doc:
- **Availability:** the doc says the 99.5% goal isn't met by this design without redundancy and monitoring of the connection service. That's a requirement the delivery node has to answer.
- **Criteria I added:** "availability ownership" as a major criterion, and the hosted option's dependence on provider client behavior for visible disconnects. Both are my additions, not things we discussed. Tell me if either should come out.

Once you've reviewed the doc, I'll move on to the change store, delivery, and browser-sync nodes when you say so.