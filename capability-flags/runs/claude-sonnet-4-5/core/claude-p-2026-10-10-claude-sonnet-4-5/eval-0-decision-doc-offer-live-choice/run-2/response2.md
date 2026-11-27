Created the decision doc at `docs/decisions/change-delivery-mechanism.md` and linked it from the HLD. The doc preserves:

- **Why the choice matters**: Delivery mechanism shapes store indexing, session management, and browser recovery
- **The three options**: Polling (simple, stateless, but 2-5s lag), self-hosted WebSockets (fast, independent, but complex ops), hosted service (fast, simple ops, but vendor coupling + fees)
- **The criteria**: Update latency and vendor coupling rated major; operational complexity and cost moderate; implementation complexity minor
- **The selection**: WebSockets wins on fast updates without vendor lock-in, accepting operational complexity as the trade
- **What it obligates**: Change-store gets publication, delivery gets session management, browser-sync gets reconnect/catch-up

A cold reader can now reconstruct why we took on the connection management burden instead of polling (too slow for opening-time activity) or a hosted service (vendor coupling on a core path).

Ready to proceed to the three LLDs (change-store, delivery, browser-sync)?