I've written the decision doc at `docs/decisions/realtime-delivery-approach.md` and linked it from the HLD's Decisions row. It lays out:

- **Context**: why this choice has to be made once, up front, before the change-store/delivery/browser-sync nodes are designed.
- **Decision Elements**: five criteria (update latency, recurring cost, vendor coupling — all major; connection operations burden — moderate; store/delivery complexity — minor), with a note on why the freshness goal and the self-host/managed tenet are background rather than deciding factors.
- **Options in the Domain**: polling, self-hosted WebSockets, and the hosted service, each described and scored against every element.
- **Selection**: self-hosted WebSockets wins on the two major criteria it shares with the hosted service (cost, vendor coupling) plus latency, loses only on the moderate connection-ops criterion — and what it forecloses and obligates downstream for the change store, delivery, and browser-sync nodes.

That's Phase 1 (HLD-level) complete and at its stop. Take a look at both the HLD edits and the new decision doc — once you're happy with them, say so and we'll move on to the three nodes: change store, delivery, and browser sync.