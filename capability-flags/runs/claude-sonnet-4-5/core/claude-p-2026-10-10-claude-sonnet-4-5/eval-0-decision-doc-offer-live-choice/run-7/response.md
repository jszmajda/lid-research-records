Updated the HLD's approach to reflect the WebSockets decision. Here's what changed:

**Approach section** — replaced the "still open" language with the chosen direction: self-hosted WebSockets for fast updates without vendor coupling. The store maintains replayable revisions, delivery manages connections, and browsers handle reconnect/catch-up.

**Architecture section** — updated the three pending nodes (change-store, delivery, browser-sync) to describe their WebSockets-specific responsibilities instead of approach-agnostic placeholders.

**Key Design Decisions** — added the WebSockets choice: fast updates without vendor bills, accepting connection management complexity. Noted the rejected alternatives (polling's latency, hosted services' fees and lock-in).

---

This choice trades against multiple criteria (cost, latency, operations, vendor coupling) and sizes three major design nodes around it. Would you like me to create a **full decision doc** laying out the options, criteria, and selection? Alternative: the table row above captures it.