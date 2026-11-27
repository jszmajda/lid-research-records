## Phase 1 Complete — Decision Doc Written

I've created a comprehensive decision doc (`docs/decisions/delivery-approach.md`) that lays out the full reasoning:

**Decision Elements** establish the gates (meets HLD goals, one authoritative revision, connectivity visibility) and the weighted criteria: latency (major), operational overhead (major), time-to-market (moderate), vendor coupling (moderate), and cost (moderate).

**Options in the Domain** analyzes all three approaches:
- **Five-second polling** — simplest, but can't deliver subsecond and users perceive lag as broken
- **Self-hosted WebSockets** — subsecond delivery and independence, but the team owns connection infrastructure
- **Hosted realtime service** — fastest to market and operationally effortless, but vendor lock-in and recurring costs

**Selection** explains the judgment: latency and independence are the deciding criteria. Polling is eliminated because it can't deliver subsecond updates. Between hosted and self-hosted WebSockets, the team is accepting operational overhead (connection management, session tracking, reconnect resilience) to retain independence and avoid vendor coupling. This is a one-time investment in infrastructure for a system that runs for years.

**Implications** name what the choice forecloses (no hosted services) and obligates downstream (full revision history in change store, connection state and session tracking in delivery, reconnect logic in browser sync).

The HLD now links to this doc, so a reader months from now can understand the tradeoff and re-run the judgment if circumstances change. No conversation context needed.

**Ready to proceed to Phase 2 — drafting the three leaf LLDs for change-store, delivery, and browser-sync?**